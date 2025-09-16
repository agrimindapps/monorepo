import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/device_model.dart';
import '../providers/device_management_provider.dart';
import 'device_tile_widget.dart';

/// Widget que exibe a lista de dispositivos do usuário
/// Organizada em seções de dispositivos ativos e inativos
class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasDevices) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!provider.hasDevices) {
          return const Center(
            child: Text('Nenhum dispositivo encontrado'),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Seção de dispositivos ativos
              if (provider.activeDevices.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Dispositivos Ativos',
                  provider.activeDevices.length,
                  Icons.verified,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                ...provider.activeDevices.map(
                  (device) => _buildDeviceItem(context, device, provider),
                ),
              ],

              // Seção de dispositivos inativos
              if (provider.inactiveDevices.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  'Dispositivos Inativos',
                  provider.inactiveDevices.length,
                  Icons.block,
                  Colors.grey,
                ),
                const SizedBox(height: 8),
                ...provider.inactiveDevices.map(
                  (device) => _buildDeviceItem(context, device, provider),
                ),
              ],

              // Espaçamento final
              const SizedBox(height: 80),
            ],
          ),
        );
      },
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
              color: color.withOpacity(0.1),
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
    DeviceModel device,
    DeviceManagementProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DeviceTileWidget(
        device: device,
        isCurrentDevice: provider.currentDevice?.uuid == device.uuid,
        isBeingRevoked: provider.isDeviceBeingRevoked(device.uuid),
        onRevoke: device.isActive
          ? () => _showRevokeDialog(context, device, provider)
          : null,
        onTap: () => _showDeviceDetails(context, device),
      ),
    );
  }

  Future<void> _showRevokeDialog(
    BuildContext context,
    DeviceModel device,
    DeviceManagementProvider provider,
  ) async {
    // Previne revogar o dispositivo atual
    if (provider.currentDevice?.uuid == device.uuid) {
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
            Text('Deseja revogar o acesso do dispositivo:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
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

    if (confirmed == true) {
      final success = await provider.revokeDevice(
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
    showModalBottomSheet(
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
class _DeviceDetailsSheet extends StatelessWidget {
  final DeviceModel device;

  const _DeviceDetailsSheet({required this.device});

  @override
  Widget build(BuildContext context) {
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
              // Handle da sheet
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

              // Header do dispositivo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                            color: Color(int.parse(device.statusColorHex.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            device.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(int.parse(device.statusColorHex.replaceFirst('#', '0xFF'))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lista de detalhes
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection('Informações do Dispositivo', [
                      _buildDetailItem('Modelo', device.model),
                      _buildDetailItem('Fabricante', device.manufacturer),
                      _buildDetailItem('Plataforma', '${device.platform} ${device.systemVersion}'),
                      _buildDetailItem('Tipo', device.isPhysicalDevice ? 'Físico' : 'Emulador'),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Informações do App', [
                      _buildDetailItem('Versão', '${device.appVersion} (${device.buildNumber})'),
                      _buildDetailItem('UUID', device.uuid, isMonospace: true),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Atividade', [
                      _buildDetailItem(
                        'Primeiro Login',
                        DateFormat('dd/MM/yyyy HH:mm').format(device.firstLoginAt),
                      ),
                      _buildDetailItem(
                        'Última Atividade',
                        DateFormat('dd/MM/yyyy HH:mm').format(device.lastActiveAt),
                      ),
                      _buildDetailItem(
                        'Status',
                        device.isActive ? 'Ativo' : 'Revogado',
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Indicador se é o dispositivo atual
                    Consumer<DeviceManagementProvider>(
                      builder: (context, provider, child) {
                        if (provider.currentDevice?.uuid == device.uuid) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.smartphone, color: Colors.blue.shade600),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
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