/// Represents a discovered server device on the local network
class ServerDevice {
  /// Creates a server device
  const ServerDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.discoveredAt,
    this.attributes = const {},
  });

  /// Unique identifier for the server (typically IP:port combination)
  final String id;

  /// Human-readable name of the server device
  final String name;

  /// IPv4/IPv6 address of the server
  final String ipAddress;

  /// Port number where the service is running
  final int port;

  /// Timestamp when the server was discovered
  final DateTime discoveredAt;

  /// Additional attributes from the mDNS service record
  final Map<String, String> attributes;

  /// Creates a server device from JSON
  factory ServerDevice.fromJson(Map<String, dynamic> json) {
    return ServerDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      discoveredAt: DateTime.parse(json['discoveredAt'] as String),
      attributes: Map<String, String>.from(json['attributes'] as Map? ?? {}),
    );
  }

  /// Converts server device to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'discoveredAt': discoveredAt.toIso8601String(),
      'attributes': attributes,
    };
  }

  /// Returns a formatted address string (IP:port)
  String get address => '$ipAddress:$port';

  /// Returns how long ago the server was discovered
  String get timeSinceDiscovery {
    final duration = DateTime.now().difference(discoveredAt);
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} seconds ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return '${duration.inHours} hours ago';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ServerDevice(id: $id, name: $name, address: $address)';

  /// Creates a copy with updated fields
  ServerDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    DateTime? discoveredAt,
    Map<String, String>? attributes,
  }) {
    return ServerDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      attributes: attributes ?? this.attributes,
    );
  }
}
