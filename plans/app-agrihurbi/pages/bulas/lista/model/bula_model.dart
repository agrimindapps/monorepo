class BulaModel {
  final String idReg;
  final String descricao;
  final String? fabricante;

  BulaModel({
    required this.idReg,
    required this.descricao,
    this.fabricante,
  });

  factory BulaModel.fromJson(Map<String, dynamic> json) {
    return BulaModel(
      idReg: json['idReg'] as String,
      descricao: json['descricao'] as String,
      fabricante: json['fabricante'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idReg': idReg,
      'descricao': descricao,
      'fabricante': fabricante,
    };
  }
}
