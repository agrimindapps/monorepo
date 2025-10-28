class Diagnostico {
  String objectId;
  int createdAt;
  int updatedAt;
  bool status;
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

  Diagnostico({
    this.objectId = '',
    this.createdAt = 0,
    this.updatedAt = 0,
    this.status = false,
    this.idReg = '',
    this.fkIdDefensivo = '',
    this.nomeDefensivo = '',
    this.fkIdCultura = '',
    this.nomeCultura = '',
    this.fkIdPraga = '',
    this.nomePraga,
    this.dsMin,
    this.dsMax = '',
    this.um = '',
    this.minAplicacaoT = '',
    this.maxAplicacaoT = '',
    this.umT = '',
    this.minAplicacaoA = '',
    this.maxAplicacaoA = '',
    this.umA = '',
    this.intervalo = '',
    this.intervalo2 = '',
    this.epocaAplicacao = '',
  });

  factory Diagnostico.fromJson(Map<String, dynamic> json) {
    return Diagnostico(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      status: json['Status'],
      idReg: json['IdReg'],
      fkIdDefensivo: json['fkIdDefensivo'],
      nomeDefensivo: json['nomeDefensivo'],
      fkIdCultura: json['fkIdCultura'],
      nomeCultura: json['nomeCultura'],
      fkIdPraga: json['fkIdPraga'],
      nomePraga: json['nomePraga'],
      dsMin: json['dsMin'],
      dsMax: json['dsMax'],
      um: json['um'],
      minAplicacaoT: json['minAplicacaoT'],
      maxAplicacaoT: json['maxAplicacaoT'],
      umT: json['umT'],
      minAplicacaoA: json['minAplicacaoA'],
      maxAplicacaoA: json['maxAplicacaoA'],
      umA: json['umA'],
      intervalo: json['intervalo'],
      intervalo2: json['intervalo2'],
      epocaAplicacao: json['epocaAplicacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'Status': status,
      'IdReg': idReg,
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
