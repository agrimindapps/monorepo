import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/usecases/get_praga_by_id_usecase.dart';
import '../../domain/usecases/get_pragas_usecase.dart';

/// Get pragas use case provider
final getPragasUseCaseProvider = Provider<GetPragasUseCase>((ref) {
  return getIt<GetPragasUseCase>();
});

/// Pragas provider
///
/// Provides the list of all pragas
final pragasProvider = FutureProvider<List<PragaEntity>>((ref) async {
  final usecase = ref.watch(getPragasUseCaseProvider);
  final result = await usecase(NoParams());

  return result.fold(
    (failure) => throw failure,
    (pragas) => pragas,
  );
});

/// Praga by ID provider
///
/// Provides a specific praga by its ID
final pragaByIdProvider =
    FutureProvider.family<PragaEntity, String>((ref, id) async {
  final usecase = getIt<GetPragaByIdUseCase>();
  final result = await usecase(id);

  return result.fold(
    (failure) => throw failure,
    (praga) => praga,
  );
});
