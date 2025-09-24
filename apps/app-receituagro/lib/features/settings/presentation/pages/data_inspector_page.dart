import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/inspector/receita_agro_data_inspector_initializer.dart';

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
  Map<String, dynamic> _moduleStats = {};
  List<DatabaseRecord> _currentBoxData = [];
  List<SharedPreferencesRecord> _sharedPrefsData = [];
  String? _selectedBoxKey;
  
  final DatabaseInspectorService _inspector = DatabaseInspectorService.instance;
  List<String> _availableModules = ['Todos'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // HiveBoxes, SharedPrefs, Estatísticas, Sistema
    _initializeInspector();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeInspector() {
    // Garantir que o inspector está inicializado
    ReceitaAgroDataInspectorInitializer.initialize();
    
    // Obter módulos disponíveis
    final modules = _inspector.customBoxes.map((box) => box.module ?? 'Outros').toSet().toList();
    modules.sort();
    _availableModules = ['Todos', ...modules];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Carregar estatísticas por módulo
      _moduleStats = ReceitaAgroDataInspectorInitializer.getModuleStats();
      
      // Carregar SharedPreferences
      _sharedPrefsData = await _inspector.loadSharedPreferencesData();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _moduleStats = {'error': e.toString()};
        _isLoading = false;
      });
      
      if (kDebugMode) {
        print('Erro ao carregar dados do inspector: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector - ReceitaAgro'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'HiveBoxes'),
            Tab(text: 'SharedPrefs'),
            Tab(text: 'Estatísticas'),
            Tab(text: 'Sistema'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moduleStats.containsKey('error')
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHiveBoxesTab(),
                    _buildSharedPrefsTab(),
                    _buildStatsTab(),
                    _buildSystemTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar dados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _moduleStats['error']?.toString() ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiveBoxesTab() {
    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filtro por módulo
              DropdownButtonFormField<String>(
                value: _selectedModule,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por Módulo',
                  border: OutlineInputBorder(),
                ),
                items: _availableModules.map((module) {
                  return DropdownMenuItem(
                    value: module,
                    child: Text(module),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedModule = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Campo de busca
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar boxes...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ],
          ),
        ),
        // Lista de boxes
        Expanded(
          child: _buildBoxesList(),
        ),
      ],
    );
  }

  Widget _buildSharedPrefsTab() {
    return Column(
      children: [
        // Busca nas SharedPrefs
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar nas SharedPreferences...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        // Lista de SharedPreferences
        Expanded(
          child: _buildSharedPrefsList(),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    if (_moduleStats.isEmpty) {
      return const Center(child: Text('Nenhuma estatística disponível'));
    }

    final moduleStats = _moduleStats['moduleStats'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo geral
          _buildGeneralStatsCard(),
          const SizedBox(height: 16),
          // Saúde do sistema
          _buildSystemHealthCard(),
          const SizedBox(height: 24),
          // Estatísticas por módulo
          const Text(
            'Estatísticas por Módulo:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...moduleStats.entries.map((entry) => _buildModuleStatsCard(entry.key, entry.value as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ferramentas do Sistema:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSystemToolsCard(),
          const SizedBox(height: 24),
          const Text(
            'Informações do Sistema:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSystemInfoCard(),
        ],
      ),
    );
  }

  Widget _buildBoxesList() {
    final allBoxes = _inspector.customBoxes;
    
    // Filtrar boxes
    var filteredBoxes = allBoxes.where((box) {
      final matchesModule = _selectedModule == 'Todos' || box.module == _selectedModule;
      final matchesSearch = _searchQuery.isEmpty || 
          box.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (box.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesModule && matchesSearch;
    }).toList();
    
    if (filteredBoxes.isEmpty) {
      return const Center(
        child: Text('Nenhuma box encontrada com os filtros aplicados'),
      );
    }
    
    return ListView.builder(
      itemCount: filteredBoxes.length,
      itemBuilder: (context, index) {
        final box = filteredBoxes[index];
        final stats = _inspector.getBoxStats(box.key);
        
        return _buildBoxCard(box, stats);
      },
    );
  }

  Widget _buildBoxCard(CustomBoxType box, Map<String, dynamic> stats) {
    final hasError = stats.containsKey('error');
    final totalRecords = stats['totalRecords'] as int? ?? 0;
    final isOpen = stats['isOpen'] as bool? ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ExpansionTile(
        leading: Icon(
          hasError ? Icons.error : (isOpen ? Icons.folder_open : Icons.folder),
          color: hasError ? Colors.red : (isOpen ? Colors.green : Colors.grey),
        ),
        title: Text(box.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Módulo: ${box.module ?? "N/A"} • Registros: $totalRecords'),
            if (box.description != null)
              Text(
                box.description!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasError)
              const Icon(Icons.warning, color: Colors.orange, size: 20),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasError) ...
                  [
                    Text(
                      'Erro: ${stats['error']}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                  ]
                else ...
                  [
                    _buildDataRow('Chave da Box', box.key),
                    _buildDataRow('Status', isOpen ? 'Aberta' : 'Fechada'),
                    _buildDataRow('Total de Registros', totalRecords.toString()),
                    if (box.description != null)
                      _buildDataRow('Descrição', box.description!),
                    const SizedBox(height: 16),
                  ],
                Row(
                  children: [
                    if (!hasError) ...
                      [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewBoxData(box.key),
                            icon: const Icon(Icons.visibility),
                            label: const Text('Ver Dados'),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _exportBoxData(box),
                        icon: const Icon(Icons.download),
                        label: const Text('Exportar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedPrefsList() {
    var filteredPrefs = _sharedPrefsData.where((pref) {
      return _searchQuery.isEmpty ||
          pref.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pref.value.toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    
    if (filteredPrefs.isEmpty) {
      return const Center(
        child: Text('Nenhuma SharedPreference encontrada'),
      );
    }
    
    return ListView.builder(
      itemCount: filteredPrefs.length,
      itemBuilder: (context, index) {
        final pref = filteredPrefs[index];
        return _buildSharedPrefCard(pref);
      },
    );
  }

  Widget _buildSharedPrefCard(SharedPreferencesRecord pref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(pref.key),
        subtitle: Text(
          'Tipo: ${pref.type} • ${pref.value.toString().length > 50 ? pref.value.toString().substring(0, 50) + "..." : pref.value}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Chave', pref.key),
                _buildDataRow('Tipo', pref.type),
                _buildDataRow('Valor', pref.value.toString()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard('${pref.key}: ${pref.value}'),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _removeSharedPref(pref.key),
                        icon: const Icon(Icons.delete),
                        label: const Text('Remover'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Geral',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDataRow('Total de Módulos', _moduleStats['totalModules']?.toString() ?? '0'),
            _buildDataRow('Boxes Registradas', _moduleStats['totalRegisteredBoxes']?.toString() ?? '0'),
            _buildDataRow('Boxes Disponíveis', _moduleStats['totalAvailableBoxes']?.toString() ?? '0'),
            _buildDataRow('Gerado em', _formatDateTime(_moduleStats['generatedAt']?.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    final healthData = ReceitaAgroDataInspectorInitializer.getSystemHealth();
    final healthPercentage = healthData['healthPercentage'] as double? ?? 0.0;
    final status = healthData['status'] as String? ?? 'Desconhecido';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Saúde do Sistema',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getHealthColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: healthPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(status)),
            ),
            const SizedBox(height: 8),
            Text('${healthPercentage.toStringAsFixed(1)}% das boxes estão funcionando corretamente'),
            const SizedBox(height: 8),
            _buildDataRow('Boxes Saudáveis', healthData['healthyBoxes']?.toString() ?? '0'),
            _buildDataRow('Boxes com Erro', healthData['errorBoxes']?.toString() ?? '0'),
            _buildDataRow('Total de Registros', healthData['totalRecords']?.toString() ?? '0'),
            if ((healthData['issues'] as List?)?.isNotEmpty == true) ...
              [
                const SizedBox(height: 8),
                const Text('Problemas Encontrados:', style: TextStyle(fontWeight: FontWeight.w500)),
                ...(healthData['issues'] as List).map((issue) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $issue', style: const TextStyle(color: Colors.red, fontSize: 12)),
                )),
              ],
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(String status) {
    switch (status) {
      case 'Excelente':
        return Colors.green;
      case 'Bom':
        return Colors.lightGreen;
      case 'Regular':
        return Colors.orange;
      case 'Crítico':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildModuleStatsCard(String module, Map<String, dynamic> stats) {
    final totalBoxes = stats['totalBoxes'] as int? ?? 0;
    final totalRecords = stats['totalRecords'] as int? ?? 0;
    final boxes = stats['boxes'] as List? ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text(module),
        subtitle: Text('$totalBoxes boxes • $totalRecords registros'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (boxes.isNotEmpty) ...
                  [
                    const Text('Boxes neste módulo:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...boxes.map((box) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('• ${box['displayName']} (${box['totalRecords']} registros)'),
                          ),
                          if (box['hasError'] == true)
                            const Icon(Icons.error, color: Colors.red, size: 16),
                        ],
                      ),
                    )),
                  ]
                else
                  const Text('Nenhuma box neste módulo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemToolsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ferramentas de Manutenção',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportAllData,
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar Tudo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearAllSharedPrefs,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpar SharedPrefs'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSystemInfo,
                    icon: const Icon(Icons.info),
                    label: const Text('Info Sistema'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Técnicas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDataRow('Aplicativo', 'ReceitaAgro'),
            _buildDataRow('Inspector Version', '2.0.0'),
            _buildDataRow('Debug Mode', kDebugMode ? 'Ativado' : 'Desativado'),
            _buildDataRow('Flutter', 'Disponível'),
            _buildDataRow('Hive', 'Disponível'),
            _buildDataRow('Core Package', 'Integrado'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value.isEmpty || value == 'N/A' 
                    ? Colors.red 
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de ação
  Future<void> _viewBoxData(String boxKey) async {
    try {
      setState(() => _isLoading = true);
      _currentBoxData = await _inspector.loadHiveBoxData(boxKey);
      setState(() {
        _selectedBoxKey = boxKey;
        _isLoading = false;
      });
      
      _showBoxDataDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar dados da box: $e');
    }
  }

  void _showBoxDataDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dados da Box: $_selectedBoxKey'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _currentBoxData.length,
            itemBuilder: (context, index) {
              final record = _currentBoxData[index];
              return Card(
                child: ExpansionTile(
                  title: Text('Registro ${index + 1}'),
                  subtitle: Text('ID: ${record.id}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JSON:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _inspector.formatAsJsonString(record.data),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          ElevatedButton(
            onPressed: () {
              _exportCurrentBoxData();
              Navigator.pop(context);
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBoxData(CustomBoxType box) async {
    try {
      final data = await _inspector.loadHiveBoxData(box.key);
      final jsonData = {
        'boxInfo': {
          'key': box.key,
          'displayName': box.displayName,
          'module': box.module,
          'description': box.description,
          'exportedAt': DateTime.now().toIso8601String(),
        },
        'data': data.map((record) => {
          'id': record.id,
          'data': record.data,
        }).toList(),
      };
      
      final jsonString = _inspector.formatAsJsonString(jsonData);
      
      await SharePlus.instance.share(ShareParams(
        text: jsonString,
        subject: 'Dados da Box: ${box.displayName}',
      ));
      
      _showSuccessSnackBar('Dados da box exportados com sucesso!');
    } catch (e) {
      _showErrorSnackBar('Erro ao exportar dados: $e');
    }
  }

  Future<void> _exportCurrentBoxData() async {
    if (_selectedBoxKey == null || _currentBoxData.isEmpty) return;
    
    final jsonData = {
      'boxKey': _selectedBoxKey,
      'exportedAt': DateTime.now().toIso8601String(),
      'totalRecords': _currentBoxData.length,
      'data': _currentBoxData.map((record) => {
        'id': record.id,
        'data': record.data,
      }).toList(),
    };
    
    final jsonString = _inspector.formatAsJsonString(jsonData);
    
    await SharePlus.instance.share(ShareParams(
      text: jsonString,
      subject: 'Dados da Box: $_selectedBoxKey',
    ));
  }

  Future<void> _removeSharedPref(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text('Deseja remover a chave "$key" das SharedPreferences?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
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
          _showSuccessSnackBar('Chave removida com sucesso!');
          await _loadData(); // Recarregar dados
        } else {
          _showErrorSnackBar('Falha ao remover a chave');
        }
      } catch (e) {
        _showErrorSnackBar('Erro ao remover chave: $e');
      }
    }
  }

  Future<void> _exportAllData() async {
    try {
      setState(() => _isLoading = true);
      
      final allData = {
        'exportInfo': {
          'appName': 'ReceitaAgro',
          'exportedAt': DateTime.now().toIso8601String(),
          'exportType': 'complete',
        },
        'systemHealth': ReceitaAgroDataInspectorInitializer.getSystemHealth(),
        'moduleStats': _moduleStats,
        'sharedPreferences': _sharedPrefsData.map((pref) => {
          'key': pref.key,
          'type': pref.type,
          'value': pref.value,
        }).toList(),
        'hiveBoxes': <String, dynamic>{},
      };
      
      // Exportar dados de todas as boxes
      for (final box in _inspector.customBoxes) {
        try {
          final boxData = await _inspector.loadHiveBoxData(box.key);
          (allData['hiveBoxes'] as Map<String, dynamic>)[box.key] = {
            'info': {
              'displayName': box.displayName,
              'module': box.module,
              'description': box.description,
            },
            'data': boxData.map((record) => {
              'id': record.id,
              'data': record.data,
            }).toList(),
          };
        } catch (e) {
          (allData['hiveBoxes'] as Map<String, dynamic>)[box.key] = {
            'error': e.toString(),
          };
        }
      }
      
      final jsonString = _inspector.formatAsJsonString(allData);
      
      await SharePlus.instance.share(ShareParams(
        text: jsonString,
        subject: 'Exportação Completa - ReceitaAgro Data Inspector',
      ));
      
      setState(() => _isLoading = false);
      _showSuccessSnackBar('Todos os dados exportados com sucesso!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro na exportação completa: $e');
    }
  }

  Future<void> _refreshData() async {
    _showSuccessSnackBar('Atualizando dados...');
    await _loadData();
    _showSuccessSnackBar('Dados atualizados!');
  }

  Future<void> _clearAllSharedPrefs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Limpeza'),
        content: const Text(
          'Deseja limpar TODAS as SharedPreferences? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // Remover todas as SharedPreferences uma por uma
        for (final pref in _sharedPrefsData) {
          await _inspector.removeSharedPreferencesKey(pref.key);
        }
        
        _showSuccessSnackBar('SharedPreferences limpas com sucesso!');
        await _loadData(); // Recarregar dados
      } catch (e) {
        _showErrorSnackBar('Erro ao limpar SharedPreferences: $e');
      }
    }
  }

  void _showSystemInfo() {
    final healthData = ReceitaAgroDataInspectorInitializer.getSystemHealth();
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Sistema'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status Geral: ${healthData['status']}'),
              Text('Saúde: ${healthData['healthPercentage'].toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              const Text('Boxes:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total Registrada: ${healthData['totalRegisteredBoxes']}'),
              Text('Saudáveis: ${healthData['healthyBoxes']}'),
              Text('Com Erro: ${healthData['errorBoxes']}'),
              const SizedBox(height: 16),
              Text('Total de Registros: ${healthData['totalRecords']}'),
              Text('Verificado em: ${_formatDateTime(healthData['checkedAt']?.toString())}'),
            ],
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

  // Utilitários
  String _formatDateTime(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessSnackBar('Copiado para a área de transferência');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}