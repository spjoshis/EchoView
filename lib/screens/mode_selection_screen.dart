import 'package:flutter/material.dart';
import 'package:cam_star/models/app_mode.dart';
import 'package:cam_star/widgets/mode_selection_card.dart';
import 'package:cam_star/screens/server/server_screen.dart';
import 'package:cam_star/screens/client/client_screen.dart';

/// Main screen for selecting between Server and Client modes
class ModeSelectionScreen extends StatelessWidget {
  /// Creates a mode selection screen
  const ModeSelectionScreen({super.key});

  /// Navigates to the screen corresponding to the selected mode
  void _navigateToMode(BuildContext context, AppMode mode) {
    final Widget destination;

    switch (mode) {
      case AppMode.server:
        destination = const ServerScreen();
        break;
      case AppMode.client:
        destination = const ClientScreen();
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo/Icon
                Icon(
                  Icons.videocam,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // App Title
                Text(
                  'CamStar',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Local Network Camera Streaming',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Server Mode Card
                ModeSelectionCard(
                  title: AppMode.server.displayName,
                  description: AppMode.server.description,
                  icon: Icons.cast,
                  onTap: () => _navigateToMode(context, AppMode.server),
                ),
                const SizedBox(height: 16),

                // Client Mode Card
                ModeSelectionCard(
                  title: AppMode.client.displayName,
                  description: AppMode.client.description,
                  icon: Icons.devices_other,
                  onTap: () => _navigateToMode(context, AppMode.client),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
