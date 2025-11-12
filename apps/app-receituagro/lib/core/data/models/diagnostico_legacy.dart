import 'package:core/core.dart' hide Column;

// part 'diagnostico_hive.g.dart';

class DiagnosticoHive {
  String objectId;

  int createdAt;

  int updatedAt;

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
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: (json['IdReg'] as String?) ?? '',
      fkIdDefensivo: (json['fkIdDefensivo'] as String?) ?? '',
      nomeDefensivo: json['nomeDefensivo'] as String?,
      fkIdCultura: (json['fkIdCultura'] as String?) ?? '',
      nomeCultura: json['nomeCultura'] as String?,
      fkIdPraga: (json['fkIdPraga'] as String?) ?? '',
      nomePraga: json['nomePraga'] as String?,
      dsMin: json['dsMin'] as String?,
      dsMax: (json['dsMax'] as String?) ?? '',
      um: (json['um'] as String?) ?? '',
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

  String get id => idReg;
  String get nome => nomeDefensivo ?? 'Defensivo desconhecido';
  String get cultura => nomeCultura ?? 'Cultura desconhecida';
  String get praga => nomePraga ?? 'Praga desconhecida';
  String get sintomas =>
      dsMax; // Usando dsMax como sintomas por compatibilidade
  String get situacao => 'Ativo'; // Situação padrão
  String get tipo => 'Diagnóstico'; // Tipo padrão

  // Nota: O método toDataMap() foi movido para DiagnosticoHiveExtension
  // para prover resolução dinâmica de dados relacionados (defensivo, cultura, praga).
  // Ver: core/extensions/diagnostico_hive_extension.dart

  @override
  String toString() {
    return 'DiagnosticoHive{objectId: $objectId, nomeDefensivo: $nomeDefensivo, nomePraga: $nomePraga}';
  }
}
