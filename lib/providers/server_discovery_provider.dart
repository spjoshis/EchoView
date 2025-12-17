import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cam_star/models/server_device.dart';
import 'package:cam_star/services/server_discovery_service.dart';

/// State of the server discovery process
enum DiscoveryState {
  /// Discovery is not active
  idle,

  /// Currently scanning for servers
  scanning,

  /// Discovery encountered an error
  error,
}

/// Provider for managing server discovery state
class ServerDiscoveryProvider extends ChangeNotifier {
  /// Creates a server discovery provider
  ServerDiscoveryProvider() {
    _discoveryService = ServerDiscoveryService();
  }

  late ServerDiscoveryService _discoveryService;
  List<ServerDevice> _servers = [];
  DiscoveryState _state = DiscoveryState.idle;
  String? _errorMessage;
  StreamSubscription<List<ServerDevice>>? _serversSubscription;

  /// List of discovered servers
  List<ServerDevice> get servers => _servers;

  /// Current discovery state
  DiscoveryState get state => _state;

  /// Error message if state is error
  String? get errorMessage => _errorMessage;

  /// Whether discovery is currently active
  bool get isScanning => _state == DiscoveryState.scanning;

  /// Whether there are no servers found
  bool get hasNoServers => _servers.isEmpty && _state == DiscoveryState.scanning;

  /// Starts server discovery
  Future<void> startDiscovery() async {
    if (_state == DiscoveryState.scanning) {
      return;
    }

    try {
      _state = DiscoveryState.scanning;
      _errorMessage = null;
      _servers = [];
      notifyListeners();

      // Subscribe to server updates
      _serversSubscription?.cancel();
      _serversSubscription = _discoveryService.serversStream.listen(
        (servers) {
          _servers = servers;
          notifyListeners();
        },
        onError: (error) {
          _state = DiscoveryState.error;
          _errorMessage = error.toString();
          notifyListeners();
        },
      );

      // Start the discovery service
      await _discoveryService.startDiscovery();
    } catch (e) {
      _state = DiscoveryState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Stops server discovery
  Future<void> stopDiscovery() async {
    await _serversSubscription?.cancel();
    _serversSubscription = null;

    await _discoveryService.stopDiscovery();

    _state = DiscoveryState.idle;
    _servers = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Refreshes the server list (restarts discovery)
  Future<void> refresh() async {
    try {
      _state = DiscoveryState.scanning;
      _errorMessage = null;
      _servers = [];
      notifyListeners();

      await _discoveryService.refresh();
    } catch (e) {
      _state = DiscoveryState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _serversSubscription?.cancel();
    _discoveryService.dispose();
    super.dispose();
  }
}
