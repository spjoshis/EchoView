import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../models/camera_info.dart';
import '../models/stream_quality.dart';
import '../services/camera_service.dart';

/// Provider for managing camera state
class CameraProvider extends ChangeNotifier {
  final CameraService _cameraService;

  List<CameraInfo> _availableCameras = [];
  CameraInfo? _selectedCamera;
  StreamQuality _quality = StreamQuality.auto;
  bool _isInitializing = false;
  String? _errorMessage;

  CameraProvider(this._cameraService);

  /// Get list of available cameras
  List<CameraInfo> get availableCameras => List.unmodifiable(_availableCameras);

  /// Get currently selected camera
  CameraInfo? get selectedCamera => _selectedCamera;

  /// Get current quality setting
  StreamQuality get quality => _quality;

  /// Check if camera is currently initializing
  bool get isInitializing => _isInitializing;

  /// Get error message if any
  String? get errorMessage => _errorMessage;

  /// Check if there's an error
  bool get hasError => _errorMessage != null;

  /// Check if camera is initialized
  bool get isInitialized => _cameraService.isInitialized;

  /// Get camera controller for preview
  CameraController? get controller => _cameraService.controller;

  /// Get camera description for selected camera
  CameraDescription? get currentCamera => _cameraService.currentCamera;

  /// Load available cameras
  Future<void> loadCameras() async {
    _clearError();

    try {
      print('Loading available cameras...');
      _availableCameras = await _cameraService.getAvailableCameras();
      print('Found ${_availableCameras.length} cameras');

      // Auto-select first camera if available
      if (_availableCameras.isNotEmpty && _selectedCamera == null) {
        // Prefer back camera if available
        final backCamera = _availableCameras.firstWhere(
          (camera) => camera.isBackCamera,
          orElse: () => _availableCameras.first,
        );
        await selectCamera(backCamera.id);
      }

      notifyListeners();
    } on CameraException catch (e) {
      _setError('Failed to load cameras: ${e.description}');
    } catch (e) {
      _setError('Failed to load cameras: $e');
    }
  }

  /// Select a camera by ID
  Future<void> selectCamera(String cameraId) async {
    _clearError();
    _isInitializing = true;
    notifyListeners();

    try {
      print('Selecting camera: $cameraId');

      // Find camera info
      final cameraInfo = _availableCameras.firstWhere(
        (camera) => camera.id == cameraId,
        orElse: () => throw CameraException(
          'cameraNotFound',
          'Camera with ID $cameraId not found',
        ),
      );

      // Initialize camera
      await _cameraService.initializeCamera(cameraId, quality: _quality);

      _selectedCamera = cameraInfo;
      print('Camera selected: ${cameraInfo.name}');
    } on CameraException catch (e) {
      _setError('Failed to select camera: ${e.description}');
    } catch (e) {
      _setError('Failed to select camera: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Set video quality
  Future<void> setQuality(StreamQuality newQuality) async {
    if (_quality == newQuality) return;

    _quality = newQuality;
    print('Quality changed to: ${newQuality.displayName}');

    // If camera is already initialized, reinitialize with new quality
    if (_selectedCamera != null && isInitialized) {
      await selectCamera(_selectedCamera!.id);
    } else {
      notifyListeners();
    }
  }

  /// Get camera media stream for WebRTC
  Future<dynamic> getCameraStream() async {
    try {
      return await _cameraService.getCameraMediaStream();
    } on CameraException catch (e) {
      _setError('Failed to get camera stream: ${e.description}');
      rethrow;
    } catch (e) {
      _setError('Failed to get camera stream: $e');
      rethrow;
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) {
      _setError('No other cameras available');
      return;
    }

    final currentCamera = _selectedCamera;
    if (currentCamera == null) {
      _setError('No camera selected');
      return;
    }

    // Find the other camera (opposite lens direction)
    final otherCamera = _availableCameras.firstWhere(
      (camera) => camera.id != currentCamera.id,
      orElse: () => _availableCameras.first,
    );

    await selectCamera(otherCamera.id);
  }

  /// Clear camera resources
  Future<void> clearCamera() async {
    await _cameraService.dispose();
    _selectedCamera = null;
    _clearError();
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    print('Camera error: $message');
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  @override
  Future<void> dispose() async {
    await _cameraService.dispose();
    super.dispose();
  }
}
