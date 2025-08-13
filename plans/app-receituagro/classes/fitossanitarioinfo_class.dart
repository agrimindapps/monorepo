class FitossanitariosInfo {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  // int status;
  String? embalagens;
  String? tecnologia;
  String? pHumanas;
  String? pAmbiental;
  String? manejoResistencia;
  String? compatibilidade;
  String? manejoIntegrado;
  String fkIdDefensivo;

  FitossanitariosInfo({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    // required this.status,
    this.embalagens,
    this.tecnologia,
    this.pHumanas,
    this.pAmbiental,
    this.manejoResistencia,
    this.compatibilidade,
    this.manejoIntegrado,
    required this.fkIdDefensivo,
  });

  factory FitossanitariosInfo.fromJson(Map<String, dynamic> json) {
    return FitossanitariosInfo(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: json['idReg'] ?? '',
      // status: json['Status'] != null ? json['Status'] as int : 0,
      embalagens: json['embalagens'] as String?,
      tecnologia: json['tecnologia'] as String?,
      pHumanas: json['pHumanas'] as String?,
      pAmbiental: json['pAmbiental'] as String?,
      manejoResistencia: json['manejoResistencia'] as String?,
      compatibilidade: json['compatibilidade'] as String?,
      manejoIntegrado: json['manejoIntegrado'] as String?,
      fkIdDefensivo: json['fkIdDefensivo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      // 'Status': status,
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
