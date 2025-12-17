import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/peer_connection_state.dart';
import '../models/server_device.dart';
import '../services/webrtc_client_service.dart';

/// Provider for managing stream viewer state on the client
class StreamViewerProvider extends ChangeNotifier {
  final WebRTCClientService _webrtcService;

  PeerConnectionState _connectionState = PeerConnectionState.disconnected;
  ServerDevice? _connectedServer;
  MediaStream? _remoteStream;
  String? _errorMessage;

  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _remoteStreamSubscription;

  StreamViewerProvider(this._webrtcService);

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      await _webrtcService.initialize();

      // Listen to connection state changes
      _connectionStateSubscription =
          _webrtcService.connectionStateStream.listen((state) {
        _connectionState = state;
        print('Connection state changed: ${state.displayName}');

        // Set error message if connection failed
        if (state == PeerConnectionState.failed) {
          _setError('Failed to connect to server');
        } else if (state == PeerConnectionState.disconnected && _connectedServer != null) {
          _setError('Disconnected from server');
        }

        notifyListeners();
      });

      // Listen to remote stream changes
      _remoteStreamSubscription =
          _webrtcService.remoteStreamStream.listen((stream) {
        _remoteStream = stream;
        if (stream != null) {
          print('Received remote stream with ${stream.getTracks().length} tracks');
          _clearError();
        }
        notifyListeners();
      });

      print('Stream viewer provider initialized');
    } catch (e) {
      print('Error initializing stream viewer provider: $e');
      _setError('Failed to initialize: $e');
    }
  }

  /// Connect to a server
  Future<void> connectToServer(ServerDevice server) async {
    if (_connectionState.isActive) {
      throw Exception('Already connected or connecting. Disconnect first.');
    }

    _clearError();
    _connectedServer = server;
    notifyListeners();

    try {
      print('Connecting to server: ${server.name} at ${server.address}');

      await _webrtcService.connect(
        serverIp: server.ipAddress,
        serverPort: server.port,
      );

      print('Connection initiated to ${server.name}');
    } catch (e) {
      print('Error connecting to server: $e');
      _setError('Failed to connect: $e');
      _connectedServer = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Disconnect from the server
  Future<void> disconnect() async {
    if (_connectionState == PeerConnectionState.disconnected) {
      return;
    }

    print('Disconnecting from server');

    try {
      await _webrtcService.disconnect();

      _connectedServer = null;
      _remoteStream = null;
      _clearError();

      print('Disconnected successfully');
      notifyListeners();
    } catch (e) {
      print('Error disconnecting: $e');
      _setError('Failed to disconnect: $e');
    }
  }

  /// Get connection state
  PeerConnectionState get connectionState => _connectionState;

  /// Get connected server
  ServerDevice? get connectedServer => _connectedServer;

  /// Get video renderer
  RTCVideoRenderer get videoRenderer => _webrtcService.videoRenderer;

  /// Get remote stream
  MediaStream? get remoteStream => _remoteStream;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if has error
  bool get hasError => _errorMessage != null;

  /// Check if connected
  bool get isConnected => _connectionState.isConnected;

  /// Check if connecting
  bool get isConnecting => _connectionState == PeerConnectionState.connecting;

  /// Check if has video stream
  bool get hasVideoStream => _remoteStream != null && _remoteStream!.getTracks().isNotEmpty;

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  @override
  Future<void> dispose() async {
    print('Disposing stream viewer provider');

    await _connectionStateSubscription?.cancel();
    await _remoteStreamSubscription?.cancel();

    await _webrtcService.dispose();

    super.dispose();
  }
}
