import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';
import '../../repositories/i_diagnosticos_repository.dart';
import 'i_diagnosticos_metadata_service.dart';

/// Implementation of metadata service for diagnosticos
///
/// Extracts unique values and metadata from diagnosticos
/// for UI components, filters, and analytics.
@Injectable(as: IDiagnosticosMetadataService)
class DiagnosticosMetadataService implements IDiagnosticosMetadataService {
  final IDiagnosticosRepository _repository;

  DiagnosticosMetadataService(this._repository);

  @override
  Future<Either<Failure, List<String>>> getAllDefensivos() async {
    return _repository.getAllDefensivos();
  }

  @override
  Future<Either<Failure, List<String>>> getAllCulturas() async {
    return _repository.getAllCulturas();
  }

  @override
  Future<Either<Failure, List<String>>> getAllPragas() async {
    return _repository.getAllPragas();
  }

  @override
  Future<Either<Failure, List<String>>> getUnidadesMedida() async {
    return _repository.getUnidadesMedida();
  }

  @override
  Future<Either<Failure, DiagnosticoFiltersData>> getFiltersData() async {
    // Fetch all metadata in parallel for efficiency
    final results = await Future.wait([
      getAllDefensivos(),
      getAllCulturas(),
      getAllPragas(),
      getUnidadesMedida(),
    ]);

    // Check for failures
    for (final result in results) {
      if (result.isLeft()) {
        return result.fold(
          (failure) => Left(failure),
          (_) => const Left(CacheFailure('Unexpected error')),
        );
      }
    }

    // Extract successful values
    final defensivos = results[0].fold((l) => <String>[], (r) => r);
    final culturas = results[1].fold((l) => <String>[], (r) => r);
    final pragas = results[2].fold((l) => <String>[], (r) => r);
    final unidades = results[3].fold((l) => <String>[], (r) => r);

    // All application types are available
    const tipos = TipoAplicacao.values;

    return Right(
      DiagnosticoFiltersData(
        defensivos: defensivos,
        culturas: culturas,
        pragas: pragas,
        unidadesMedida: unidades,
        tiposAplicacao: tipos,
      ),
    );
  }

  // ========== Client-side metadata methods ==========

  @override
  DiagnosticoFiltersData extractFiltersDataFromList(
    List<DiagnosticoEntity> diagnosticos,
  ) {
    // Use Sets to collect unique values
    final defensivosSet = <String>{};
    final culturasSet = <String>{};
    final pragasSet = <String>{};
    final unidadesSet = <String>{};
    final tiposSet = <TipoAplicacao>{};

    for (final diagnostico in diagnosticos) {
      // Collect defensivos (prefer name over ID)
      final defensivo = diagnostico.nomeDefensivo ?? diagnostico.idDefensivo;
      if (defensivo.isNotEmpty) {
        defensivosSet.add(defensivo);
      }

      // Collect culturas (prefer name over ID)
      final cultura = diagnostico.nomeCultura ?? diagnostico.idCultura;
      if (cultura.isNotEmpty) {
        culturasSet.add(cultura);
      }

      // Collect pragas (prefer name over ID)
      final praga = diagnostico.nomePraga ?? diagnostico.idPraga;
      if (praga.isNotEmpty) {
        pragasSet.add(praga);
      }

      // Collect measurement units
      if (diagnostico.dosagem.unidadeMedida.isNotEmpty) {
        unidadesSet.add(diagnostico.dosagem.unidadeMedida);
      }

      // Collect application types
      tiposSet.addAll(diagnostico.aplicacao.tiposDisponiveis);
    }

    // Convert sets to sorted lists
    final defensivos = defensivosSet.toList()..sort();
    final culturas = culturasSet.toList()..sort();
    final pragas = pragasSet.toList()..sort();
    final unidades = unidadesSet.toList()..sort();
    final tipos = tiposSet.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return DiagnosticoFiltersData(
      defensivos: defensivos,
      culturas: culturas,
      pragas: pragas,
      unidadesMedida: unidades,
      tiposAplicacao: tipos,
    );
  }
}
