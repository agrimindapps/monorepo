class PragaCounts {
  final int insetos;
  final int doencas;
  final int plantas;
  final int culturas;

  PragaCounts({
    this.insetos = 0,
    this.doencas = 0,
    this.plantas = 0,
    this.culturas = 0,
  });

  PragaCounts copyWith({
    int? insetos,
    int? doencas,
    int? plantas,
    int? culturas,
  }) {
    return PragaCounts(
      insetos: insetos ?? this.insetos,
      doencas: doencas ?? this.doencas,
      plantas: plantas ?? this.plantas,
      culturas: culturas ?? this.culturas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'insetos': insetos,
      'doencas': doencas,
      'plantas': plantas,
      'culturas': culturas,
    };
  }

  factory PragaCounts.fromMap(Map<String, dynamic> map) {
    return PragaCounts(
      insetos: map['insetos']?.toInt() ?? 0,
      doencas: map['doencas']?.toInt() ?? 0,
      plantas: map['plantas']?.toInt() ?? 0,
      culturas: map['culturas']?.toInt() ?? 0,
    );
  }
}