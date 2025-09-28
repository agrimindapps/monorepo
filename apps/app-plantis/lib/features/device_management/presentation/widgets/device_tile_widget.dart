import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/device_model.dart';

/// Widget que representa um tile individual de dispositivo
/// Mostra informações principais e ações disponíveis
class DeviceTileWidget extends StatelessWidget {
  final DeviceModel device;
  final bool isCurrentDevice;
  final bool isBeingRevoked;
  final VoidCallback? onRevoke;
  final VoidCallback? onTap;

  const DeviceTileWidget({
    Key? key,
    required this.device,
    this.isCurrentDevice = false,
    this.isBeingRevoked = false,
    this.onRevoke,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCurrentDevice ? 4 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentDevice
            ? BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do dispositivo
              Row(
                children: [
                  // Ícone da plataforma
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      device.platformIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Informações principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                device.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentDevice)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ATUAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          device.model,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Menu de ações
                  if (!isCurrentDevice && device.isActive && !isBeingRevoked)
                    _buildActionButton(context),
                ],
              ),

              const SizedBox(height: 12),

              // Status e informações adicionais
              Row(
                children: [
                  // Status do dispositivo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(device.statusColorHex.replaceFirst('#', '0xFF'))
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      device.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(
                          int.parse(device.statusColorHex.replaceFirst('#', '0xFF'))
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Última atividade
                  Text(
                    _formatLastActivity(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),

              // Informações técnicas (colapsadas por padrão)
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${device.platform} ${device.systemVersion} • App ${device.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Indicador de carregamento se está sendo revogado
              if (isBeingRevoked) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Revogando dispositivo...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'revoke' && onRevoke != null) {
          onRevoke!();
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'revoke',
          child: ListTile(
            leading: Icon(Icons.block, color: Colors.red),
            title: Text('Revogar'),
            subtitle: Text('Desconectar dispositivo'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Color _getIconBackgroundColor(BuildContext context) {
    if (!device.isActive) {
      return Colors.grey.withValues(alpha: 0.1);
    }

    if (isCurrentDevice) {
      return Theme.of(context).primaryColor.withValues(alpha: 0.1);
    }

    return Theme.of(context).cardColor.withValues(alpha: 0.5);
  }

  String _formatLastActivity() {
    final now = DateTime.now();
    final difference = now.difference(device.lastActiveAt);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'há 1 semana' : 'há ${weeks} semanas';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há ${months} meses';
    } else {
      // Para atividades muito antigas, mostra data
      return DateFormat('dd/MM/yyyy').format(device.lastActiveAt);
    }
  }
}