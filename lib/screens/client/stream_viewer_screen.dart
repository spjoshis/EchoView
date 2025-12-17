import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../models/peer_connection_state.dart';
import '../../models/server_device.dart';
import '../../providers/stream_viewer_provider.dart';
import '../../services/webrtc_client_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/app_button.dart';

/// Screen for viewing live video stream from a server
class StreamViewerScreen extends StatefulWidget {
  final ServerDevice server;

  const StreamViewerScreen({
    super.key,
    required this.server,
  });

  @override
  State<StreamViewerScreen> createState() => _StreamViewerScreenState();
}

class _StreamViewerScreenState extends State<StreamViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          StreamViewerProvider(WebRTCClientService())..initialize(),
      child: _StreamViewerContent(server: widget.server),
    );
  }
}

class _StreamViewerContent extends StatefulWidget {
  final ServerDevice server;

  const _StreamViewerContent({required this.server});

  @override
  State<_StreamViewerContent> createState() => _StreamViewerContentState();
}

class _StreamViewerContentState extends State<_StreamViewerContent> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Auto-connect when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToServer();
    });
  }

  Future<void> _connectToServer() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final provider = context.read<StreamViewerProvider>();
      await provider.connectToServer(widget.server);
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: theme.colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _connectToServer,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Disconnect when leaving the screen
          final provider = context.read<StreamViewerProvider>();
          await provider.disconnect();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.server.name),
              Text(
                widget.server.address,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        body: Consumer<StreamViewerProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                // Video player section
                Expanded(
                  child: _buildVideoPlayer(context, provider),
                ),

                // Control section
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
                        _buildConnectionStatus(context, provider),
                        AppSpacing.gapMd,
                        _buildControlButtons(context, provider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(
    BuildContext context,
    StreamViewerProvider provider,
  ) {
    // Show different states
    if (provider.hasError &&
        provider.connectionState == PeerConnectionState.failed) {
      return ErrorView(
        message: provider.errorMessage ?? 'Connection failed',
        onRetry: _connectToServer,
      );
    }

    if (provider.isConnecting || _isConnecting) {
      return const LoadingView(message: 'Connecting to server...');
    }

    if (provider.connectionState == PeerConnectionState.disconnected) {
      return const PlaceholderView(
        icon: Icons.videocam_off_outlined,
        message: 'Disconnected',
        subtitle: 'Tap connect to start streaming',
      );
    }

    if (provider.isConnected && !provider.hasVideoStream) {
      return const LoadingView(message: 'Waiting for video stream...');
    }

    if (provider.hasVideoStream) {
      // Show video stream
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video renderer
            RTCVideoView(
              provider.videoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              mirror: false,
            ),

            // Connected indicator
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: StatusBadge(
                text: 'LIVE',
                color: AppColors.connected,
                showPulse: true,
              ),
            ),
          ],
        ),
      );
    }

    return const PlaceholderView(
      icon: Icons.videocam_off_outlined,
      message: 'No Stream',
      subtitle: 'Waiting for connection',
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    StreamViewerProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (provider.connectionState) {
      case PeerConnectionState.disconnected:
        statusColor = colorScheme.onSurfaceVariant;
        statusIcon = Icons.link_off;
        statusText = 'Disconnected';
        break;
      case PeerConnectionState.connecting:
        statusColor = colorScheme.primary;
        statusIcon = Icons.sync;
        statusText = 'Connecting...';
        break;
      case PeerConnectionState.connected:
        statusColor = brightness == Brightness.light
            ? AppColors.lightSuccess
            : AppColors.darkSuccess;
        statusIcon = Icons.check_circle;
        statusText = 'Connected';
        break;
      case PeerConnectionState.failed:
        statusColor = colorScheme.error;
        statusIcon = Icons.error;
        statusText = 'Connection Failed';
        break;
      case PeerConnectionState.closed:
        statusColor = colorScheme.onSurfaceVariant;
        statusIcon = Icons.link_off;
        statusText = 'Closed';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(statusIcon, color: statusColor, size: AppSpacing.iconSmall),
        AppSpacing.gapSm,
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    StreamViewerProvider provider,
  ) {
    if (provider.isConnected) {
      return DangerButton(
        onPressed: () async {
          await provider.disconnect();
        },
        icon: Icons.stop,
        label: 'Disconnect',
      );
    }

    if (provider.connectionState == PeerConnectionState.failed) {
      return PrimaryButton(
        onPressed: _connectToServer,
        icon: Icons.refresh,
        label: 'Retry Connection',
      );
    }

    if (provider.connectionState == PeerConnectionState.disconnected) {
      return PrimaryButton(
        onPressed: _connectToServer,
        icon: Icons.play_arrow,
        label: 'Connect',
      );
    }

    return const SizedBox.shrink();
  }
}
