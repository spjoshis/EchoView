import 'package:flutter/material.dart';
import 'package:cam_star/models/server_device.dart';
import 'package:cam_star/theme/app_spacing.dart';
import 'package:cam_star/theme/app_text_styles.dart';

/// A widget that displays a server device in a card (grid-compatible)
class ServerListItem extends StatelessWidget {
  /// Creates a server list item
  const ServerListItem({
    required this.server,
    required this.onTap,
    super.key,
  });

  /// The server device to display
  final ServerDevice server;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Row(
                children: [
                  Container(
                    width: AppSpacing.iconLarge,
                    height: AppSpacing.iconLarge,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppSpacing.borderRadiusSmall,
                    ),
                    child: Icon(
                      Icons.cast,
                      color: colorScheme.onPrimaryContainer,
                      size: AppSpacing.iconMedium,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: AppSpacing.iconSmall,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              AppSpacing.gapMd,

              // Server Name
              Text(
                server.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.gapXs,

              // Server Address
              Text(
                server.address,
                style: AppTextStyles.monospace.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.gapXs,

              // Discovery Time
              Text(
                'Discovered ${server.timeSinceDiscovery}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
