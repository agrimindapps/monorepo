import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/device_identity_service.dart';
import '../items/device_list_item.dart';

/// Device Management Dialog
///
/// Features:
/// - Full list of connected devices
/// - Device details and management
/// - Revoke multiple devices at once
/// - Device limit information
class DeviceManagementDialog extends ConsumerWidget {
  final dynamic settingsData;

  const DeviceManagementDialog({
    super.key,
    required this.settingsData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final devices = (settingsData?.connectedDevicesInfo is List)
        ? (settingsData.connectedDevicesInfo as List<dynamic>)
            .whereType<DeviceInfo>()
            .toList()
        : <DeviceInfo>[];
    final currentDevice = settingsData?.currentDeviceInfo as DeviceInfo?;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeviceLimitInfo(theme, devices.length),
                    
                    const SizedBox(height: 20),
                    if (currentDevice != null) ...[
                      Text(
                        'Dispositivo Atual',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DeviceListItem(
                        device: currentDevice,
                        isPrimary: true,
                        onRevoke: null,
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (devices.isNotEmpty && devices.length > 1) ...[
                      Text(
                        'Outros Dispositivos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...devices.where((device) => device.uuid != currentDevice?.uuid).map((device) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DeviceListItem(
                            device: device,
                            isPrimary: false,
                            onRevoke: () => _revokeDevice(context, ref, device),
                          ),
                        );
                      }),
                    ],
                    if (devices.length <= 1) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Nenhum outro dispositivo conectado. Você pode usar sua conta em até 3 dispositivos simultaneamente.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  /// Dialog header
  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gerenciar Dispositivos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Device limit information
  Widget _buildDeviceLimitInfo(ThemeData theme, dynamic deviceCountDynamic) {
    final int deviceCount = (deviceCountDynamic is int) ? deviceCountDynamic : 0;
    final isNearLimit = deviceCount >= 2;
    final isAtLimit = deviceCount >= 3;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isAtLimit) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.warning;
      statusText = 'Limite atingido ($deviceCount/3 dispositivos)';
    } else if (isNearLimit) {
      statusColor = theme.colorScheme.tertiary;
      statusIcon = Icons.info_outline;
      statusText = 'Próximo do limite ($deviceCount/3 dispositivos)';
    } else {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Dentro do limite ($deviceCount/3 dispositivos)';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAtLimit
                      ? 'Revogue um dispositivo para adicionar outro.'
                      : 'Você pode usar sua conta em até 3 dispositivos diferentes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog actions
  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Revoke device with confirmation
  /// NOTE: Device management is currently disabled - feature in development
  Future<void> _revokeDevice(BuildContext context, WidgetRef ref, DeviceInfo device) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recurso em Desenvolvimento'),
        content: const Text(
          'O gerenciamento de dispositivos está sendo desenvolvido.\n\n'
          'Esta funcionalidade estará disponível em breve.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
