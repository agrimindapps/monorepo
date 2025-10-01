import 'package:core/core.dart';

part 'pragas_hive.g.dart';

@HiveType(typeId: 105)
class PragasHive extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  String nomeComum;

  @HiveField(5)
  String nomeCientifico;

  @HiveField(6)
  String? dominio;

  @HiveField(7)
  String? reino;

  @HiveField(8)
  String? subReino;

  @HiveField(9)
  String? clado01;

  @HiveField(10)
  String? clado02;

  @HiveField(11)
  String? clado03;

  @HiveField(12)
  String? superDivisao;

  @HiveField(13)
  String? divisao;

  @HiveField(14)
  String? subDivisao;

  @HiveField(15)
  String? classe;

  @HiveField(16)
  String? subClasse;

  @HiveField(17)
  String? superOrdem;

  @HiveField(18)
  String? ordem;

  @HiveField(19)
  String? subOrdem;

  @HiveField(20)
  String? infraOrdem;

  @HiveField(21)
  String? superFamilia;

  @HiveField(22)
  String? familia;

  @HiveField(23)
  String? subFamilia;

  @HiveField(24)
  String? tribo;

  @HiveField(25)
  String? subTribo;

  @HiveField(26)
  String? genero;

  @HiveField(27)
  String? especie;

  @HiveField(28)
  String tipoPraga;

  PragasHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
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

  factory PragasHive.fromJson(Map<String, dynamic> json) {
    return PragasHive(
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: (json['idReg'] as String?) ?? '',
      nomeComum: (json['nomeComum'] as String?) ?? '',
      nomeCientifico: (json['nomeCientifico'] as String?) ?? '',
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
      tipoPraga: (json['tipoPraga'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
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

  // Getters convenientes para compatibilidade com código legado
  String? get descricao => tipoPraga.isNotEmpty ? tipoPraga : null; // Usando tipoPraga como descrição

  @override
  String toString() {
    return 'PragasHive{objectId: $objectId, nomeComum: $nomeComum, nomeCientifico: $nomeCientifico}';
  }
}