class PragasInf {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
  String? descrisao;
  String? sintomas;
  String? bioecologia;
  String? controle;
  String fkIdPraga;

  PragasInf({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    required this.status,
    this.descrisao,
    this.sintomas,
    this.bioecologia,
    this.controle,
    required this.fkIdPraga,
  });

  factory PragasInf.fromJson(Map<String, dynamic> json) {
    return PragasInf(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      idReg: json['IdReg'],
      status: json['Status'],
      descrisao: json['descrisao'],
      sintomas: json['sintomas'],
      bioecologia: json['bioecologia'],
      controle: json['controle'],
      fkIdPraga: json['fkIdPraga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'IdReg': idReg,
      'Status': status,
      'descrisao': descrisao,
      'sintomas': sintomas,
      'bioecologia': bioecologia,
      'controle': controle,
      'fkIdPraga': fkIdPraga,
    };
  }
}
