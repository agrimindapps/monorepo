import 'package:core/core.dart'
    hide deviceManagementNotifierProvider, DeviceManagementState, Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/device_management_providers.dart';
import '../widgets/device_actions_widget.dart';
import '../widgets/device_list_widget.dart';
import '../widgets/device_statistics_widget.dart';

/// Página principal de gerenciamento de dispositivos
/// Interface principal para visualizar e gerenciar dispositivos no app-plantis
class DeviceManagementPage extends ConsumerStatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  ConsumerState<DeviceManagementPage> createState() =>
      _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceManagementAsync = ref.watch(deviceManagementNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Dispositivos'),
        elevation: 0,
        actions: [
          deviceManagementAsync.when(
            data: (deviceState) => PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Atualizar'),
                    dense: true,
                  ),
                ),
                if (deviceState.hasDevices && deviceState.activeDeviceCount > 1)
                  const PopupMenuItem(
                    value: 'revoke_all',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Revogar Outros Dispositivos'),
                      dense: true,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Ajuda'),
                    dense: true,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.devices), text: 'Dispositivos'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Estatísticas'),
          ],
        ),
      ),
      body: deviceManagementAsync.when(
        data: (deviceState) => Column(
          children: [
            _buildFeedbackMessages(deviceState),
            _buildGeneralStatus(deviceState),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDevicesTab(deviceState),
                  _buildStatisticsTab(deviceState),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar: $error')),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFeedbackMessages(DeviceManagementState deviceState) {
    if (deviceState.errorMessage != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                deviceState.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
              onPressed: () => ref
                  .read(deviceManagementNotifierProvider.notifier)
                  .clearError(),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    }

    if (deviceState.successMessage != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                deviceState.successMessage!,
                style: TextStyle(color: Colors.green.shade700, fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.green.shade600, size: 18),
              onPressed: () => ref
                  .read(deviceManagementNotifierProvider.notifier)
                  .clearSuccess(),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGeneralStatus(DeviceManagementState deviceState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: deviceState.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              deviceState.statusIcon,
              color: deviceState.statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceState.statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deviceState.deviceLimitText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (deviceState.hasReachedDeviceLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LIMITE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            )
          else if (deviceState.isNearDeviceLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'QUASE NO LIMITE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDevicesTab(DeviceManagementState deviceState) {
    if (!deviceState.hasDevices) {
      return _buildEmptyDevicesState();
    }

    return const Column(
      children: [
        DeviceActionsWidget(),

        SizedBox(height: 8),
        Expanded(child: DeviceListWidget()),
      ],
    );
  }

  Widget _buildStatisticsTab(DeviceManagementState deviceState) {
    return const DeviceStatisticsWidget();
  }

  Widget _buildEmptyDevicesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum dispositivo registrado',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Este é seu primeiro dispositivo.\nVocê pode adicionar até 3 dispositivos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _validateCurrentDevice(context),
              icon: const Icon(Icons.verified),
              label: const Text('Registrar Este Dispositivo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final deviceManagementAsync = ref.watch(deviceManagementNotifierProvider);

    return deviceManagementAsync.when(
      data: (deviceState) {
        if (!deviceState.canAddMoreDevices) return null;

        return FloatingActionButton.extended(
          onPressed: deviceState.isValidating
              ? null
              : () => _validateCurrentDevice(context),
          icon: deviceState.isValidating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(
            deviceState.isValidating ? 'Validando...' : 'Validar Dispositivo',
          ),
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'refresh':
        await ref.read(deviceManagementNotifierProvider.notifier).refresh();
        break;

      case 'revoke_all':
        await _showRevokeAllDialog(context);
        break;

      case 'help':
        _showHelpDialog(context);
        break;
    }
  }

  Future<void> _validateCurrentDevice(BuildContext context) async {
    final notifier = ref.read(deviceManagementNotifierProvider.notifier);

    final result = await notifier.validateCurrentDevice();

    if (result != null && !result.isValid) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Falha na validação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showRevokeAllDialog(BuildContext context) async {
    final deviceState = ref.read(deviceManagementNotifierProvider).valueOrNull;
    if (deviceState == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Outros Dispositivos'),
        content: Text(
          'Isso irá desconectar todos os outros dispositivos (${deviceState.activeDeviceCount - 1}), '
          'mantendo apenas este dispositivo ativo.\n\n'
          'Esta ação não pode ser desfeita.',
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

    if (confirmed == true && mounted) {
      await ref
          .read(deviceManagementNotifierProvider.notifier)
          .revokeAllOtherDevices(
            reason: 'Logout remoto via interface de gerenciamento',
          );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda - Gerenciamento de Dispositivos'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'O que são dispositivos registrados?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'São os aparelhos (celular, tablet, computador) onde você fez login no Plantis. '
                'Você pode ter até 3 dispositivos ativos simultaneamente.',
              ),
              SizedBox(height: 16),
              Text(
                'Por que revogar um dispositivo?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Quando perder ou trocar de aparelho\n'
                '• Para liberar espaço para um novo dispositivo\n'
                '• Por questões de segurança\n'
                '• Quando não usar mais um aparelho',
              ),
              SizedBox(height: 16),
              Text(
                'O que acontece ao revogar?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'O dispositivo revogado será desconectado automaticamente e precisará '
                'fazer login novamente para usar o Plantis.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
