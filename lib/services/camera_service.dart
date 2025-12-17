import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/camera_info.dart';
import '../models/stream_quality.dart';

/// Service for managing camera access and streaming
class CameraService {
  CameraController? _controller;
  MediaStream? _localStream;
  List<CameraDescription> _availableCameras = [];

  /// Get list of available cameras
  Future<List<CameraInfo>> getAvailableCameras() async {
    try {
      _availableCameras = await availableCameras();
      return _availableCameras
          .map((desc) => CameraInfo.fromDescription(desc))
          .toList();
    } catch (e) {
      throw CameraException(
        'cameraEnumeration',
        'Failed to enumerate cameras: $e',
      );
    }
  }

  /// Initialize camera with specified ID and quality
  Future<void> initializeCamera(
    String cameraId, {
    StreamQuality quality = StreamQuality.auto,
  }) async {
    // Dispose existing controller if any
    await dispose();

    try {
      // Find the camera description
      final description = _availableCameras.firstWhere(
        (desc) => desc.name == cameraId,
        orElse: () => throw CameraException(
          'cameraNotFound',
          'Camera with ID $cameraId not found',
        ),
      );

      // Create camera controller
      _controller = CameraController(
        description,
        _getResolutionPreset(quality),
        enableAudio: false, // Video only for now
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Initialize the controller
      await _controller!.initialize();
    } catch (e) {
      throw CameraException(
        'cameraInitialization',
        'Failed to initialize camera: $e',
      );
    }
  }

  /// Get the camera media stream for WebRTC
  Future<MediaStream> getCameraMediaStream() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraException(
        'cameraNotInitialized',
        'Camera not initialized. Call initializeCamera first.',
      );
    }

    if (_localStream != null) {
      return _localStream!;
    }

    try {
      // Determine facing mode
      final facingMode = _controller!.description.lensDirection == CameraLensDirection.front
          ? 'user'
          : 'environment';

      // Create a media stream from the camera using WebRTC
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': {
          'facingMode': facingMode,
          'optional': [
            {'minWidth': '640'},
            {'minHeight': '480'},
          ],
        },
      });

      return _localStream!;
    } catch (e) {
      throw CameraException(
        'streamCreation',
        'Failed to create camera stream: $e',
      );
    }
  }

  /// Switch to a different camera
  Future<void> switchCamera(
    String cameraId, {
    StreamQuality quality = StreamQuality.auto,
  }) async {
    await initializeCamera(cameraId, quality: quality);
  }

  /// Get the current camera controller (for preview)
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Get current camera description
  CameraDescription? get currentCamera => _controller?.description;

  /// Dispose camera resources
  Future<void> dispose() async {
    // Dispose controller
    await _controller?.dispose();
    _controller = null;

    // Dispose media stream
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        track.stop();
      });
      _localStream!.dispose();
      _localStream = null;
    }
  }

  /// Convert StreamQuality to ResolutionPreset
  ResolutionPreset _getResolutionPreset(StreamQuality quality) {
    switch (quality) {
      case StreamQuality.low:
        return ResolutionPreset.medium; // 480p
      case StreamQuality.medium:
      case StreamQuality.auto:
        return ResolutionPreset.high; // 720p
      case StreamQuality.high:
        return ResolutionPreset.veryHigh; // 1080p
    }
  }
}
