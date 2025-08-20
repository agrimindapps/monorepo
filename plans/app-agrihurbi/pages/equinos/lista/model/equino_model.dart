
class EquinoModel {
  final String idReg;
  final String nomeComum;
  final String paisOrigem;
  final String miniatura;
  final bool status;

  EquinoModel({
    required this.idReg,
    required this.nomeComum,
    required this.paisOrigem,
    required this.miniatura,
    required this.status,
  });

  factory EquinoModel.fromJson(Map<String, dynamic> json) {
    return EquinoModel(
      idReg: json['idReg'] ?? '',
      nomeComum: json['nomeComum'] ?? '',
      paisOrigem: json['paisOrigem'] ?? '',
      miniatura: json['miniatura'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'paisOrigem': paisOrigem,
      'miniatura': miniatura,
      'status': status,
    };
  }
}
