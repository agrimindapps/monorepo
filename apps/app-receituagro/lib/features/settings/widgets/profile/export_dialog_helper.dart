import 'package:flutter/material.dart';

/// Helper para criar diálogos de exportação de dados
/// Responsabilidade: UI helper para dialogs reutilizáveis
class ExportDialogHelper {
  const ExportDialogHelper._();

  /// Build export dialog widget (reusável para JSON/CSV)
  static Widget buildExportDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required String buttonLabel,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(description, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onConfirm,
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar diálogo de exportação JSON
  static void showExportJsonDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => buildExportDialog(
        context: context,
        title: 'Exportar como JSON',
        icon: Icons.data_object,
        description:
            'Esta funcionalidade irá baixar todos os seus dados em formato JSON estruturado. Ideal para backup ou migração de dados.',
        buttonLabel: 'Exportar JSON',
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.construction, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Exportação JSON em desenvolvimento'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  /// Mostrar diálogo de exportação CSV
  static void showExportCsvDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => buildExportDialog(
        context: context,
        title: 'Exportar como CSV',
        icon: Icons.table_chart,
        description:
            'Esta funcionalidade irá baixar todos os seus dados em formato CSV (planilha). Ideal para análise em Excel ou Google Sheets.',
        buttonLabel: 'Exportar CSV',
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.construction, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Exportação CSV em desenvolvimento'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
