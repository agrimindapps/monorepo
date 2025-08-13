// Project imports:
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivos_stats_entity.dart';
import '../dtos/defensivo_dto.dart';
import '../dtos/defensivos_stats_dto.dart';

/// Mapper responsável pela conversão entre entities e DTOs
/// 
/// Isola as camadas permitindo mudanças independentes sem quebrar outras camadas
class DefensivosMapper {
  /// Converte DefensivoEntity para DefensivoDto
  DefensivoDto defensivoEntityToDto(DefensivoEntity entity) {
    return DefensivoDto(
      id: entity.id,
      nomeComercial: entity.nomeComercial,
      fabricante: entity.fabricante,
      classeAgronomica: entity.classeAgronomica,
      ingredienteAtivo: entity.ingredienteAtivo,
      modoDeAcao: entity.modoDeAcao,
      isNew: entity.isNew,
      lastAccessedTimestamp: entity.lastAccessed?.toIso8601String(),
    );
  }

  /// Converte DefensivoDto para DefensivoEntity
  DefensivoEntity defensivoDtoToEntity(DefensivoDto dto) {
    DateTime? lastAccessed;
    if (dto.lastAccessedTimestamp != null) {
      lastAccessed = DateTime.tryParse(dto.lastAccessedTimestamp!);
    }

    return DefensivoEntity(
      id: dto.id,
      nomeComercial: dto.nomeComercial,
      fabricante: dto.fabricante,
      classeAgronomica: dto.classeAgronomica,
      ingredienteAtivo: dto.ingredienteAtivo,
      modoDeAcao: dto.modoDeAcao,
      isNew: dto.isNew,
      lastAccessed: lastAccessed,
    );
  }

  /// Converte DefensivosStatsEntity para DefensivosStatsDto
  DefensivosStatsDto statsEntityToDto(DefensivosStatsEntity entity) {
    return DefensivosStatsDto(
      totalDefensivos: entity.totalDefensivos,
      totalFabricantes: entity.totalFabricantes,
      totalModosDeAcao: entity.totalModosDeAcao,
      totalIngredientesAtivos: entity.totalIngredientesAtivos,
      totalClassesAgronomicas: entity.totalClassesAgronomicas,
    );
  }

  /// Converte DefensivosStatsDto para DefensivosStatsEntity
  DefensivosStatsEntity statsDtoToEntity(DefensivosStatsDto dto) {
    return DefensivosStatsEntity(
      totalDefensivos: dto.totalDefensivos,
      totalFabricantes: dto.totalFabricantes,
      totalModosDeAcao: dto.totalModosDeAcao,
      totalIngredientesAtivos: dto.totalIngredientesAtivos,
      totalClassesAgronomicas: dto.totalClassesAgronomicas,
    );
  }

  /// Converte lista de DefensivoEntity para lista de DefensivoDto
  List<DefensivoDto> defensivoEntitiesToDtos(List<DefensivoEntity> entities) {
    return entities.map((entity) => defensivoEntityToDto(entity)).toList();
  }

  /// Converte lista de DefensivoDto para lista de DefensivoEntity
  List<DefensivoEntity> defensivoDtosToEntities(List<DefensivoDto> dtos) {
    return dtos.map((dto) => defensivoDtoToEntity(dto)).toList();
  }
}