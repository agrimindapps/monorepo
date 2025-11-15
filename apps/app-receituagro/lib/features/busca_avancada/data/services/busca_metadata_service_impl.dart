import 'package:injectable/injectable.dart';
import 'package:core/core.dart';

import '../../domain/entities/busca_entity.dart';
import '../../domain/services/i_busca_metadata_service.dart';
import '../datasources/i_busca_datasource.dart';

/// Implementação do serviço de metadados de busca
@LazySingleton(as: IBuscaMetadataService)
class BuscaMetadataService implements IBuscaMetadataService {
  final IBuscaDatasource _datasource;

  BuscaMetadataService(this._datasource);

  @override
  Future<Either<Failure, BuscaMetadataEntity>> loadMetadata() async {
    try {
      final data = await loadAllDropdownData();

      return data.fold(
        (failure) => Left(failure),
        (dropdownData) {
          return Right(BuscaMetadataEntity(
            culturas: dropdownData['culturas'] ?? [],
            pragas: dropdownData['pragas'] ?? [],
            defensivos: dropdownData['defensivos'] ?? [],
            tipos: ['diagnostico', 'praga', 'defensivo', 'cultura'],
          ));
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar metadados: $e'));
    }
  }

  @override
  String findItemNameById(List<DropdownItemEntity> items, String? id) {
    if (id == null) return 'Desconhecido(a)';

    final item = items.where((item) => item.id == id).firstOrNull;

    return item?.nome ?? 'Desconhecido(a)';
  }

  @override
  Map<String, String> buildDetailedFiltersMap(
    BuscaFiltersEntity filters,
    BuscaMetadataEntity metadata,
  ) {
    final detailedFilters = <String, String>{};

    if (filters.culturaId != null) {
      detailedFilters['Cultura'] =
          findItemNameById(metadata.culturas, filters.culturaId);
    }

    if (filters.pragaId != null) {
      detailedFilters['Praga'] =
          findItemNameById(metadata.pragas, filters.pragaId);
    }

    if (filters.defensivoId != null) {
      detailedFilters['Defensivo'] =
          findItemNameById(metadata.defensivos, filters.defensivoId);
    }

    if (filters.query != null && filters.query!.isNotEmpty) {
      detailedFilters['Busca'] = filters.query!;
    }

    return detailedFilters;
  }

  @override
  List<DropdownItemEntity> formatCulturas(List<dynamic> culturas) {
    return culturas
        .map((c) => DropdownItemEntity(
              id: c['id'] as String,
              nome: c['nome'] as String,
            ))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  @override
  List<DropdownItemEntity> formatPragas(List<dynamic> pragas) {
    return pragas
        .map((p) => DropdownItemEntity(
              id: p['id'] as String,
              nome: p['nome'] as String,
            ))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  @override
  List<DropdownItemEntity> formatDefensivos(List<dynamic> defensivos) {
    return defensivos
        .map((d) => DropdownItemEntity(
              id: d['id'] as String,
              nome: d['nome'] as String,
            ))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  @override
  Future<Either<Failure, Map<String, List<DropdownItemEntity>>>>
      loadAllDropdownData() async {
    try {
      final results = await Future.wait([
        _datasource.loadCulturas(),
        _datasource.loadPragas(),
        _datasource.loadDefensivos(),
      ]);

      return Right({
        'culturas': formatCulturas(results[0]),
        'pragas': formatPragas(results[1]),
        'defensivos': formatDefensivos(results[2]),
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar dados: $e'));
    }
  }
}
