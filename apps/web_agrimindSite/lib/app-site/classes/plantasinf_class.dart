class PlantasInf {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
  String? ciclo;
  String? reproducao;
  String? habitat;
  String? adaptacoes;
  String? altura;
  String? filotaxia;
  String? formaLimbo;
  String? superficie;
  String? consistencia;
  String? nervacao;
  String? nervacaoComprimento;
  String? inflorescencia;
  String? perianto;
  String? tipologiaFruto;
  String? observacoes;
  String? fkIdPraga;

  PlantasInf(
      {this.objectId = '',
      this.createdAt = 0,
      this.updatedAt = 0,
      this.idReg = '',
      this.status = 1,
      this.ciclo = '',
      this.reproducao = '',
      this.habitat = '',
      this.adaptacoes = '',
      this.altura = '',
      this.filotaxia = '',
      this.formaLimbo = '',
      this.superficie = '',
      this.consistencia = '',
      this.nervacao = '',
      this.nervacaoComprimento = '',
      this.inflorescencia = '',
      this.perianto = '',
      this.tipologiaFruto = '',
      this.observacoes = '',
      this.fkIdPraga = ''});

  factory PlantasInf.fromJson(Map<String, dynamic> json) {
    return PlantasInf(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      idReg: json['IdReg'],
      status: json['Status'],
      ciclo: json['ciclo'],
      reproducao: json['reproducao'],
      habitat: json['habitat'],
      adaptacoes: json['adaptacoes'],
      altura: json['altura'],
      filotaxia: json['filotaxia'],
      formaLimbo: json['formaLimbo'],
      superficie: json['superficie'],
      consistencia: json['consistencia'],
      nervacao: json['nervacao'],
      nervacaoComprimento: json['nervacaoComprimento'],
      inflorescencia: json['inflorescencia'],
      perianto: json['perianto'],
      tipologiaFruto: json['tipologiaFruto'],
      observacoes: json['observacoes'],
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
      'ciclo': ciclo,
      'reproducao': reproducao,
      'habitat': habitat,
      'adaptacoes': adaptacoes,
      'altura': altura,
      'filotaxia': filotaxia,
      'formaLimbo': formaLimbo,
      'superficie': superficie,
      'consistencia': consistencia,
      'nervacao': nervacao,
      'nervacaoComprimento': nervacaoComprimento,
      'inflorescencia': inflorescencia,
      'perianto': perianto,
      'tipologiaFruto': tipologiaFruto,
      'observacoes': observacoes,
      'fkIdPraga': fkIdPraga,
    };
  }
}
