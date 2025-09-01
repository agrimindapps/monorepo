import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../infrastructure/services/database_inspector_service.dart';
import '../../theme/data_inspector_theme.dart';

/// Export tab for comprehensive data export capabilities
/// Enhanced version of app-receituagro export functionality with multiple formats
class ExportTab extends StatefulWidget {
  final DatabaseInspectorService inspector;
  final DataInspectorTheme theme;
  final String appName;
  final List<String> hiveBoxes;

  const ExportTab({
    super.key,
    required this.inspector,
    required this.theme,
    required this.appName,
    required this.hiveBoxes,
  });

  @override
  State<ExportTab> createState() => _ExportTabState();
}

class _ExportTabState extends State<ExportTab> {
  final Set<String> _selectedBoxes = <String>{};
  bool _includeSharedPreferences = true;
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: DataInspectorDesignTokens.spacingL),
          _buildFormatSelection(),
          const SizedBox(height: DataInspectorDesignTokens.spacingL),
          _buildDataSourceSelection(),
          const SizedBox(height: DataInspectorDesignTokens.spacingL),
          _buildHiveBoxesSelection(),
          const SizedBox(height: DataInspectorDesignTokens.spacingXl),
          _buildExportActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        child: Column(
          children: [
            Icon(
              Icons.download_rounded,
              size: DataInspectorDesignTokens.iconXl,
              color: widget.theme.primaryColor,
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingS),
            Text(
              'Exportação de Dados',
              style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingS),
            Text(
              'Exporte dados do ${widget.appName} em diversos formatos',
              style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection() {
    return _buildSection(
      title: 'Formato de Exportação',
      icon: Icons.file_copy,
      child: Column(
        children: ExportFormat.values.map((format) {
          return RadioListTile<ExportFormat>(
            value: format,
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            title: Text(
              _getFormatDisplayName(format),
              style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor,
              ),
            ),
            subtitle: Text(
              _getFormatDescription(format),
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
            activeColor: widget.theme.primaryColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataSourceSelection() {
    return _buildSection(
      title: 'Fontes de Dados',
      icon: Icons.source,
      child: Column(
        children: [
          CheckboxListTile(
            value: _includeSharedPreferences,
            onChanged: (value) {
              setState(() {
                _includeSharedPreferences = value ?? false;
              });
            },
            title: Text(
              'SharedPreferences',
              style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor,
              ),
            ),
            subtitle: Text(
              'Incluir dados do SharedPreferences na exportação',
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
            activeColor: widget.theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHiveBoxesSelection() {
    if (widget.hiveBoxes.isEmpty) {
      return _buildSection(
        title: 'Hive Boxes',
        icon: Icons.storage,
        child: Container(
          padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
          decoration: BoxDecoration(
            color: widget.theme.surfaceColor,
            borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: DataInspectorDesignTokens.spacingS),
              Expanded(
                child: Text(
                  'Nenhuma Hive Box disponível para exportação',
                  style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSection(
      title: 'Hive Boxes (${_selectedBoxes.length}/${widget.hiveBoxes.length})',
      icon: Icons.storage,
      child: Column(
        children: [
          // Select all/none buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedBoxes.addAll(widget.hiveBoxes);
                  });
                },
                icon: const Icon(Icons.select_all),
                label: const Text('Selecionar Todas'),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedBoxes.clear();
                  });
                },
                icon: const Icon(Icons.deselect),
                label: const Text('Limpar Seleção'),
              ),
            ],
          ),
          const Divider(),
          // Box list
          ...widget.hiveBoxes.map((boxKey) {
            final displayName = widget.inspector.getBoxDisplayName(boxKey);
            final stats = widget.inspector.getBoxStats(boxKey);
            final recordCount = stats['totalRecords'] ?? 0;
            final isOpen = stats['isOpen'] == true;
            
            return CheckboxListTile(
              value: _selectedBoxes.contains(boxKey),
              onChanged: isOpen ? (value) {
                setState(() {
                  if (value == true) {
                    _selectedBoxes.add(boxKey);
                  } else {
                    _selectedBoxes.remove(boxKey);
                  }
                });
              } : null,
              title: Text(
                displayName,
                style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                  color: isOpen 
                      ? widget.theme.onSurfaceColor 
                      : widget.theme.onSurfaceColor.withValues(alpha: 0.5),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Box: $boxKey',
                    style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                      color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    isOpen 
                        ? '$recordCount registro${recordCount != 1 ? 's' : ''}'
                        : 'Box fechada - não disponível',
                    style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                      color: isOpen 
                          ? widget.theme.primaryColor 
                          : widget.theme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              activeColor: widget.theme.primaryColor,
              secondary: Icon(
                isOpen ? Icons.storage : Icons.lock,
                color: isOpen 
                    ? widget.theme.successColor 
                    : widget.theme.errorColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExportActions() {
    final hasDataToExport = _selectedBoxes.isNotEmpty || _includeSharedPreferences;
    
    return Column(
      children: [
        // Export summary
        Container(
          padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
          decoration: BoxDecoration(
            color: widget.theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
            border: Border.all(
              color: widget.theme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.summarize,
                color: widget.theme.primaryColor,
                size: DataInspectorDesignTokens.iconL,
              ),
              const SizedBox(height: DataInspectorDesignTokens.spacingS),
              Text(
                'Resumo da Exportação',
                style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                  color: widget.theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DataInspectorDesignTokens.spacingS),
              _buildSummaryRow('Formato', _getFormatDisplayName(_selectedFormat)),
              if (_includeSharedPreferences)
                _buildSummaryRow('SharedPreferences', 'Incluído'),
              if (_selectedBoxes.isNotEmpty)
                _buildSummaryRow('Hive Boxes', '${_selectedBoxes.length} selecionada${_selectedBoxes.length != 1 ? 's' : ''}'),
              if (!hasDataToExport)
                Text(
                  'Nenhuma fonte de dados selecionada',
                  style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                    color: widget.theme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DataInspectorDesignTokens.spacingL),
        
        // Export buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (!_isExporting && hasDataToExport) ? _exportToFile : null,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_alt),
                label: Text(_isExporting ? 'Exportando...' : 'Exportar para Arquivo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
                ),
              ),
            ),
            const SizedBox(width: DataInspectorDesignTokens.spacingS),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (!_isExporting && hasDataToExport) ? _copyPathsToClipboard : null,
                icon: const Icon(Icons.content_copy),
                label: const Text('Copiar Caminhos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: widget.theme.primaryColor,
                  size: DataInspectorDesignTokens.iconM,
                ),
                const SizedBox(width: DataInspectorDesignTokens.spacingS),
                Text(
                  title,
                  style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DataInspectorDesignTokens.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: DataInspectorDesignTokens.captionTextStyle.copyWith(
              color: widget.theme.onSurfaceColor,
            ),
          ),
          Text(
            value,
            style: DataInspectorDesignTokens.captionTextStyle.copyWith(
              color: widget.theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.txt:
        return 'Texto';
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'Formato estruturado para backup e análise';
      case ExportFormat.csv:
        return 'Para planilhas e análise de dados';
      case ExportFormat.txt:
        return 'Texto simples para leitura';
    }
  }

  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.txt:
        return 'txt';
    }
  }

  Future<void> _exportToFile() async {
    setState(() => _isExporting = true);
    
    try {
      final files = <File>[];
      
      // Export SharedPreferences if selected
      if (_includeSharedPreferences) {
        final file = await widget.inspector.exportSharedPreferencesData();
        files.add(file);
      }
      
      // Export selected Hive boxes
      for (final boxKey in _selectedBoxes) {
        final file = await widget.inspector.exportBoxData(boxKey);
        files.add(file);
      }
      
      if (files.isNotEmpty) {
        final message = files.length == 1
            ? 'Arquivo exportado: ${files.first.path}'
            : '${files.length} arquivos exportados';
        _showSuccessSnackbar(message);
      }
    } catch (e) {
      _showErrorSnackbar('Erro na exportação: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _copyPathsToClipboard() async {
    setState(() => _isExporting = true);
    
    try {
      final files = <String>[];
      
      // Export and collect file paths
      if (_includeSharedPreferences) {
        final file = await widget.inspector.exportSharedPreferencesData();
        files.add(file.path);
      }
      
      for (final boxKey in _selectedBoxes) {
        final file = await widget.inspector.exportBoxData(boxKey);
        files.add(file.path);
      }
      
      if (files.isNotEmpty) {
        final pathsText = files.join('\n');
        await Clipboard.setData(ClipboardData(text: pathsText));
        
        final message = files.length == 1
            ? 'Caminho copiado para área de transferência'
            : '${files.length} caminhos copiados para área de transferência';
        _showSuccessSnackbar(message);
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao copiar caminhos: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getSuccessSnackbar(message, theme: widget.theme),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getErrorSnackbar(message, theme: widget.theme),
    );
  }
}

/// Supported export formats
enum ExportFormat {
  json,
  csv,
  txt,
}