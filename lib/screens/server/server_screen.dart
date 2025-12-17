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
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/control_panel.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/rotated_camera_preview.dart';

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
                padding: AppSpacing.paddingMd,
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
                      // Camera and Quality Controls
                      if (!broadcastProvider.isBroadcasting)
                        ControlPanel(
                          title: 'Camera Settings',
                          children: [
                            _buildCameraSelection(context, cameraProvider),
                            AppSpacing.gapMd,
                            _buildQualitySelection(context, cameraProvider),
                          ],
                        ),

                      if (!broadcastProvider.isBroadcasting) AppSpacing.gapMd,

                      // Status Display
                      _buildStatusDisplay(context, broadcastProvider),

                      AppSpacing.gapMd,

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
      return ErrorView(message: cameraProvider.errorMessage!);
    }

    if (cameraProvider.isInitializing) {
      return const LoadingView(message: 'Initializing camera...');
    }

    if (!cameraProvider.isInitialized || cameraProvider.controller == null) {
      return const PlaceholderView(
        icon: Icons.videocam_off_outlined,
        message: 'No Camera Selected',
        subtitle: 'Select a camera to begin',
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
            child: RepaintBoundary(
              child: RotatedCameraPreview(
                controller: cameraProvider.controller!,
              ),
            ),
          ),

          // Broadcasting indicator
          if (broadcastProvider.isBroadcasting)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: StatusBadge(
                text: 'LIVE',
                color: AppColors.live,
                showPulse: true,
              ),
            ),

          // Viewer count
          if (broadcastProvider.isBroadcasting)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: AppSpacing.borderRadiusXLarge,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: AppSpacing.iconSmall,
                    ),
                    AppSpacing.gapSm,
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
        const Icon(Icons.videocam, size: AppSpacing.iconSmall),
        AppSpacing.gapMd,
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
        const Icon(Icons.high_quality, size: AppSpacing.iconSmall),
        AppSpacing.gapMd,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (broadcastProvider.hasError) {
      return Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: AppSpacing.borderRadiusSmall,
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            AppSpacing.gapMd,
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
          const Icon(Icons.info_outline, size: AppSpacing.iconSmall),
          AppSpacing.gapSm,
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
            AppSpacing.gapSm,
            Text(
              'Broadcasting',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.gapSm,
        Text(
          'Viewers: ${broadcastProvider.viewerCount} | '
          'Clients: ${broadcastProvider.totalClients}',
          style: theme.textTheme.bodySmall,
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
      return DangerButton(
        onPressed: () async {
          await broadcastProvider.stopBroadcast();
        },
        icon: Icons.stop,
        label: 'Stop Broadcasting',
      );
    }

    return PrimaryButton(
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
                  final theme = Theme.of(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to start broadcast: $e'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              }
            }
          : null,
      icon: Icons.videocam,
      label: 'Start Broadcasting',
    );
  }
}
