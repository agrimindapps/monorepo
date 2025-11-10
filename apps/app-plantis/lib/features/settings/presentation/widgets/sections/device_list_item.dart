import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../../core/theme/plantis_colors.dart';

/// Widget para exibir um dispositivo na lista
class DeviceListItem extends StatelessWidget {
  final DeviceEntity device;
  final bool isCurrent;
  final VoidCallback? onRevoke;

  const DeviceListItem({
    required this.device,
    this.isCurrent = false,
    this.onRevoke,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = device.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrent ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? const BorderSide(color: PlantisColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ícone da plataforma
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getPlatformColor(device.platform).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getPlatformIcon(device.platform),
                    color: _getPlatformColor(device.platform),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Info do dispositivo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              device.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: PlantisColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ATUAL',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.model,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Botão de revogar (apenas para outros dispositivos ativos)
                if (!isCurrent && isActive && onRevoke != null)
                  IconButton(
                    onPressed: onRevoke,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Revogar acesso',
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Informações adicionais
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    context,
                    Icons.phone_android,
                    device.systemVersion,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    context,
                    Icons.apps,
                    'v${device.appVersion}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Última atividade
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Última atividade: ${_formatLastActive(device.lastActiveAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Status
            if (!isActive) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.block,
                    size: 14,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Acesso revogado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.apple;
      case 'web':
        return Icons.language;
      case 'windows':
        return Icons.window;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.devices;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return const Color(0xFF3DDC84);
      case 'ios':
        return const Color(0xFF000000);
      case 'web':
        return const Color(0xFF4285F4);
      case 'windows':
        return const Color(0xFF0078D4);
      case 'macos':
        return const Color(0xFF000000);
      case 'linux':
        return const Color(0xFFFCC624);
      default:
        return PlantisColors.primary;
    }
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) return 'agora';
    if (difference.inHours < 1) return '${difference.inMinutes}m atrás';
    if (difference.inDays < 1) return '${difference.inHours}h atrás';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} sem atrás';

    return DateFormat('dd/MM/yyyy').format(lastActive);
  }
}
