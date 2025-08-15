/// Entidade base para itens favoritos (Domain Layer)
/// Princípio: Single Responsibility - Apenas representa um favorito
abstract class FavoritoEntity {
  final String id;
  final String tipo;
  final String nomeDisplay;
  final DateTime? adicionadoEm;

  const FavoritoEntity({
    required this.id,
    required this.tipo,
    required this.nomeDisplay,
    this.adicionadoEm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tipo == other.tipo;

  @override
  int get hashCode => id.hashCode ^ tipo.hashCode;
}

/// Favorito de Defensivo
class FavoritoDefensivoEntity extends FavoritoEntity {
  final String nomeComum;
  final String ingredienteAtivo;
  final String? fabricante;

  const FavoritoDefensivoEntity({
    required super.id,
    required this.nomeComum,
    required this.ingredienteAtivo,
    this.fabricante,
    super.adicionadoEm,
  }) : super(
          tipo: TipoFavorito.defensivo,
          nomeDisplay: nomeComum,
        );

  @override
  String toString() {
    return 'FavoritoDefensivoEntity{id: $id, nomeComum: $nomeComum, ingredienteAtivo: $ingredienteAtivo}';
  }
}

/// Favorito de Praga
class FavoritoPragaEntity extends FavoritoEntity {
  final String nomeComum;
  final String nomeCientifico;
  final String tipoPraga;

  const FavoritoPragaEntity({
    required super.id,
    required this.nomeComum,
    required this.nomeCientifico,
    required this.tipoPraga,
    super.adicionadoEm,
  }) : super(
          tipo: TipoFavorito.praga,
          nomeDisplay: nomeComum,
        );

  /// Getters de conveniência
  bool get isInseto => tipoPraga == '1';
  bool get isDoenca => tipoPraga == '2';
  bool get isPlanta => tipoPraga == '3';

  @override
  String toString() {
    return 'FavoritoPragaEntity{id: $id, nomeComum: $nomeComum, nomeCientifico: $nomeCientifico}';
  }
}

/// Favorito de Diagnóstico
class FavoritoDiagnosticoEntity extends FavoritoEntity {
  final String nomePraga;
  final String nomeDefensivo;
  final String cultura;
  final String dosagem;

  const FavoritoDiagnosticoEntity({
    required super.id,
    required this.nomePraga,
    required this.nomeDefensivo,
    required this.cultura,
    required this.dosagem,
    super.adicionadoEm,
  }) : super(
          tipo: TipoFavorito.diagnostico,
          nomeDisplay: '$nomePraga - $nomeDefensivo',
        );

  @override
  String toString() {
    return 'FavoritoDiagnosticoEntity{id: $id, nomePraga: $nomePraga, nomeDefensivo: $nomeDefensivo, cultura: $cultura}';
  }
}

/// Favorito de Cultura
class FavoritoCulturaEntity extends FavoritoEntity {
  final String nomeCultura;
  final String? descricao;

  const FavoritoCulturaEntity({
    required super.id,
    required this.nomeCultura,
    this.descricao,
    super.adicionadoEm,
  }) : super(
          tipo: TipoFavorito.cultura,
          nomeDisplay: nomeCultura,
        );

  @override
  String toString() {
    return 'FavoritoCulturaEntity{id: $id, nomeCultura: $nomeCultura}';
  }
}

/// Value Object para tipos de favorito
class TipoFavorito {
  static const String defensivo = 'defensivo';
  static const String praga = 'praga';
  static const String diagnostico = 'diagnostico';
  static const String cultura = 'cultura';

  static const List<String> todos = [
    defensivo,
    praga,
    diagnostico,
    cultura,
  ];

  static bool isValid(String tipo) => todos.contains(tipo);
}

/// Value Object para estatísticas de favoritos
class FavoritosStats {
  final int totalDefensivos;
  final int totalPragas;
  final int totalDiagnosticos;
  final int totalCulturas;
  final int total;

  const FavoritosStats({
    required this.totalDefensivos,
    required this.totalPragas,
    required this.totalDiagnosticos,
    required this.totalCulturas,
  }) : total = totalDefensivos + totalPragas + totalDiagnosticos + totalCulturas;

  factory FavoritosStats.empty() {
    return const FavoritosStats(
      totalDefensivos: 0,
      totalPragas: 0,
      totalDiagnosticos: 0,
      totalCulturas: 0,
    );
  }

  Map<String, int> toMap() {
    return {
      TipoFavorito.defensivo: totalDefensivos,
      TipoFavorito.praga: totalPragas,
      TipoFavorito.diagnostico: totalDiagnosticos,
      TipoFavorito.cultura: totalCulturas,
      'total': total,
    };
  }

  @override
  String toString() {
    return 'FavoritosStats{defensivos: $totalDefensivos, pragas: $totalPragas, diagnosticos: $totalDiagnosticos, culturas: $totalCulturas, total: $total}';
  }
}