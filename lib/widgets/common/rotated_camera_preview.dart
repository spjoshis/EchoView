import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// A camera preview widget that handles rotation based on sensor orientation
///
/// This widget wraps CameraPreview and applies the necessary transforms to
/// display the camera feed in the correct orientation for landscape mode.
class RotatedCameraPreview extends StatelessWidget {
  final CameraController controller;

  const RotatedCameraPreview({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Get rotation angle based on sensor orientation and lens direction
    final rotationAngle = _calculateRotationAngle();

    // Get aspect ratio - may need to be inverted based on rotation
    final aspectRatio = _getAspectRatio();

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Transform.rotate(
        angle: rotationAngle,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  /// Calculate rotation angle in radians based on sensor orientation
  ///
  /// Camera sensor orientations are typically:
  /// - Back camera: 90° (needs -90° rotation for landscape)
  /// - Front camera: 270° (needs -90° rotation for landscape)
  double _calculateRotationAngle() {
    final sensorOrientation = controller.description.sensorOrientation;
    final isBackCamera =
        controller.description.lensDirection == CameraLensDirection.back;

    // Convert sensor orientation to rotation angle for landscape mode
    // Landscape left (device rotated 90° CCW) is the base orientation

    if (isBackCamera) {
      // Back camera typically has 90° sensor orientation
      // To display correctly in landscape, we need to rotate
      switch (sensorOrientation) {
        case 0:
          return 0.0; // No rotation needed
        case 90:
          return -1.5708; // -90° in radians (most common)
        case 180:
          return 3.14159; // 180° in radians
        case 270:
          return 1.5708; // 90° in radians
        default:
          return 0.0;
      }
    } else {
      // Front camera typically has 270° sensor orientation
      // Front camera also needs mirroring (handled by camera package)
      switch (sensorOrientation) {
        case 0:
          return 0.0;
        case 90:
          return -1.5708; // -90° in radians
        case 180:
          return 3.14159; // 180° in radians
        case 270:
          return -1.5708; // -90° in radians (most common for front)
        default:
          return 0.0;
      }
    }
  }

  /// Get the correct aspect ratio for the rotated preview
  ///
  /// When rotating 90° or 270°, width and height are swapped
  double _getAspectRatio() {
    final sensorOrientation = controller.description.sensorOrientation;
    final originalAspectRatio = controller.value.aspectRatio;

    // For 90° and 270° rotations, invert the aspect ratio
    if (sensorOrientation == 90 || sensorOrientation == 270) {
      return 1.0 / originalAspectRatio;
    }

    return originalAspectRatio;
  }
}
