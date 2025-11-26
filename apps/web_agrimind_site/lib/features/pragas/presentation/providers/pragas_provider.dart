import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/praga_entity.dart';

/// Pragas provider
///
/// Provides the list of all pragas
final pragasProvider = FutureProvider<List<PragaEntity>>((ref) async {
  final usecase = ref.watch(getPragasUseCaseProvider);
  final result = await usecase(NoParams());

  return result.fold((failure) => throw failure, (pragas) => pragas);
});

/// Praga by ID provider
///
/// Provides a specific praga by its ID
final pragaByIdProvider = FutureProvider.family<PragaEntity, String>((
  ref,
  id,
) async {
  final usecase = ref.watch(getPragaByIdUseCaseProvider);
  final result = await usecase(id);

  return result.fold((failure) => throw failure, (praga) => praga);
});
