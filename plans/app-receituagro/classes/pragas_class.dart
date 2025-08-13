class Pragas {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  // int status;
  String nomeComum;
  String nomeCientifico;
  String? dominio;
  String? reino;
  String? subReino;
  String? clado01;
  String? clado02;
  String? clado03;
  String? superDivisao;
  String? divisao;
  String? subDivisao;
  String? classe;
  String? subClasse;
  String? superOrdem;
  String? ordem;
  String? subOrdem;
  String? infraOrdem;
  String? superFamilia;
  String? familia;
  String? subFamilia;
  String? tribo;
  String? subTribo;
  String? genero;
  String? especie;
  String tipoPraga;

  Pragas({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    // required this.status,
    required this.nomeComum,
    required this.nomeCientifico,
    this.dominio,
    this.reino,
    this.subReino,
    this.clado01,
    this.clado02,
    this.clado03,
    this.superDivisao,
    this.divisao,
    this.subDivisao,
    this.classe,
    this.subClasse,
    this.superOrdem,
    this.ordem,
    this.subOrdem,
    this.infraOrdem,
    this.superFamilia,
    this.familia,
    this.subFamilia,
    this.tribo,
    this.subTribo,
    this.genero,
    this.especie,
    required this.tipoPraga,
  });

  factory Pragas.fromJson(Map<String, dynamic> json) {
    return Pragas(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: json['idReg'] ?? '',
      // status: json['Status'] != null ? json['Status'] as int : 0,
      nomeComum: json['nomeComum'] ?? '',
      nomeCientifico: json['nomeCientifico'] ?? '',
      dominio: json['dominio'] as String?,
      reino: json['reino'] as String?,
      subReino: json['subReino'] as String?,
      clado01: json['clado01'] as String?,
      clado02: json['clado02'] as String?,
      clado03: json['clado03'] as String?,
      superDivisao: json['superDivisao'] as String?,
      divisao: json['divisao'] as String?,
      subDivisao: json['subDivisao'] as String?,
      classe: json['classe'] as String?,
      subClasse: json['subClasse'] as String?,
      superOrdem: json['superOrdem'] as String?,
      ordem: json['ordem'] as String?,
      subOrdem: json['subOrdem'] as String?,
      infraOrdem: json['infraOrdem'] as String?,
      superFamilia: json['superFamilia'] as String?,
      familia: json['familia'] as String?,
      subFamilia: json['subFamilia'] as String?,
      tribo: json['tribo'] as String?,
      subTribo: json['subTribo'] as String?,
      genero: json['genero'] as String?,
      especie: json['especie'] as String?,
      tipoPraga: json['tipoPraga'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      // 'Status': status,
      'nomeComum': nomeComum,
      'nomeCientifico': nomeCientifico,
      'dominio': dominio,
      'reino': reino,
      'subReino': subReino,
      'clado01': clado01,
      'clado02': clado02,
      'clado03': clado03,
      'superDivisao': superDivisao,
      'divisao': divisao,
      'subDivisao': subDivisao,
      'classe': classe,
      'subClasse': subClasse,
      'superOrdem': superOrdem,
      'ordem': ordem,
      'subOrdem': subOrdem,
      'infraOrdem': infraOrdem,
      'superFamilia': superFamilia,
      'familia': familia,
      'subFamilia': subFamilia,
      'tribo': tribo,
      'subTribo': subTribo,
      'genero': genero,
      'especie': especie,
      'tipoPraga': tipoPraga,
    };
  }
}
