class Diagnostico {
  String objectId;
  int createdAt;
  int updatedAt;
  // bool status;
  String idReg;
  String fkIdDefensivo;
  String? nomeDefensivo;
  String fkIdCultura;
  String? nomeCultura;
  String fkIdPraga;
  String? nomePraga;
  String? dsMin;
  String dsMax;
  String um;
  String? minAplicacaoT;
  String? maxAplicacaoT;
  String? umT;
  String? minAplicacaoA;
  String? maxAplicacaoA;
  String? umA;
  String? intervalo;
  String? intervalo2;
  String? epocaAplicacao;

  Diagnostico(
      {required this.objectId,
      required this.createdAt,
      required this.updatedAt,
      // required this.status,
      required this.idReg,
      required this.fkIdDefensivo,
      this.nomeDefensivo,
      required this.fkIdCultura,
      this.nomeCultura,
      required this.fkIdPraga,
      this.nomePraga,
      this.dsMin,
      required this.dsMax,
      required this.um,
      this.minAplicacaoT,
      this.maxAplicacaoT,
      this.umT,
      this.minAplicacaoA,
      this.maxAplicacaoA,
      this.umA,
      this.intervalo,
      this.intervalo2,
      this.epocaAplicacao});

  factory Diagnostico.fromJson(Map<String, dynamic> json) {
    return Diagnostico(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: json['IdReg'] ?? '',
      // status: json['Status'] != null ? json['Status'] as bool : false,
      fkIdDefensivo: json['fkIdDefensivo'] ?? '',
      nomeDefensivo: json['nomeDefensivo'] as String?,
      fkIdCultura: json['fkIdCultura'] ?? '',
      nomeCultura: json['nomeCultura'] as String?,
      fkIdPraga: json['fkIdPraga'] ?? '',
      nomePraga: json['nomePraga'] as String?,
      dsMin: json['dsMin'] as String?,
      dsMax: json['dsMax'] ?? '',
      um: json['um'] ?? '',
      minAplicacaoT: json['minAplicacaoT'] as String?,
      maxAplicacaoT: json['maxAplicacaoT'] as String?,
      umT: json['umT'] as String?,
      minAplicacaoA: json['minAplicacaoA'] as String?,
      maxAplicacaoA: json['maxAplicacaoA'] as String?,
      umA: json['umA'] as String?,
      intervalo: json['intervalo'] as String?,
      intervalo2: json['intervalo2'] as String?,
      epocaAplicacao: json['epocaAplicacao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      // 'Status': status,
      'idReg': idReg,
      'fkIdDefensivo': fkIdDefensivo,
      'nomeDefensivo': nomeDefensivo,
      'fkIdCultura': fkIdCultura,
      'nomeCultura': nomeCultura,
      'fkIdPraga': fkIdPraga,
      'nomePraga': nomePraga,
      'dsMin': dsMin,
      'dsMax': dsMax,
      'um': um,
      'minAplicacaoT': minAplicacaoT,
      'maxAplicacaoT': maxAplicacaoT,
      'umT': umT,
      'minAplicacaoA': minAplicacaoA,
      'maxAplicacaoA': maxAplicacaoA,
      'umA': umA,
      'intervalo': intervalo,
      'intervalo2': intervalo2,
      'epocaAplicacao': epocaAplicacao,
    };
  }
}
