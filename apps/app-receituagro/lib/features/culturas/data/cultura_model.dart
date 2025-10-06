class CulturaModel {
  final String idReg;
  final String cultura;
  final String grupo;

  const CulturaModel({
    required this.idReg,
    required this.cultura,
    required this.grupo,
  });

  factory CulturaModel.fromMap(Map<String, dynamic> map) {
    return CulturaModel(
      idReg: map['idReg']?.toString() ?? '',
      cultura: map['cultura']?.toString() ?? 'Cultura desconhecida',
      grupo: map['grupo']?.toString() ?? 'Sem grupo definido',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CulturaModel &&
        other.idReg == idReg &&
        other.cultura == cultura &&
        other.grupo == grupo;
  }

  @override
  int get hashCode => idReg.hashCode ^ cultura.hashCode ^ grupo.hashCode;

  @override
  String toString() {
    return 'CulturaModel(idReg: $idReg, cultura: $cultura, grupo: $grupo)';
  }
}
