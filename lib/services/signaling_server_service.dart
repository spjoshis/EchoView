import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// HTTP server for WebRTC signaling (SDP and ICE candidate exchange)
class SignalingServerService {
  HttpServer? _server;
  int? _port;

  // Callbacks for WebRTC events
  Future<RTCSessionDescription> Function(String clientId)? _onOfferRequested;
  Future<void> Function(String clientId, RTCSessionDescription answer)? _onAnswerReceived;
  Future<void> Function(String clientId, RTCIceCandidate candidate)? _onIceCandidateReceived;

  /// Start the HTTP signaling server
  Future<int> start({int? port}) async {
    if (_server != null) {
      throw Exception('Server is already running');
    }

    try {
      // Use provided port or find an available one
      final serverPort = port ?? await _findAvailablePort();

      // Create request handler
      final handler = _createHandler();

      // Start the server
      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        serverPort,
      );

      _port = _server!.port;

      print('Signaling server started on port: $_port');
      return _port!;
    } catch (e) {
      throw Exception('Failed to start signaling server: $e');
    }
  }

  /// Stop the HTTP server
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _port = null;
      print('Signaling server stopped');
    }
  }

  /// Set callback for when a client requests an offer
  void onOfferRequested(Future<RTCSessionDescription> Function(String clientId) callback) {
    _onOfferRequested = callback;
  }

  /// Set callback for when a client sends an answer
  void onAnswerReceived(Future<void> Function(String clientId, RTCSessionDescription answer) callback) {
    _onAnswerReceived = callback;
  }

  /// Set callback for when ICE candidates are received
  void onIceCandidateReceived(Future<void> Function(String clientId, RTCIceCandidate candidate) callback) {
    _onIceCandidateReceived = callback;
  }

  /// Get the current server port
  int? get port => _port;

  /// Check if server is running
  bool get isRunning => _server != null;

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
  }

  /// Create the HTTP request handler
  Handler _createHandler() {
    return Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(_router);
  }

  /// CORS middleware to allow cross-origin requests (safe for local network)
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        // Handle preflight requests
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }

        // Add CORS headers to response
        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  /// CORS headers
  Map<String, String> get _corsHeaders => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      };

  /// Route requests to appropriate handlers
  FutureOr<Response> _router(Request request) async {
    final path = request.url.path;
    final segments = path.split('/');

    try {
      // Health check endpoint
      if (path == 'health') {
        return Response.ok(
          jsonEncode({'status': 'ok', 'port': _port}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get offer endpoint: GET /offer/:clientId
      if (segments.length == 2 && segments[0] == 'offer' && request.method == 'GET') {
        return await _handleOfferRequest(segments[1]);
      }

      // Receive answer endpoint: POST /answer/:clientId
      if (segments.length == 2 && segments[0] == 'answer' && request.method == 'POST') {
        return await _handleAnswerReceived(segments[1], request);
      }

      // ICE candidate endpoint: POST /ice-candidate/:clientId
      if (segments.length == 2 && segments[0] == 'ice-candidate' && request.method == 'POST') {
        return await _handleIceCandidateReceived(segments[1], request);
      }

      // Unknown endpoint
      return Response.notFound('Endpoint not found: $path');
    } catch (e) {
      print('Error handling request: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Handle offer request from client
  Future<Response> _handleOfferRequest(String clientId) async {
    if (_onOfferRequested == null) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Offer handler not registered'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final offer = await _onOfferRequested!(clientId);
      return Response.ok(
        jsonEncode({
          'sdp': offer.sdp,
          'type': offer.type,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create offer: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Handle answer received from client
  Future<Response> _handleAnswerReceived(String clientId, Request request) async {
    if (_onAnswerReceived == null) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Answer handler not registered'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final answer = RTCSessionDescription(
        json['sdp'] as String,
        json['type'] as String,
      );

      await _onAnswerReceived!(clientId, answer);

      return Response.ok(
        jsonEncode({'status': 'ok'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid answer format: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Handle ICE candidate received from client
  Future<Response> _handleIceCandidateReceived(String clientId, Request request) async {
    if (_onIceCandidateReceived == null) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'ICE candidate handler not registered'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final candidate = RTCIceCandidate(
        json['candidate'] as String,
        json['sdpMid'] as String,
        json['sdpMLineIndex'] as int,
      );

      await _onIceCandidateReceived!(clientId, candidate);

      return Response.ok(
        jsonEncode({'status': 'ok'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid ICE candidate format: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Find an available port for the server
  Future<int> _findAvailablePort() async {
    // Try ports in the range 8000-9000
    for (int port = 8000; port < 9000; port++) {
      try {
        final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        final availablePort = server.port;
        await server.close();
        return availablePort;
      } catch (e) {
        // Port not available, try next
        continue;
      }
    }

    // Fallback: let the system choose a port
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final availablePort = server.port;
    await server.close();
    return availablePort;
  }
}
