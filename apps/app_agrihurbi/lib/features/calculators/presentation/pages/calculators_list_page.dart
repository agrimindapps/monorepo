import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/calculator_entity.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/calculator_provider_simple.dart';
import '../widgets/calculator_card_widget.dart';
import '../widgets/calculator_search_widget.dart';
import '../widgets/calculator_category_filter.dart';

/// Página de listagem de calculadoras
/// 
/// Implementa navegação por categorias, busca e favoritos
/// Segue o padrão Provider estabelecido na migração livestock
class CalculatorsListPage extends StatefulWidget {
  final String? category;
  
  const CalculatorsListPage({super.key, this.category});

  @override
  State<CalculatorsListPage> createState() => _CalculatorsListPageState();
}

class _CalculatorsListPageState extends State<CalculatorsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Carrega dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CalculatorProvider>();
      provider.refreshAllData();
      
      // Aplica filtro de categoria se especificado
      if (widget.category != null) {
        final category = _mapStringToCategory(widget.category!);
        if (category != null) {
          provider.updateCategoryFilter(category);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calculate), text: 'Todas'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoritas'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CalculatorProvider>().refreshAllData(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Barra de busca e filtros
              _buildSearchAndFilters(provider),
              
              // Conteúdo principal em abas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllCalculatorsTab(provider),
                    _buildFavoritesTab(provider),
                    _buildHistoryTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(CalculatorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CalculatorSearchWidget(
            controller: _searchController,
            onChanged: provider.updateSearchQuery,
            hintText: 'Buscar calculadoras...',
          ),
          const SizedBox(height: 12),
          CalculatorCategoryFilter(
            selectedCategory: provider.selectedCategory,
            onCategoryChanged: provider.updateCategoryFilter,
            onClearFilters: provider.clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildAllCalculatorsTab(CalculatorProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando calculadoras...'),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar calculadoras',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadCalculators();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final calculators = provider.filteredCalculators;

    if (calculators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isEmpty
                  ? 'Nenhuma calculadora disponível'
                  : 'Nenhuma calculadora encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.searchQuery.isEmpty
                  ? 'As calculadoras ainda não foram implementadas'
                  : 'Tente ajustar os filtros de busca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (provider.searchQuery.isNotEmpty || provider.selectedCategory != null)
              const SizedBox(height: 16),
            if (provider.searchQuery.isNotEmpty || provider.selectedCategory != null)
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.clearFilters();
                },
                child: const Text('Limpar Filtros'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCalculators(),
      child: _buildCalculatorsList(calculators, provider),
    );
  }

  Widget _buildFavoritesTab(CalculatorProvider provider) {
    final favoriteCalculators = provider.favoriteCalculators;

    if (provider.isLoadingFavorites) {
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

    if (favoriteCalculators.isEmpty) {
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
          ],
        ),
      );
    }

    return _buildCalculatorsList(favoriteCalculators, provider);
  }

  Widget _buildHistoryTab(CalculatorProvider provider) {
    final history = provider.calculationHistory;

    if (provider.isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando histórico...'),
          ],
        ),
      );
    }

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum cálculo no histórico',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Execute cálculos para vê-los\naparecendo nesta seção',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final historyItem = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.calculate, color: Colors.white),
            ),
            title: Text(historyItem.calculatorName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatHistoryResult(historyItem)),
                const SizedBox(height: 4),
                Text(
                  _formatDate(historyItem.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleHistoryAction(value, historyItem, provider),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reapply',
                  child: Row(
                    children: [
                      Icon(Icons.replay),
                      SizedBox(width: 8),
                      Text('Reaplicar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Remover'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _navigateToCalculatorWithHistory(historyItem, provider),
          ),
        );
      },
    );
  }

  Widget _buildCalculatorsList(List<CalculatorEntity> calculators, CalculatorProvider provider) {
    // Agrupa calculadoras por categoria para melhor visualização
    final Map<CalculatorCategory, List<CalculatorEntity>> calculatorsByCategory = {};
    
    for (final calculator in calculators) {
      calculatorsByCategory.putIfAbsent(calculator.category, () => []).add(calculator);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: calculatorsByCategory.length,
      itemBuilder: (context, categoryIndex) {
        final category = calculatorsByCategory.keys.elementAt(categoryIndex);
        final categoryCalculators = calculatorsByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da categoria
            if (provider.selectedCategory == null) // Só mostra se não há filtro de categoria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  category.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            
            // Lista de calculadoras da categoria
            ...categoryCalculators.map((calculator) {
              return CalculatorCardWidget(
                calculator: calculator,
                isFavorite: provider.isCalculatorFavorite(calculator.id),
                onTap: () => _navigateToCalculator(calculator.id),
                onFavoriteToggle: () => provider.toggleFavorite(calculator.id),
              );
            }),
            
            // Espaçamento entre categorias
            if (categoryIndex < calculatorsByCategory.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _navigateToCalculator(String calculatorId) {
    context.push('/home/calculators/detail/$calculatorId');
  }

  void _navigateToCalculatorWithHistory(
    CalculationHistory historyItem,
    CalculatorProvider provider,
  ) {
    provider.applyHistoryResult(historyItem);
    context.push('/home/calculators/detail/${historyItem.calculatorId}');
  }

  void _handleHistoryAction(
    String action,
    CalculationHistory historyItem,
    CalculatorProvider provider,
  ) {
    switch (action) {
      case 'reapply':
        _navigateToCalculatorWithHistory(historyItem, provider);
        break;
      case 'delete':
        _confirmDeleteHistoryItem(historyItem, provider);
        break;
    }
  }

  void _confirmDeleteHistoryItem(
    CalculationHistory historyItem,
    CalculatorProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover do Histórico'),
        content: Text(
          'Tem certeza que deseja remover "${historyItem.calculatorName}" do histórico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.removeFromHistory(historyItem.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removido do histórico'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  String _formatHistoryResult(CalculationHistory historyItem) {
    final result = historyItem.result;
    if (result.type == ResultType.single && result.values.isNotEmpty) {
      final value = result.values.first;
      return '${value.label}: ${value.value} ${value.unit}';
    } else if (result.type == ResultType.multiple && result.values.isNotEmpty) {
      final primaryValue = result.values.firstWhere(
        (v) => v.isPrimary,
        orElse: () => result.values.first,
      );
      return '${primaryValue.label}: ${primaryValue.value} ${primaryValue.unit}';
    }
    return 'Resultado calculado';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min atrás';
      } else {
        return '${difference.inHours}h atrás';
      }
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getPageTitle() {
    if (widget.category == null) {
      return 'Calculadoras Agrícolas';
    }

    switch (widget.category) {
      case 'nutrition':
        return 'Calculadoras de Nutrição';
      case 'livestock':
        return 'Calculadoras de Pecuária';
      case 'crops':
        return 'Calculadoras de Cultivos';
      case 'soil':
        return 'Calculadoras de Solo';
      case 'irrigation':
        return 'Calculadoras de Irrigação';
      default:
        return 'Calculadoras Agrícolas';
    }
  }

  CalculatorCategory? _mapStringToCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'nutrition':
        return CalculatorCategory.nutrition;
      case 'livestock':
        return CalculatorCategory.livestock;
      case 'crops':
        return CalculatorCategory.crops;
      case 'soil':
        return CalculatorCategory.crops; // Usando crops pois não há categoria soil
      case 'irrigation':
        return CalculatorCategory.irrigation;
      default:
        return null;
    }
  }
}