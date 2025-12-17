import 'package:camera/camera.dart';

/// Represents information about an available camera device
class CameraInfo {
  final String id;
  final String name;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;

  CameraInfo({
    required this.id,
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  /// Factory constructor to create CameraInfo from CameraDescription
  factory CameraInfo.fromDescription(CameraDescription description) {
    return CameraInfo(
      id: description.name,
      name: _getLensName(description.lensDirection),
      lensDirection: description.lensDirection,
      sensorOrientation: description.sensorOrientation,
    );
  }

  /// Helper method to get user-friendly lens name
  static String _getLensName(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.front:
        return 'Front Camera';
      case CameraLensDirection.back:
        return 'Back Camera';
      case CameraLensDirection.external:
        return 'External Camera';
    }
  }

  /// Check if this is the front-facing camera
  bool get isFrontCamera => lensDirection == CameraLensDirection.front;

  /// Check if this is the back-facing camera
  bool get isBackCamera => lensDirection == CameraLensDirection.back;

  @override
  String toString() => 'CameraInfo(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
