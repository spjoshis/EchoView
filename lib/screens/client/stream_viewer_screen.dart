import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../models/peer_connection_state.dart';
import '../../models/server_device.dart';
import '../../providers/stream_viewer_provider.dart';
import '../../services/webrtc_client_service.dart';

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
      create: (_) => StreamViewerProvider(WebRTCClientService())..initialize(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
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
                        _buildConnectionStatus(context, provider),
                        const SizedBox(height: 16),
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
    if (provider.hasError && provider.connectionState == PeerConnectionState.failed) {
      return _buildErrorView(
        context,
        provider.errorMessage ?? 'Connection failed',
      );
    }

    if (provider.isConnecting || _isConnecting) {
      return _buildLoadingView(context, 'Connecting to server...');
    }

    if (provider.connectionState == PeerConnectionState.disconnected) {
      return _buildPlaceholderView(
        context,
        Icons.videocam_off_outlined,
        'Disconnected',
        'Tap connect to start streaming',
      );
    }

    if (provider.isConnected && !provider.hasVideoStream) {
      return _buildLoadingView(context, 'Waiting for video stream...');
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
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
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
          ],
        ),
      );
    }

    return _buildPlaceholderView(
      context,
      Icons.videocam_off_outlined,
      'No Stream',
      'Waiting for connection',
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    StreamViewerProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

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
        statusColor = Colors.green;
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
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 8),
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
      return FilledButton.icon(
        onPressed: () async {
          await provider.disconnect();
        },
        icon: const Icon(Icons.stop),
        label: const Text('Disconnect'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }

    if (provider.connectionState == PeerConnectionState.failed) {
      return FilledButton.icon(
        onPressed: _connectToServer,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry Connection'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }

    if (provider.connectionState == PeerConnectionState.disconnected) {
      return FilledButton.icon(
        onPressed: _connectToServer,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Connect'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }

    return const SizedBox.shrink();
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
              'Connection Error',
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
