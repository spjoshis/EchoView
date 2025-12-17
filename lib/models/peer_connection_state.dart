/// Represents the state of a WebRTC peer connection
enum PeerConnectionState {
  /// No connection established
  disconnected,

  /// Attempting to establish connection
  connecting,

  /// Connection successfully established
  connected,

  /// Connection attempt failed
  failed,

  /// Connection was closed
  closed;

  /// Check if the connection is currently connected
  bool get isConnected => this == PeerConnectionState.connected;

  /// Check if the connection is active (connecting or connected)
  bool get isActive => this == connecting || this == connected;

  /// Check if the connection has failed or is closed
  bool get isTerminated => this == failed || this == closed;

  /// Get user-friendly display name for the state
  String get displayName {
    switch (this) {
      case PeerConnectionState.disconnected:
        return 'Disconnected';
      case PeerConnectionState.connecting:
        return 'Connecting...';
      case PeerConnectionState.connected:
        return 'Connected';
      case PeerConnectionState.failed:
        return 'Connection Failed';
      case PeerConnectionState.closed:
        return 'Closed';
    }
  }

  /// Get description for the state
  String get description {
    switch (this) {
      case PeerConnectionState.disconnected:
        return 'No connection to server';
      case PeerConnectionState.connecting:
        return 'Establishing connection to server';
      case PeerConnectionState.connected:
        return 'Successfully connected to server';
      case PeerConnectionState.failed:
        return 'Failed to connect to server';
      case PeerConnectionState.closed:
        return 'Connection has been closed';
    }
  }
}
