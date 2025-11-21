class DefensivoAgrupadoItemModel {
  final String idReg;
  final String line1;
  final String line2;
  final String? count;
  final String? ingredienteAtivo;
  final String? categoria;
  final String? fabricante;
  final String? classeAgronomica;
  final String? modoAcao;

  const DefensivoAgrupadoItemModel({
    required this.idReg,
    required this.line1,
    required this.line2,
    this.count,
    this.ingredienteAtivo,
    this.categoria,
    this.fabricante,
    this.classeAgronomica,
    this.modoAcao,
  });
  bool get isDefensivo => line2.isNotEmpty && ingredienteAtivo != null;
  bool get isGroup => !isDefensivo;
  int get itemCount => int.tryParse(count ?? '0') ?? 0;
  
  String get displayTitle => line1.isNotEmpty ? line1 : 'Item sem nome';
  String get displaySubtitle => line2.isNotEmpty ? line2 : '';
  String get displayCount => count ?? '';
  
  bool get hasCount => count != null && count!.isNotEmpty;
  bool get hasIngredienteAtivo => ingredienteAtivo != null && ingredienteAtivo!.isNotEmpty;

  factory DefensivoAgrupadoItemModel.fromMap(Map<String, dynamic> map) {
    return DefensivoAgrupadoItemModel(
      idReg: _safeToString(map['idReg']) ?? '',
      line1: _safeToString(map['line1']) ?? '',
      line2: _safeToString(map['line2']) ?? '',
      count: _safeToString(map['count']),
      ingredienteAtivo: _safeToString(map['ingredienteAtivo']),
      categoria: _safeToString(map['categoria']),
      fabricante: _safeToString(map['fabricante']),
      classeAgronomica: _safeToString(map['classeAgronomica']),
      modoAcao: _safeToString(map['modoAcao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'line1': line1,
      'line2': line2,
      'count': count,
      'ingredienteAtivo': ingredienteAtivo,
      'categoria': categoria,
      'fabricante': fabricante,
      'classeAgronomica': classeAgronomica,
      'modoAcao': modoAcao,
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
    return other is DefensivoAgrupadoItemModel &&
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
        (count?.hashCode ?? 0) ^
        (ingredienteAtivo?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'DefensivoAgrupadoItemModel('
        'idReg: $idReg, '
        'line1: $line1, '
        'line2: $line2, '
        'isDefensivo: $isDefensivo'
        ')';
  }
}
