import 'package:core/core.dart' hide Column;

// part 'fitossanitario_info_hive.g.dart';

class FitossanitarioInfoHive {
  String objectId;

  int createdAt;

  int updatedAt;

  String idReg;

  String? embalagens;

  String? tecnologia;

  String? pHumanas;

  String? pAmbiental;

  String? manejoResistencia;

  String? compatibilidade;

  String? manejoIntegrado;

  String fkIdDefensivo;

  FitossanitarioInfoHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    this.embalagens,
    this.tecnologia,
    this.pHumanas,
    this.pAmbiental,
    this.manejoResistencia,
    this.compatibilidade,
    this.manejoIntegrado,
    required this.fkIdDefensivo,
  });

  factory FitossanitarioInfoHive.fromJson(Map<String, dynamic> json) {
    return FitossanitarioInfoHive(
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? int.tryParse(json['createdAt'].toString()) ?? 0
          : 0,
      updatedAt: json['updatedAt'] != null
          ? int.tryParse(json['updatedAt'].toString()) ?? 0
          : 0,
      idReg: (json['idReg'] as String?) ?? '',
      embalagens: json['embalagens'] as String?,
      tecnologia: json['tecnologia'] as String?,
      pHumanas: json['pHumanas'] as String?,
      pAmbiental: json['pAmbiental'] as String?,
      manejoResistencia: json['manejoResistencia'] as String?,
      compatibilidade: json['compatibilidade'] as String?,
      manejoIntegrado: json['manejoIntegrado'] as String?,
      fkIdDefensivo: (json['fkIdDefensivo'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      'embalagens': embalagens,
      'tecnologia': tecnologia,
      'pHumanas': pHumanas,
      'pAmbiental': pAmbiental,
      'manejoResistencia': manejoResistencia,
      'compatibilidade': compatibilidade,
      'manejoIntegrado': manejoIntegrado,
      'fkIdDefensivo': fkIdDefensivo,
    };
  }

  @override
  String toString() {
    return 'FitossanitarioInfoHive{objectId: $objectId, fkIdDefensivo: $fkIdDefensivo}';
  }
}
