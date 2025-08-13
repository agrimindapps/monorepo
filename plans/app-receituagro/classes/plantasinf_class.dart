class PlantasInf {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  // int status;
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

  PlantasInf({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    // required this.status,
    this.ciclo,
    this.reproducao,
    this.habitat,
    this.adaptacoes,
    this.altura,
    this.filotaxia,
    this.formaLimbo,
    this.superficie,
    this.consistencia,
    this.nervacao,
    this.nervacaoComprimento,
    this.inflorescencia,
    this.perianto,
    this.tipologiaFruto,
    this.observacoes,
    this.fkIdPraga,
  });

  factory PlantasInf.fromJson(Map<String, dynamic> json) {
    return PlantasInf(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: json['idReg'] ?? '',
      // status: json['Status'] != null ? json['Status'] as int : 0,
      ciclo: json['ciclo'] as String?,
      reproducao: json['reproducao'] as String?,
      habitat: json['habitat'] as String?,
      adaptacoes: json['adaptacoes'] as String?,
      altura: json['altura'] as String?,
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
      'idReg': idReg,
      // 'Status': status,
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
