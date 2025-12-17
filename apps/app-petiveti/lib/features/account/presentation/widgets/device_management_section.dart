import 'package:core/core.dart'
    hide Column, DeviceManagementState, deviceManagementProvider;
import 'package:flutter/material.dart';

import '../../../device_management/presentation/providers/device_management_notifier.dart';
import '../utils/widget_utils.dart';
import 'device_management_dialog.dart';

/// Seção de gerenciamento de dispositivos na página de perfil
/// Mostra resumo e permite navegação para página completa
class DeviceManagementSection extends ConsumerWidget {
  const DeviceManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceManagementAsync = ref.watch(deviceManagementProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, 'Dispositivos Conectados'),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: deviceManagementAsync.when(
            data: (DeviceManagementState deviceState) =>
                _buildDeviceContent(context, deviceState),
            loading: () => _buildLoadingState(),
            error: (Object error, StackTrace? stack) =>
                _buildErrorState(context, error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceContent(
    BuildContext context,
    DeviceManagementState deviceState,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: deviceState.statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              deviceState.statusIcon,
              color: deviceState.statusColor,
              size: 20,
            ),
          ),
          title: Text(
            deviceState.deviceSummary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            deviceState.statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeviceDialog(context),
        ),
        if (deviceState.hasDevices) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeviceDialog(context),
                    icon: const Icon(Icons.devices, size: 18),
                    label: const Text('Gerenciar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: deviceState.activeDeviceCount > 1
                        ? () => _showRevokeAllDialog(context, deviceState)
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Desconectar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Carregando dispositivos...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'Erro ao carregar dispositivos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showDeviceDialog(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void _showDeviceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const DeviceManagementDialog(),
    );
  }

  Future<void> _showRevokeAllDialog(
    BuildContext context,
    DeviceManagementState state,
  ) async {
    // We can reuse the dialog logic or just open the dialog
    // Opening the dialog is simpler and consistent
    _showDeviceDialog(context);
  }
}
