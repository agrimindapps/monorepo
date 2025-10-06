import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'device_card_widget.dart';

/// Widget que exibe lista de dispositivos
class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({
    super.key,
    required this.devices,
    required this.onDeviceAction,
    this.currentDeviceUuid,
  });
  final List<DeviceEntity> devices;
  final String? currentDeviceUuid;
  final void Function(String deviceUuid, String action) onDeviceAction;

  @override
  Widget build(BuildContext context) {
    // Separar dispositivos ativos e inativos
    final activeDevices = devices.where((d) => d.isActive).toList();
    final inactiveDevices = devices.where((d) => !d.isActive).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // Primeiro mostrar header dos ativos
        if (index == 0 && activeDevices.isNotEmpty) {
          return _buildSectionHeader(
            context,
            'Dispositivos Ativos',
            activeDevices.length,
            Icons.check_circle,
            Colors.green,
          );
        }

        // Mostrar dispositivos ativos
        if (index > 0 && index <= activeDevices.length) {
          final deviceIndex = index - 1;
          final device = activeDevices[deviceIndex];
          return DeviceCardWidget(
            device: device,
            isCurrentDevice: device.uuid == currentDeviceUuid,
            onAction: (action) => onDeviceAction(device.uuid, action),
          );
        }

        // Header dos inativos (se houver)
        final activeSection =
            activeDevices.isNotEmpty ? activeDevices.length + 1 : 0;
        if (index == activeSection && inactiveDevices.isNotEmpty) {
          return _buildSectionHeader(
            context,
            'Dispositivos Inativos',
            inactiveDevices.length,
            Icons.block,
            Colors.red,
          );
        }

        // Mostrar dispositivos inativos
        if (index > activeSection && inactiveDevices.isNotEmpty) {
          final deviceIndex = index - activeSection - 1;
          if (deviceIndex < inactiveDevices.length) {
            final device = inactiveDevices[deviceIndex];
            return DeviceCardWidget(
              device: device,
              isCurrentDevice: device.uuid == currentDeviceUuid,
              onAction: (action) => onDeviceAction(device.uuid, action),
            );
          }
        }

        return const SizedBox.shrink();
      }, childCount: _calculateChildCount(activeDevices, inactiveDevices)),
    );
  }

  int _calculateChildCount(
    List<DeviceEntity> active,
    List<DeviceEntity> inactive,
  ) {
    int count = 0;

    // Dispositivos ativos + header (se houver)
    if (active.isNotEmpty) {
      count += active.length + 1;
    }

    // Dispositivos inativos + header (se houver)
    if (inactive.isNotEmpty) {
      count += inactive.length + 1;
    }

    return count;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
