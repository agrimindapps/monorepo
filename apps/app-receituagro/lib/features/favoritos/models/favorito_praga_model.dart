class FavoritoPragaModel {
  final int id;
  final String idReg;
  final String nomeComum;
  final String? nomeSecundario;
  final String? nomeCientifico;
  final String tipoPraga;
  final String? descricao;
  final String? sintomas;
  final String? controle;
  final String? imagem;
  final DateTime dataCriacao;

  const FavoritoPragaModel({
    required this.id,
    required this.idReg,
    required this.nomeComum,
    this.nomeSecundario,
    this.nomeCientifico,
    required this.tipoPraga,
    this.descricao,
    this.sintomas,
    this.controle,
    this.imagem,
    required this.dataCriacao,
  });

  factory FavoritoPragaModel.fromMap(Map<String, dynamic> map) {
    return FavoritoPragaModel(
      id: map['id'] as int? ?? 0,
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString() ?? 'Praga desconhecida',
      nomeSecundario: map['nomeSecundario']?.toString(),
      nomeCientifico: map['nomeCientifico']?.toString(),
      tipoPraga: map['tipoPraga']?.toString() ?? '1',
      descricao: map['descricao']?.toString(),
      sintomas: map['sintomas']?.toString(),
      controle: map['controle']?.toString(),
      imagem: map['imagem']?.toString(),
      dataCriacao: DateTime.tryParse(map['dataCriacao']?.toString() ?? '') ?? DateTime.now(),
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
    return other is FavoritoPragaModel &&
        other.id == id &&
        other.idReg == idReg;
  }

  @override
  int get hashCode => id.hashCode ^ idReg.hashCode;

  @override
  String toString() {
    return 'FavoritoPragaModel(id: $id, idReg: $idReg, nomeComum: $nomeComum)';
  }
}