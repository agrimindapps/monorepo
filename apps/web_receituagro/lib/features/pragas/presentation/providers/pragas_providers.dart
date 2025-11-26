import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/praga.dart';
import '../../domain/usecases/get_all_pragas_usecase.dart';

part 'pragas_providers.g.dart';

/// Provider for GetAllPragasUseCase
@riverpod
GetAllPragasUseCase getAllPragasUseCase(Ref ref) {
  return getIt<GetAllPragasUseCase>();
}

/// Provider for pragas list with state management
@riverpod
class PragasNotifier extends _$PragasNotifier {
  @override
  Future<List<Praga>> build() async {
    return _fetchPragas();
  }

  Future<List<Praga>> _fetchPragas() async {
    final useCase = ref.read(getAllPragasUseCaseProvider);
    final result = await useCase(const NoParams());

    return result.fold(
      (failure) => throw Exception(failure.message),
      (pragas) => pragas,
    );
  }

  /// Refresh pragas list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPragas());
  }
}

/// Alias provider for easier access (matches naming convention)
@riverpod
Future<List<Praga>> pragasList(Ref ref) async {
  return ref.watch(pragasProvider.future);
}
