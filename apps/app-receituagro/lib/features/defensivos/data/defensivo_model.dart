class DefensivoModel {
  final String idReg;
  final String line1;
  final String line2;
  final String? nomeComum;
  final String? ingredienteAtivo;
  final String? classeAgronomica;
  final String? fabricante;
  final String? modoAcao;

  const DefensivoModel({
    required this.idReg,
    required this.line1,
    required this.line2,
    this.nomeComum,
    this.ingredienteAtivo,
    this.classeAgronomica,
    this.fabricante,
    this.modoAcao,
  });

  factory DefensivoModel.fromMap(Map<String, dynamic> map) {
    return DefensivoModel(
      idReg: map['idReg']?.toString() ?? '',
      line1: map['line1']?.toString() ?? map['nomeComum']?.toString() ?? 'Defensivo desconhecido',
      line2: map['line2']?.toString() ?? map['ingredienteAtivo']?.toString() ?? 'Sem ingrediente ativo',
      nomeComum: map['nomeComum']?.toString(),
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
      classeAgronomica: map['classeAgronomica']?.toString(),
      fabricante: map['fabricante']?.toString(),
      modoAcao: map['modoAcao']?.toString(),
    );
  }

  // Computed display properties
  String get displayName => nomeComum ?? line1;
  String get displayIngredient => ingredienteAtivo ?? line2;
  String get displayClass => classeAgronomica ?? 'Não especificado';
  String get displayFabricante => fabricante ?? 'Não informado';
  String get displayModoAcao => modoAcao ?? 'Não especificado';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoModel &&
        other.idReg == idReg &&
        other.line1 == line1 &&
        other.line2 == line2 &&
        other.nomeComum == nomeComum &&
        other.ingredienteAtivo == ingredienteAtivo &&
        other.classeAgronomica == classeAgronomica &&
        other.fabricante == fabricante &&
        other.modoAcao == modoAcao;
  }

  @override
  int get hashCode {
    return idReg.hashCode ^
        line1.hashCode ^
        line2.hashCode ^
        (nomeComum?.hashCode ?? 0) ^
        (ingredienteAtivo?.hashCode ?? 0) ^
        (classeAgronomica?.hashCode ?? 0) ^
        (fabricante?.hashCode ?? 0) ^
        (modoAcao?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'DefensivoModel(idReg: $idReg, line1: $line1, line2: $line2, nomeComum: $nomeComum)';
  }
}