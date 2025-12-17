/// Defines the operation mode of the application
enum AppMode {
  /// Server mode - broadcasts camera feed to clients
  server,

  /// Client mode - views camera stream from servers
  client,
}

/// Extension methods for AppMode enum
extension AppModeExtension on AppMode {
  /// Returns a human-readable display name for the mode
  String get displayName {
    switch (this) {
      case AppMode.server:
        return 'Server Mode';
      case AppMode.client:
        return 'Client Mode';
    }
  }

  /// Returns a description of what the mode does
  String get description {
    switch (this) {
      case AppMode.server:
        return 'Broadcast your camera feed to other devices on the local network';
      case AppMode.client:
        return 'View camera streams from other devices on the local network';
    }
  }
}
