import 'dart:async';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:cam_star/models/server_device.dart';

/// Service for discovering CamStar server devices on the local network using mDNS
class ServerDiscoveryService {
  /// Creates a server discovery service
  ServerDiscoveryService() {
    _serversController = StreamController<List<ServerDevice>>.broadcast();
  }

  /// The mDNS service type for CamStar servers
  static const String serviceType = '_camstar._tcp';

  /// Default port for CamStar servers
  static const int defaultPort = 8080;

  /// Timeout duration for server expiry (if not seen in this time, remove)
  static const Duration serverTimeout = Duration(seconds: 30);

  MDnsClient? _mdnsClient;
  late StreamController<List<ServerDevice>> _serversController;
  final Map<String, ServerDevice> _discoveredServers = {};
  final Map<String, DateTime> _lastSeenTimes = {};
  Timer? _cleanupTimer;
  bool _isDiscovering = false;

  /// Stream of discovered servers (emits updated list when servers appear/disappear)
  Stream<List<ServerDevice>> get serversStream => _serversController.stream;

  /// Current list of discovered servers
  List<ServerDevice> get servers => _discoveredServers.values.toList();

  /// Whether discovery is currently active
  bool get isDiscovering => _isDiscovering;

  /// Starts mDNS discovery for CamStar servers
  Future<void> startDiscovery() async {
    if (_isDiscovering) {
      return;
    }

    try {
      _isDiscovering = true;
      _discoveredServers.clear();
      _lastSeenTimes.clear();

      // Create mDNS client
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      // Start periodic cleanup of expired servers
      _cleanupTimer?.cancel();
      _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _removeExpiredServers();
      });

      // Query for CamStar services
      await _queryForServers();

      // Emit initial empty list
      _emitServersList();
    } catch (e) {
      _isDiscovering = false;
      rethrow;
    }
  }

  /// Stops mDNS discovery
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) {
      return;
    }

    _isDiscovering = false;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    _mdnsClient?.stop();
    _mdnsClient = null;

    _discoveredServers.clear();
    _lastSeenTimes.clear();
    _emitServersList();
  }

  /// Refreshes the server discovery (restarts the scan)
  Future<void> refresh() async {
    await stopDiscovery();
    await startDiscovery();
  }

  /// Queries for CamStar services on the network
  Future<void> _queryForServers() async {
    if (_mdnsClient == null) return;

    try {
      // Query for PTR records (service discovery)
      await for (final PtrResourceRecord ptr in _mdnsClient!
          .lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(serviceType),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: (sink) => sink.close(),
      )) {
        await _handleServiceDiscovered(ptr);
      }

      // Keep querying periodically
      if (_isDiscovering) {
        Timer(const Duration(seconds: 10), () {
          if (_isDiscovering) {
            _queryForServers();
          }
        });
      }
    } catch (e) {
      // Silently handle timeout or other errors and continue
    }
  }

  /// Handles a discovered service PTR record
  Future<void> _handleServiceDiscovered(PtrResourceRecord ptr) async {
    if (_mdnsClient == null) return;

    try {
      // Get SRV records (host and port info)
      await for (final SrvResourceRecord srv in _mdnsClient!
          .lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )
          .timeout(
        const Duration(seconds: 2),
        onTimeout: (sink) => sink.close(),
      )) {
        await _handleSrvRecord(srv, ptr.domainName);
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Handles an SRV record to extract server details
  Future<void> _handleSrvRecord(
    SrvResourceRecord srv,
    String domainName,
  ) async {
    if (_mdnsClient == null) return;

    try {
      // Get A records (IPv4 addresses)
      await for (final IPAddressResourceRecord aRecord in _mdnsClient!
          .lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(srv.target),
      )
          .timeout(
        const Duration(seconds: 2),
        onTimeout: (sink) => sink.close(),
      )) {
        _addServer(
          address: aRecord.address,
          port: srv.port,
          name: _extractServiceName(domainName),
        );
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Extracts a human-readable service name from the domain name
  String _extractServiceName(String domainName) {
    // Domain name format: "DeviceName._camstar._tcp.local"
    final parts = domainName.split('.');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return 'Unknown Device';
  }

  /// Adds or updates a discovered server
  void _addServer({
    required InternetAddress address,
    required int port,
    required String name,
  }) {
    final id = '${address.address}:$port';
    final now = DateTime.now();

    // Update last seen time
    _lastSeenTimes[id] = now;

    // Add server if new
    if (!_discoveredServers.containsKey(id)) {
      final server = ServerDevice(
        id: id,
        name: name,
        ipAddress: address.address,
        port: port,
        discoveredAt: now,
      );

      _discoveredServers[id] = server;
      _emitServersList();
    }
  }

  /// Removes servers that haven't been seen within the timeout period
  void _removeExpiredServers() {
    final now = DateTime.now();
    final expiredIds = <String>[];

    for (final entry in _lastSeenTimes.entries) {
      if (now.difference(entry.value) > serverTimeout) {
        expiredIds.add(entry.key);
      }
    }

    if (expiredIds.isNotEmpty) {
      for (final id in expiredIds) {
        _discoveredServers.remove(id);
        _lastSeenTimes.remove(id);
      }
      _emitServersList();
    }
  }

  /// Emits the current list of servers to the stream
  void _emitServersList() {
    if (!_serversController.isClosed) {
      _serversController.add(servers);
    }
  }

  /// Disposes the service and cleans up resources
  Future<void> dispose() async {
    await stopDiscovery();
    await _serversController.close();
  }
}
