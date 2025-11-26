import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivo_by_id_usecase.dart';

/// Provider for defensivos list
///
/// Fetches all defensivos using the GetDefensivosUseCase
/// Throws [Failure] on error (caught by AsyncValue)
final defensivosProvider = FutureProvider<List<DefensivoEntity>>((ref) async {
  final useCase = ref.watch(getDefensivosUseCaseProvider);
  final result = await useCase(const NoParams());

  return result.fold(
    (failure) => throw failure,
    (defensivos) => defensivos,
  );
});

/// Provider for a single defensivo by ID
///
/// Fetches a specific defensivo by its ID
/// Throws [Failure] on error (caught by AsyncValue)
final defensivoProvider =
    FutureProvider.family<DefensivoEntity, String>((ref, id) async {
  final useCase = ref.watch(getDefensivoByIdUseCaseProvider);
  final result = await useCase(GetDefensivoByIdParams(id));

  return result.fold(
    (failure) => throw failure,
    (defensivo) => defensivo,
  );
});
