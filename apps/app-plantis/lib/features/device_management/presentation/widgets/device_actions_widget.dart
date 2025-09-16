import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/device_management_provider.dart';

/// Widget de ações rápidas para gerenciamento de dispositivos
/// Fornece acesso rápido às funcionalidades principais
class DeviceActionsWidget extends StatelessWidget {
  const DeviceActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManagementProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Primeira linha de ações
              Row(
                children: [
                  // Validar dispositivo atual
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Validar Dispositivo',
                      subtitle: 'Registrar este aparelho',
                      icon: Icons.verified,
                      color: Colors.blue,
                      enabled: !provider.isValidating && provider.canAddMoreDevices,
                      loading: provider.isValidating,
                      onTap: () => _validateCurrentDevice(context, provider),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Atualizar lista
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Atualizar',
                      subtitle: 'Sincronizar dados',
                      icon: Icons.refresh,
                      color: Colors.green,
                      enabled: !provider.isLoading,
                      loading: provider.isLoading,
                      onTap: () => provider.refresh(),
                    ),
                  ),
                ],
              ),

              // Segunda linha de ações (se aplicável)
              if (provider.hasDevices && provider.activeDeviceCount > 1) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Revogar outros dispositivos
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        title: 'Logout Remoto',
                        subtitle: 'Desconectar outros dispositivos',
                        icon: Icons.logout,
                        color: Colors.red,
                        enabled: !provider.isRevoking,
                        loading: provider.isRevoking,
                        onTap: () => _showRevokeAllDialog(context, provider),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Espaço para ação futura ou informação
                    Expanded(
                      child: _buildInfoCard(
                        context: context,
                        title: '${provider.activeDeviceCount}/3',
                        subtitle: 'Dispositivos ativos',
                        icon: Icons.devices,
                        color: provider.hasReachedDeviceLimit ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],

              // Aviso de limite se necessário
              if (provider.hasReachedDeviceLimit) ...[
                const SizedBox(height: 8),
                _buildLimitWarning(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
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
                  color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: loading
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
                  color: enabled
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
                  color: enabled
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
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
          Icon(
            Icons.warning_amber,
            color: Colors.orange.shade600,
            size: 20,
          ),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade600,
                  ),
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
    DeviceManagementProvider provider,
  ) async {
    final result = await provider.validateCurrentDevice();

    if (result != null && !result.isValid && context.mounted) {
      String message = result.message ?? 'Falha na validação';

      if (result.status.name == 'exceeded') {
        message = 'Limite de dispositivos atingido. Revogue um dispositivo inativo primeiro.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: result.status.name == 'exceeded'
              ? SnackBarAction(
                  label: 'Ver Dispositivos',
                  textColor: Colors.white,
                  onPressed: () {
                    // O usuário já está na tela de dispositivos
                  },
                )
              : null,
        ),
      );
    }
  }

  Future<void> _showRevokeAllDialog(
    BuildContext context,
    DeviceManagementProvider provider,
  ) async {
    final otherDevicesCount = provider.activeDeviceCount - 1;

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

    if (confirmed == true) {
      final result = await provider.revokeAllOtherDevices(
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