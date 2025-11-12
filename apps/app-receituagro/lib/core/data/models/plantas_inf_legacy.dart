import 'package:core/core.dart' hide Column;

// part 'plantas_inf_hive.g.dart';

class PlantasInfHive {
  String objectId;

  int createdAt;

  int updatedAt;

  String idReg;

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

  PlantasInfHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
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

  factory PlantasInfHive.fromJson(Map<String, dynamic> json) {
    return PlantasInfHive(
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: (json['idReg'] as String?) ?? '',
      ciclo: json['ciclo'] as String?,
      reproducao: json['reproducao'] as String?,
      habitat: json['habitat'] as String?,
      adaptacoes: json['adaptacoes'] as String?,
      altura: json['altura'] as String?,
      filotaxia: json['filotaxia'] as String?,
      formaLimbo: json['formaLimbo'] as String?,
      superficie: json['superficie'] as String?,
      consistencia: json['consistencia'] as String?,
      nervacao: json['nervacao'] as String?,
      nervacaoComprimento: json['nervacaoComprimento'] as String?,
      inflorescencia: json['inflorescencia'] as String?,
      perianto: json['perianto'] as String?,
      tipologiaFruto: json['tipologiaFruto'] as String?,
      observacoes: json['observacoes'] as String?,
      fkIdPraga: json['fkIdPraga'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
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

  @override
  String toString() {
    return 'PlantasInfHive{objectId: $objectId, fkIdPraga: $fkIdPraga}';
  }
}
