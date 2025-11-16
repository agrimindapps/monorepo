import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/ui_components.dart';
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
      final animalsState = ref.read(animalsNotifierProvider);
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
    final animalsState = ref.watch(animalsNotifierProvider);
    final uiState = ref.watch(animalsUIStateProvider);
    final filteredAnimals = ref.watch(filteredAnimalsProvider);
    
    if (animalsState.isLoading && animalsState.animals.isEmpty) {
      return UIComponents.centeredLoading(
        message: 'Carregando seus pets...',
        size: 32,
      );
    }
    
    if (animalsState.animals.isEmpty) {
      return const EmptyAnimalsState();
    }
    if (animalsState.filter.hasActiveFilters && filteredAnimals.isEmpty) {
      return UIComponents.searchEmptyState(
        onClearFilters: () {
          ref.read(animalsNotifierProvider.notifier).clearFilters();
        },
      );
    }

    return Semantics(
      label: 'Lista de pets',
      hint: 'Arraste para baixo para atualizar a lista',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(animalsUIStateProvider.notifier).resetPagination();
          await ref.read(animalsNotifierProvider.notifier).loadAnimals();
        },
        child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemExtent: 120, // Approximate height of AnimalCard
        itemCount: _getItemCount(filteredAnimals.length, uiState),
        itemBuilder: (context, index) {
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
    return UIComponents.loadingListItem(
      semanticLabel: 'Carregando mais pets',
      size: 20,
    );
  }

}
