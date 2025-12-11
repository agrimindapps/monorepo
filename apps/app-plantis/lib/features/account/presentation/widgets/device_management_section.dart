import 'package:core/core.dart' hide Column, DeviceManagementState;
import 'package:flutter/material.dart';

import '../../../../core/providers/device_management_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../utils/widget_utils.dart';

/// Seção de gerenciamento de dispositivos na página de perfil
/// Mostra resumo e permite navegação para página completa
class DeviceManagementSection extends ConsumerWidget {
  const DeviceManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceManagementAsync = ref.watch(deviceManagementNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, 'Dispositivos Conectados'),
        const SizedBox(height: 16),
        PlantisCard(
          child: deviceManagementAsync.when(
            data: (deviceState) => _buildDeviceContent(context, deviceState),
            loading: () => _buildLoadingState(),
            error: (error, stack) =>
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
          onTap: () => context.push(AppRouter.deviceManagement),
        ),
        if (deviceState.hasDevices) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRouter.deviceManagement),
                    icon: const Icon(Icons.devices, size: 18),
                    label: const Text('Gerenciar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: deviceState.activeDeviceCount > 1
                        ? () => _showRevokeAllDialog(context)
                        : null,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Revogar Outros'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.red,
                    ),
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
            onPressed: () => context.push(AppRouter.deviceManagement),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRevokeAllDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Revogar Todos os Outros Dispositivos?'),
          ],
        ),
        content: const Text(
          'Esta ação irá desconectar todos os outros dispositivos conectados à sua conta, '
          'exceto este dispositivo atual. Você precisará fazer login novamente neles.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revogar Todos'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.push(AppRouter.deviceManagement);
    }
  }
}
