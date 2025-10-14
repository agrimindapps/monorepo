import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data_inspector_helpers.dart';
import 'hive_box_loader_service.dart';

/// Widget do tab de HiveBoxes
///
/// Responsabilidades:
/// - Filtros por módulo e busca
/// - Lista de HiveBoxes com stats
/// - Cards expansíveis com registros
/// - Exportação de dados
class HiveTabWidget extends StatefulWidget {
  final DatabaseInspectorService inspector;
  final List<String> availableModules;
  final String selectedModule;
  final String searchQuery;
  final ValueChanged<String> onModuleChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onShowSuccessMessage;
  final ValueChanged<String> onShowErrorMessage;

  const HiveTabWidget({
    super.key,
    required this.inspector,
    required this.availableModules,
    required this.selectedModule,
    required this.searchQuery,
    required this.onModuleChanged,
    required this.onSearchChanged,
    required this.onShowSuccessMessage,
    required this.onShowErrorMessage,
  });

  @override
  State<HiveTabWidget> createState() => _HiveTabWidgetState();
}

class _HiveTabWidgetState extends State<HiveTabWidget> {
  final Set<String> _expandedBoxes = {};
  final Set<String> _expandedRecords = {}; // boxKey_recordIndex

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildBoxesList()),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: widget.selectedModule,
            decoration: InputDecoration(
              labelText: 'Módulo',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items:
                widget.availableModules.map((module) {
                  return DropdownMenuItem(value: module, child: Text(module));
                }).toList(),
            onChanged: (value) => widget.onModuleChanged(value!),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar HiveBox',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBoxesList() {
    final filteredBoxes =
        widget.inspector.customBoxes.where((box) {
          final matchesModule =
              widget.selectedModule == 'Todos' ||
              box.module == widget.selectedModule;
          final matchesSearch =
              widget.searchQuery.isEmpty ||
              box.displayName.toLowerCase().contains(
                widget.searchQuery.toLowerCase(),
              );
          return matchesModule && matchesSearch;
        }).toList();

    if (filteredBoxes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBoxes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final box = filteredBoxes[index];
        return _buildBoxCard(box);
      },
    );
  }

  Widget _buildBoxCard(CustomBoxType box) {
    final stats = widget.inspector.getBoxStats(box.key);
    final totalRecords = stats['totalRecords'] as int? ?? 0;
    final isOpen = stats['isOpen'] as bool? ?? false;
    final errorMessage = stats['error']?.toString() ?? '';
    final isAlreadyOpenError = errorMessage.contains('already open');
    final hasError = stats.containsKey('error') && !isAlreadyOpenError;

    final isExpanded = _expandedBoxes.contains(box.key);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedBoxes.remove(box.key);
                } else {
                  _expandedBoxes.add(box.key);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          hasError
                              ? Colors.red.withValues(alpha: 0.1)
                              : (isOpen
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasError
                          ? Icons.error_outline
                          : (isOpen ? Icons.folder_open : Icons.folder),
                      color:
                          hasError
                              ? Colors.red
                              : (isOpen ? Colors.green : Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          box.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${box.module ?? "N/A"} • $totalRecords ${totalRecords == 1 ? "registro" : "registros"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildBoxContent(box, hasError, stats),
          ],
        ],
      ),
    );
  }

  Widget _buildBoxContent(
    CustomBoxType box,
    bool hasError,
    Map<String, dynamic> stats,
  ) {
    final errorMessage = stats['error']?.toString() ?? '';
    final isAlreadyOpenError = errorMessage.contains('already open');

    if (hasError && !isAlreadyOpenError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Erro: $errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<DatabaseRecord>>(
      future: HiveBoxLoaderService.loadBoxDataSafely(box.key),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erro ao carregar: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Nenhum registro encontrado',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Column(
          children: [
            ...records.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return _buildRecordCard(box.key, index, record, records.length);
            }),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _exportBoxData(box, records),
                  icon: const Icon(Icons.download),
                  label: Text(
                    'Exportar ${records.length} ${records.length == 1 ? "registro" : "registros"}',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordCard(
    String boxKey,
    int index,
    DatabaseRecord record,
    int totalRecords,
  ) {
    final recordKey = '${boxKey}_$index';
    final isExpanded = _expandedRecords.contains(recordKey);

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        index == 0 ? 16 : 8,
        16,
        index == totalRecords - 1 ? 0 : 0,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedRecords.remove(recordKey);
                } else {
                  _expandedRecords.add(recordKey);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registro #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${record.id}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyJson(record.data),
                        tooltip: 'Copiar JSON',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: SelectableText(
                DataInspectorHelpers.formatJson(record.data),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma HiveBox encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _copyJson(dynamic data) {
    Clipboard.setData(
      ClipboardData(text: DataInspectorHelpers.formatJson(data)),
    );
    widget.onShowSuccessMessage('JSON copiado!');
  }

  Future<void> _exportBoxData(
    CustomBoxType box,
    List<DatabaseRecord> records,
  ) async {
    try {
      // Reload fresh data
      final freshRecords = await HiveBoxLoaderService.loadBoxDataSafely(
        box.key,
      );

      final jsonData = {
        'boxInfo': {
          'key': box.key,
          'displayName': box.displayName,
          'module': box.module,
          'description': box.description,
          'exportedAt': DateTime.now().toIso8601String(),
          'totalRecords': freshRecords.length,
        },
        'data':
            freshRecords
                .map((record) => {'id': record.id, 'data': record.data})
                .toList(),
      };

      final jsonString = DataInspectorHelpers.formatJson(jsonData);

      await SharePlus.instance.share(
        ShareParams(text: jsonString, subject: 'Export: ${box.displayName}'),
      );

      widget.onShowSuccessMessage(
        '${freshRecords.length} registros exportados!',
      );
    } catch (e) {
      widget.onShowErrorMessage('Erro ao exportar: $e');
    }
  }
}
