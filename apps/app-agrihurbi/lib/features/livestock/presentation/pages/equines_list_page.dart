import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/equine_entity.dart';
import '../providers/equines_provider.dart';
import '../widgets/equine_card_widget.dart';
import '../widgets/livestock_search_widget.dart';

/// Página de listagem de equinos com filtros e busca
class EquinesListPage extends ConsumerStatefulWidget {
  const EquinesListPage({super.key});

  @override
  ConsumerState<EquinesListPage> createState() => _EquinesListPageState();
}

class _EquinesListPageState extends ConsumerState<EquinesListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  // bool _showFilters = false; // TODO: Implementar filtros avançados para equinos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(equinesProvider.notifier).loadEquines();
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
    final provider = ref.watch(equinesProvider.notifier);
    final state = ref.watch(equinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equinos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadEquines(),
            tooltip: 'Atualizar',
          ),
          /* // Filtros futuros
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
          */
        ],
      ),
      body: Column(
        children: [
          LivestockSearchWidget(
            controller: _searchController,
            onChanged: provider.updateSearchQuery,
            hintText: 'Buscar equinos...',
          ),
          // Se houver filtros, adicionar aqui
          Expanded(child: _buildEquinesList(context, provider, state)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEquine(context),
        tooltip: 'Adicionar Equino',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEquinesList(
    BuildContext context, 
    EquinesNotifier provider, 
    EquinesState state
  ) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando equinos...'),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
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
              'Erro ao carregar equinos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadEquines();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final filteredEquines = state.filteredEquines;

    if (filteredEquines.isEmpty) {
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
              state.searchQuery.isEmpty
                  ? 'Nenhum equino cadastrado'
                  : 'Nenhum equino encontrado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isEmpty
                  ? 'Adicione seu primeiro equino clicando no botão +'
                  : 'Tente ajustar os filtros de busca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadEquines(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: filteredEquines.length,
        itemBuilder: (context, index) {
          final equine = filteredEquines[index];
          return EquineCardWidget(
            equine: equine,
            onTap: () => _navigateToEquineDetail(context, equine.id),
            onEdit: () => _navigateToEditEquine(context, equine.id),
            onDelete: () => _confirmDeleteEquine(context, equine),
          );
        },
      ),
    );
  }

  void _navigateToAddEquine(BuildContext context) async {
    // Ajustar rota conforme go_router config
    await context.push('/home/livestock/equines/add');
    // Refresh após retorno
    ref.read(equinesProvider.notifier).loadEquines();
  }

  void _navigateToEquineDetail(BuildContext context, String equineId) {
    context.push('/home/livestock/equines/detail/$equineId');
  }

  void _navigateToEditEquine(BuildContext context, String equineId) async {
    await context.push('/home/livestock/equines/edit/$equineId');
    // Refresh após retorno
    ref.read(equinesProvider.notifier).loadEquines();
  }

  void _confirmDeleteEquine(BuildContext context, EquineEntity equine) {
    // Para deleção rápida na lista, podemos precisar implementar delete no provider de leitura
    // ou usar o management provider aqui também.
    // Por simplicidade, vamos mostrar dialog e se confirmado usar management provider
    // Mas precisamos importar o management provider.
    // Vamos deixar como TODO ou implementar usando o management provider.
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Funcionalidade de exclusão'),
            content: const Text('Para excluir, por favor abra a tela de edição.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
