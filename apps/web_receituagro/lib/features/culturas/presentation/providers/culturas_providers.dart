import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/cultura.dart';
import '../../domain/usecases/get_all_culturas_usecase.dart';

part 'culturas_providers.g.dart';

/// Provider for GetAllCulturasUseCase
@riverpod
GetAllCulturasUseCase getAllCulturasUseCase(GetAllCulturasUseCaseRef ref) {
  return getIt<GetAllCulturasUseCase>();
}

/// Provider for culturas list with state management
@riverpod
class CulturasNotifier extends _$CulturasNotifier {
  @override
  Future<List<Cultura>> build() async {
    return _fetchCulturas();
  }

  Future<List<Cultura>> _fetchCulturas() async {
    final useCase = ref.read(getAllCulturasUseCaseProvider);
    final result = await useCase(const NoParams());

    return result.fold(
      (failure) => throw Exception(failure.message),
      (culturas) => culturas,
    );
  }

  /// Refresh culturas list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCulturas());
  }
}

/// Alias provider for easier access (matches naming convention)
@riverpod
Future<List<Cultura>> culturasList(CulturasListRef ref) async {
  return ref.watch(culturasNotifierProvider.future);
}
