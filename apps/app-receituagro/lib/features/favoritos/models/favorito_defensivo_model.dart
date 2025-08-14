class FavoritoDefensivoModel {
  final int id;
  final String idReg;
  final String line1;
  final String line2;
  final String? nomeComum;
  final String? ingredienteAtivo;
  final String? classeAgronomica;
  final String? fabricante;
  final String? modoAcao;
  final DateTime dataCriacao;

  const FavoritoDefensivoModel({
    required this.id,
    required this.idReg,
    required this.line1,
    required this.line2,
    this.nomeComum,
    this.ingredienteAtivo,
    this.classeAgronomica,
    this.fabricante,
    this.modoAcao,
    required this.dataCriacao,
  });

  factory FavoritoDefensivoModel.fromMap(Map<String, dynamic> map) {
    return FavoritoDefensivoModel(
      id: map['id'] ?? 0,
      idReg: map['idReg']?.toString() ?? '',
      line1: map['line1']?.toString() ?? map['nomeComum']?.toString() ?? 'Defensivo desconhecido',
      line2: map['line2']?.toString() ?? map['ingredienteAtivo']?.toString() ?? 'Sem ingrediente ativo',
      nomeComum: map['nomeComum']?.toString(),
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
      classeAgronomica: map['classeAgronomica']?.toString(),
      fabricante: map['fabricante']?.toString(),
      modoAcao: map['modoAcao']?.toString(),
      dataCriacao: DateTime.tryParse(map['dataCriacao']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get displayName => nomeComum ?? line1;
  String get displayIngredient => ingredienteAtivo ?? line2;
  String get displayClass => classeAgronomica ?? 'Não especificado';
  String get displayFabricante => fabricante ?? 'Não informado';
  String get displayModoAcao => modoAcao ?? 'Não especificado';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritoDefensivoModel &&
        other.id == id &&
        other.idReg == idReg;
  }

  @override
  int get hashCode => id.hashCode ^ idReg.hashCode;

  @override
  String toString() {
    return 'FavoritoDefensivoModel(id: $id, idReg: $idReg, nomeComum: $nomeComum)';
  }
}