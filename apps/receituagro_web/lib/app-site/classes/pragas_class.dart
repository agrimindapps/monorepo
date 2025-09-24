class Pragas {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
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

  Pragas(
      {this.objectId = '',
      this.createdAt = 0,
      this.updatedAt = 0,
      this.idReg = '',
      this.status = 1,
      this.nomeComum = '',
      this.nomeCientifico = '',
      this.dominio = '',
      this.reino = '',
      this.subReino = '',
      this.clado01 = '',
      this.clado02 = '',
      this.clado03 = '',
      this.superDivisao = '',
      this.divisao = '',
      this.subDivisao = '',
      this.classe = '',
      this.subClasse = '',
      this.superOrdem = '',
      this.ordem = '',
      this.subOrdem = '',
      this.infraOrdem = '',
      this.superFamilia = '',
      this.familia = '',
      this.subFamilia = '',
      this.tribo = '',
      this.subTribo = '',
      this.genero = '',
      this.especie = '',
      this.tipoPraga = ''});

  factory Pragas.fromJson(Map<String, dynamic> json) {
    return Pragas(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      idReg: json['IdReg'],
      status: json['Status'],
      nomeComum: json['nomeComum'],
      nomeCientifico: json['nomeCientifico'],
      dominio: json['dominio'],
      reino: json['reino'],
      subReino: json['subReino'],
      clado01: json['clado01'],
      clado02: json['clado02'],
      clado03: json['clado03'],
      superDivisao: json['superDivisao'],
      divisao: json['divisao'],
      subDivisao: json['subDivisao'],
      classe: json['classe'],
      subClasse: json['subClasse'],
      superOrdem: json['superOrdem'],
      ordem: json['ordem'],
      subOrdem: json['subOrdem'],
      infraOrdem: json['infraOrdem'],
      superFamilia: json['superFamilia'],
      familia: json['familia'],
      subFamilia: json['subFamilia'],
      tribo: json['tribo'],
      subTribo: json['subTribo'],
      genero: json['genero'],
      especie: json['especie'],
      tipoPraga: json['tipoPraga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'IdReg': idReg,
      'Status': status,
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
      'tipoPraga': tipoPraga
    };
  }
}
