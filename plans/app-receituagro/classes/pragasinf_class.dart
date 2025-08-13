class PragasInf {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  // int status;
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
    // required this.status,
    this.descrisao,
    this.sintomas,
    this.bioecologia,
    this.controle,
    required this.fkIdPraga,
  });

  factory PragasInf.fromJson(Map<String, dynamic> json) {
    return PragasInf(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: json['idReg'] ?? '',
      // status: json['Status'] != null ? json['Status'] as int : 0,
      descrisao: json['descrisao'] as String?,
      sintomas: json['sintomas'] as String?,
      bioecologia: json['bioecologia'] as String?,
      controle: json['controle'] as String?,
      fkIdPraga: json['fkIdPraga'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      // 'Status': status,
      'descrisao': descrisao,
      'sintomas': sintomas,
      'bioecologia': bioecologia,
      'controle': controle,
      'fkIdPraga': fkIdPraga,
    };
  }
}
