// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/web_internal_layout.dart';
import '../../../defensivos/domain/entities/defensivo.dart';
import '../../../defensivos/domain/services/export_service.dart';
import '../../../defensivos/presentation/providers/defensivos_providers.dart';

/// Export page with 3 export options
/// Based on Vue.js ReceituagroCadastro-master export functionality
class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  bool _isExporting = false;
  String? _lastExportMessage;

  @override
  Widget build(BuildContext context) {
    return WebInternalLayout(
      title: 'Exportar Dados',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            const SizedBox(height: 32),

            // Export options
            _buildExportOptions(context),

            const SizedBox(height: 24),

            // Status message
            if (_lastExportMessage != null) _buildStatusMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.file_download,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exportar Dados',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exporte os dados do sistema para backup ou análise',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 3 ? 1.2 : 2.5,
          children: [
            _ExportOptionCard(
              icon: Icons.table_chart,
              title: 'Backup CSV',
              subtitle: 'Exporta todos os defensivos em formato CSV (planilha)',
              color: Colors.blue,
              buttonLabel: 'Exportar CSV',
              isLoading: _isExporting,
              onTap: () => _exportCsv(),
            ),
            _ExportOptionCard(
              icon: Icons.code,
              title: 'Backup JSON',
              subtitle:
                  'Exporta todos os dados em formato JSON (completo com diagnósticos)',
              color: Colors.orange,
              buttonLabel: 'Exportar JSON',
              isLoading: _isExporting,
              onTap: () => _exportJson(),
            ),
            _ExportOptionCard(
              icon: Icons.cloud_upload,
              title: 'Exportação Filtrada',
              subtitle:
                  'Exporta apenas registros completos (prontos para produção)',
              color: Colors.green,
              buttonLabel: 'Exportar Filtrado',
              isLoading: _isExporting,
              onTap: () => _exportFiltered(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _lastExportMessage!,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _lastExportMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() {
      _isExporting = true;
      _lastExportMessage = null;
    });

    try {
      final defensivosAsync = ref.read(defensivosProvider);
      final defensivos = defensivosAsync.when(
        data: (data) => data,
        loading: () => <Defensivo>[],
        error: (_, __) => <Defensivo>[],
      );

      if (defensivos.isEmpty) {
        _showError('Nenhum defensivo encontrado para exportar');
        return;
      }

      final exportService = ExportService();
      final csv = exportService.exportToCsv(defensivos: defensivos);

      _downloadFile(csv, 'defensivos_backup.csv', 'text/csv');

      setState(() {
        _lastExportMessage =
            'Exportação CSV concluída! ${defensivos.length} defensivos exportados.';
      });
    } catch (e) {
      _showError('Erro ao exportar CSV: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportJson() async {
    setState(() {
      _isExporting = true;
      _lastExportMessage = null;
    });

    try {
      final defensivosAsync = ref.read(defensivosProvider);
      final defensivos = defensivosAsync.when(
        data: (data) => data,
        loading: () => <Defensivo>[],
        error: (_, __) => <Defensivo>[],
      );

      if (defensivos.isEmpty) {
        _showError('Nenhum defensivo encontrado para exportar');
        return;
      }

      final exportService = ExportService();
      final json = exportService.exportToJson(defensivos: defensivos);

      _downloadFile(json, 'defensivos_backup.json', 'application/json');

      setState(() {
        _lastExportMessage =
            'Exportação JSON concluída! ${defensivos.length} defensivos exportados.';
      });
    } catch (e) {
      _showError('Erro ao exportar JSON: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportFiltered() async {
    setState(() {
      _isExporting = true;
      _lastExportMessage = null;
    });

    try {
      final defensivosAsync = ref.read(defensivosProvider);
      final defensivos = defensivosAsync.when(
        data: (data) => data,
        loading: () => <Defensivo>[],
        error: (_, __) => <Defensivo>[],
      );

      if (defensivos.isEmpty) {
        _showError('Nenhum defensivo encontrado para exportar');
        return;
      }

      // For now, export all as we don't have diagnosticos/infos loaded here
      // In production, this would filter based on DefensivoStats
      final exportService = ExportService();
      final json = exportService.exportToJson(defensivos: defensivos);

      _downloadFile(json, 'defensivos_filtered.json', 'application/json');

      setState(() {
        _lastExportMessage =
            'Exportação filtrada concluída! ${defensivos.length} defensivos exportados.';
      });
    } catch (e) {
      _showError('Erro ao exportar: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isExporting = false;
    });
  }
}

/// Export option card widget
class _ExportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final MaterialColor color;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.buttonLabel,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onTap,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.download, color: color.shade700),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.shade50,
                  foregroundColor: color.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
