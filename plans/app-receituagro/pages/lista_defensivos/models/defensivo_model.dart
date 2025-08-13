class DefensivoModel {
  final String idReg;
  final String line1;
  final String line2;
  final String? nomeComum;
  final String? ingredienteAtivo;
  final String? classeAgronomica;

  const DefensivoModel({
    required this.idReg,
    required this.line1,
    required this.line2,
    this.nomeComum,
    this.ingredienteAtivo,
    this.classeAgronomica,
  });

  factory DefensivoModel.fromMap(Map<String, dynamic> map) {
    return DefensivoModel(
      idReg: map['idReg']?.toString() ?? '',
      line1: map['line1']?.toString() ?? '',
      line2: map['line2']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString(),
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
      classeAgronomica: map['classeAgronomica']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'line1': line1,
      'line2': line2,
      if (nomeComum != null) 'nomeComum': nomeComum,
      if (ingredienteAtivo != null) 'ingredienteAtivo': ingredienteAtivo,
      if (classeAgronomica != null) 'classeAgronomica': classeAgronomica,
    };
  }

  String get displayName => nomeComum ?? line1;
  String get displayIngredient => ingredienteAtivo ?? line2;
  String get displayClass => classeAgronomica ?? 'Não especificado';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoModel &&
        other.idReg == idReg &&
        other.line1 == line1 &&
        other.line2 == line2 &&
        other.nomeComum == nomeComum &&
        other.ingredienteAtivo == ingredienteAtivo &&
        other.classeAgronomica == classeAgronomica;
  }

  @override
  int get hashCode {
    return idReg.hashCode ^
        line1.hashCode ^
        line2.hashCode ^
        (nomeComum?.hashCode ?? 0) ^
        (ingredienteAtivo?.hashCode ?? 0) ^
        (classeAgronomica?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'DefensivoModel(idReg: $idReg, line1: $line1, line2: $line2, nomeComum: $nomeComum, ingredienteAtivo: $ingredienteAtivo, classeAgronomica: $classeAgronomica)';
  }
}