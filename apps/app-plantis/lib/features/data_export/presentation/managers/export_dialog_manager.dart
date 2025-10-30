import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Manager for export-related dialogs
/// Centralizes help and confirmation dialogs
class ExportDialogManager {
  /// Shows help dialog explaining LGPD and export features
  Future<void> showHelpDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: PlantisColors.primary),
            SizedBox(width: 8),
            Text('Ajuda - Exportação de Dados'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sobre a LGPD:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'A Lei Geral de Proteção de Dados garante o seu direito de exportar seus dados pessoais em formato estruturado.',
              ),
              SizedBox(height: 16),
              Text(
                'Tipos de dados incluídos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Plantas cadastradas por você'),
              Text('• Tarefas e lembretes criados'),
              Text('• Espaços organizacionais'),
              Text('• Configurações personalizadas'),
              Text('• Metadados de fotos (não as imagens)'),
              SizedBox(height: 16),
              Text('Segurança:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Limite de uma exportação por hora'),
              Text('• Arquivos válidos por 30 dias'),
              Text('• Dados criptografados durante o processamento'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlantisColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  /// Shows delete confirmation dialog
  /// Returns true if user confirms deletion, false otherwise
  Future<bool?> showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar exportação'),
        content: const Text('Tem certeza que deseja deletar esta exportação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}
