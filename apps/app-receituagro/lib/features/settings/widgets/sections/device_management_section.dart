import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/device_identity_service.dart';
import '../../presentation/providers/settings_notifier.dart';

/// Device Management Section for Settings Page
///
/// Features:
/// - Shows current device with primary badge
/// - Lists up to 3 connected devices
/// - Limit exceeded dialog with revoke options
/// - Device validation and management
class DeviceManagementSection extends ConsumerWidget {
  const DeviceManagementSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return settingsAsync.when(
      data: (settingsState) {
        final devices = settingsState.connectedDevicesInfo;
        final currentDevice = settingsState.currentDeviceInfo;
        final hasDeviceManagement = ref.read(settingsNotifierProvider.notifier).isDeviceManagementEnabled;
        if (settingsState.currentUserId.isEmpty) {
          return const SizedBox.shrink();
        }
        if (!hasDeviceManagement) {
          return const SizedBox.shrink();
        }

        return _buildContent(context, theme, ref, settingsState, devices, currentDevice);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    SettingsState settingsState,
    List<DeviceInfo> devices,
    DeviceInfo? currentDevice,
  ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispositivos Conectados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: (theme.textTheme.titleLarge?.fontSize ?? 22) + 2,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.devices_other,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  currentDevice?.displayName ?? 'Nenhum dispositivo registrado',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  devices.isEmpty
                      ? 'Nenhum dispositivo conectado'
                      : '${devices.length} ${devices.length == 1 ? 'dispositivo' : 'dispositivos'} conectado${devices.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openDeviceManagementDialog(context, ref),
              ),
              if (devices.length >= 3)
                _buildDeviceLimitStatus(context, theme, devices.length),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openDeviceManagementDialog(context, ref),
                    icon: const Icon(Icons.devices, size: 18),
                    label: const Text('Gerenciar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Open device management dialog
  Future<void> _openDeviceManagementDialog(BuildContext context, WidgetRef ref) async {
    final Widget? dialog = await Future.microtask(() {
      return null;
    });

    if (context.mounted && dialog != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => dialog,
      );
    }
  }

  /// Device limit status indicator
  Widget _buildDeviceLimitStatus(BuildContext context, ThemeData theme, int deviceCount) {
    if (deviceCount <= 2) {
      return const SizedBox.shrink();
    }

    final isLimitExceeded = deviceCount >= 3;
    final statusColor = isLimitExceeded
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLimitExceeded ? Icons.warning : Icons.info_outline,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLimitExceeded
                  ? 'Limite de dispositivos atingido. Revogue um dispositivo para adicionar outro.'
                  : 'Próximo do limite de dispositivos (3 máximo).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}