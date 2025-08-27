import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/animal.dart';
import '../providers/animals_provider.dart';
import '../providers/animals_ui_state_provider.dart';
import 'animal_card.dart';
import 'empty_animals_state.dart';

/// Enhanced AnimalsBody with pagination and performance optimizations
/// 
/// Responsibilities:
/// - Display animals list with pagination
/// - Handle pull-to-refresh
/// - Manage loading states
/// - Optimize ListView performance
class AnimalsBody extends ConsumerStatefulWidget {
  final VoidCallback onAddAnimal;
  final void Function(Animal) onViewAnimalDetails;
  final void Function(Animal) onEditAnimal;
  final void Function(Animal) onDeleteAnimal;

  const AnimalsBody({
    super.key,
    required this.onAddAnimal,
    required this.onViewAnimalDetails,
    required this.onEditAnimal,
    required this.onDeleteAnimal,
  });

  @override
  ConsumerState<AnimalsBody> createState() => _AnimalsBodyState();
}

class _AnimalsBodyState extends ConsumerState<AnimalsBody> {
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final animalsState = ref.read(animalsProvider);
      final uiState = ref.read(animalsUIStateProvider);
      
      if (!uiState.isLoadingMore && !uiState.hasReachedMax) {
        ref.read(animalsUIStateProvider.notifier)
          .loadMoreItems(animalsState.animals.length);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    final uiState = ref.watch(animalsUIStateProvider);
    final filteredAnimals = ref.watch(filteredAnimalsProvider);
    
    if (animalsState.isLoading && animalsState.animals.isEmpty) {
      return Semantics(
        label: 'Carregando lista de pets',
        hint: 'Aguarde enquanto carregamos seus pets',
        liveRegion: true,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (animalsState.animals.isEmpty) {
      return const EmptyAnimalsState();
    }

    // Show filtered empty state if filters are applied but no results
    if (animalsState.filter.hasActiveFilters && filteredAnimals.isEmpty) {
      return _buildEmptyFilteredState(animalsState);
    }

    return Semantics(
      label: 'Lista de pets',
      hint: 'Arraste para baixo para atualizar a lista',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(animalsUIStateProvider.notifier).resetPagination();
          await ref.read(animalsProvider.notifier).loadAnimals();
        },
        child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        // Performance optimization: provide itemExtent for better performance
        itemExtent: 120, // Approximate height of AnimalCard
        itemCount: _getItemCount(filteredAnimals.length, uiState),
        itemBuilder: (context, index) {
          // Show loading indicator for last item when loading more
          if (index >= filteredAnimals.length) {
            return _buildLoadingIndicator();
          }
          
          final animal = filteredAnimals[index];
          return AnimalCard(
            key: ValueKey(animal.id), // Performance: stable keys
            animal: animal,
            onTap: () => widget.onViewAnimalDetails(animal),
            onEdit: () => widget.onEditAnimal(animal),
            onDelete: () => widget.onDeleteAnimal(animal),
          );
        },
        ),
      ),
    );
  }

  int _getItemCount(int filteredLength, AnimalsUIState uiState) {
    if (uiState.isLoadingMore) {
      return filteredLength + 1; // +1 for loading indicator
    }
    return filteredLength;
  }

  Widget _buildLoadingIndicator() {
    return Semantics(
      label: 'Carregando mais pets',
      hint: 'Aguarde enquanto carregamos mais pets',
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFilteredState(AnimalsState animalsState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Ícone de busca vazia',
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum pet encontrado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros de busca',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Limpar todos os filtros',
              hint: 'Toque para remover todos os filtros e mostrar todos os pets',
              button: true,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(animalsProvider.notifier).clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}