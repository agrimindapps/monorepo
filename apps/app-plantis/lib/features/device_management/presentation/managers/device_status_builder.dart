import 'package:flutter/material.dart';

import '../../data/models/device_model.dart';
import '../../presentation/providers/device_management_notifier.dart';

/// Builds status UI for device management
/// Handles device status display and statistics
class DeviceStatusBuilder {
  /// Builds general status card
  static Widget buildGeneralStatus(
    DeviceManagementState deviceState,
    BuildContext context,
  ) {
    if (!deviceState.isCurrentDeviceIdentified) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dispositivo Atual',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _buildDeviceStatus(deviceState.currentDevice!),
            ],
          ),
          const SizedBox(height: 12),
          _buildDeviceInfo(deviceState.currentDevice!),
          const SizedBox(height: 12),
          _buildDeviceStats(deviceState),
        ],
      ),
    );
  }

  static Widget _buildDeviceStatus(DeviceModel device) {
    final isActive = device.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
        ),
      ),
    );
  }

  static Widget _buildDeviceInfo(DeviceModel device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${device.uuid}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistema: ${device.platform} ${device.systemVersion}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  static Widget _buildDeviceStats(DeviceManagementState deviceState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          'Dispositivos Ativos',
          '${deviceState.activeDeviceCount}/3',
          Colors.blue,
        ),
        _buildStatItem(
          'Dispositivos Totais',
          deviceState.totalDeviceCount.toString(),
          Colors.purple,
        ),
      ],
    );
  }

  static Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Gets status text for a device
  static String getStatusText(DeviceModel device) {
    if (!device.isActive) return 'Inativo';
    return 'Ativo';
  }

  /// Gets status icon for a device
  static IconData getStatusIcon(DeviceModel device) {
    return device.isActive ? Icons.check_circle : Icons.cancel;
  }

  /// Gets device limit text
  static String getDeviceLimitText(int activeCount, int limit) {
    final remaining = limit - activeCount;
    if (remaining <= 0) return 'Limite atingido';
    if (remaining == 1) return 'Mais 1 dispositivo permitido';
    return 'Mais $remaining dispositivos permitidos';
  }
}
