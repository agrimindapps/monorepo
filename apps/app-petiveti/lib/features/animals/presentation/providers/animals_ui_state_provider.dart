import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/animal.dart';
import 'animals_provider.dart';

/// Local UI state for the Animals page
/// 
/// This provider manages UI-specific state that doesn't belong
/// in the global animals provider, following Clean Architecture principles
class AnimalsUIState {
  final bool isSearchMode;
  final String searchQuery;
  final int currentPage;
  final int itemsPerPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const AnimalsUIState({
    this.isSearchMode = false,
    this.searchQuery = '',
    this.currentPage = 0,
    this.itemsPerPage = 20,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  AnimalsUIState copyWith({
    bool? isSearchMode,
    String? searchQuery,
    int? currentPage,
    int? itemsPerPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return AnimalsUIState(
      isSearchMode: isSearchMode ?? this.isSearchMode,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// Calculate the number of items to display based on pagination
  int get displayItemCount => (currentPage + 1) * itemsPerPage;
}

class AnimalsUIStateNotifier extends StateNotifier<AnimalsUIState> {
  AnimalsUIStateNotifier() : super(const AnimalsUIState());

  /// Toggle search mode
  void toggleSearchMode() {
    state = state.copyWith(
      isSearchMode: !state.isSearchMode,
      searchQuery: '', // Clear search when toggling
    );
  }

  /// Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 0, // Reset pagination when searching
      hasReachedMax: false,
    );
  }

  /// Load more items for pagination
  void loadMoreItems(int totalItems) {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true);

    // Check if we've reached the maximum
    final nextDisplayCount = state.displayItemCount + state.itemsPerPage;
    final hasReachedMax = nextDisplayCount >= totalItems;

    state = state.copyWith(
      currentPage: state.currentPage + 1,
      isLoadingMore: false,
      hasReachedMax: hasReachedMax,
    );
  }

  /// Reset pagination state
  void resetPagination() {
    state = state.copyWith(
      currentPage: 0,
      hasReachedMax: false,
      isLoadingMore: false,
    );
  }

  /// Clear search and reset to normal mode
  void clearSearch() {
    state = state.copyWith(
      isSearchMode: false,
      searchQuery: '',
      currentPage: 0,
      hasReachedMax: false,
    );
  }
}

/// UI state provider for Animals page
final animalsUIStateProvider = 
    StateNotifierProvider<AnimalsUIStateNotifier, AnimalsUIState>((ref) {
  return AnimalsUIStateNotifier();
});

/// Computed provider for filtered and paginated animals
final filteredAnimalsProvider = Provider<List<Animal>>((ref) {
  final animalsState = ref.watch(animalsProvider);
  final uiState = ref.watch(animalsUIStateProvider);

  // Use the new comprehensive filtering system from AnimalsProvider
  List<Animal> filteredAnimals = animalsState.displayedAnimals;

  // Apply pagination
  final maxItems = uiState.displayItemCount;
  final paginatedAnimals = filteredAnimals.take(maxItems).toList();

  return paginatedAnimals;
});