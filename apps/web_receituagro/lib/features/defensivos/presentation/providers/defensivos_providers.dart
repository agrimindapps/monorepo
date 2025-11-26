import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/defensivo.dart';
import '../../domain/services/defensivos_filter_service.dart';
import '../../domain/services/defensivos_pagination_service.dart';
import '../../domain/usecases/search_defensivos_usecase.dart';

part 'defensivos_providers.g.dart';

// ========== Services Providers ==========

@riverpod
DefensivosFilterService defensivosFilterService(Ref ref) {
  return DefensivosFilterService();
}

@riverpod
DefensivosPaginationService defensivosPaginationService(Ref ref) {
  return DefensivosPaginationService();
}

// ========== State Providers ==========

/// Main defensivos state provider
@riverpod
class DefensivosNotifier extends _$DefensivosNotifier {
  @override
  FutureOr<List<Defensivo>> build() async {
    return _fetchDefensivos();
  }

  /// Fetch all defensivos
  Future<List<Defensivo>> _fetchDefensivos() async {
    final useCase = ref.read(getAllDefensivosUseCaseProvider);
    final result = await useCase(const NoParams());

    return result.fold(
      (failure) => throw Exception(failure.message),
      (defensivos) => defensivos,
    );
  }

  /// Search defensivos by query
  Future<void> search(String query) async {
    state = const AsyncLoading();

    final useCase = ref.read(searchDefensivosUseCaseProvider);
    final filterService = ref.read(defensivosFilterServiceProvider);

    final result = await useCase(SearchDefensivosParams(query: query));

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (defensivos) {
        // Apply client-side filtering for better UX
        final filtered = filterService.filterByQuery(defensivos, query);
        return AsyncData(filtered);
      },
    );

    // Reset pagination when searching
    ref.read(currentPageProvider.notifier).firstPage();
  }

  /// Refresh defensivos
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDefensivos());
  }

  /// Reset to show all defensivos
  void showAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDefensivos());
    ref.read(currentPageProvider.notifier).firstPage();
  }

  /// Delete a defensivo by ID
  Future<bool> deleteDefensivo(String id) async {
    final useCase = ref.read(deleteDefensivoUseCaseProvider);
    final result = await useCase(id);

    return result.fold(
      (failure) {
        // Handle error - could show snackbar here
        return false;
      },
      (_) {
        // Success - refresh the list
        refresh();
        return true;
      },
    );
  }
}

// ========== Pagination State ==========

/// Current page provider
@riverpod
class CurrentPage extends _$CurrentPage {
  @override
  int build() => 0;

  void nextPage(int totalPages) {
    if (state < totalPages - 1) {
      state = state + 1;
    }
  }

  void previousPage() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void goToPage(int page) {
    state = page;
  }

  void firstPage() {
    state = 0;
  }

  void lastPage(int totalPages) {
    state = totalPages - 1;
  }
}

// ========== Derived States ==========

/// Paginated defensivos (current page items)
@riverpod
List<Defensivo> paginatedDefensivos(Ref ref) {
  final defensivosAsync = ref.watch(defensivosProvider);
  final currentPage = ref.watch(currentPageProvider);
  final paginationService = ref.watch(defensivosPaginationServiceProvider);

  return defensivosAsync.when(
    data: (defensivos) {
      return paginationService.getPage(defensivos, currentPage);
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Total pages
@riverpod
int totalPages(Ref ref) {
  final defensivosAsync = ref.watch(defensivosProvider);
  final paginationService = ref.watch(defensivosPaginationServiceProvider);

  return defensivosAsync.when(
    data: (defensivos) {
      return paginationService.getTotalPages(defensivos.length);
    },
    loading: () => 1,
    error: (_, __) => 1,
  );
}

/// Page numbers to display in pagination UI
@riverpod
List<int> pageNumbers(Ref ref) {
  final currentPage = ref.watch(currentPageProvider);
  final totalPagesCount = ref.watch(totalPagesProvider);
  final paginationService = ref.watch(defensivosPaginationServiceProvider);

  return paginationService.getPageNumbers(currentPage, totalPagesCount);
}
