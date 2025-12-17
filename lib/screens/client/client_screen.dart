import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cam_star/providers/server_discovery_provider.dart';
import 'package:cam_star/widgets/server_list_item.dart';
import 'package:cam_star/screens/client/stream_viewer_screen.dart';
import 'package:cam_star/theme/app_spacing.dart';
import 'package:cam_star/widgets/common/state_views.dart';
import 'package:cam_star/widgets/common/app_button.dart';

/// Client mode screen - discovers and connects to camera servers
class ClientScreen extends StatelessWidget {
  /// Creates a client screen
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServerDiscoveryProvider()..startDiscovery(),
      child: const _ClientScreenContent(),
    );
  }
}

class _ClientScreenContent extends StatelessWidget {
  const _ClientScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Mode'),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        actions: [
          Consumer<ServerDiscoveryProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isScanning ? null : provider.refresh,
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: Consumer<ServerDiscoveryProvider>(
        builder: (context, provider, child) {
          // Show error state
          if (provider.state == DiscoveryState.error) {
            return ErrorView(
              message: provider.errorMessage ?? 'An unknown error occurred',
              onRetry: provider.refresh,
            );
          }

          // Show empty state if no servers found
          if (provider.servers.isEmpty) {
            if (provider.isScanning) {
              return const LoadingView(message: 'Scanning for servers...');
            }
            return EmptyView(
              message: 'No servers found\n\n'
                  'Make sure:\n'
                  '• You\'re connected to Wi-Fi\n'
                  '• A server is running on the same network\n'
                  '• The server is in Server mode',
              icon: Icons.search_off,
              actionLabel: 'Refresh',
              onAction: provider.refresh,
            );
          }

          // Show server grid
          return _buildServerGrid(context, provider);
        },
      ),
    );
  }

  Widget _buildServerGrid(
    BuildContext context,
    ServerDiscoveryProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with server count
        Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              if (provider.isScanning) ...[
                SizedBox(
                  width: AppSpacing.iconSmall,
                  height: AppSpacing.iconSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                AppSpacing.gapMd,
              ],
              Text(
                'Found ${provider.servers.length} server(s)',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Server Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate number of columns based on screen width
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

              return GridView.builder(
                padding: AppSpacing.paddingMd,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: provider.servers.length,
                itemBuilder: (context, index) {
                  final server = provider.servers[index];
                  return ServerListItem(
                    server: server,
                    onTap: () {
                      // Navigate to stream viewer screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StreamViewerScreen(server: server),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
