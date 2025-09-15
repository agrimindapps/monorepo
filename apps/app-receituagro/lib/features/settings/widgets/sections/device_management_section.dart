import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../dialogs/device_management_dialog.dart';
import '../items/device_list_item.dart';

/// Device Management Section for Settings Page
/// 
/// Features:
/// - Shows current device with primary badge
/// - Lists up to 3 connected devices
/// - Limit exceeded dialog with revoke options
/// - Device validation and management
class DeviceManagementSection extends StatelessWidget {
  const DeviceManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<SettingsProvider, ReceitaAgroAuthProvider>(
      builder: (context, provider, authProvider, child) {
        final devices = provider.connectedDevices;
        final currentDevice = provider.currentDevice;
        final hasDeviceManagement = provider.isDeviceManagementEnabled;

        // Only show for authenticated users (not anonymous)
        if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
          return const SizedBox.shrink();
        }

        // Don't show section if device management is disabled
        if (!hasDeviceManagement) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: SettingsDesignTokens.sectionMargin,
          elevation: SettingsDesignTokens.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              _buildSectionHeader(context, theme, devices.length),
              
              // Current Device
              if (currentDevice != null)
                DeviceListItem(
                  device: currentDevice,
                  isPrimary: true,
                  onRevoke: null, // Can't revoke current device
                ),

              // Connected Devices
              ...devices.map((device) {
                if (device.uuid == currentDevice?.uuid) {
                  return const SizedBox.shrink();
                }
                
                return DeviceListItem(
                  device: device,
                  isPrimary: false,
                  onRevoke: () => _revokeDevice(context, provider, device),
                );
              }),

              // Device Limit Status
              _buildDeviceLimitStatus(context, theme, devices.length),

              // Manage Devices Button
              _buildManageDevicesButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  /// Section header with device count
  Widget _buildSectionHeader(BuildContext context, ThemeData theme, int deviceCount) {
    return Padding(
      padding: SettingsDesignTokens.sectionHeaderPadding,
      child: Row(
        children: [
          Icon(
            SettingsDesignTokens.deviceManagementIcon,
            size: SettingsDesignTokens.sectionIconSize,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispositivos Conectados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$deviceCount de 3 dispositivos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
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

  /// Manage devices button
  Widget _buildManageDevicesButton(BuildContext context, SettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _openDeviceManagementDialog(context, provider),
          icon: const Icon(Icons.devices, size: 18),
          label: const Text('Gerenciar Dispositivos'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  /// Revoke device with confirmation
  Future<void> _revokeDevice(BuildContext context, SettingsProvider provider, DeviceInfo device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Dispositivo'),
        content: Text(
          'Tem certeza que deseja revogar o acesso do dispositivo "${device.displayName}"?\n\n'
          'O usuário precisará fazer login novamente neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.revokeDevice(device.uuid);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dispositivo "${device.displayName}" revogado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao revogar dispositivo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Open device management dialog
  Future<void> _openDeviceManagementDialog(BuildContext context, SettingsProvider provider) async {
    await showDialog(
      context: context,
      builder: (context) => DeviceManagementDialog(provider: provider),
    );
  }
}