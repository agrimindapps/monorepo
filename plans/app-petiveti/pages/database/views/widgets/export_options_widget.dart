// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/database_controller.dart';
import '../../utils/database_helpers.dart';

class ExportOptionsWidget extends StatelessWidget {
  final DatabaseController controller;

  const ExportOptionsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasData || !controller.canExport()) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.file_download),
      tooltip: 'Exportar dados',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'json',
          child: Row(
            children: [
              Icon(Icons.code, size: 18),
              SizedBox(width: 8),
              Text('Exportar como JSON'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_view, size: 18),
              SizedBox(width: 8),
              Text('Exportar como CSV'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'all',
          child: Row(
            children: [
              Icon(Icons.download, size: 18),
              SizedBox(width: 8),
              Text('Exportar todos os formatos'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'summary',
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18),
              SizedBox(width: 8),
              Text('Ver resumo da exportação'),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleExportOption(context, value),
    );
  }

  Future<void> _handleExportOption(BuildContext context, String option) async {
    try {
      switch (option) {
        case 'json':
          await _exportJson(context);
          break;
        case 'csv':
          await _exportCsv(context);
          break;
        case 'all':
          await _exportAllFormats(context);
          break;
        case 'summary':
          _showExportSummary(context);
          break;
      }
    } catch (e) {
      DatabaseHelpers.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _exportJson(BuildContext context) async {
    try {
      final exportData = await controller.exportToJson();
      
      // In a real implementation, you would save the file or share it
      DatabaseHelpers.showSuccessSnackBar(
        context,
        'JSON exportado: ${exportData.filename}',
      );
      
      _showExportDialog(context, exportData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final exportData = await controller.exportToCsv();
      
      // In a real implementation, you would save the file or share it
      DatabaseHelpers.showSuccessSnackBar(
        context,
        'CSV exportado: ${exportData.filename}',
      );
      
      _showExportDialog(context, exportData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _exportAllFormats(BuildContext context) async {
    try {
      final exports = await controller.exportAllFormats();
      
      DatabaseHelpers.showSuccessSnackBar(
        context,
        'Exportados ${exports.length} arquivos',
      );
      
      _showMultipleExportsDialog(context, exports);
    } catch (e) {
      rethrow;
    }
  }

  void _showExportSummary(BuildContext context) {
    final summary = controller.getExportSummary();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Resumo da Exportação'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            summary,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, dynamic exportData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Exportação Concluída'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arquivo: ${exportData.filename}'),
            Text('Formato: ${exportData.format.toUpperCase()}'),
            Text('Tamanho: ${DatabaseHelpers.formatFileSize(exportData.content.length)}'),
            Text('Exportado em: ${exportData.exportedAt.toString().split('.')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showExportContent(context, exportData);
            },
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Visualizar'),
          ),
        ],
      ),
    );
  }

  void _showMultipleExportsDialog(BuildContext context, List<dynamic> exports) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Exportações Concluídas'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exports.length,
            itemBuilder: (context, index) {
              final export = exports[index];
              return ListTile(
                leading: Icon(
                  export.format == 'json' ? Icons.code : Icons.table_view,
                  size: 20,
                ),
                title: Text(export.filename),
                subtitle: Text('${export.format.toUpperCase()} - ${DatabaseHelpers.formatFileSize(export.content.length)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility, size: 16),
                  onPressed: () {
                    Navigator.pop(context);
                    _showExportContent(context, export);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showExportContent(BuildContext context, dynamic exportData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conteúdo - ${exportData.filename}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              exportData.content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
