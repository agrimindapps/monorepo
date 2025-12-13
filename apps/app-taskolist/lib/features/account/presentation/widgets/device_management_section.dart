import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_providers.dart';

/// Seção de gerenciamento de dispositivos na página de perfil
/// Permite visualizar e revogar dispositivos conectados
class DeviceManagementSection extends ConsumerWidget {
  const DeviceManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDevicesAsync = ref.watch(userDevicesProvider);
    final currentDevice = ref.watch(currentDeviceProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Dispositivos Conectados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: userDevicesAsync.when(
            data: (devices) => _buildDeviceContent(
                  context,
                  ref,
                  devices,
                  currentDevice,
                ),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context, error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceContent(
    BuildContext context,
    WidgetRef ref,
    List<DeviceEntity> devices,
    DeviceEntity? currentDevice,
  ) {
    final theme = Theme.of(context);
    final activeDeviceCount = devices.where((d) => d.isActive).length;
    final totalDeviceCount = devices.length;

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(activeDeviceCount).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(activeDeviceCount),
              color: _getStatusColor(activeDeviceCount),
              size: 20,
            ),
          ),
          title: Text(
            _getDeviceSummary(activeDeviceCount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _getStatusText(activeDeviceCount, totalDeviceCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: () => _showDeviceManagementDialog(context, ref, devices, currentDevice),
        ),
        if (activeDeviceCount > 0) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeviceManagementDialog(context, ref, devices, currentDevice),
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
                    onPressed: activeDeviceCount > 1
                        ? () => _showRevokeAllDialog(context, ref)
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
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
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
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int count) {
    if (count == 0) return Colors.grey;
    if (count <= 3) return AppColors.success;
    return AppColors.warning;
  }

  IconData _getStatusIcon(int count) {
    if (count == 0) return Icons.devices_other;
    if (count <= 3) return Icons.verified;
    return Icons.warning;
  }

  String _getDeviceSummary(int count) {
    if (count == 0) return 'Nenhum dispositivo';
    if (count == 1) return '1 dispositivo ativo';
    return '$count dispositivos ativos';
  }

  String _getStatusText(int active, int total) {
    if (total == 0) return 'Nenhum dispositivo registrado';
    if (active == total) return 'Todos ativos';
    return '$active de $total ativos';
  }

  void _showDeviceManagementDialog(
    BuildContext context,
    WidgetRef ref,
    List<DeviceEntity> devices,
    DeviceEntity? currentDevice,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Dispositivos Conectados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: devices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices_other, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum dispositivo registrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: devices.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isCurrentDevice = device.id == currentDevice?.id;

                        return Card(
                          elevation: isCurrentDevice ? 2 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isCurrentDevice
                                ? const BorderSide(color: AppColors.primaryColor, width: 2)
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: device.isActive
                                  ? AppColors.success.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              child: Icon(
                                _getDeviceIcon(device.platform),
                                color: device.isActive ? AppColors.success : Colors.grey,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    device.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (isCurrentDevice)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ATUAL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${device.platform} • ${device.model}'),
                                const SizedBox(height: 2),
                                Text(
                                  'Último acesso: ${_formatDate(device.lastActiveAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: !isCurrentDevice && device.isActive
                                ? IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showRevokeDeviceDialog(context, ref, device.uuid, device.name);
                                    },
                                    icon: const Icon(Icons.logout, color: AppColors.error),
                                    tooltip: 'Desconectar',
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      case 'web':
        return Icons.web;
      case 'macos':
      case 'windows':
      case 'linux':
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m atrás';
    if (difference.inHours < 24) return '${difference.inHours}h atrás';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showRevokeDeviceDialog(
    BuildContext context,
    WidgetRef ref,
    String deviceUuid,
    String deviceName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(child: Text('Desconectar Dispositivo?')),
          ],
        ),
        content: Text(
          'Tem certeza que deseja desconectar "$deviceName"?\n\n'
          'Será necessário fazer login novamente neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      final repository = ref.read(deviceRepositoryProvider);
      final result = await repository.revokeDevice(
        userId: user.id,
        deviceUuid: deviceUuid,
      );

      if (context.mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao desconectar: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            // Força refresh da lista
            ref.invalidate(userDevicesProvider);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dispositivo desconectado com sucesso'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _showRevokeAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(child: Text('Revogar Todos?')),
          ],
        ),
        content: const Text(
          'Esta ação irá desconectar todos os outros dispositivos conectados à sua conta, '
          'exceto este dispositivo atual.\n\n'
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revogar Todos'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final user = ref.read(authProvider).value;
      final currentDevice = ref.read(currentDeviceProvider).value;
      
      if (user == null || currentDevice == null) return;

      final repository = ref.read(deviceRepositoryProvider);
      final result = await repository.revokeAllOtherDevices(
        userId: user.id,
        currentDeviceUuid: currentDevice.uuid,
      );

      if (context.mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao revogar dispositivos: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            // Força refresh da lista
            ref.invalidate(userDevicesProvider);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dispositivos desconectados com sucesso'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      }
    }
  }
}
