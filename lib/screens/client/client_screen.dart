import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cam_star/providers/server_discovery_provider.dart';
import 'package:cam_star/widgets/server_list_item.dart';
import 'package:cam_star/screens/client/stream_viewer_screen.dart';

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
            return _buildErrorState(context, provider);
          }

          // Show empty state if no servers found
          if (provider.servers.isEmpty) {
            return _buildEmptyState(context, provider);
          }

          // Show server list
          return _buildServerList(context, provider);
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ServerDiscoveryProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Discovery Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'An unknown error occurred',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ServerDiscoveryProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.isScanning) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Scanning for servers...',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few seconds',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Icon(
                Icons.search_off,
                size: 80,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                'No servers found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Make sure:\n'
                '• You\'re connected to Wi-Fi\n'
                '• A server is running on the same network\n'
                '• The server is in Server mode',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: provider.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerList(
    BuildContext context,
    ServerDiscoveryProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (provider.isScanning) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
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
        Expanded(
          child: ListView.builder(
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
                      builder: (context) => StreamViewerScreen(server: server),
                    ),
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
