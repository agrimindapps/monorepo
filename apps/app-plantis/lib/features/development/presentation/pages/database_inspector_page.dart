import 'package:flutter/material.dart';
import 'package:core/core.dart';

class DatabaseInspectorPage extends StatefulWidget {
  const DatabaseInspectorPage({super.key});

  @override
  State<DatabaseInspectorPage> createState() => _DatabaseInspectorPageState();
}

class _DatabaseInspectorPageState extends State<DatabaseInspectorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _inspectorService = DatabaseInspectorService.instance;
  
  List<String> _availableBoxes = [];
  List<DatabaseRecord> _currentBoxRecords = [];
  List<SharedPreferencesRecord> _sharedPrefsRecords = [];
  String? _selectedBox;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeInspector();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeInspector() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Registrar boxes conhecidas do Plantis
      _inspectorService.registerCustomBoxes([
        const CustomBoxType(
          key: 'plants',
          displayName: 'Plantas',
          description: 'Dados das plantas cadastradas',
          module: 'Plantis',
        ),
        const CustomBoxType(
          key: 'tasks',
          displayName: 'Tarefas',
          description: 'Tarefas de cuidado das plantas',
          module: 'Plantis',
        ),
        const CustomBoxType(
          key: 'spaces',
          displayName: 'Espaços',
          description: 'Espaços onde as plantas estão localizadas',
          module: 'Plantis',
        ),
        const CustomBoxType(
          key: 'settings',
          displayName: 'Configurações',
          description: 'Configurações do app',
          module: 'Plantis',
        ),
      ]);

      _availableBoxes = _inspectorService.getAvailableHiveBoxes();
      await _loadSharedPreferences();

      if (_availableBoxes.isNotEmpty) {
        _selectedBox = _availableBoxes.first;
        await _loadBoxData(_selectedBox!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao inicializar inspector: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBoxData(String boxKey) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _inspectorService.loadHiveBoxData(boxKey);
      setState(() {
        _currentBoxRecords = records;
        _selectedBox = boxKey;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados da box $boxKey: $e';
        _currentBoxRecords = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSharedPreferences() async {
    try {
      final records = await _inspectorService.loadSharedPreferencesData();
      setState(() {
        _sharedPrefsRecords = records;
      });
    } catch (e) {
      // Não mostra erro para SharedPreferences, apenas mantém lista vazia
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Database Inspector'),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Hive Boxes'),
            Tab(text: 'SharedPreferences'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHiveBoxTab(),
          _buildSharedPreferencesTab(),
        ],
      ),
    );
  }

  Widget _buildHiveBoxTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_availableBoxes.isEmpty) {
      return _buildEmptyState('Nenhuma Hive Box encontrada');
    }

    return Column(
      children: [
        // Seletor de Box
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBox,
                  decoration: InputDecoration(
                    labelText: 'Selecionar Box',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _availableBoxes.map((box) {
                    return DropdownMenuItem<String>(
                      value: box,
                      child: Text(_inspectorService.getBoxDisplayName(box)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _loadBoxData(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _initializeInspector(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar',
              ),
            ],
          ),
        ),
        // Lista de registros
        Expanded(
          child: _buildRecordsList(),
        ),
      ],
    );
  }

  Widget _buildSharedPreferencesTab() {
    if (_sharedPrefsRecords.isEmpty) {
      return _buildEmptyState('Nenhuma preferência encontrada');
    }

    return Column(
      children: [
        // Cabeçalho com estatísticas
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_sharedPrefsRecords.length} chaves',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () => _loadSharedPreferences(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar',
              ),
            ],
          ),
        ),
        // Lista de preferências
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _sharedPrefsRecords.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = _sharedPrefsRecords[index];
              return _buildSharedPrefsCard(record);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    if (_currentBoxRecords.isEmpty) {
      return _buildEmptyState('Nenhum registro encontrado nesta box');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _currentBoxRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = _currentBoxRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(DatabaseRecord record) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          'ID: ${record.id}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${record.fields.length} campos',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dados:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _inspectorService.formatAsJsonString(record.data),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedPrefsCard(SharedPreferencesRecord record) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          record.key,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${record.type} • ${record.sizeInBytes} bytes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          record.formattedValue,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        onTap: () => _showSharedPrefsDetails(record),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _initializeInspector(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSharedPrefsDetails(SharedPreferencesRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.key),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${record.type}'),
            Text('Tamanho: ${record.sizeInBytes} bytes'),
            const SizedBox(height: 16),
            const Text('Valor:'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                record.formattedValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar exclusão'),
                  content: Text('Deseja remover a chave "${record.key}"?'),
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
                      child: const Text('Remover'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                Navigator.of(context).pop();
                await _inspectorService.removeSharedPreferencesKey(record.key);
                await _loadSharedPreferences();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chave "${record.key}" removida'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}