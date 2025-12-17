import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../models/stream_quality.dart';
import '../../providers/camera_provider.dart';
import '../../providers/broadcast_provider.dart';
import '../../services/camera_service.dart';
import '../../services/server_registration_service.dart';
import '../../services/signaling_server_service.dart';
import '../../services/webrtc_server_service.dart';

/// Server mode screen - broadcasts camera feed to clients
class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CameraProvider(CameraService())..loadCameras(),
        ),
        ChangeNotifierProvider(
          create: (_) => BroadcastProvider(
            ServerRegistrationService(),
            SignalingServerService(),
            WebRTCServerService(),
          ),
        ),
      ],
      child: const _ServerScreenContent(),
    );
  }
}

class _ServerScreenContent extends StatelessWidget {
  const _ServerScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Mode'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Consumer2<CameraProvider, BroadcastProvider>(
        builder: (context, cameraProvider, broadcastProvider, _) {
          return Column(
            children: [
              // Camera Preview Section
              Expanded(
                child: _buildCameraPreview(
                  context,
                  cameraProvider,
                  broadcastProvider,
                ),
              ),

              // Controls Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Camera Selection
                      if (!broadcastProvider.isBroadcasting)
                        _buildCameraSelection(context, cameraProvider),

                      const SizedBox(height: 12),

                      // Quality Selection
                      if (!broadcastProvider.isBroadcasting)
                        _buildQualitySelection(context, cameraProvider),

                      const SizedBox(height: 16),

                      // Status Display
                      _buildStatusDisplay(
                        context,
                        broadcastProvider,
                      ),

                      const SizedBox(height: 16),

                      // Broadcast Button
                      _buildBroadcastButton(
                        context,
                        cameraProvider,
                        broadcastProvider,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview(
    BuildContext context,
    CameraProvider cameraProvider,
    BroadcastProvider broadcastProvider,
  ) {
    if (cameraProvider.hasError) {
      return _buildErrorView(context, cameraProvider.errorMessage!);
    }

    if (cameraProvider.isInitializing) {
      return _buildLoadingView(context, 'Initializing camera...');
    }

    if (!cameraProvider.isInitialized || cameraProvider.controller == null) {
      return _buildPlaceholderView(
        context,
        Icons.videocam_off_outlined,
        'No Camera Selected',
        'Select a camera to begin',
      );
    }

    // Show camera preview
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          Center(
            child: AspectRatio(
              aspectRatio: cameraProvider.controller!.value.aspectRatio,
              child: CameraPreview(cameraProvider.controller!),
            ),
          ),

          // Broadcasting indicator
          if (broadcastProvider.isBroadcasting)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Viewer count
          if (broadcastProvider.isBroadcasting)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${broadcastProvider.viewerCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraSelection(
    BuildContext context,
    CameraProvider cameraProvider,
  ) {
    if (cameraProvider.availableCameras.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.videocam, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            value: cameraProvider.selectedCamera?.id,
            isExpanded: true,
            hint: const Text('Select Camera'),
            items: cameraProvider.availableCameras.map((camera) {
              return DropdownMenuItem(
                value: camera.id,
                child: Text(camera.name),
              );
            }).toList(),
            onChanged: (cameraId) {
              if (cameraId != null) {
                cameraProvider.selectCamera(cameraId);
              }
            },
          ),
        ),
        if (cameraProvider.availableCameras.length > 1)
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Switch Camera',
            onPressed: () => cameraProvider.switchCamera(),
          ),
      ],
    );
  }

  Widget _buildQualitySelection(
    BuildContext context,
    CameraProvider cameraProvider,
  ) {
    return Row(
      children: [
        Icon(Icons.high_quality, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<StreamQuality>(
            value: cameraProvider.quality,
            isExpanded: true,
            items: StreamQuality.values.map((quality) {
              return DropdownMenuItem(
                value: quality,
                child: Text(quality.displayName),
              );
            }).toList(),
            onChanged: (quality) {
              if (quality != null) {
                cameraProvider.setQuality(quality);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDisplay(
    BuildContext context,
    BroadcastProvider broadcastProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (broadcastProvider.hasError) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                broadcastProvider.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    if (!broadcastProvider.isBroadcasting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          const Text('Ready to broadcast'),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cast, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Broadcasting',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Viewers: ${broadcastProvider.viewerCount} | '
          'Clients: ${broadcastProvider.totalClients}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildBroadcastButton(
    BuildContext context,
    CameraProvider cameraProvider,
    BroadcastProvider broadcastProvider,
  ) {
    final canStartBroadcast = cameraProvider.isInitialized &&
        !cameraProvider.hasError &&
        !broadcastProvider.isBroadcasting;

    if (broadcastProvider.isBroadcasting) {
      return FilledButton.icon(
        onPressed: () async {
          await broadcastProvider.stopBroadcast();
        },
        icon: const Icon(Icons.stop),
        label: const Text('Stop Broadcasting'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: canStartBroadcast
          ? () async {
              try {
                final cameraStream = await cameraProvider.getCameraStream();
                await broadcastProvider.startBroadcast(
                  serverName: 'CamStar Server',
                  cameraStream: cameraStream,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to start broadcast: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          : null,
      icon: const Icon(Icons.videocam),
      label: const Text('Start Broadcasting'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
