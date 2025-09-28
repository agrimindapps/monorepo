import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../providers/vehicle_device_provider.dart';
import '../widgets/device_actions_dialog.dart';
import '../widgets/device_list_widget.dart';

/// Página principal de gerenciamento de dispositivos
class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
  }

  void _loadDevices() {
    final provider = context.read<VehicleDeviceProvider>();
    provider.loadUserDevices();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<VehicleDeviceProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              slivers: [
                // Header com informações gerais
                SliverToBoxAdapter(
                  child: _buildHeader(provider),
                ),
                
                // Lista de dispositivos
                _buildDevicesList(provider),
                
                // Footer com informações adicionais
                SliverToBoxAdapter(
                  child: _buildFooter(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(VehicleDeviceProvider provider) {
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
          _buildDeviceStats(provider),
        ],
      ),
    );
  }

  Widget _buildDeviceStats(VehicleDeviceProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Conectados',
            '${provider.activeDeviceCount}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${provider.devices.length}',
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(VehicleDeviceProvider provider) {
    if (provider.isLoading) {
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

    if (provider.hasError) {
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
                provider.errorMessage ?? 'Erro desconhecido',
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

    if (!provider.hasDevices) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.devices_other,
                size: 64,
                color: Colors.grey[300],
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
      devices: provider.devices,
      currentDeviceUuid: provider.currentDevice?.uuid,
      onDeviceAction: _handleDeviceAction,
    );
  }

  Widget _buildFooter(VehicleDeviceProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informações Importantes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
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
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<VehicleDeviceProvider>();
    await provider.refresh();
  }

  void _handleMenuAction(String action) {
    final provider = context.read<VehicleDeviceProvider>();
    
    switch (action) {
      case 'logout_all':
        _showRevokeAllDialog(provider);
        break;
      case 'info':
        _showInfoDialog();
        break;
    }
  }

  void _handleDeviceAction(String deviceUuid, String action) {
    final provider = context.read<VehicleDeviceProvider>();
    final device = provider.getDeviceByUuid(deviceUuid);
    
    if (device == null) return;
    
    showDialog(
      context: context,
      builder: (context) => DeviceActionsDialog(
        device: device,
        isCurrentDevice: provider.isCurrentDevice(deviceUuid),
        onAction: (actionType) => _executeDeviceAction(deviceUuid, actionType),
      ),
    );
  }

  Future<void> _executeDeviceAction(String deviceUuid, String action) async {
    final provider = context.read<VehicleDeviceProvider>();
    
    switch (action) {
      case 'revoke':
        final success = await provider.revokeDevice(deviceUuid);
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
        // Implementar renomeação se necessário
        break;
    }
  }

  void _showRevokeAllDialog(VehicleDeviceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar Outros Dispositivos'),
        content: const Text(
          'Isso irá desconectar todos os outros dispositivos, '
          'mantendo apenas este. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.revokeAllOtherDevices();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Outros dispositivos desconectados'),
                    backgroundColor: Colors.green,
                  ),
                );
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
    showDialog(
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
