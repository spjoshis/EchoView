import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service for registering the server on the local network via mDNS
class ServerRegistrationService {
  static const String _serviceType = '_camstar._tcp';

  MDnsClient? _mdnsClient;
  String? _serviceName;
  int? _port;
  Map<String, String> _attributes = {};

  /// Register the service with mDNS
  Future<void> registerService({
    required String serverName,
    required int httpPort,
    Map<String, String>? attributes,
  }) async {
    // Unregister existing service if any
    await unregisterService();

    _serviceName = serverName;
    _port = httpPort;
    _attributes = attributes ?? {};

    try {
      // Get local IP address
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();

      if (wifiIP == null) {
        throw Exception('Unable to get WiFi IP address. Make sure you are connected to WiFi.');
      }

      // Add default attributes
      _attributes.putIfAbsent('version', () => '1.0');
      _attributes.putIfAbsent('viewers', () => '0');

      // Create mDNS client
      _mdnsClient = MDnsClient();
      _mdnsClient!.start();

      // Construct the service instance name
      final instanceName = '$_serviceName.$_serviceType.local';

      print('Registering mDNS service: $instanceName on $wifiIP:$httpPort');
      print('Service attributes: $_attributes');

      // Note: multicast_dns package doesn't support service registration
      // We would need to use platform-specific code or a different package
      // For now, we'll just keep the client running to respond to queries
      // This is a limitation we'll need to address with platform channels

      print('Warning: Full mDNS service registration requires platform-specific implementation');
      print('Server is discoverable at: $wifiIP:$httpPort');

    } catch (e) {
      _mdnsClient?.stop();
      _mdnsClient = null;
      throw Exception('Failed to register mDNS service: $e');
    }
  }

  /// Update service attributes (e.g., viewer count)
  void updateAttributes(Map<String, String> attributes) {
    _attributes.addAll(attributes);

    // In a full implementation, we would re-advertise the service
    // with updated TXT records
    // ignore: avoid_print
    print('Updated service attributes: $_attributes');
  }

  /// Unregister the service
  Future<void> unregisterService() async {
    if (_mdnsClient != null) {
      _mdnsClient!.stop();
      _mdnsClient = null;
    }

    _serviceName = null;
    _port = null;
    _attributes.clear();
  }

  /// Check if service is registered
  bool get isRegistered => _mdnsClient != null;

  /// Get current service name
  String? get serviceName => _serviceName;

  /// Get current port
  int? get port => _port;

  /// Get current attributes
  Map<String, String> get attributes => Map.unmodifiable(_attributes);

  /// Dispose resources
  Future<void> dispose() async {
    await unregisterService();
  }
}

/// Platform-specific server registration implementation note:
///
/// The multicast_dns package currently only supports service discovery,
/// not service registration/advertisement. To fully implement mDNS service
/// registration, we would need to:
///
/// 1. Use platform channels to call native mDNS APIs:
///    - iOS: Use Bonjour (NSNetService)
///    - Android: Use NSD (Network Service Discovery)
///
/// 2. Or use an HTTP-based discovery fallback where clients poll a
///    known endpoint for available servers
///
/// For the MVP, the server will register via the discovery service
/// that the client already uses, but in reverse - the server will
/// respond to mDNS queries instead of registering.
///
/// Alternative implementation approach:
/// - Use the existing ServerDiscoveryService infrastructure
/// - Have the server respond to multicast queries
/// - Clients use the existing discovery mechanism
