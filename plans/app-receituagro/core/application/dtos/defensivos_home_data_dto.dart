// Project imports:
import 'defensivo_dto.dart';
import 'defensivos_stats_dto.dart';

/// DTO que agrega os dados necessários para a tela home dos defensivos
class DefensivosHomeDataDto {
  final DefensivosStatsDto stats;
  final List<DefensivoDto> recentlyAccessed;
  final List<DefensivoDto> newProducts;

  const DefensivosHomeDataDto({
    required this.stats,
    required this.recentlyAccessed,
    required this.newProducts,
  });

  /// Construtor vazio para inicialização
  factory DefensivosHomeDataDto.empty() {
    return const DefensivosHomeDataDto(
      stats: DefensivosStatsDto(
        totalDefensivos: 0,
        totalFabricantes: 0,
        totalModosDeAcao: 0,
        totalIngredientesAtivos: 0,
        totalClassesAgronomicas: 0,
      ),
      recentlyAccessed: [],
      newProducts: [],
    );
  }

  /// Verifica se há dados válidos para exibir
  bool get hasData {
    return stats.totalDefensivos > 0;
  }

  @override
  String toString() {
    return 'DefensivosHomeDataDto{stats: $stats, recentlyAccessed: ${recentlyAccessed.length}, newProducts: ${newProducts.length}}';
  }

  DefensivosHomeDataDto copyWith({
    DefensivosStatsDto? stats,
    List<DefensivoDto>? recentlyAccessed,
    List<DefensivoDto>? newProducts,
  }) {
    return DefensivosHomeDataDto(
      stats: stats ?? this.stats,
      recentlyAccessed: recentlyAccessed ?? this.recentlyAccessed,
      newProducts: newProducts ?? this.newProducts,
    );
  }
}