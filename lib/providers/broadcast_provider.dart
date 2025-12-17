import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/peer_connection_state.dart';
import '../services/server_registration_service.dart';
import '../services/signaling_server_service.dart';
import '../services/webrtc_server_service.dart';

/// Provider for managing broadcast state on the server
class BroadcastProvider extends ChangeNotifier {
  final ServerRegistrationService _registrationService;
  final SignalingServerService _signalingService;
  final WebRTCServerService _webrtcService;

  bool _isBroadcasting = false;
  int _serverPort = 0;
  Map<String, PeerConnectionState> _clientStates = {};
  String? _errorMessage;
  StreamSubscription? _clientStatesSubscription;

  BroadcastProvider(
    this._registrationService,
    this._signalingService,
    this._webrtcService,
  );

  /// Check if currently broadcasting
  bool get isBroadcasting => _isBroadcasting;

  /// Get the signaling server port
  int get serverPort => _serverPort;

  /// Get number of connected viewers
  int get viewerCount =>
      _clientStates.values.where((state) => state.isConnected).length;

  /// Get total number of clients (including connecting)
  int get totalClients => _clientStates.length;

  /// Get client connection states
  Map<String, PeerConnectionState> get clientStates =>
      Map.unmodifiable(_clientStates);

  /// Get error message if any
  String? get errorMessage => _errorMessage;

  /// Check if there's an error
  bool get hasError => _errorMessage != null;

  /// Start broadcasting
  Future<void> startBroadcast({
    required String serverName,
    required MediaStream cameraStream,
  }) async {
    if (_isBroadcasting) {
      throw Exception('Already broadcasting');
    }

    _clearError();

    try {
      print('Starting broadcast...');

      // 1. Initialize WebRTC service with camera stream
      print('Initializing WebRTC service...');
      await _webrtcService.initialize(cameraStream);

      // 2. Start HTTP signaling server
      print('Starting signaling server...');
      _serverPort = await _signalingService.start();
      print('Signaling server started on port: $_serverPort');

      // 3. Set up signaling server callbacks
      _setupSignalingCallbacks();

      // 4. Register mDNS service
      print('Registering mDNS service...');
      await _registrationService.registerService(
        serverName: serverName,
        httpPort: _serverPort,
        attributes: {
          'version': '1.0',
          'viewers': '0',
        },
      );

      // 5. Listen to client state changes
      _clientStatesSubscription = _webrtcService.clientStatesStream.listen(
        (states) {
          _clientStates = states;
          _updateViewerCount();
          notifyListeners();
        },
      );

      _isBroadcasting = true;
      print('Broadcast started successfully');
      notifyListeners();
    } catch (e) {
      print('Error starting broadcast: $e');
      _setError('Failed to start broadcast: $e');

      // Cleanup on error
      await stopBroadcast();
      rethrow;
    }
  }

  /// Stop broadcasting
  Future<void> stopBroadcast() async {
    if (!_isBroadcasting) {
      return;
    }

    print('Stopping broadcast...');

    try {
      // 1. Unregister mDNS service
      await _registrationService.unregisterService();

      // 2. Stop signaling server
      await _signalingService.stop();

      // 3. Dispose WebRTC service (closes all peer connections)
      await _webrtcService.dispose();

      // 4. Cancel client states subscription
      await _clientStatesSubscription?.cancel();
      _clientStatesSubscription = null;

      _isBroadcasting = false;
      _serverPort = 0;
      _clientStates.clear();
      _clearError();

      print('Broadcast stopped');
      notifyListeners();
    } catch (e) {
      print('Error stopping broadcast: $e');
      _setError('Failed to stop broadcast: $e');
    }
  }

  /// Set up signaling server callbacks
  void _setupSignalingCallbacks() {
    // Handle offer requests
    _signalingService.onOfferRequested((clientId) async {
      print('Offer requested by client: $clientId');
      try {
        final offer = await _webrtcService.createOffer(clientId);
        print('Offer created for client: $clientId');
        return offer;
      } catch (e) {
        print('Error creating offer for client $clientId: $e');
        rethrow;
      }
    });

    // Handle answer received
    _signalingService.onAnswerReceived((clientId, answer) async {
      print('Answer received from client: $clientId');
      try {
        await _webrtcService.setRemoteAnswer(clientId, answer);
        print('Remote answer set for client: $clientId');
      } catch (e) {
        print('Error setting remote answer for client $clientId: $e');
        rethrow;
      }
    });

    // Handle ICE candidates
    _signalingService.onIceCandidateReceived((clientId, candidate) async {
      print('ICE candidate received from client: $clientId');
      try {
        await _webrtcService.addIceCandidate(clientId, candidate);
      } catch (e) {
        print('Error adding ICE candidate for client $clientId: $e');
      }
    });
  }

  /// Update viewer count in mDNS service
  void _updateViewerCount() {
    if (_isBroadcasting) {
      _registrationService.updateAttributes({
        'viewers': viewerCount.toString(),
      });
    }
  }

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
    await stopBroadcast();
    super.dispose();
  }
}
