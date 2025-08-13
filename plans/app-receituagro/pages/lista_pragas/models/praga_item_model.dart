class PragaItemModel {
  final String idReg;
  final String nomeComum;
  final String? nomeSecundario;
  final String? nomeCientifico;
  final String? nomeImagem;
  final String? categoria;
  final String? tipo;

  const PragaItemModel({
    required this.idReg,
    required this.nomeComum,
    this.nomeSecundario,
    this.nomeCientifico,
    this.nomeImagem,
    this.categoria,
    this.tipo,
  });

  factory PragaItemModel.fromMap(Map<String, dynamic> map) {
    return PragaItemModel(
      idReg: _safeToString(map['idReg']) ?? '',
      nomeComum: _safeToString(map['nomeComum']) ?? '',
      nomeSecundario: _safeToString(map['nomeSecundario']),
      nomeCientifico: _safeToString(map['nomeCientifico']),
      nomeImagem: _safeToString(map['nomeImagem']),
      categoria: _safeToString(map['categoria']),
      tipo: _safeToString(map['tipo']),
    );
  }

  static String? _safeToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map || value is List) return null;
    return value.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'nomeSecundario': nomeSecundario,
      'nomeCientifico': nomeCientifico,
      'nomeImagem': nomeImagem,
      'categoria': categoria,
      'tipo': tipo,
    };
  }

  PragaItemModel copyWith({
    String? idReg,
    String? nomeComum,
    String? nomeSecundario,
    String? nomeCientifico,
    String? nomeImagem,
    String? categoria,
    String? tipo,
  }) {
    return PragaItemModel(
      idReg: idReg ?? this.idReg,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeSecundario: nomeSecundario ?? this.nomeSecundario,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      nomeImagem: nomeImagem ?? this.nomeImagem,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragaItemModel && other.idReg == idReg;
  }

  @override
  int get hashCode => idReg.hashCode;

  @override
  String toString() {
    return 'PragaItemModel(idReg: $idReg, nomeComum: $nomeComum, nomeCientifico: $nomeCientifico)';
  }
}