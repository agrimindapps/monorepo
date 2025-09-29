import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;

import '../../../../core/providers/auth_provider.dart';
import '../../presentation/providers/settings_provider.dart';
import '../dialogs/device_management_dialog.dart';

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

    return provider_lib.Consumer2<SettingsProvider, ReceitaAgroAuthProvider>(
      builder: (context, provider, authProvider, child) {
        final devices = provider.connectedDevicesInfo;
        final currentDevice = provider.currentDeviceInfo;
        final hasDeviceManagement = provider.isDeviceManagementEnabled;

        // Only show for authenticated users (not anonymous)
        if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
          return const SizedBox.shrink();
        }

        // Don't show section if device management is disabled
        if (!hasDeviceManagement) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Dispositivos Conectados',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: (theme.textTheme.titleLarge?.fontSize ?? 22) + 2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Modern Card with elevated design
            Card(
              margin: EdgeInsets.zero,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Main Device Status with Icon Container
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
                      'Recursos em desenvolvimento',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDeviceManagementDialog(context, provider),
                  ),

                  // Device Limit Status (if needed)
                  if (devices.length >= 3)
                    _buildDeviceLimitStatus(context, theme, devices.length),

                  // Action Buttons Row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openDeviceManagementDialog(context, provider),
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
      },
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



  /// Open device management dialog
  Future<void> _openDeviceManagementDialog(BuildContext context, SettingsProvider provider) async {
    await showDialog<void>(
      context: context,
      builder: (context) => DeviceManagementDialog(provider: provider),
    );
  }
}