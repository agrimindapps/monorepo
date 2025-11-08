import 'package:core/core.dart' show DeviceEntity;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../../../../core/theme/gasometer_colors.dart';
import '../../domain/extensions/vehicle_device_extension.dart';

/// Diálogo com ações para um dispositivo específico
class DeviceActionsDialog extends StatelessWidget {
  const DeviceActionsDialog({
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
    return AlertDialog(
      title: Row(
        children: [
          _buildPlatformIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${device.platform} ${device.systemVersion}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeviceDetails(context),
            if (isCurrentDevice)
              _buildCurrentDeviceNotice(context)
            else
              _buildActionButtons(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildDeviceDetails(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildDetailRow('Status', _getStatusText(), _getStatusColor()),
          const Divider(height: 20),
          _buildDetailRow('Modelo', device.model, Colors.black87),
          const Divider(height: 20),
          _buildDetailRow('Fabricante', device.manufacturer, Colors.black87),
          const Divider(height: 20),
          _buildDetailRow(
            'Versão do App',
            device.fullAppVersion,
            Colors.black87,
          ),
          const Divider(height: 20),
          _buildDetailRow(
            'Primeiro Acesso',
            dateFormat.format(device.firstLoginAt),
            Colors.black87,
          ),
          const Divider(height: 20),
          _buildDetailRow(
            'Última Atividade',
            dateFormat.format(device.lastActiveAt),
            Colors.black87,
          ),
          if (device.location != null) ...[
            const Divider(height: 20),
            _buildDetailRow('Localização', device.location!, Colors.black87),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentDeviceNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GasometerColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GasometerColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: GasometerColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este Dispositivo',
                  style: TextStyle(
                    color: GasometerColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você está usando este dispositivo atualmente. Não é possível desconectá-lo.',
                  style: TextStyle(
                    color: GasometerColors.primary.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!device.isActive) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.block, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dispositivo Inativo',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Este dispositivo já foi desconectado e não tem mais acesso à sua conta.',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ações Disponíveis:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            'Desconectar Dispositivo',
            'Remove o acesso deste dispositivo à sua conta',
            Icons.block,
            Colors.red,
            () => _confirmRevokeDevice(context),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            'Ver Mais Detalhes',
            'Exibe informações técnicas adicionais',
            Icons.info_outline,
            Colors.blue,
            () => _showTechnicalDetails(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  void _confirmRevokeDevice(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Desconexão'),
            content: Text(
              'Tem certeza que deseja desconectar o dispositivo "${device.name}"?\n\n'
              'Este dispositivo perderá o acesso à sua conta imediatamente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha confirmação
                  Navigator.of(context).pop(); // Fecha diálogo principal
                  onAction('revoke');
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

  void _showTechnicalDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalhes Técnicos - ${device.name}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTechnicalDetail('UUID', device.uuid),
                  _buildTechnicalDetail('Identificador', device.identifier),
                  _buildTechnicalDetail(
                    'Dispositivo Físico',
                    device.isPhysicalDevice ? 'Sim' : 'Não',
                  ),
                  if (device.ipAddress != null)
                    _buildTechnicalDetail('IP', device.ipAddress!),
                  _buildTechnicalDetail('Build Number', device.buildNumber),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  Widget _buildTechnicalDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: TextStyle(color: Colors.grey[700], fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (!device.isActive) return 'Inativo';
    if (isCurrentDevice) return 'Dispositivo Atual';
    return device.vehicleActivityStatus;
  }

  Color _getStatusColor() {
    if (!device.isActive) return Colors.red;
    if (isCurrentDevice) return GasometerColors.primary;

    final diff = DateTime.now().difference(device.lastActiveAt);
    if (diff.inMinutes < 5) return Colors.green;
    if (diff.inDays < 1) return Colors.orange;
    return Colors.grey;
  }
}
