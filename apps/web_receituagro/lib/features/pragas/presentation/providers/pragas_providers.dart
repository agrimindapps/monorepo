import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/praga.dart';

part 'pragas_providers.g.dart';

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
