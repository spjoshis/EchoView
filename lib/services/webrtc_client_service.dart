import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/peer_connection_state.dart';

/// WebRTC client service for receiving video stream from server
class WebRTCClientService {
  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _videoRenderer = RTCVideoRenderer();
  String? _clientId;
  String? _serverBaseUrl;

  // Stream controllers
  final _connectionStateController = StreamController<PeerConnectionState>.broadcast();
  final _remoteStreamController = StreamController<MediaStream?>.broadcast();

  PeerConnectionState _connectionState = PeerConnectionState.disconnected;

  // WebRTC configuration (local network only - no STUN/TURN servers)
  final Map<String, dynamic> _configuration = {
    'iceServers': [], // Empty = local network only
    'iceTransportPolicy': 'all',
    'bundlePolicy': 'max-bundle',
    'rtcpMuxPolicy': 'require',
  };

  /// Initialize the video renderer
  Future<void> initialize() async {
    await _videoRenderer.initialize();
    print('Video renderer initialized');
  }

  /// Connect to the server and establish WebRTC connection
  Future<void> connect({
    required String serverIp,
    required int serverPort,
  }) async {
    if (_peerConnection != null) {
      throw Exception('Already connected. Call disconnect() first.');
    }

    try {
      _serverBaseUrl = 'http://$serverIp:$serverPort';
      _clientId = const Uuid().v4();

      print('Connecting to server: $_serverBaseUrl with client ID: $_clientId');
      _updateConnectionState(PeerConnectionState.connecting);

      // Create peer connection
      _peerConnection = await createPeerConnection(_configuration);

      // Set up event handlers
      _setupPeerConnectionHandlers();

      // Request offer from server
      print('Requesting offer from server...');
      final offer = await _requestOffer();

      // Set remote description
      print('Setting remote description...');
      await _peerConnection!.setRemoteDescription(offer);

      // Create answer
      print('Creating answer...');
      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveVideo': true,
        'offerToReceiveAudio': false,
      });

      // Set local description
      await _peerConnection!.setLocalDescription(answer);

      // Send answer to server
      print('Sending answer to server...');
      await _sendAnswer(answer);

      print('WebRTC handshake completed');
    } catch (e) {
      print('Error connecting to server: $e');
      _updateConnectionState(PeerConnectionState.failed);
      await disconnect();
      rethrow;
    }
  }

  /// Disconnect from the server
  Future<void> disconnect() async {
    print('Disconnecting from server');

    // Close peer connection
    if (_peerConnection != null) {
      await _peerConnection!.close();
      await _peerConnection!.dispose();
      _peerConnection = null;
    }

    _updateConnectionState(PeerConnectionState.disconnected);
    _remoteStreamController.add(null);

    _serverBaseUrl = null;
    _clientId = null;
  }

  /// Request SDP offer from server
  Future<RTCSessionDescription> _requestOffer() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverBaseUrl/offer/$_clientId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Server returned error: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return RTCSessionDescription(
        json['sdp'] as String,
        json['type'] as String,
      );
    } catch (e) {
      throw Exception('Failed to request offer: $e');
    }
  }

  /// Send SDP answer to server
  Future<void> _sendAnswer(RTCSessionDescription answer) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverBaseUrl/answer/$_clientId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sdp': answer.sdp,
          'type': answer.type,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Server returned error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send answer: $e');
    }
  }

  /// Send ICE candidate to server
  Future<void> _sendIceCandidate(RTCIceCandidate candidate) async {
    if (_serverBaseUrl == null || _clientId == null) return;

    try {
      await http.post(
        Uri.parse('$_serverBaseUrl/ice-candidate/$_clientId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error sending ICE candidate: $e');
    }
  }

  /// Set up peer connection event handlers
  void _setupPeerConnectionHandlers() {
    if (_peerConnection == null) return;

    // Track event - when we receive media from server
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      print('Received track: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];
        print('Received remote stream with ${stream.getTracks().length} tracks');
        _videoRenderer.srcObject = stream;
        _remoteStreamController.add(stream);
      }
    };

    // Connection state changes
    _peerConnection!.onConnectionState = (state) {
      print('Connection state: $state');

      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _updateConnectionState(PeerConnectionState.connected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _updateConnectionState(PeerConnectionState.failed);
          disconnect();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          _updateConnectionState(PeerConnectionState.disconnected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _updateConnectionState(PeerConnectionState.closed);
          break;
        default:
          break;
      }
    };

    // ICE candidate events
    _peerConnection!.onIceCandidate = (candidate) {
      // Filter to only local network candidates (Story 5 requirement)
      if (_isLocalCandidate(candidate)) {
        print('Local ICE candidate: ${candidate.candidate}');
        _sendIceCandidate(candidate);
      } else {
        print('Filtered non-local ICE candidate');
      }
    };

    // ICE connection state
    _peerConnection!.onIceConnectionState = (state) {
      print('ICE connection state: $state');
    };

    // ICE gathering state
    _peerConnection!.onIceGatheringState = (state) {
      print('ICE gathering state: $state');
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

  /// Update connection state
  void _updateConnectionState(PeerConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Get video renderer for displaying the stream
  RTCVideoRenderer get videoRenderer => _videoRenderer;

  /// Get connection state stream
  Stream<PeerConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Get remote stream stream
  Stream<MediaStream?> get remoteStreamStream =>
      _remoteStreamController.stream;

  /// Get current connection state
  PeerConnectionState get connectionState => _connectionState;

  /// Check if connected
  bool get isConnected => _connectionState.isConnected;

  /// Dispose all resources
  Future<void> dispose() async {
    print('Disposing WebRTC client service');

    await disconnect();

    // Dispose video renderer
    await _videoRenderer.dispose();

    // Close stream controllers
    await _connectionStateController.close();
    await _remoteStreamController.close();
  }
}
