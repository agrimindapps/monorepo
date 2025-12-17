import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../../defensivos/domain/entities/defensivo.dart';
import '../../../defensivos/domain/entities/diagnostico.dart';
import '../../../defensivos/domain/usecases/search_defensivos_usecase.dart';
import '../../../defensivos/presentation/providers/defensivos_usecases_providers.dart';

part 'public_defensivos_providers.g.dart';

// ========== State Providers ==========

/// Public defensivos state provider (Read Only)
@riverpod
class PublicDefensivosNotifier extends _$PublicDefensivosNotifier {
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

    if (query.trim().isEmpty) {
      state = await AsyncValue.guard(() => _fetchDefensivos());
      return;
    }

    final useCase = ref.read(searchDefensivosUseCaseProvider);
    final result = await useCase(SearchDefensivosParams(query: query));

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (defensivos) => AsyncData(defensivos),
    );
  }

  /// Refresh defensivos
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDefensivos());
  }
}

// ========== Details Providers ==========

/// Fetch defensivo details by ID
@riverpod
Future<Defensivo> publicDefensivoDetails(Ref ref, String id) async {
  final useCase = ref.read(getDefensivoByIdUseCaseProvider);
  final result = await useCase(id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (defensivo) => defensivo,
  );
}

/// Fetch diagnosticos by defensivo ID
@riverpod
Future<List<Diagnostico>> publicDefensivoDiagnosticos(Ref ref, String id) async {
  final useCase = ref.read(getDiagnosticosByDefensivoIdUseCaseProvider);
  final result = await useCase(id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (diagnosticos) => diagnosticos,
  );
}

// ========== Pagination State ==========

/// Current page provider for public list
@riverpod
class PublicCurrentPage extends _$PublicCurrentPage {
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
}

// ========== Derived States ==========

/// Paginated public defensivos
@riverpod
List<Defensivo> publicPaginatedDefensivos(Ref ref) {
  final defensivosAsync = ref.watch(publicDefensivosNotifierProvider);
  final currentPage = ref.watch(publicCurrentPageProvider);
  const pageSize = 12;

  return defensivosAsync.when(
    data: (defensivos) {
      final startIndex = currentPage * pageSize;
      if (startIndex >= defensivos.length) return [];
      
      final endIndex = startIndex + pageSize;
      return defensivos.sublist(
        startIndex, 
        endIndex > defensivos.length ? defensivos.length : endIndex
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Total pages for public list
@riverpod
int publicTotalPages(Ref ref) {
  final defensivosAsync = ref.watch(publicDefensivosNotifierProvider);
  const pageSize = 12;

  return defensivosAsync.when(
    data: (defensivos) => (defensivos.length / pageSize).ceil(),
    loading: () => 0,
    error: (_, __) => 0,
  );
}
