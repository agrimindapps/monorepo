import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cultura.dart';
import '../../domain/repositories/culturas_repository.dart';
import '../../domain/usecases/create_cultura_usecase.dart';
import '../../domain/usecases/update_cultura_usecase.dart';

part 'cultura_cadastro_provider.g.dart';

/// Provider for managing cultura cadastro state
@riverpod
class CulturaCadastro extends _$CulturaCadastro {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  /// Load existing cultura for editing
  Future<Either<Failure, Cultura>> loadCultura(String culturaId) async {
    final repository = getIt<CulturasRepository>();
    return repository.getCulturaById(culturaId);
  }

  /// Save cultura (create or update)
  Future<Either<Failure, Cultura>> saveCultura({
    String? id, // null = create, non-null = update
    required String nomeComum,
    required String nomeCientifico,
    required String familia,
    String? descricao,
    String? imageUrl,
    List<String>? variedades,
  }) async {
    state = const AsyncLoading();

    try {
      final cultura = Cultura(
        id: id ?? const Uuid().v4(),
        nomeComum: nomeComum,
        nomeCientifico: nomeCientifico,
        familia: familia,
        descricao: descricao,
        imageUrl: imageUrl,
        variedades: variedades,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Either<Failure, Cultura> result;

      if (id == null) {
        // Create
        final createUseCase = getIt<CreateCulturaUseCase>();
        result = await createUseCase(cultura);
      } else {
        // Update
        final updateUseCase = getIt<UpdateCulturaUseCase>();
        result = await updateUseCase(cultura);
      }

      result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
        },
        (cultura) {
          state = const AsyncData(null);
        },
      );

      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }
}
