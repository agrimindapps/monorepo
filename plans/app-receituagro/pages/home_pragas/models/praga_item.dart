class PragaItem {
  final String idReg;
  final String? nomeComum;
  final String? nomeCientifico;
  final String tipo;
  final String? imagem;

  PragaItem({
    required this.idReg,
    this.nomeComum,
    this.nomeCientifico,
    this.tipo = '1',
    this.imagem,
  });

  factory PragaItem.fromMap(Map<String, dynamic> map) {
    return PragaItem(
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString(),
      nomeCientifico: map['nomeCientifico']?.toString(),
      tipo: map['tipoPraga']?.toString() ?? map['tipo']?.toString() ?? '1',
      imagem: map['nomeImagem']?.toString() ?? map['imagem']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'nomeCientifico': nomeCientifico,
      'tipo': tipo,
      'imagem': imagem,
    };
  }

  PragaItem copyWith({
    String? idReg,
    String? nomeComum,
    String? nomeCientifico,
    String? tipo,
    String? imagem,
  }) {
    return PragaItem(
      idReg: idReg ?? this.idReg,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      tipo: tipo ?? this.tipo,
      imagem: imagem ?? this.imagem,
    );
  }
}