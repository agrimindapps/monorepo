import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/receituagro_navigation_service.dart';
import '../../../../core/utils/receita_agro_data_inspector_initializer.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';

/// Data Inspector Page - Refatorada com visual moderno
/// Responsabilidade única: Inspeção visual de dados do Hive e SharedPreferences
class DataInspectorPage extends StatefulWidget {
  const DataInspectorPage({super.key});

  @override
  State<DataInspectorPage> createState() => _DataInspectorPageState();
}

class _DataInspectorPageState extends State<DataInspectorPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedModule = 'Todos';

  final DatabaseInspectorService _inspector = DatabaseInspectorService.instance;
  List<String> _availableModules = ['Todos'];
  List<SharedPreferencesRecord> _sharedPrefsData = [];
  final Set<String> _expandedBoxes = {};
  final Set<String> _expandedPrefs = {};
  final Set<String> _expandedRecords = {}; // boxKey_recordIndex

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeInspector();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeInspector() {
    ReceitaAgroDataInspectorInitializer.initialize();

    final modules =
        _inspector.customBoxes
            .map((box) => box.module ?? 'Outros')
            .toSet()
            .toList();
    modules.sort();
    _availableModules = ['Todos', ...modules];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _sharedPrefsData = await _inspector.loadSharedPreferencesData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (kDebugMode) {
        print('Erro ao carregar dados do inspector: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [_buildHeader(isDark), Expanded(child: _buildBody())],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ModernHeaderWidget(
      title: 'Data Inspector',
      subtitle: 'Inspeção de Hive e SharedPreferences',
      leftIcon: Icons.storage_outlined,
      rightIcon: Icons.refresh,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed:
          () => GetIt.instance<ReceitaAgroNavigationService>().goBack<void>(),
      onRightIconPressed: _loadData,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        StandardTabBarWidget(
          tabController: _tabController,
          tabs: const [
            StandardTabData(icon: Icons.folder_open, text: 'HiveBoxes'),
            StandardTabData(icon: Icons.settings, text: 'SharedPrefs'),
          ],
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [_buildHiveBoxesTab(), _buildSharedPrefsTab()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHiveBoxesTab() {
    return Column(
      children: [_buildHiveFilters(), Expanded(child: _buildHiveBoxesList())],
    );
  }

  Widget _buildHiveFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedModule,
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
                _availableModules.map((module) {
                  return DropdownMenuItem(value: module, child: Text(module));
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedModule = value!);
            },
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
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHiveBoxesList() {
    final filteredBoxes =
        _inspector.customBoxes.where((box) {
          final matchesModule =
              _selectedModule == 'Todos' || box.module == _selectedModule;
          final matchesSearch =
              _searchQuery.isEmpty ||
              box.displayName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          return matchesModule && matchesSearch;
        }).toList();

    if (filteredBoxes.isEmpty) {
      return _buildEmptyState('Nenhuma HiveBox encontrada', Icons.folder_off);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBoxes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final box = filteredBoxes[index];
        return _buildHiveBoxCard(box);
      },
    );
  }

  Widget _buildHiveBoxCard(CustomBoxType box) {
    final stats = _inspector.getBoxStats(box.key);
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
            _buildHiveBoxContent(box, hasError, stats),
          ],
        ],
      ),
    );
  }

  Widget _buildHiveBoxContent(
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
      future: _loadBoxDataSafely(box.key),
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
                _formatJson(record.data),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSharedPrefsTab() {
    return Column(
      children: [
        _buildSharedPrefsFilters(),
        Expanded(child: _buildSharedPrefsList()),
      ],
    );
  }

  Widget _buildSharedPrefsFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Buscar SharedPreference',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildSharedPrefsList() {
    final filteredPrefs =
        _sharedPrefsData.where((pref) {
          return _searchQuery.isEmpty ||
              pref.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              pref.value.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();

    if (filteredPrefs.isEmpty) {
      return _buildEmptyState(
        'Nenhuma SharedPreference encontrada',
        Icons.settings_suggest,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPrefs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pref = filteredPrefs[index];
        return _buildSharedPrefCard(pref);
      },
    );
  }

  Widget _buildSharedPrefCard(SharedPreferencesRecord pref) {
    final isExpanded = _expandedPrefs.contains(pref.key);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedPrefs.remove(pref.key);
                } else {
                  _expandedPrefs.add(pref.key);
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
                      color: _getTypeColor(pref.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(pref.type),
                      color: _getTypeColor(pref.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pref.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tipo: ${pref.type}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                        onPressed:
                            () =>
                                _copyToClipboard('${pref.key}: ${pref.value}'),
                        tooltip: 'Copiar',
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _formatValue(pref.value),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _copyToClipboard(pref.value.toString()),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copiar Valor'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmRemoveSharedPref(pref.key),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Remover'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  /// Carrega dados de uma HiveBox com estratégia segura: abrir → ler → fechar
  /// Isso evita erros de "box já aberta"
  Future<List<DatabaseRecord>> _loadBoxDataSafely(String boxKey) async {
    try {
      var box = Hive.box<dynamic>(boxKey);
      final wasAlreadyOpen = box.isOpen;
      if (!wasAlreadyOpen) {
        box = await Hive.openBox<dynamic>(boxKey);
      }
      final records = <DatabaseRecord>[];
      for (var i = 0; i < box.length; i++) {
        try {
          final key = box.keyAt(i);
          final value = box.getAt(i);

          if (value != null) {
            final dataMap =
                value is Map<String, dynamic>
                    ? value
                    : <String, dynamic>{'raw': value};

            records.add(
              DatabaseRecord(
                id: key?.toString() ?? i.toString(),
                data: dataMap,
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Erro ao ler registro $i da box $boxKey: $e');
          }
        }
      }
      if (!wasAlreadyOpen && box.isOpen) {
        await box.close();
      }

      return records;
    } catch (e) {
      if (e.toString().contains('already open')) {
        try {
          final box = Hive.box<dynamic>(boxKey);
          final records = <DatabaseRecord>[];

          for (var i = 0; i < box.length; i++) {
            try {
              final key = box.keyAt(i);
              final value = box.getAt(i);

              if (value != null) {
                final dataMap =
                    value is Map<String, dynamic>
                        ? value
                        : <String, dynamic>{'raw': value};

                records.add(
                  DatabaseRecord(
                    id: key?.toString() ?? i.toString(),
                    data: dataMap,
                  ),
                );
              }
            } catch (readError) {
              if (kDebugMode) {
                print('Erro ao ler registro $i: $readError');
              }
            }
          }

          return records;
        } catch (fallbackError) {
          throw Exception('Failed to load Hive box $boxKey: $fallbackError');
        }
      }

      throw Exception('Failed to load Hive box $boxKey: $e');
    }
  }
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'string':
        return Colors.blue;
      case 'int':
        return Colors.green;
      case 'double':
        return Colors.orange;
      case 'bool':
        return Colors.purple;
      case 'list':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'string':
        return Icons.text_fields;
      case 'int':
      case 'double':
        return Icons.numbers;
      case 'bool':
        return Icons.toggle_on;
      case 'list':
        return Icons.list;
      default:
        return Icons.settings;
    }
  }

  String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      try {
        final decoded = json.decode(value);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      } catch (e) {
        return value;
      }
    }
    return _formatJson(value);
  }

  void _copyJson(dynamic data) {
    Clipboard.setData(ClipboardData(text: _formatJson(data)));
    _showSnackBar('JSON copiado!', isError: false);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copiado!', isError: false);
  }

  Future<void> _exportBoxData(
    CustomBoxType box,
    List<DatabaseRecord> records,
  ) async {
    try {
      final freshRecords = await _loadBoxDataSafely(box.key);

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

      final jsonString = _formatJson(jsonData);

      await SharePlus.instance.share(
        ShareParams(text: jsonString, subject: 'Export: ${box.displayName}'),
      );

      _showSnackBar(
        '${freshRecords.length} registros exportados!',
        isError: false,
      );
    } catch (e) {
      _showSnackBar('Erro ao exportar: $e', isError: true);
    }
  }

  Future<void> _confirmRemoveSharedPref(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Remoção'),
            content: Text('Deseja remover a chave "$key"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remover'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await _inspector.removeSharedPreferencesKey(key);
        if (success) {
          _showSnackBar('Chave removida!', isError: false);
          await _loadData();
        } else {
          _showSnackBar('Falha ao remover', isError: true);
        }
      } catch (e) {
        _showSnackBar('Erro: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
