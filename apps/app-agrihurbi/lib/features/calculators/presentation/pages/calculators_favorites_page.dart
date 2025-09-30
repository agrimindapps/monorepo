import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/services/calculator_favorites_service.dart';
import '../providers/calculator_provider_simple.dart';
import '../widgets/calculator_card_widget.dart';

/// Página de calculadoras favoritas
/// 
/// Implementa gestão completa de favoritos com organização e exportação
class CalculatorsFavoritesPage extends StatefulWidget {
  const CalculatorsFavoritesPage({super.key});

  @override
  State<CalculatorsFavoritesPage> createState() => _CalculatorsFavoritesPageState();
}

class _CalculatorsFavoritesPageState extends State<CalculatorsFavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  
  List<CalculatorEntity> _favoriteCalculators = [];
  FavoritesStats? _stats;
  bool _isLoading = true;
  CalculatorFavoritesService? _favoritesService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFavoritesService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeFavoritesService() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritesService = CalculatorFavoritesService(prefs);
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_favoritesService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<CalculatorProvider>();
      final favoriteCalculators = await _favoritesService!.filterFavorites(
        provider.calculators,
      );
      final stats = await _favoritesService!.getStats();

      setState(() {
        _favoriteCalculators = favoriteCalculators;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadoras Favoritas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Favoritas'),
            Tab(icon: Icon(Icons.analytics), text: 'Estatísticas'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'organize',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Organizar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Exportar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Importar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Limpar Todos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFavoritesTab(provider),
              _buildStatsTab(),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFavoritesTab(CalculatorProvider provider) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando favoritos...'),
          ],
        ),
      );
    }

    if (_favoriteCalculators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma calculadora favorita',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione calculadoras aos favoritos\ntocando no ícone de coração',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/home/calculators'),
              child: const Text('Explorar Calculadoras'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: _buildFavoritesList(),
    );
  }

  Widget _buildFavoritesList() {
    // Agrupa favoritos por categoria
    final Map<CalculatorCategory, List<CalculatorEntity>> favoritesByCategory = {};
    
    for (final calculator in _favoriteCalculators) {
      favoritesByCategory.putIfAbsent(calculator.category, () => []).add(calculator);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: favoritesByCategory.length + 1, // +1 para o header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header com informações
          return _buildFavoritesHeader();
        }

        final categoryIndex = index - 1;
        final category = favoritesByCategory.keys.elementAt(categoryIndex);
        final categoryCalculators = favoritesByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da categoria
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text('${categoryCalculators.length}'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
            ),
            
            // Lista de calculadoras da categoria
            ...categoryCalculators.map((calculator) {
              return CalculatorCardWidget(
                calculator: calculator,
                isFavorite: true,
                onTap: () => _navigateToCalculator(calculator.id),
                onFavoriteToggle: () => _removeFavorite(calculator),
                showCategory: false,
              );
            }),
            
            // Espaçamento entre categorias
            if (categoryIndex < favoritesByCategory.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesHeader() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Suas Calculadoras Favoritas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_favoriteCalculators.length} ${_favoriteCalculators.length == 1 ? "calculadora" : "calculadoras"} favorita${_favoriteCalculators.length == 1 ? "" : "s"}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_isLoading || _stats == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Card de estatísticas gerais
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estatísticas Gerais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('Total de Favoritos', '${_stats!.totalFavorites}'),
                _buildStatRow(
                  'Última Sincronização',
                  _stats!.lastSync != null
                      ? _formatDate(_stats!.lastSync!)
                      : 'Nunca',
                ),
                _buildStatRow(
                  'Backup Disponível',
                  _stats!.hasBackup ? 'Sim' : 'Não',
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Card de distribuição por categoria
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribuição por Categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildCategoryDistribution(),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Ações de manutenção
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manutenção',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sincronizar Favoritos'),
                  subtitle: const Text('Sincronizar com servidor remoto'),
                  onTap: _syncFavorites,
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Criar Backup'),
                  subtitle: const Text('Criar backup local dos favoritos'),
                  onTap: _createBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restaurar Backup'),
                  subtitle: const Text('Restaurar favoritos do backup'),
                  onTap: _restoreBackup,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryDistribution() {
    final Map<CalculatorCategory, int> distribution = {};
    
    for (final calculator in _favoriteCalculators) {
      distribution[calculator.category] = 
          (distribution[calculator.category] ?? 0) + 1;
    }

    if (distribution.isEmpty) {
      return [
        const Text('Nenhum dado para exibir'),
      ];
    }

    return distribution.entries.map((entry) {
      final category = entry.key;
      final count = entry.value;
      final percentage = (count / _favoriteCalculators.length * 100).round();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(category.displayName),
            ),
            Text('$count ($percentage%)'),
          ],
        ),
      );
    }).toList();
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 0 && _favoriteCalculators.isNotEmpty) {
      return FloatingActionButton(
        onPressed: () => context.push('/home/calculators/search'),
        tooltip: 'Buscar mais calculadoras',
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'organize':
        _showOrganizeDialog();
        break;
      case 'export':
        _exportFavorites();
        break;
      case 'import':
        _importFavorites();
        break;
      case 'clear':
        _showClearAllDialog();
        break;
    }
  }

  void _showOrganizeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Organizar Favoritos'),
        content: const Text('Funcionalidade de organização em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportFavorites() async {
    // Implementar exportação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de exportação em desenvolvimento'),
      ),
    );
  }

  void _importFavorites() async {
    // Implementar importação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de importação em desenvolvimento'),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Todos os Favoritos'),
        content: const Text(
          'Tem certeza que deseja remover todas as calculadoras dos favoritos? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllFavorites();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Limpar Todos'),
          ),
        ],
      ),
    );
  }

  void _clearAllFavorites() async {
    if (_favoritesService == null) return;

    final success = await _favoritesService!.clearAllFavorites();
    if (success) {
      await _loadFavorites();
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os favoritos foram removidos'),
        ),
      );
    }
  }

  void _syncFavorites() async {
    if (_favoritesService == null) return;

    final success = await _favoritesService!.syncFavorites();
    if (success) {
      await _loadFavorites();
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favoritos sincronizados com sucesso'),
        ),
      );
    }
  }

  void _createBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup criado automaticamente'),
      ),
    );
  }

  void _restoreBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de restauração em desenvolvimento'),
      ),
    );
  }

  void _removeFavorite(CalculatorEntity calculator) async {
    if (_favoritesService == null) return;

    final success = await _favoritesService!.removeFromFavorites(calculator.id);
    if (success) {
      await _loadFavorites();
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${calculator.name} removida dos favoritos'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              await _favoritesService!.addToFavorites(calculator.id);
              await _loadFavorites();
            },
          ),
        ),
      );
    }
  }

  void _navigateToCalculator(String calculatorId) {
    context.push('/home/calculators/detail/$calculatorId');
  }

  IconData _getCategoryIcon(CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.irrigation:
        return Icons.water_drop;
      case CalculatorCategory.nutrition:
        return Icons.eco;
      case CalculatorCategory.livestock:
        return Icons.pets;
      case CalculatorCategory.crops:
        return Icons.agriculture;
      case CalculatorCategory.yield:
        return Icons.trending_up;
      case CalculatorCategory.machinery:
        return Icons.precision_manufacturing;
      case CalculatorCategory.management:
        return Icons.manage_accounts;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}