class FitossanitariosInfo {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
  String? embalagens;
  String? tecnologia;
  String? pHumanas;
  String? pAmbiental;
  String? manejoResistencia;
  String? compatibilidade;
  String? manejoIntegrado;
  String fkIdDefensivo;

  FitossanitariosInfo({
    this.objectId = '',
    this.createdAt = 0,
    this.updatedAt = 0,
    this.idReg = '',
    this.status = 1,
    this.embalagens = '',
    this.tecnologia = '',
    this.pHumanas = '',
    this.pAmbiental = '',
    this.manejoResistencia = '',
    this.compatibilidade = '',
    this.manejoIntegrado = '',
    this.fkIdDefensivo = '',
  });

  factory FitossanitariosInfo.fromJson(Map<String, dynamic> json) {
    return FitossanitariosInfo(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      idReg: json['IdReg'],
      status: json['Status'],
      embalagens: json['embalagens'],
      tecnologia: json['tecnologia'],
      pHumanas: json['pHumanas'],
      pAmbiental: json['pAmbiental'],
      manejoResistencia: json['manejoResistencia'],
      compatibilidade: json['compatibilidade'],
      manejoIntegrado: json['manejoIntegrado'],
      fkIdDefensivo: json['fkIdDefensivo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'IdReg': idReg,
      'Status': status,
      'embalagens': embalagens,
      'tecnologia': tecnologia,
      'pHumanas': pHumanas,
      'pAmbiental': pAmbiental,
      'manejoResistencia': manejoResistencia,
      'compatibilidade': compatibilidade,
      'manejoIntegrado': manejoIntegrado,
      'fkIdDefensivo': fkIdDefensivo,
    };
  }
}
