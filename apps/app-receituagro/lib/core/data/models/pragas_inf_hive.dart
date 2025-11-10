import 'package:core/core.dart' hide Column;

part 'pragas_inf_hive.g.dart';

@HiveType(typeId: 106)
class PragasInfHive extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  String? descrisao;

  @HiveField(5)
  String? sintomas;

  @HiveField(6)
  String? bioecologia;

  @HiveField(7)
  String? controle;

  @HiveField(8)
  String fkIdPraga;

  PragasInfHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    this.descrisao,
    this.sintomas,
    this.bioecologia,
    this.controle,
    required this.fkIdPraga,
  });

  factory PragasInfHive.fromJson(Map<String, dynamic> json) {
    return PragasInfHive(
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: (json['idReg'] as String?) ?? '',
      descrisao: json['descrisao'] as String?,
      sintomas: json['sintomas'] as String?,
      bioecologia: json['bioecologia'] as String?,
      controle: json['controle'] as String?,
      fkIdPraga: (json['fkIdPraga'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      'descrisao': descrisao,
      'sintomas': sintomas,
      'bioecologia': bioecologia,
      'controle': controle,
      'fkIdPraga': fkIdPraga,
    };
  }

  @override
  String toString() {
    return 'PragasInfHive{objectId: $objectId, fkIdPraga: $fkIdPraga}';
  }
}
