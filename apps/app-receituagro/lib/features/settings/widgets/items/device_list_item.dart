import 'package:flutter/material.dart';
import '../../constants/settings_design_tokens.dart';
import '../../../../core/services/device_identity_service.dart';

/// Individual device list item component
/// 
/// Features:
/// - Device info display (name, platform, version)
/// - Primary device badge
/// - Last active timestamp
/// - Revoke action for non-primary devices
/// - Platform-specific icons
class DeviceListItem extends StatelessWidget {
  final DeviceInfo device;
  final bool isPrimary;
  final VoidCallback? onRevoke;

  const DeviceListItem({
    super.key,
    required this.device,
    this.isPrimary = false,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surface,
        border: Border.all(
          color: isPrimary 
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Platform Icon
          _buildPlatformIcon(theme),
          
          const SizedBox(width: 12),
          
          // Device Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Name + Primary Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      _buildPrimaryBadge(theme),
                    ],
                  ],
                ),
                
                const SizedBox(height: 2),
                
                // Platform and System Version
                Text(
                  '${device.platform} ${device.systemVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Last Active
                Text(
                  _formatLastActive(device.lastActiveAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Revoke Button (only for non-primary devices)
          if (!isPrimary && onRevoke != null) ...[
            const SizedBox(width: 8),
            _buildRevokeButton(theme),
          ],
        ],
      ),
    );
  }

  /// Platform-specific icon
  Widget _buildPlatformIcon(ThemeData theme) {
    IconData platformIcon;
    Color iconColor;

    switch (device.platform.toLowerCase()) {
      case 'ios':
        platformIcon = Icons.phone_iphone;
        iconColor = Colors.grey.shade700;
        break;
      case 'android':
        platformIcon = Icons.android;
        iconColor = Colors.green;
        break;
      default:
        platformIcon = Icons.device_unknown;
        iconColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        platformIcon,
        size: 20,
        color: iconColor,
      ),
    );
  }

  /// Primary device badge
  Widget _buildPrimaryBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'ATUAL',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Revoke button for non-primary devices
  Widget _buildRevokeButton(ThemeData theme) {
    return IconButton(
      onPressed: onRevoke,
      icon: Icon(
        Icons.close,
        size: 18,
        color: theme.colorScheme.error,
      ),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.error.withOpacity(0.1),
        padding: const EdgeInsets.all(4),
        minimumSize: const Size(28, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      tooltip: 'Revogar acesso deste dispositivo',
    );
  }

  /// Format last active timestamp
  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Ativo agora';
    } else if (difference.inMinutes < 60) {
      return 'Ativo ${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return 'Ativo ${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return 'Ativo ${difference.inDays}d atrás';
    } else {
      return 'Ativo em ${lastActive.day}/${lastActive.month}/${lastActive.year}';
    }
  }
}