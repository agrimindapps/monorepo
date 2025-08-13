import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'dart:io';

class DataInspectorPage extends StatefulWidget {
  const DataInspectorPage({super.key});

  @override
  State<DataInspectorPage> createState() => _DataInspectorPageState();
}

class _DataInspectorPageState extends State<DataInspectorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseInspectorService _inspector = DatabaseInspectorService.instance;
  
  // Estados
  bool _isLoading = false;
  String? _selectedBox;
  List<DatabaseRecord> _hiveRecords = [];
  List<SharedPreferencesRecord> _sharedPrefsRecords = [];
  Map<String, dynamic> _generalStats = {};
  
  // Filtros
  String _searchQuery = '';
  bool _showJsonView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeInspector();
    _loadGeneralStats();
  }

  void _initializeInspector() {
    // Registrar boxes customizadas do app-plantis
    _inspector.registerCustomBoxes([
      CustomBoxType(
        key: 'plants_box',
        displayName: 'Plantas',
        module: 'plants',
        description: 'Dados das plantas cadastradas',
      ),
      CustomBoxType(
        key: 'care_tasks_box',
        displayName: 'Tarefas de Cuidados',
        module: 'care',
        description: 'Lembretes e tarefas de cuidados',
      ),
      CustomBoxType(
        key: 'notifications_box',
        displayName: 'Notificações',
        module: 'notifications',
        description: 'Configurações e histórico de notificações',
      ),
      CustomBoxType(
        key: 'user_preferences_box',
        displayName: 'Preferências do Usuário',
        module: 'settings',
        description: 'Configurações e preferências do app',
      ),
    ]);
  }

  Future<void> _loadGeneralStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = _inspector.getGeneralStats();
      setState(() {
        _generalStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Erro ao carregar estatísticas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHiveBoxData(String boxKey) async {
    setState(() {
      _isLoading = true;
      _selectedBox = boxKey;
    });
    
    try {
      final records = await _inspector.loadHiveBoxData(boxKey);
      setState(() {
        _hiveRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Erro ao carregar dados da box: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSharedPreferences() async {
    setState(() => _isLoading = true);
    
    try {
      final records = await _inspector.loadSharedPreferencesData();
      setState(() {
        _sharedPrefsRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Erro ao carregar SharedPreferences: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportData() async {
    try {
      File? exportedFile;
      
      if (_tabController.index == 0 && _selectedBox != null) {
        // Exportar Hive Box
        exportedFile = await _inspector.exportBoxData(_selectedBox!);
      } else if (_tabController.index == 1) {
        // Exportar SharedPreferences
        exportedFile = await _inspector.exportSharedPreferencesData();
      }
      
      if (exportedFile != null) {
        _showSuccess('Dados exportados para: ${exportedFile.path}');
      }
    } catch (e) {
      _showError('Erro ao exportar dados: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.teal,
        action: SnackBarAction(
          label: 'Copiar',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: message));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Inspetor de Dados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_showJsonView ? Icons.table_chart : Icons.code),
            onPressed: () {
              setState(() => _showJsonView = !_showJsonView);
            },
            tooltip: _showJsonView ? 'Visualização em Tabela' : 'Visualização JSON',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
            tooltip: 'Exportar Dados',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0 && _selectedBox != null) {
                _loadHiveBoxData(_selectedBox!);
              } else if (_tabController.index == 1) {
                _loadSharedPreferences();
              } else {
                _loadGeneralStats();
              }
            },
            tooltip: 'Atualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Hive Boxes'),
            Tab(text: 'SharedPrefs'),
            Tab(text: 'Estatísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHiveBoxesTab(),
          _buildSharedPreferencesTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildHiveBoxesTab() {
    final availableBoxes = _inspector.customBoxes;
    
    if (availableBoxes.isEmpty) {
      return _buildEmptyState(
        'Nenhuma Hive Box registrada',
        'Configure as boxes no DatabaseInspectorService',
      );
    }

    return Column(
      children: [
        // Box Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecione uma Box:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableBoxes.map((box) {
                  final isSelected = _selectedBox == box.key;
                  return ChoiceChip(
                    label: Text(box.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _loadHiveBoxData(box.key);
                      }
                    },
                    selectedColor: Colors.teal,
                    backgroundColor: Colors.grey.shade800,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade300,
                    ),
                  );
                }).toList(),
              ),
              if (_selectedBox != null) ...[
                const SizedBox(height: 8),
                Text(
                  _inspector.getBoxDescription(_selectedBox!) ?? '',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        
        // Search Bar
        if (_hiveRecords.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pesquisar nos dados...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        
        // Data Display
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                )
              : _selectedBox == null
                  ? _buildEmptyState(
                      'Selecione uma box',
                      'Escolha uma box acima para visualizar os dados',
                    )
                  : _hiveRecords.isEmpty
                      ? _buildEmptyState(
                          'Box vazia',
                          'Esta box não contém dados',
                        )
                      : _showJsonView
                          ? _buildJsonView(_hiveRecords)
                          : _buildTableView(_hiveRecords),
        ),
      ],
    );
  }

  Widget _buildSharedPreferencesTab() {
    if (_sharedPrefsRecords.isEmpty && !_isLoading) {
      // Carregar dados na primeira visualização
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSharedPreferences();
      });
    }

    return Column(
      children: [
        // Search Bar
        if (_sharedPrefsRecords.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pesquisar chaves...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        
        // Data Display
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                )
              : _sharedPrefsRecords.isEmpty
                  ? _buildEmptyState(
                      'Sem dados',
                      'SharedPreferences está vazio',
                    )
                  : _buildSharedPreferencesList(),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    if (_generalStats.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(
            'Estatísticas Gerais',
            [
              _buildStatRow('Total de Hive Boxes', '${_generalStats['totalHiveBoxes'] ?? 0}'),
              _buildStatRow('Total de Registros', '${_generalStats['totalHiveRecords'] ?? 0}'),
              _buildStatRow('Boxes Customizadas', '${_generalStats['customBoxesRegistered'] ?? 0}'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildStatsCard(
            'Boxes Disponíveis',
            (_generalStats['availableBoxes'] as List<dynamic>? ?? [])
                .map((box) => _buildStatRow(
                      _inspector.getBoxDisplayName(box.toString()),
                      box.toString(),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Box Details
          ..._inspector.customBoxes.map((box) {
            final stats = _inspector.getBoxStats(box.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildStatsCard(
                box.displayName,
                [
                  _buildStatRow('Chave', box.key),
                  if (box.module != null)
                    _buildStatRow('Módulo', box.module!),
                  if (box.description != null) 
                    _buildStatRow('Descrição', box.description!),
                  if (stats['totalRecords'] != null)
                    _buildStatRow('Total de Registros', '${stats['totalRecords']}'),
                  if (stats['isOpen'] != null)
                    _buildStatRow('Status', stats['isOpen'] ? 'Aberta' : 'Fechada'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableView(List<DatabaseRecord> records) {
    final filteredRecords = records.where((record) {
      if (_searchQuery.isEmpty) return true;
      final searchLower = _searchQuery.toLowerCase();
      return record.id.toLowerCase().contains(searchLower) ||
          record.data.toString().toLowerCase().contains(searchLower);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              'ID: ${record.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${record.fields.length} campos',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: record.data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${entry.value}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJsonView(List<DatabaseRecord> records) {
    final filteredRecords = records.where((record) {
      if (_searchQuery.isEmpty) return true;
      final searchLower = _searchQuery.toLowerCase();
      return record.id.toLowerCase().contains(searchLower) ||
          record.data.toString().toLowerCase().contains(searchLower);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        final jsonString = _inspector.formatAsJsonString(record.data);
        
        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              'ID: ${record.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.black,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        jsonString,
                        style: const TextStyle(
                          color: Colors.green,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        color: Colors.grey,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: jsonString));
                          _showSuccess('JSON copiado!');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSharedPreferencesList() {
    final filteredRecords = _sharedPrefsRecords.where((record) {
      if (_searchQuery.isEmpty) return true;
      final searchLower = _searchQuery.toLowerCase();
      return record.key.toLowerCase().contains(searchLower) ||
          record.value.toString().toLowerCase().contains(searchLower);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              record.key,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo: ${record.type}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valor: ${record.value}',
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tamanho: ${record.sizeInBytes} bytes',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) async {
                if (value == 'copy') {
                  Clipboard.setData(ClipboardData(text: record.value.toString()));
                  _showSuccess('Valor copiado!');
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.grey.shade900,
                      title: const Text('Confirmar Exclusão', style: TextStyle(color: Colors.white)),
                      content: Text(
                        'Deseja remover a chave "${record.key}"?',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Remover', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    final success = await _inspector.removeSharedPreferencesKey(record.key);
                    if (success) {
                      _showSuccess('Chave removida!');
                      _loadSharedPreferences();
                    } else {
                      _showError('Erro ao remover chave');
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 18),
                      SizedBox(width: 8),
                      Text('Copiar valor'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remover', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(String title, List<Widget> children) {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}