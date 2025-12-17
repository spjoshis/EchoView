/// Video stream quality presets
enum StreamQuality {
  /// Low quality: 480p @ 15fps (good for slow networks)
  low,

  /// Medium quality: 720p @ 30fps (balanced)
  medium,

  /// High quality: 1080p @ 30fps (best quality)
  high,

  /// Auto quality: Adaptive based on network (720p @ 30fps default)
  auto;

  /// Get user-friendly display name
  String get displayName {
    switch (this) {
      case StreamQuality.low:
        return 'Low (480p)';
      case StreamQuality.medium:
        return 'Medium (720p)';
      case StreamQuality.high:
        return 'High (1080p)';
      case StreamQuality.auto:
        return 'Auto';
    }
  }

  /// Get description for the quality level
  String get description {
    switch (this) {
      case StreamQuality.low:
        return '640x480 at 15fps - Best for slow networks';
      case StreamQuality.medium:
        return '1280x720 at 30fps - Balanced quality and performance';
      case StreamQuality.high:
        return '1920x1080 at 30fps - Best quality, requires good network';
      case StreamQuality.auto:
        return 'Automatically adjusts based on network conditions';
    }
  }

  /// Get video constraints for this quality level
  Map<String, dynamic> get constraints {
    switch (this) {
      case StreamQuality.low:
        return {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '15',
          },
          'optional': [],
        };
      case StreamQuality.medium:
        return {
          'mandatory': {
            'minWidth': '1280',
            'minHeight': '720',
            'minFrameRate': '30',
          },
          'optional': [],
        };
      case StreamQuality.high:
        return {
          'mandatory': {
            'minWidth': '1920',
            'minHeight': '1080',
            'minFrameRate': '30',
          },
          'optional': [],
        };
      case StreamQuality.auto:
        // Default to medium quality for auto mode
        return {
          'mandatory': {
            'minWidth': '1280',
            'minHeight': '720',
            'minFrameRate': '30',
          },
          'optional': [],
        };
    }
  }

  /// Get resolution width
  int get width {
    switch (this) {
      case StreamQuality.low:
        return 640;
      case StreamQuality.medium:
      case StreamQuality.auto:
        return 1280;
      case StreamQuality.high:
        return 1920;
    }
  }

  /// Get resolution height
  int get height {
    switch (this) {
      case StreamQuality.low:
        return 480;
      case StreamQuality.medium:
      case StreamQuality.auto:
        return 720;
      case StreamQuality.high:
        return 1080;
    }
  }

  /// Get frame rate
  int get frameRate {
    switch (this) {
      case StreamQuality.low:
        return 15;
      case StreamQuality.medium:
      case StreamQuality.high:
      case StreamQuality.auto:
        return 30;
    }
  }
}
