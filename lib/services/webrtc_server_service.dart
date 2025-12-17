import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/peer_connection_state.dart';

/// WebRTC server service for broadcasting camera stream to multiple clients
class WebRTCServerService {
  static const int maxClients = 5;

  // Camera media stream to broadcast
  MediaStream? _cameraStream;

  // Map of client IDs to their peer connections
  final Map<String, RTCPeerConnection> _peerConnections = {};

  // Map of client IDs to their connection states
  final Map<String, PeerConnectionState> _connectionStates = {};

  // Map of client IDs to pending ICE candidates
  final Map<String, List<RTCIceCandidate>> _pendingIceCandidates = {};

  // Stream controller for connection state changes
  final _stateController = StreamController<Map<String, PeerConnectionState>>.broadcast();

  // WebRTC configuration (local network only - no STUN/TURN servers)
  final Map<String, dynamic> _configuration = {
    'iceServers': [], // Empty = local network only
    'iceTransportPolicy': 'all',
    'bundlePolicy': 'max-bundle',
    'rtcpMuxPolicy': 'require',
  };

  /// Initialize the service with the camera stream
  Future<void> initialize(MediaStream cameraStream) async {
    _cameraStream = cameraStream;
    print('WebRTC server service initialized with camera stream');
  }

  /// Create a WebRTC offer for a new client
  Future<RTCSessionDescription> createOffer(String clientId) async {
    if (_cameraStream == null) {
      throw Exception('Camera stream not initialized. Call initialize() first.');
    }

    if (_peerConnections.length >= maxClients) {
      throw Exception('Maximum number of clients ($maxClients) reached');
    }

    if (_peerConnections.containsKey(clientId)) {
      throw Exception('Client $clientId already has a peer connection');
    }

    try {
      print('Creating peer connection for client: $clientId');

      // Create peer connection
      final peerConnection = await createPeerConnection(_configuration);

      // Add camera stream tracks to peer connection
      _cameraStream!.getTracks().forEach((track) {
        print('Adding track to peer connection: ${track.kind}');
        peerConnection.addTrack(track, _cameraStream!);
      });

      // Set up event handlers
      _setupPeerConnectionHandlers(clientId, peerConnection);

      // Store peer connection
      _peerConnections[clientId] = peerConnection;
      _updateConnectionState(clientId, PeerConnectionState.connecting);

      // Create offer
      final offer = await peerConnection.createOffer({
        'offerToReceiveVideo': false,
        'offerToReceiveAudio': false,
      });

      // Set local description
      await peerConnection.setLocalDescription(offer);

      print('Offer created for client $clientId');
      return offer;
    } catch (e) {
      print('Error creating offer for client $clientId: $e');
      await removeClient(clientId);
      rethrow;
    }
  }

  /// Set remote answer from client
  Future<void> setRemoteAnswer(
    String clientId,
    RTCSessionDescription answer,
  ) async {
    final peerConnection = _peerConnections[clientId];
    if (peerConnection == null) {
      throw Exception('No peer connection found for client $clientId');
    }

    try {
      print('Setting remote answer for client $clientId');
      await peerConnection.setRemoteDescription(answer);

      // Add any pending ICE candidates
      final pendingCandidates = _pendingIceCandidates[clientId];
      if (pendingCandidates != null && pendingCandidates.isNotEmpty) {
        print('Adding ${pendingCandidates.length} pending ICE candidates for $clientId');
        for (final candidate in pendingCandidates) {
          await peerConnection.addCandidate(candidate);
        }
        _pendingIceCandidates[clientId]?.clear();
      }
    } catch (e) {
      print('Error setting remote answer for client $clientId: $e');
      rethrow;
    }
  }

  /// Add ICE candidate from client
  Future<void> addIceCandidate(
    String clientId,
    RTCIceCandidate candidate,
  ) async {
    final peerConnection = _peerConnections[clientId];

    if (peerConnection == null) {
      print('No peer connection for client $clientId, ignoring ICE candidate');
      return;
    }

    try {
      // Check if we have set remote description yet
      final remoteDesc = await peerConnection.getRemoteDescription();
      if (remoteDesc == null) {
        // Queue candidate for later
        _pendingIceCandidates.putIfAbsent(clientId, () => []).add(candidate);
        print('Queued ICE candidate for client $clientId (no remote description yet)');
      } else {
        // Add candidate immediately
        await peerConnection.addCandidate(candidate);
        print('Added ICE candidate for client $clientId');
      }
    } catch (e) {
      print('Error adding ICE candidate for client $clientId: $e');
    }
  }

  /// Remove a client and clean up its peer connection
  Future<void> removeClient(String clientId) async {
    print('Removing client: $clientId');

    final peerConnection = _peerConnections.remove(clientId);
    if (peerConnection != null) {
      await peerConnection.close();
      await peerConnection.dispose();
    }

    _connectionStates.remove(clientId);
    _pendingIceCandidates.remove(clientId);

    _notifyStateChange();
  }

  /// Set up event handlers for a peer connection
  void _setupPeerConnectionHandlers(
    String clientId,
    RTCPeerConnection peerConnection,
  ) {
    // Connection state changes
    peerConnection.onConnectionState = (state) {
      print('Client $clientId connection state: $state');

      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _updateConnectionState(clientId, PeerConnectionState.connected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _updateConnectionState(clientId, PeerConnectionState.failed);
          removeClient(clientId);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          _updateConnectionState(clientId, PeerConnectionState.disconnected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _updateConnectionState(clientId, PeerConnectionState.closed);
          removeClient(clientId);
          break;
        default:
          break;
      }
    };

    // ICE candidate events
    peerConnection.onIceCandidate = (candidate) {
      // Filter to only local network candidates (Story 5 requirement)
      if (_isLocalCandidate(candidate)) {
        print('Local ICE candidate for client $clientId: ${candidate.candidate}');
        // In a full implementation, we would send this to the client
        // via the signaling server
      } else {
        print('Filtered non-local ICE candidate for client $clientId');
      }
    };

    // ICE connection state
    peerConnection.onIceConnectionState = (state) {
      print('Client $clientId ICE connection state: $state');
    };

    // ICE gathering state
    peerConnection.onIceGatheringState = (state) {
      print('Client $clientId ICE gathering state: $state');
    };
  }

  /// Check if ICE candidate is local network only (Story 5 security requirement)
  bool _isLocalCandidate(RTCIceCandidate candidate) {
    final candidateStr = candidate.candidate;
    if (candidateStr == null) return false;

    // Accept host candidates (local network)
    if (candidateStr.contains('typ host')) {
      return true;
    }

    // Reject server reflexive candidates (external IP via STUN)
    if (candidateStr.contains('typ srflx')) {
      return false;
    }

    // Reject relay candidates (TURN servers)
    if (candidateStr.contains('typ relay')) {
      return false;
    }

    return true;
  }

  /// Update connection state for a client
  void _updateConnectionState(String clientId, PeerConnectionState state) {
    _connectionStates[clientId] = state;
    _notifyStateChange();
  }

  /// Notify listeners of state changes
  void _notifyStateChange() {
    _stateController.add(Map.from(_connectionStates));
  }

  /// Get all connected clients
  Map<String, RTCPeerConnection> get clients => Map.unmodifiable(_peerConnections);

  /// Get connection states stream
  Stream<Map<String, PeerConnectionState>> get clientStatesStream => _stateController.stream;

  /// Get current connection states
  Map<String, PeerConnectionState> get connectionStates => Map.unmodifiable(_connectionStates);

  /// Get number of connected clients
  int get connectedClientCount =>
      _connectionStates.values.where((state) => state.isConnected).length;

  /// Check if service is initialized
  bool get isInitialized => _cameraStream != null;

  /// Dispose all resources
  Future<void> dispose() async {
    print('Disposing WebRTC server service');

    // Close all peer connections
    final clients = List<String>.from(_peerConnections.keys);
    for (final clientId in clients) {
      await removeClient(clientId);
    }

    // Clear all state
    _peerConnections.clear();
    _connectionStates.clear();
    _pendingIceCandidates.clear();

    // Close stream controller
    await _stateController.close();

    _cameraStream = null;
  }
}
