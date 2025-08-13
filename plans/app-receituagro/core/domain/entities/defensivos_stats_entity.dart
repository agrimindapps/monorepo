/// Entity que representa as estatísticas dos defensivos no domínio
class DefensivosStatsEntity {
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModosDeAcao;
  final int totalIngredientesAtivos;
  final int totalClassesAgronomicas;

  const DefensivosStatsEntity({
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModosDeAcao,
    required this.totalIngredientesAtivos,
    required this.totalClassesAgronomicas,
  });

  /// Regra de negócio: verifica se há dados suficientes para exibir estatísticas
  bool get hasValidData {
    return totalDefensivos > 0 &&
        totalFabricantes > 0 &&
        totalModosDeAcao > 0 &&
        totalIngredientesAtivos > 0 &&
        totalClassesAgronomicas > 0;
  }

  /// Regra de negócio: calcula a média de defensivos por fabricante
  double get defensivosPorFabricante {
    if (totalFabricantes == 0) return 0;
    return totalDefensivos / totalFabricantes;
  }

  @override
  String toString() {
    return 'DefensivosStatsEntity{totalDefensivos: $totalDefensivos, totalFabricantes: $totalFabricantes}';
  }

  DefensivosStatsEntity copyWith({
    int? totalDefensivos,
    int? totalFabricantes,
    int? totalModosDeAcao,
    int? totalIngredientesAtivos,
    int? totalClassesAgronomicas,
  }) {
    return DefensivosStatsEntity(
      totalDefensivos: totalDefensivos ?? this.totalDefensivos,
      totalFabricantes: totalFabricantes ?? this.totalFabricantes,
      totalModosDeAcao: totalModosDeAcao ?? this.totalModosDeAcao,
      totalIngredientesAtivos: totalIngredientesAtivos ?? this.totalIngredientesAtivos,
      totalClassesAgronomicas: totalClassesAgronomicas ?? this.totalClassesAgronomicas,
    );
  }
}