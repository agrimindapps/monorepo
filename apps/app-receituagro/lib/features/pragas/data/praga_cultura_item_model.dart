class PragaCulturaItemModel {
  final String idReg;
  final String nomeComum;
  final String? nomeSecundario;
  final String? nomeCientifico;
  final String? nomeImagem;
  final String? tipoPraga;
  final String? categoria;
  final String? grupo;

  const PragaCulturaItemModel({
    required this.idReg,
    required this.nomeComum,
    this.nomeSecundario,
    this.nomeCientifico,
    this.nomeImagem,
    this.tipoPraga,
    this.categoria,
    this.grupo,
  });

  bool get isInseto => tipoPraga == '1';
  bool get isDoenca => tipoPraga == '2';
  bool get isPlantaInvasora => tipoPraga == '3';

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

  String get imagePath => 'assets/imagens/bigsize/${nomeCientifico ?? nomeImagem}.jpg';

  factory PragaCulturaItemModel.fromMap(Map<String, dynamic> map) {
    return PragaCulturaItemModel(
      idReg: _safeToString(map['idReg']) ?? '',
      nomeComum: _safeToString(map['nomeComum']) ?? '',
      nomeSecundario: _safeToString(map['nomeSecundario']),
      nomeCientifico: _safeToString(map['nomeCientifico']),
      nomeImagem: _safeToString(map['nomeImagem']),
      tipoPraga: _safeToString(map['tipoPraga']),
      categoria: _safeToString(map['categoria']),
      grupo: _safeToString(map['grupo']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'nomeSecundario': nomeSecundario,
      'nomeCientifico': nomeCientifico,
      'nomeImagem': nomeImagem,
      'tipoPraga': tipoPraga,
      'categoria': categoria,
      'grupo': grupo,
    };
  }

  static String? _safeToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is Map || value is List) return null;
    return value.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragaCulturaItemModel && 
        other.idReg == idReg &&
        other.tipoPraga == tipoPraga;
  }

  @override
  int get hashCode => idReg.hashCode ^ (tipoPraga?.hashCode ?? 0);

  @override
  String toString() {
    return 'PragaCulturaItemModel(idReg: $idReg, nomeComum: $nomeComum, tipoPraga: $tipoPraga)';
  }
}