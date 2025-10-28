import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/defensivo.dart';
import '../../domain/services/defensivos_filter_service.dart';
import '../../domain/services/defensivos_pagination_service.dart';
import '../../domain/usecases/get_all_defensivos_usecase.dart';
import '../../domain/usecases/search_defensivos_usecase.dart';

part 'defensivos_providers.g.dart';

// ========== Use Cases Providers ==========

@riverpod
GetAllDefensivosUseCase getAllDefensivosUseCase(
  GetAllDefensivosUseCaseRef ref,
) {
  return getIt<GetAllDefensivosUseCase>();
}

@riverpod
SearchDefensivosUseCase searchDefensivosUseCase(
  SearchDefensivosUseCaseRef ref,
) {
  return getIt<SearchDefensivosUseCase>();
}

// ========== Services Providers ==========

@riverpod
DefensivosFilterService defensivosFilterService(
  DefensivosFilterServiceRef ref,
) {
  return DefensivosFilterService();
}

@riverpod
DefensivosPaginationService defensivosPaginationService(
  DefensivosPaginationServiceRef ref,
) {
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
    ref.read(currentPageProvider.notifier).state = 0;
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
    ref.read(currentPageProvider.notifier).state = 0;
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
List<Defensivo> paginatedDefensivos(PaginatedDefensivosRef ref) {
  final defensivosAsync = ref.watch(defensivosNotifierProvider);
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
int totalPages(TotalPagesRef ref) {
  final defensivosAsync = ref.watch(defensivosNotifierProvider);
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
List<int> pageNumbers(PageNumbersRef ref) {
  final currentPage = ref.watch(currentPageProvider);
  final totalPagesCount = ref.watch(totalPagesProvider);
  final paginationService = ref.watch(defensivosPaginationServiceProvider);

  return paginationService.getPageNumbers(currentPage, totalPagesCount);
}
