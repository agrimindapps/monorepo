import 'package:core/core.dart' ;
import 'package:flutter/material.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../domain/extensions/vehicle_device_extension.dart';

/// Widget de card para exibir informações de um dispositivo
class DeviceCardWidget extends StatelessWidget {
  const DeviceCardWidget({
    super.key,
    required this.device,
    required this.onAction,
    this.isCurrentDevice = false,
  });
  final DeviceEntity device;
  final bool isCurrentDevice;
  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentDevice ? GasometerColors.primary : Colors.grey[200]!,
          width: isCurrentDevice ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAction('details'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildDeviceInfo(context),
                const SizedBox(height: 12),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildPlatformIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      device.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentDevice
                            ? GasometerColors.primary
                            : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentDevice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GasometerColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ESTE DISPOSITIVO',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${device.platform} ${device.systemVersion}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildStatusIndicator(context),
      ],
    );
  }

  Widget _buildPlatformIcon() {
    IconData iconData;
    Color iconColor;

    switch (device.platform.toLowerCase()) {
      case 'ios':
        iconData = Icons.phone_iphone;
        iconColor = Colors.grey[700]!;
        break;
      case 'android':
        iconData = Icons.android;
        iconColor = Colors.green;
        break;
      case 'web':
        iconData = Icons.web;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.device_unknown;
        iconColor = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 28),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!device.isActive) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = 'Inativo';
    } else {
      final diff = DateTime.now().difference(device.lastActiveAt);
      if (diff.inMinutes < 5) {
        statusColor = Colors.green;
        statusIcon = Icons.circle;
        statusText = 'Online';
      } else if (diff.inHours < 1) {
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = '${diff.inMinutes}min';
      } else if (diff.inDays < 1) {
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = '${diff.inHours}h';
      } else {
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
        statusText = '${diff.inDays}d';
      }
    }

    return Column(
      children: [
        Icon(statusIcon, color: statusColor, size: 16),
        const SizedBox(height: 2),
        Text(
          statusText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'Modelo', device.model, Icons.smartphone),
          const Divider(height: 16),
          _buildInfoRow(
            context,
            'Fabricante',
            device.manufacturer,
            Icons.business,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            context,
            'App Version',
            device.fullAppVersion,
            Icons.apps,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Primeiro acesso',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                dateFormat.format(device.firstLoginAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Última atividade',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                dateFormat.format(device.lastActiveAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (!isCurrentDevice && device.isActive)
          IconButton(
            onPressed: () => onAction('revoke'),
            icon: const Icon(Icons.block),
            color: Colors.red,
            tooltip: 'Desconectar dispositivo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }
}
