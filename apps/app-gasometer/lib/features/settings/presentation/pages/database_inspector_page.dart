import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import '../../../../core/services/database_inspector_service.dart';

class DatabaseInspectorPage extends StatefulWidget {
  const DatabaseInspectorPage({super.key});

  @override
  State<DatabaseInspectorPage> createState() => _DatabaseInspectorPageState();
}

class _DatabaseInspectorPageState extends State<DatabaseInspectorPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _inspectorService = GasOMeterDatabaseInspectorService.instance;
  
  bool _isLoading = false;
  String? _selectedBox;
  List<DatabaseRecord> _boxData = [];
  List<SharedPreferencesRecord> _sharedPrefsData = [];
  Map<String, dynamic> _generalStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGeneralStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGeneralStats() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = _inspectorService.getGasOMeterStats();
      final sharedPrefs = await _inspectorService.loadSharedPreferencesData();
      
      setState(() {
        _generalStats = stats;
        _sharedPrefsData = sharedPrefs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Erro ao carregar estatísticas: $e', isError: true);
    }
  }

  Future<void> _loadBoxData(String boxKey) async {
    setState(() {
      _isLoading = true;
      _selectedBox = boxKey;
    });

    try {
      final data = await _inspectorService.loadHiveBoxData(boxKey);
      setState(() {
        _boxData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Erro ao carregar dados da box $boxKey: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Inspetor de Banco de Dados'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Resumo', icon: Icon(Icons.assessment)),
            Tab(text: 'Hive Boxes', icon: Icon(Icons.storage)),
            Tab(text: 'SharedPreferences', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHiveBoxesTab(),
          _buildSharedPreferencesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildModulesCard(),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_generalStats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estatísticas Gerais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total de Boxes',
                    '${_generalStats['totalHiveBoxes'] ?? 0}',
                    Icons.storage,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total de Registros',
                    '${_generalStats['totalHiveRecords'] ?? 0}',
                    Icons.description,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Módulos',
                    '${_generalStats['totalModules'] ?? 0}',
                    Icons.apps,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'SharedPreferences',
                    '${_sharedPrefsData.length}',
                    Icons.settings,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesCard() {
    final moduleStats = _generalStats['moduleStats'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apps, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Dados por Módulo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final entry in moduleStats.entries) ...[
              _buildModuleStatItem(entry.key, entry.value as Map<String, dynamic>),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModuleStatItem(String moduleName, Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getModuleIcon(moduleName),
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moduleName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${stats['totalBoxes']} boxes • ${stats['totalRecords']} registros',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ações Rápidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadGeneralStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyStatsToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Stats'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiveBoxesTab() {
    final boxesInfo = _inspectorService.getGasOMeterBoxesInfo();

    return Column(
      children: [
        if (_selectedBox != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Visualizando: ${_inspectorService.getBoxDisplayName(_selectedBox!)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _selectedBox = null;
                    _boxData.clear();
                  }),
                  icon: const Icon(Icons.close),
                  label: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: _selectedBox == null 
              ? _buildBoxesList(boxesInfo)
              : _buildBoxDataView(),
        ),
      ],
    );
  }

  Widget _buildBoxesList(List<Map<String, dynamic>> boxesInfo) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: boxesInfo.length,
      itemBuilder: (context, index) {
        final boxInfo = boxesInfo[index];
        final isAvailable = !boxInfo['hasError'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAvailable 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getModuleIcon(boxInfo['module']),
                color: isAvailable 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                size: 20,
              ),
            ),
            title: Text(boxInfo['displayName']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${boxInfo['totalRecords']} registros • ${boxInfo['module']}'),
                if (boxInfo['description'] != null)
                  Text(
                    boxInfo['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                if (boxInfo['hasError'])
                  Text(
                    'Erro: ${boxInfo['error']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            trailing: isAvailable ? const Icon(Icons.chevron_right) : const Icon(Icons.error),
            enabled: isAvailable,
            onTap: isAvailable ? () => _loadBoxData(boxInfo['key']) : null,
          ),
        );
      },
    );
  }

  Widget _buildBoxDataView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_boxData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro encontrado',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _boxData.length,
      itemBuilder: (context, index) {
        final record = _boxData[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text('ID: ${record.id}'),
            subtitle: Text('${record.fields.length} campos'),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    _inspectorService.formatAsJsonString(record.data),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSharedPreferencesTab() {
    if (_sharedPrefsData.isEmpty) {
      return const Center(
        child: Text('Nenhuma preferência encontrada'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sharedPrefsData.length,
      itemBuilder: (context, index) {
        final record = _sharedPrefsData[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(record.key),
            subtitle: Text('${record.type} • ${record.sizeInBytes}B'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(record.formattedValue),
                  tooltip: 'Copiar valor',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSharedPreferencesKey(record.key),
                  tooltip: 'Deletar chave',
                ),
              ],
            ),
            onTap: () => _showValueDialog(record),
          ),
        );
      },
    );
  }

  IconData _getModuleIcon(String module) {
    switch (module) {
      case 'Veículos':
        return Icons.directions_car;
      case 'Combustível':
        return Icons.local_gas_station;
      case 'Manutenção':
        return Icons.build;
      case 'Odômetro':
        return Icons.speed;
      case 'Despesas':
        return Icons.attach_money;
      case 'Sincronização':
        return Icons.sync;
      case 'Categorias':
        return Icons.category;
      default:
        return Icons.storage;
    }
  }

  void _showValueDialog(SharedPreferencesRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Valor: ${record.key}'),
        content: SingleChildScrollView(
          child: SelectableText(
            record.formattedValue,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              _copyToClipboard(record.formattedValue);
              Navigator.of(context).pop();
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSharedPreferencesKey(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir a chave "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _inspectorService.removeSharedPreferencesKey(key);
      if (success) {
        _loadGeneralStats(); // Refresh data
        _showSnackBar('Chave "$key" removida com sucesso');
      } else {
        _showSnackBar('Erro ao remover chave "$key"', isError: true);
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copiado para a área de transferência');
  }

  void _copyStatsToClipboard() {
    final statsText = _inspectorService.formatAsJsonString(_generalStats);
    _copyToClipboard(statsText);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}