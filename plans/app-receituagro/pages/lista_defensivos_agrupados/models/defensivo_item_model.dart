class DefensivoItemModel {
  final String idReg;
  final String line1;
  final String line2;
  final String? count;
  final String? ingredienteAtivo;

  const DefensivoItemModel({
    required this.idReg,
    required this.line1,
    required this.line2,
    this.count,
    this.ingredienteAtivo,
  });

  factory DefensivoItemModel.fromMap(Map<String, dynamic> map) {
    return DefensivoItemModel(
      idReg: map['idReg']?.toString() ?? '',
      line1: map['line1']?.toString() ?? '',
      line2: map['line2']?.toString() ?? '',
      count: map['count']?.toString(),
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'line1': line1,
      'line2': line2,
      if (count != null) 'count': count,
      if (ingredienteAtivo != null) 'ingredienteAtivo': ingredienteAtivo,
    };
  }

  bool get isDefensivo => line2.isNotEmpty && ingredienteAtivo != null;
  
  int get itemCount => int.tryParse(count ?? '0') ?? 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoItemModel &&
        other.idReg == idReg &&
        other.line1 == line1 &&
        other.line2 == line2 &&
        other.count == count &&
        other.ingredienteAtivo == ingredienteAtivo;
  }

  @override
  int get hashCode {
    return idReg.hashCode ^
        line1.hashCode ^
        line2.hashCode ^
        count.hashCode ^
        ingredienteAtivo.hashCode;
  }

  @override
  String toString() {
    return 'DefensivoItemModel(idReg: $idReg, line1: $line1, line2: $line2, count: $count, ingredienteAtivo: $ingredienteAtivo)';
  }
}