import 'package:core/core.dart'
    hide DeviceManagementState, Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/device_management_providers.dart';
import '../../data/models/device_model.dart';
import 'device_tile_widget.dart';

/// Widget que exibe a lista de dispositivos do usuário
/// Organizada em seções de dispositivos ativos e inativos
class DeviceListWidget extends ConsumerWidget {
  const DeviceListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceManagementAsync = ref.watch(deviceManagementNotifierProvider);

    return deviceManagementAsync.when(
      data: (deviceState) {
        if (!deviceState.hasDevices) {
          return const Center(child: Text('Nenhum dispositivo encontrado'));
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(deviceManagementNotifierProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (deviceState.activeDevices.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Dispositivos Ativos',
                  deviceState.activeDevices.length,
                  Icons.verified,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                ...deviceState.activeDevices.map(
                  (device) =>
                      _buildDeviceItem(context, ref, device, deviceState),
                ),
              ],
              if (deviceState.inactiveDevices.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  'Dispositivos Inativos',
                  deviceState.inactiveDevices.length,
                  Icons.block,
                  Colors.grey,
                ),
                const SizedBox(height: 8),
                ...deviceState.inactiveDevices.map(
                  (device) =>
                      _buildDeviceItem(context, ref, device, deviceState),
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          if (title.contains('Ativos'))
            Text(
              'Limite: 3',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    WidgetRef ref,
    DeviceModel device,
    DeviceManagementState deviceState,
  ) {
    final isBeingRevoked =
        deviceState.isRevoking && deviceState.revokingDeviceUuid == device.uuid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DeviceTileWidget(
        device: device,
        isCurrentDevice: deviceState.currentDevice?.uuid == device.uuid,
        isBeingRevoked: isBeingRevoked,
        onRevoke: device.isActive
            ? () => _showRevokeDialog(context, ref, device, deviceState)
            : null,
        onTap: () => _showDeviceDetails(context, device),
      ),
    );
  }

  Future<void> _showRevokeDialog(
    BuildContext context,
    WidgetRef ref,
    DeviceModel device,
    DeviceManagementState deviceState,
  ) async {
    if (deviceState.currentDevice?.uuid == device.uuid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não é possível revogar o dispositivo atual'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Dispositivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deseja revogar o acesso do dispositivo:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Text(
                    device.platformIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          device.model,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Este dispositivo será desconectado imediatamente e '
              'precisará fazer login novamente.',
              style: TextStyle(fontSize: 14),
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
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(deviceManagementNotifierProvider.notifier)
          .revokeDevice(
            device.uuid,
            reason: 'Revogado manualmente via interface',
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dispositivo ${device.name} foi revogado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showDeviceDetails(BuildContext context, DeviceModel device) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DeviceDetailsSheet(device: device),
    );
  }
}

/// Sheet de detalhes do dispositivo
class _DeviceDetailsSheet extends ConsumerWidget {
  final DeviceModel device;

  const _DeviceDetailsSheet({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      device.platformIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                device.statusColorHex.replaceFirst('#', '0xFF'),
                              ),
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            device.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                int.parse(
                                  device.statusColorHex.replaceFirst(
                                    '#',
                                    '0xFF',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection('Informações do Dispositivo', [
                      _buildDetailItem('Modelo', device.model),
                      _buildDetailItem('Fabricante', device.manufacturer),
                      _buildDetailItem(
                        'Plataforma',
                        '${device.platform} ${device.systemVersion}',
                      ),
                      _buildDetailItem(
                        'Tipo',
                        device.isPhysicalDevice ? 'Físico' : 'Emulador',
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Informações do App', [
                      _buildDetailItem(
                        'Versão',
                        '${device.appVersion} (${device.buildNumber})',
                      ),
                      _buildDetailItem('UUID', device.uuid, isMonospace: true),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Atividade', [
                      _buildDetailItem(
                        'Primeiro Login',
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(device.firstLoginAt),
                      ),
                      _buildDetailItem(
                        'Última Atividade',
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(device.lastActiveAt),
                      ),
                      _buildDetailItem(
                        'Status',
                        device.isActive ? 'Ativo' : 'Revogado',
                      ),
                    ]),

                    const SizedBox(height: 24),
                    ref
                        .watch(deviceManagementNotifierProvider)
                        .when(
                          data: (deviceState) {
                            if (deviceState.currentDevice?.uuid ==
                                device.uuid) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.smartphone,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dispositivo Atual',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Este é o dispositivo que você está usando agora',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    bool isMonospace = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: isMonospace ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
