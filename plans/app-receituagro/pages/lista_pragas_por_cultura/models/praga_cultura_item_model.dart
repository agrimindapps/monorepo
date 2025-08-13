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

  factory PragaCulturaItemModel.fromMap(Map<String, dynamic> map) {
    return PragaCulturaItemModel(
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString() ?? '',
      nomeSecundario: map['nomeSecundario']?.toString(),
      nomeCientifico: map['nomeCientifico']?.toString(),
      nomeImagem: map['nomeImagem']?.toString(),
      tipoPraga: map['tipoPraga']?.toString(),
      categoria: map['categoria']?.toString(),
      grupo: map['grupo']?.toString(),
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

  PragaCulturaItemModel copyWith({
    String? idReg,
    String? nomeComum,
    String? nomeSecundario,
    String? nomeCientifico,
    String? nomeImagem,
    String? tipoPraga,
    String? categoria,
    String? grupo,
  }) {
    return PragaCulturaItemModel(
      idReg: idReg ?? this.idReg,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeSecundario: nomeSecundario ?? this.nomeSecundario,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      nomeImagem: nomeImagem ?? this.nomeImagem,
      tipoPraga: tipoPraga ?? this.tipoPraga,
      categoria: categoria ?? this.categoria,
      grupo: grupo ?? this.grupo,
    );
  }

  // Getters for type checking
  bool get isInseto => tipoPraga == '1';
  bool get isDoenca => tipoPraga == '2';
  bool get isPlantaInvasora => tipoPraga == '3';

  // Helper for image path
  String get imagePath => 'assets/imagens/bigsize/${nomeCientifico ?? nomeImagem}.jpg';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragaCulturaItemModel && other.idReg == idReg;
  }

  @override
  int get hashCode => idReg.hashCode;

  @override
  String toString() {
    return 'PragaCulturaItemModel(idReg: $idReg, nomeComum: $nomeComum, tipoPraga: $tipoPraga)';
  }
}