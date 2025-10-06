import 'package:core/core.dart';

part 'fitossanitario_info_hive.g.dart';

@HiveType(typeId: 103)
class FitossanitarioInfoHive extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  String? embalagens;

  @HiveField(5)
  String? tecnologia;

  @HiveField(6)
  String? pHumanas;

  @HiveField(7)
  String? pAmbiental;

  @HiveField(8)
  String? manejoResistencia;

  @HiveField(9)
  String? compatibilidade;

  @HiveField(10)
  String? manejoIntegrado;

  @HiveField(11)
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
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
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
