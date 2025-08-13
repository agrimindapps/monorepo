class DiagnosticoItemModel {
  final String idReg;
  final String nomePraga;
  final String nomeCientifico;
  final String fkIdCultura;
  final String cultura;
  final String fkIdDefensivo;
  final String nomeDefensivo;
  final String ingredienteAtivo;
  final String fkIdPraga;
  final String dosagem;
  final String vazaoTerrestre;
  final String vazaoAerea;
  final String intervaloAplicacao;
  final String intervaloSeguranca;

  DiagnosticoItemModel({
    required this.idReg,
    required this.nomePraga,
    required this.nomeCientifico,
    required this.fkIdCultura,
    required this.cultura,
    required this.fkIdDefensivo,
    required this.nomeDefensivo,
    required this.ingredienteAtivo,
    required this.fkIdPraga,
    required this.dosagem,
    required this.vazaoTerrestre,
    required this.vazaoAerea,
    required this.intervaloAplicacao,
    required this.intervaloSeguranca,
  });

  /// Cria uma instância a partir de um mapa
  factory DiagnosticoItemModel.fromMap(Map<String, dynamic> map) {
    return DiagnosticoItemModel(
      idReg: map['idReg'] ?? '',
      nomePraga: map['nomePraga'] ?? '',
      nomeCientifico: map['nomeCientifico'] ?? '',
      fkIdCultura: map['fkIdCultura'] ?? '',
      cultura: map['cultura'] ?? '',
      fkIdDefensivo: map['fkIdDefensivo'] ?? '',
      nomeDefensivo: map['nomeDefensivo'] ?? '',
      ingredienteAtivo: map['ingredienteAtivo'] ?? '',
      fkIdPraga: map['fkIdPraga'] ?? '',
      dosagem: map['dosagem'] ?? '',
      vazaoTerrestre: map['vazaoTerrestre'] ?? '',
      vazaoAerea: map['vazaoAerea'] ?? '',
      intervaloAplicacao: map['intervaloAplicacao'] ?? '',
      intervaloSeguranca: map['intervaloSeguranca'] ?? '',
    );
  }

  /// Converte o modelo para um mapa
  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomePraga': nomePraga,
      'nomeCientifico': nomeCientifico,
      'fkIdCultura': fkIdCultura,
      'cultura': cultura,
      'fkIdDefensivo': fkIdDefensivo,
      'nomeDefensivo': nomeDefensivo,
      'ingredienteAtivo': ingredienteAtivo,
      'fkIdPraga': fkIdPraga,
      'dosagem': dosagem,
      'vazaoTerrestre': vazaoTerrestre,
      'vazaoAerea': vazaoAerea,
      'intervaloAplicacao': intervaloAplicacao,
      'intervaloSeguranca': intervaloSeguranca,
    };
  }

  /// Representação em string do modelo
  @override
  String toString() {
    return 'DiagnosticoItemModel(idReg: $idReg, cultura: $cultura, nomeDefensivo: $nomeDefensivo, nomePraga: $nomePraga)';
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  DiagnosticoItemModel copyWith({
    String? idReg,
    String? nomePraga,
    String? nomeCientifico,
    String? fkIdCultura,
    String? cultura,
    String? fkIdDefensivo,
    String? nomeDefensivo,
    String? ingredienteAtivo,
    String? fkIdPraga,
    String? dosagem,
    String? vazaoTerrestre,
    String? vazaoAerea,
    String? intervaloAplicacao,
    String? intervaloSeguranca,
  }) {
    return DiagnosticoItemModel(
      idReg: idReg ?? this.idReg,
      nomePraga: nomePraga ?? this.nomePraga,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      fkIdCultura: fkIdCultura ?? this.fkIdCultura,
      cultura: cultura ?? this.cultura,
      fkIdDefensivo: fkIdDefensivo ?? this.fkIdDefensivo,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      fkIdPraga: fkIdPraga ?? this.fkIdPraga,
      dosagem: dosagem ?? this.dosagem,
      vazaoTerrestre: vazaoTerrestre ?? this.vazaoTerrestre,
      vazaoAerea: vazaoAerea ?? this.vazaoAerea,
      intervaloAplicacao: intervaloAplicacao ?? this.intervaloAplicacao,
      intervaloSeguranca: intervaloSeguranca ?? this.intervaloSeguranca,
    );
  }

  /// Compara dois modelos para verificar se são iguais
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticoItemModel &&
        other.idReg == idReg &&
        other.nomePraga == nomePraga &&
        other.nomeCientifico == nomeCientifico &&
        other.fkIdCultura == fkIdCultura &&
        other.cultura == cultura &&
        other.fkIdDefensivo == fkIdDefensivo &&
        other.nomeDefensivo == nomeDefensivo &&
        other.ingredienteAtivo == ingredienteAtivo &&
        other.fkIdPraga == fkIdPraga &&
        other.dosagem == dosagem &&
        other.vazaoTerrestre == vazaoTerrestre &&
        other.vazaoAerea == vazaoAerea &&
        other.intervaloAplicacao == intervaloAplicacao &&
        other.intervaloSeguranca == intervaloSeguranca;
  }

  @override
  int get hashCode {
    return idReg.hashCode ^
        nomePraga.hashCode ^
        nomeCientifico.hashCode ^
        fkIdCultura.hashCode ^
        cultura.hashCode ^
        fkIdDefensivo.hashCode ^
        nomeDefensivo.hashCode ^
        ingredienteAtivo.hashCode ^
        fkIdPraga.hashCode ^
        dosagem.hashCode ^
        vazaoTerrestre.hashCode ^
        vazaoAerea.hashCode ^
        intervaloAplicacao.hashCode ^
        intervaloSeguranca.hashCode;
  }
}
