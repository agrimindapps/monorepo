import 'package:hive/hive.dart';

part 'diagnostico_hive.g.dart';

@HiveType(typeId: 101)
class DiagnosticoHive extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  String fkIdDefensivo;

  @HiveField(5)
  String? nomeDefensivo;

  @HiveField(6)
  String fkIdCultura;

  @HiveField(7)
  String? nomeCultura;

  @HiveField(8)
  String fkIdPraga;

  @HiveField(9)
  String? nomePraga;

  @HiveField(10)
  String? dsMin;

  @HiveField(11)
  String dsMax;

  @HiveField(12)
  String um;

  @HiveField(13)
  String? minAplicacaoT;

  @HiveField(14)
  String? maxAplicacaoT;

  @HiveField(15)
  String? umT;

  @HiveField(16)
  String? minAplicacaoA;

  @HiveField(17)
  String? maxAplicacaoA;

  @HiveField(18)
  String? umA;

  @HiveField(19)
  String? intervalo;

  @HiveField(20)
  String? intervalo2;

  @HiveField(21)
  String? epocaAplicacao;

  DiagnosticoHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
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
    this.epocaAplicacao,
  });

  factory DiagnosticoHive.fromJson(Map<String, dynamic> json) {
    return DiagnosticoHive(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: json['IdReg'] ?? '',
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

  @override
  String toString() {
    return 'DiagnosticoHive{objectId: $objectId, nomeDefensivo: $nomeDefensivo, nomePraga: $nomePraga}';
  }
}