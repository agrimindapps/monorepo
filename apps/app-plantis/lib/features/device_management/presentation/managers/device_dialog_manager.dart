import 'package:flutter/material.dart';

/// Manager for device management dialogs
/// Centralizes revoke and help dialogs
class DeviceDialogManager {
  /// Shows revoke all devices confirmation dialog
  /// Returns true if user confirms, false otherwise
  Future<bool?> showRevokeAllDialog(
    BuildContext context,
    int otherDevicesCount,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Outros Dispositivos'),
        content: Text(
          'Isso irá desconectar todos os outros dispositivos ($otherDevicesCount), '
          'mantendo apenas este dispositivo ativo.\n\n'
          'Esta ação não pode ser desfeita.',
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
            child: const Text('Revogar Todos'),
          ),
        ],
      ),
    );
  }

  /// Shows help dialog about device management
  Future<void> showHelpDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda - Gerenciamento de Dispositivos'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'O que são dispositivos registrados?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'São os aparelhos (celular, tablet, computador) onde você fez login no Plantis. '
                'Você pode ter até 3 dispositivos ativos simultaneamente.',
              ),
              SizedBox(height: 16),
              Text(
                'Por que revogar um dispositivo?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Quando perder ou trocar de aparelho\n'
                '• Para liberar espaço para um novo dispositivo\n'
                '• Por questões de segurança\n'
                '• Quando não usar mais um aparelho',
              ),
              SizedBox(height: 16),
              Text(
                'O que acontece ao revogar?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'O dispositivo revogado será desconectado automaticamente e precisará '
                'fazer login novamente para usar o Plantis.',
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
