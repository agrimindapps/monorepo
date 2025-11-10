import 'package:core/core.dart' hide Column, deviceManagementNotifierProvider, DeviceManagementState;
import 'package:flutter/material.dart';

import '../../../../core/providers/device_management_providers.dart';

/// Widget de ações rápidas para gerenciamento de dispositivos
/// Fornece acesso rápido às funcionalidades principais
class DeviceActionsWidget extends ConsumerWidget {
  const DeviceActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceManagementAsync = ref.watch(deviceManagementNotifierProvider);

    return deviceManagementAsync.when(
      data: (deviceState) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    ref: ref,
                    title: 'Validar Dispositivo',
                    subtitle: 'Registrar este aparelho',
                    icon: Icons.verified,
                    color: Colors.blue,
                    enabled: !deviceState.isValidating && deviceState.canAddMoreDevices,
                    loading: deviceState.isValidating,
                    onTap: () => _validateCurrentDevice(context, ref),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    ref: ref,
                    title: 'Atualizar',
                    subtitle: 'Sincronizar dados',
                    icon: Icons.refresh,
                    color: Colors.green,
                    enabled: true,
                    loading: false,
                    onTap: () => ref.read(deviceManagementNotifierProvider.notifier).refresh(),
                  ),
                ),
              ],
            ),
            if (deviceState.hasDevices && deviceState.activeDeviceCount > 1) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      ref: ref,
                      title: 'Logout Remoto',
                      subtitle: 'Desconectar outros dispositivos',
                      icon: Icons.logout,
                      color: Colors.red,
                      enabled: !deviceState.isRevoking,
                      loading: deviceState.isRevoking,
                      onTap: () => _showRevokeAllDialog(context, ref, deviceState),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      context: context,
                      title: '${deviceState.activeDeviceCount}/3',
                      subtitle: 'Dispositivos ativos',
                      icon: Icons.devices,
                      color: deviceState.hasReachedDeviceLimit ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            if (deviceState.hasReachedDeviceLimit) ...[
              const SizedBox(height: 8),
              _buildLimitWarning(context),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
    bool loading = false,
  }) {
    return Card(
      elevation: enabled ? 2 : 1,
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      enabled
                          ? color.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    loading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                        : Icon(
                          icon,
                          color: enabled ? color : Colors.grey,
                          size: 24,
                        ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      enabled
                          ? Theme.of(context).textTheme.titleMedium?.color
                          : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      enabled
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitWarning(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limite de dispositivos atingido',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Revogue um dispositivo inativo para adicionar um novo.',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateCurrentDevice(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final notifier = ref.read(deviceManagementNotifierProvider.notifier);
    final result = await notifier.validateCurrentDevice();

    if (result != null && !result.isValid && context.mounted) {
      String message = result.message ?? 'Falha na validação';

      if (result.status.name == 'exceeded') {
        message =
            'Limite de dispositivos atingido. Revogue um dispositivo inativo primeiro.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action:
              result.status.name == 'exceeded'
                  ? SnackBarAction(
                    label: 'Ver Dispositivos',
                    textColor: Colors.white,
                    onPressed: () {
                    },
                  )
                  : null,
        ),
      );
    }
  }

  Future<void> _showRevokeAllDialog(
    BuildContext context,
    WidgetRef ref,
    DeviceManagementState deviceState,
  ) async {
    final otherDevicesCount = deviceState.activeDeviceCount - 1;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Remoto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta ação irá desconectar todos os outros dispositivos '
              '($otherDevicesCount ${otherDevicesCount == 1 ? 'dispositivo' : 'dispositivos'}), '
              'mantendo apenas este ativo.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Os dispositivos desconectados precisarão fazer login novamente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            child: const Text('Desconectar Outros'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await ref.read(deviceManagementNotifierProvider.notifier).revokeAllOtherDevices(
            reason: 'Logout remoto via ações rápidas',
          );

      if (result && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outros dispositivos desconectados com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
