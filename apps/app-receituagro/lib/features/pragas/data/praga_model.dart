class PragaModel {
  final String idReg;
  final String nomeComum;
  final String? nomeSecundario;
  final String? nomeCientifico;
  final String tipoPraga;
  final String? descricao;
  final String? sintomas;
  final String? controle;
  final String? imagem;

  const PragaModel({
    required this.idReg,
    required this.nomeComum,
    this.nomeSecundario,
    this.nomeCientifico,
    required this.tipoPraga,
    this.descricao,
    this.sintomas,
    this.controle,
    this.imagem,
  });

  factory PragaModel.fromMap(Map<String, dynamic> map) {
    return PragaModel(
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString() ?? 'Praga desconhecida',
      nomeSecundario: map['nomeSecundario']?.toString(),
      nomeCientifico: map['nomeCientifico']?.toString(),
      tipoPraga: map['tipoPraga']?.toString() ?? '1',
      descricao: map['descricao']?.toString(),
      sintomas: map['sintomas']?.toString(),
      controle: map['controle']?.toString(),
      imagem: map['imagem']?.toString(),
    );
  }
  String get displayName => nomeComum;
  String get displaySecondaryName => nomeSecundario ?? nomeCientifico ?? '';
  String get displayType {
    switch (tipoPraga) {
      case '1':
        return 'Inseto';
      case '2':
        return 'Doença';
      case '3':
        return 'Planta Daninha';
      default:
        return 'Praga';
    }
  }

  String get displayDescription => descricao ?? 'Sem descrição disponível';
  String get displaySintomas => sintomas ?? 'Sintomas não informados';
  String get displayControle => controle ?? 'Controle não especificado';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragaModel &&
        other.idReg == idReg &&
        other.nomeComum == nomeComum &&
        other.nomeSecundario == nomeSecundario &&
        other.nomeCientifico == nomeCientifico &&
        other.tipoPraga == tipoPraga;
  }

  @override
  int get hashCode {
    return idReg.hashCode ^
        nomeComum.hashCode ^
        (nomeSecundario?.hashCode ?? 0) ^
        (nomeCientifico?.hashCode ?? 0) ^
        tipoPraga.hashCode;
  }

  @override
  String toString() {
    return 'PragaModel(idReg: $idReg, nomeComum: $nomeComum, tipoPraga: $tipoPraga)';
  }
}
