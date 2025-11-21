/// Entidade de domínio para Praga (Domain Layer)
/// Princípio: Single Responsibility - Apenas representa dados da praga
class PragaEntity {
  final String idReg;
  final String nomeComum;
  final String nomeCientifico;
  final String tipoPraga;
  final String? dominio;
  final String? reino;
  final String? familia;
  final String? genero;
  final String? especie;

  const PragaEntity({
    required this.idReg,
    required this.nomeComum,
    required this.nomeCientifico,
    required this.tipoPraga,
    this.dominio,
    this.reino,
    this.familia,
    this.genero,
    this.especie,
  });

  /// Factory para criar do Drift model (Praga)
  /// TODO: Verify field mapping with actual Drift schema
  factory PragaEntity.fromDrift(dynamic driftModel) {
    // Temporarily disabled until proper Drift model mapping is established
    throw UnimplementedError(
      'PragaEntity.fromDrift needs to be implemented with correct Drift Praga field mapping'
    );
  }
  
  //   return PragaEntity(
  //     idReg: driftModel.idReg,
  //     nomeComum: driftModel.nomeComum,
  //     nomeCientifico: driftModel.nomeCientifico,
  //     tipoPraga: driftModel.tipoPraga,
  //     dominio: driftModel.dominio,
  //     reino: driftModel.reino,
  //     familia: driftModel.familia,
  //     genero: driftModel.genero,
  //     especie: driftModel.especie,
  //   );
  // }

  /// Tipos de praga
  static const String tipoInseto = '1';
  static const String tipoDoenca = '2';
  static const String tipoPlanta = '3';

  /// Getters de conveniência
  bool get isInseto => tipoPraga == tipoInseto;
  bool get isDoenca => tipoPraga == tipoDoenca;
  bool get isPlanta => tipoPraga == tipoPlanta;

  /// Nome formatado (primeiro nome antes do ';')
  String get nomeFormatado {
    final nomeList = nomeComum.split(';');
    return nomeList[0].split('-')[0].trim();
  }

  /// Nomes secundários
  List<String> get nomesSecundarios {
    final nomeList = nomeComum.split(';');
    return nomeList.length > 1 ? nomeList.sublist(1) : [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PragaEntity &&
          runtimeType == other.runtimeType &&
          idReg == other.idReg;

  @override
  int get hashCode => idReg.hashCode;

  @override
  String toString() {
    return 'PragaEntity{idReg: $idReg, nomeComum: $nomeFormatado, nomeCientifico: $nomeCientifico}';
  }
}
