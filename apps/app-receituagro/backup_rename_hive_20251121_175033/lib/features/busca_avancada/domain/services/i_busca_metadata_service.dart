import 'package:core/core.dart';
import '../entities/busca_entity.dart';

/// Interface para serviço de metadados de busca
/// Principle: Single Responsibility - Only metadata operations
abstract class IBuscaMetadataService {
  /// Carrega dados para dropdowns (culturas, pragas, defensivos)
  Future<Either<Failure, BuscaMetadataEntity>> loadMetadata();

  /// Encontra nome de item por ID em uma lista
  String findItemNameById(List<DropdownItemEntity> items, String? id);

  /// Constrói mapa de filtros detalhados com nomes
  Map<String, String> buildDetailedFiltersMap(
    BuscaFiltersEntity filters,
    BuscaMetadataEntity metadata,
  );

  /// Formata lista de culturas para dropdown
  List<DropdownItemEntity> formatCulturas(List<dynamic> culturas);

  /// Formata lista de pragas para dropdown
  List<DropdownItemEntity> formatPragas(List<dynamic> pragas);

  /// Formata lista de defensivos para dropdown
  List<DropdownItemEntity> formatDefensivos(List<dynamic> defensivos);

  /// Carrega todos os dados de dropdown em paralelo
  Future<Either<Failure, Map<String, List<DropdownItemEntity>>>>
      loadAllDropdownData();
}
