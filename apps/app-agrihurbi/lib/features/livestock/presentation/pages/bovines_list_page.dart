import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/bovine_entity.dart';
import '../providers/livestock_provider.dart';
import '../widgets/bovine_card_widget.dart';
import '../widgets/livestock_filter_widget.dart';
import '../widgets/livestock_search_widget.dart';

/// Página de listagem de bovinos com filtros e busca
///
/// Substitui a antiga bovinos_lista_page.dart do GetX
/// Implementa padrões Provider + go_router para navegação
class BovinesListPage extends ConsumerStatefulWidget {
  const BovinesListPage({super.key});

  @override
  ConsumerState<BovinesListPage> createState() => _BovinesListPageState();
}

class _BovinesListPageState extends ConsumerState<BovinesListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(livestockProviderProvider).loadBovines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(livestockProviderProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovinos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_off,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'sync',
                    child: Row(
                      children: [
                        Icon(Icons.sync),
                        SizedBox(width: 8),
                        Text('Sincronizar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'statistics',
                    child: Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('Estatísticas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Exportar'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          LivestockSearchWidget(
            controller: _searchController,
            onChanged: provider.updateSearchQuery,
            hintText: 'Buscar bovinos...',
          ),
          if (_showFilters)
            LivestockFilterWidget(
              selectedBreed: provider.selectedBreed,
              selectedOriginCountry: provider.selectedOriginCountry,
              selectedAptitude: provider.selectedAptitude,
              selectedBreedingSystem: provider.selectedBreedingSystem,
              availableBreeds: provider.uniqueBreeds,
              availableOriginCountries: provider.uniqueOriginCountries,
              onBreedChanged: provider.updateBreedFilter,
              onOriginCountryChanged: provider.updateOriginCountryFilter,
              onAptitudeChanged: provider.updateAptitudeFilter,
              onBreedingSystemChanged: provider.updateBreedingSystemFilter,
              onClearFilters: provider.clearFilters,
            ),
          Expanded(child: _buildBovinesList(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBovine(context),
        tooltip: 'Adicionar Bovino',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBovinesList(BuildContext context, LivestockProvider provider) {
    if (provider.isLoadingBovines) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando bovinos...'),
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
              'Erro ao carregar bovinos',
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
                provider.loadBovines();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final filteredBovines = provider.filteredBovines;

    if (filteredBovines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isEmpty
                  ? 'Nenhum bovino cadastrado'
                  : 'Nenhum bovino encontrado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.searchQuery.isEmpty
                  ? 'Adicione seu primeiro bovino clicando no botão +'
                  : 'Tente ajustar os filtros de busca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (provider.searchQuery.isNotEmpty || _hasActiveFilters(provider))
              const SizedBox(height: 16),
            if (provider.searchQuery.isNotEmpty || _hasActiveFilters(provider))
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.clearFilters();
                },
                child: const Text('Limpar Busca e Filtros'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadBovines(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: filteredBovines.length,
        itemBuilder: (context, index) {
          final bovine = filteredBovines[index];
          return BovineCardWidget(
            bovine: bovine,
            onTap: () => _navigateToBovineDetail(context, bovine.id),
            onEdit: () => _navigateToEditBovine(context, bovine.id),
            onDelete: () => _confirmDeleteBovine(context, bovine),
          );
        },
      ),
    );
  }

  bool _hasActiveFilters(LivestockProvider provider) {
    return provider.selectedBreed != null ||
        provider.selectedOriginCountry != null ||
        provider.selectedAptitude != null ||
        provider.selectedBreedingSystem != null;
  }

  void _handleMenuAction(String action) {

    switch (action) {
      case 'sync':
        _performSync();
        break;
      case 'statistics':
        _showStatistics();
        break;
      case 'export':
        _exportData();
        break;
    }
  }

  void _performSync() async {
    final provider = ref.read(livestockProviderProvider);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Iniciando sincronização...')));

    await provider.forceSyncNow();

    if (!mounted) return;

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na sincronização: ${provider.errorMessage}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sincronização concluída!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _showStatistics() {
    final provider = ref.read(livestockProviderProvider);

    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Estatísticas do Rebanho'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total de Bovinos: ${provider.totalActiveBovines}'),
                Text('Total de Equinos: ${provider.totalActiveEquines}'),
                Text('Total de Animais: ${provider.totalAnimals}'),
                const SizedBox(height: 16),
                Text(
                  'Filtros Ativos:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (provider.searchQuery.isNotEmpty)
                  Text('• Busca: "${provider.searchQuery}"'),
                if (provider.selectedBreed != null)
                  Text('• Raça: ${provider.selectedBreed}'),
                if (provider.selectedAptitude != null)
                  Text('• Aptidão: ${provider.selectedAptitude!.displayName}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de exportação em desenvolvimento'),
      ),
    );
  }

  void _navigateToAddBovine(BuildContext context) {
    context.push('/home/livestock/bovines/add');
  }

  void _navigateToBovineDetail(BuildContext context, String bovineId) {
    context.push('/home/livestock/bovines/detail/$bovineId');
  }

  void _navigateToEditBovine(BuildContext context, String bovineId) {
    context.push('/home/livestock/bovines/edit/$bovineId');
  }

  void _confirmDeleteBovine(BuildContext context, BovineEntity bovine) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Tem certeza que deseja excluir o bovino "${bovine.commonName}"?\n\n'
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
                  _deleteBovine(bovine);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  void _deleteBovine(BovineEntity bovine) async {
    final provider = ref.read(livestockProviderProvider);
    final success = await provider.deleteBovine(bovine.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bovino "${bovine.commonName}" excluído com sucesso'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir bovino: ${provider.errorMessage}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
