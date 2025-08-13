/// DTO para transferência de estatísticas dos defensivos entre camadas
class DefensivosStatsDto {
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModosDeAcao;
  final int totalIngredientesAtivos;
  final int totalClassesAgronomicas;

  const DefensivosStatsDto({
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModosDeAcao,
    required this.totalIngredientesAtivos,
    required this.totalClassesAgronomicas,
  });

  /// Cria DTO a partir de Map (vindo da camada de infraestrutura)
  factory DefensivosStatsDto.fromMap(Map<String, dynamic> map) {
    return DefensivosStatsDto(
      totalDefensivos: (map['totalDefensivos'] as num?)?.toInt() ?? 0,
      totalFabricantes: (map['totalFabricantes'] as num?)?.toInt() ?? 0,
      totalModosDeAcao: (map['totalModosDeAcao'] as num?)?.toInt() ?? 0,
      totalIngredientesAtivos: (map['totalIngredientesAtivos'] as num?)?.toInt() ?? 0,
      totalClassesAgronomicas: (map['totalClassesAgronomicas'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converte DTO para Map
  Map<String, dynamic> toMap() {
    return {
      'totalDefensivos': totalDefensivos,
      'totalFabricantes': totalFabricantes,
      'totalModosDeAcao': totalModosDeAcao,
      'totalIngredientesAtivos': totalIngredientesAtivos,
      'totalClassesAgronomicas': totalClassesAgronomicas,
    };
  }

  @override
  String toString() {
    return 'DefensivosStatsDto{totalDefensivos: $totalDefensivos, totalFabricantes: $totalFabricantes}';
  }

  DefensivosStatsDto copyWith({
    int? totalDefensivos,
    int? totalFabricantes,
    int? totalModosDeAcao,
    int? totalIngredientesAtivos,
    int? totalClassesAgronomicas,
  }) {
    return DefensivosStatsDto(
      totalDefensivos: totalDefensivos ?? this.totalDefensivos,
      totalFabricantes: totalFabricantes ?? this.totalFabricantes,
      totalModosDeAcao: totalModosDeAcao ?? this.totalModosDeAcao,
      totalIngredientesAtivos: totalIngredientesAtivos ?? this.totalIngredientesAtivos,
      totalClassesAgronomicas: totalClassesAgronomicas ?? this.totalClassesAgronomicas,
    );
  }
}