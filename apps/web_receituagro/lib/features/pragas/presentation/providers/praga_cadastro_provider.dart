import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/praga.dart';
import '../../domain/entities/tipo_praga.dart';

part 'praga_cadastro_provider.g.dart';

/// Provider for managing praga cadastro state
@riverpod
class PragaCadastro extends _$PragaCadastro {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  /// Load existing praga for editing
  Future<Either<Failure, Praga>> loadPraga(String pragaId) async {
    final repository = ref.read(pragasRepositoryProvider);
    return repository.getPragaById(pragaId);
  }

  /// Save praga (create or update)
  Future<Either<Failure, Praga>> savePraga({
    String? id, // null = create, non-null = update
    required String nomeComum,
    required String nomeCientifico,
    required String ordem,
    required String familia,
    TipoPraga? tipoPraga,
    String? descricao,
    String? imageUrl,
    List<String>? culturasAfetadas,
    String? danos,
    String? controle,
    // Taxonomia - Reino
    String? dominio,
    String? reino,
    String? subReino,
    // Taxonomia - Clado
    String? clado01,
    String? clado02,
    String? clado03,
    // Taxonomia - Divisão
    String? superDivisao,
    String? divisao,
    String? subDivisao,
    // Taxonomia - Classe
    String? classe,
    String? subClasse,
    // Taxonomia - Família
    String? superFamilia,
    String? subFamilia,
    // Taxonomia - Ordem
    String? superOrdem,
    String? subOrdem,
    String? infraOrdem,
    // Taxonomia - Outros
    String? tribo,
    String? subTribo,
    String? genero,
    String? especie,
  }) async {
    state = const AsyncLoading();

    try {
      final praga = Praga(
        id: id ?? const Uuid().v4(),
        nomeComum: nomeComum,
        nomeCientifico: nomeCientifico,
        ordem: ordem,
        familia: familia,
        tipoPraga: tipoPraga ?? TipoPraga.inseto,
        descricao: descricao,
        imageUrl: imageUrl,
        culturasAfetadas: culturasAfetadas,
        danos: danos,
        controle: controle,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Taxonomia - Reino
        dominio: dominio,
        reino: reino,
        subReino: subReino,
        // Taxonomia - Clado
        clado01: clado01,
        clado02: clado02,
        clado03: clado03,
        // Taxonomia - Divisão
        superDivisao: superDivisao,
        divisao: divisao,
        subDivisao: subDivisao,
        // Taxonomia - Classe
        classe: classe,
        subClasse: subClasse,
        // Taxonomia - Família
        superFamilia: superFamilia,
        subFamilia: subFamilia,
        // Taxonomia - Ordem
        superOrdem: superOrdem,
        subOrdem: subOrdem,
        infraOrdem: infraOrdem,
        // Taxonomia - Outros
        tribo: tribo,
        subTribo: subTribo,
        genero: genero,
        especie: especie,
      );

      Either<Failure, Praga> result;

      if (id == null) {
        // Create
        final createUseCase = ref.read(createPragaUseCaseProvider);
        result = await createUseCase(praga);
      } else {
        // Update
        final updateUseCase = ref.read(updatePragaUseCaseProvider);
        result = await updateUseCase(praga);
      }

      result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
        },
        (praga) {
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
