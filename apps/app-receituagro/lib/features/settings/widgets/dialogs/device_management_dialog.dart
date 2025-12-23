import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../items/device_list_item.dart';

/// Device Management Dialog
///
/// Features:
/// - Full list of connected devices
/// - Device details and management
/// - Revoke multiple devices at once
/// - Device limit information
///
/// Usa providers do core para consistência cross-app
class DeviceManagementDialog extends ConsumerWidget {
  final dynamic settingsData;

  const DeviceManagementDialog({
    super.key,
    required this.settingsData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Usa providers do core
    final currentDeviceAsync = ref.watch(currentDeviceProvider);
    final userDevicesAsync = ref.watch(userDevicesProvider);
    final deviceCount = ref.watch(deviceCountProvider);
    final maxDevices = ref.watch(maxDevicesProvider);

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
                    _buildDeviceLimitInfo(theme, deviceCount, maxDevices),
                    
                    const SizedBox(height: 20),
                    
                    // Current device section
                    currentDeviceAsync.when(
                      data: (currentDevice) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => _buildErrorWidget(theme, 'Erro ao carregar dispositivo atual'),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Other devices section
                    userDevicesAsync.when(
                      data: (devices) {
                        final currentDevice = currentDeviceAsync.value;
                        final otherDevices = devices
                            .where((d) => currentDevice == null || d.uuid != currentDevice.uuid)
                            .toList();
                        
                        if (otherDevices.isEmpty) {
                          return _buildNoOtherDevicesInfo(theme);
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outros Dispositivos',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...otherDevices.map((device) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: DeviceListItem(
                                device: device,
                                isPrimary: false,
                                onRevoke: () => _revokeDevice(context, ref, device),
                              ),
                            )),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => _buildErrorWidget(theme, 'Erro ao carregar dispositivos'),
                    ),
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

  Widget _buildErrorWidget(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOtherDevicesInfo(ThemeData theme) {
    return Container(
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
  Widget _buildDeviceLimitInfo(ThemeData theme, int deviceCount, int maxDevices) {
    final isUnlimited = maxDevices == -1;
    final isNearLimit = !isUnlimited && deviceCount >= maxDevices - 1;
    final isAtLimit = !isUnlimited && deviceCount >= maxDevices;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isUnlimited) {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.all_inclusive;
      statusText = 'Dispositivos ilimitados ($deviceCount conectados)';
    } else if (isAtLimit) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.warning;
      statusText = 'Limite atingido ($deviceCount/$maxDevices dispositivos)';
    } else if (isNearLimit) {
      statusColor = theme.colorScheme.tertiary;
      statusIcon = Icons.info_outline;
      statusText = 'Próximo do limite ($deviceCount/$maxDevices dispositivos)';
    } else {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Dentro do limite ($deviceCount/$maxDevices dispositivos)';
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
                      : isUnlimited
                          ? 'Você tem acesso ilimitado a dispositivos.'
                          : 'Você pode usar sua conta em até $maxDevices dispositivos diferentes.',
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
  Future<void> _revokeDevice(BuildContext context, WidgetRef ref, DeviceEntity device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Dispositivo'),
        content: Text(
          'Deseja revogar o acesso do dispositivo "${device.name.isNotEmpty ? device.name : device.model}"?\n\n'
          'O usuário precisará fazer login novamente neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final actions = ref.read(deviceActionsProvider);
      final success = await actions.revokeDevice(device.uuid);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Dispositivo revogado com sucesso'
                  : 'Erro ao revogar dispositivo',
            ),
            backgroundColor: success ? null : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
