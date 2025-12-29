import 'package:core/core.dart' show ConsumerStatefulWidget, ConsumerState, WidgetRef;
import 'package:flutter/material.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../providers/vehicle_device_notifier.dart';
import '../widgets/device_actions_dialog.dart';
import '../widgets/device_list_widget.dart';

/// Página principal de gerenciamento de dispositivos
class DeviceManagementPage extends ConsumerStatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  ConsumerState<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
  }

  void _loadDevices() {
    ref.read(vehicleDeviceProvider.notifier).loadUserDevices();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleDeviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Conectados'),
        backgroundColor: GasometerColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Atualizar',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout_all',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Desconectar Outros'),
                  subtitle: Text('Remove acesso de outros dispositivos'),
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Sobre'),
                  subtitle: Text('Informações sobre dispositivos'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(state),
            ),
            _buildDevicesList(state),
            SliverToBoxAdapter(
              child: _buildFooter(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(VehicleDeviceState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GasometerColors.primary.withValues(alpha: 0.1),
            GasometerColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GasometerColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.devices,
                color: GasometerColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Meus Dispositivos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: GasometerColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeviceStats(state),
        ],
      ),
    );
  }

  Widget _buildDeviceStats(VehicleDeviceState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Conectados',
            '${state.activeDeviceCount}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${state.devices.length}',
            Icons.devices_other,
            GasometerColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Limite',
            '3',
            Icons.security,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(VehicleDeviceState state) {
    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando dispositivos...'),
            ],
          ),
        ),
      );
    }

    if (state.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dispositivos',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Erro desconhecido',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _handleRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GasometerColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasDevices) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.devices_other,
                size: 64,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum dispositivo encontrado',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Faça login em outros dispositivos para vê-los aqui',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return DeviceListWidget(
      devices: state.devices,
      currentDeviceUuid: state.currentDevice?.uuid,
      onDeviceAction: _handleDeviceAction,
    );
  }

  Widget _buildFooter(VehicleDeviceState state) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informações Importantes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Você pode conectar até 3 dispositivos simultâneos\n'
            '• Dispositivos inativos há 30 dias são automaticamente removidos\n'
            '• Use "Desconectar Outros" para maior segurança\n'
            '• Seus dados são sincronizados entre todos os dispositivos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await ref.read(vehicleDeviceProvider.notifier).refresh();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'logout_all':
        _showRevokeAllDialog();
        break;
      case 'info':
        _showInfoDialog();
        break;
    }
  }

  void _handleDeviceAction(String deviceUuid, String action) {
    final notifier = ref.read(vehicleDeviceProvider.notifier);
    final device = notifier.getDeviceByUuid(deviceUuid);

    if (device == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => DeviceActionsDialog(
        device: device,
        isCurrentDevice: notifier.isCurrentDevice(deviceUuid),
        onAction: (actionType) => _executeDeviceAction(deviceUuid, actionType),
      ),
    );
  }

  Future<void> _executeDeviceAction(String deviceUuid, String action) async {
    final notifier = ref.read(vehicleDeviceProvider.notifier);

    switch (action) {
      case 'revoke':
        final success = await notifier.revokeDevice(deviceUuid);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispositivo desconectado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
        break;
      case 'rename':
        break;
    }
  }

  void _showRevokeAllDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desconectar Outros Dispositivos'),
        content: const Text(
          'Isso irá desconectar todos os outros dispositivos, '
          'mantendo apenas este. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final notifier = ref.read(vehicleDeviceProvider.notifier);
              final success = await notifier.revokeAllOtherDevices();
              if (success && mounted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Outros dispositivos desconectados'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerenciamento de Dispositivos'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como funciona:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Cada vez que você faz login, o dispositivo é registrado\n'
                '• Máximo de 3 dispositivos ativos por conta\n'
                '• Dispositivos são automaticamente limpos após 30 dias de inatividade\n'
                '• Você pode revogar o acesso de qualquer dispositivo a qualquer momento',
              ),
              SizedBox(height: 16),
              Text(
                'Segurança:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Use "Desconectar Outros" se suspeitar de acesso não autorizado\n'
                '• Monitore regularmente os dispositivos conectados\n'
                '• Cada dispositivo é identificado por nome, modelo e sistema operacional',
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
