import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/cultura_entity.dart';
import '../../domain/usecases/get_cultura_by_id_usecase.dart';

/// Provider for culturas list
///
/// Fetches all culturas using the GetCulturasUseCase
/// Throws [Failure] on error (caught by AsyncValue)
final culturasProvider = FutureProvider<List<CulturaEntity>>((ref) async {
  final useCase = ref.watch(getCulturasUseCaseProvider);
  final result = await useCase(const NoParams());

  return result.fold(
    (failure) => throw failure,
    (culturas) => culturas,
  );
});

/// Provider for a single cultura by ID
///
/// Fetches a specific cultura by its ID
/// Throws [Failure] on error (caught by AsyncValue)
final culturaProvider =
    FutureProvider.family<CulturaEntity, String>((ref, id) async {
  final useCase = ref.watch(getCulturaByIdUseCaseProvider);
  final result = await useCase(GetCulturaByIdParams(id));

  return result.fold(
    (failure) => throw failure,
    (cultura) => cultura,
  );
});
