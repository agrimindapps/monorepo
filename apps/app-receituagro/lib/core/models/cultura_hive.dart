import 'package:hive/hive.dart';

part 'cultura_hive.g.dart';

@HiveType(typeId: 100)
class CulturaHive extends HiveObject {
  @HiveField(0)
  String objectId;

  @HiveField(1)
  int createdAt;

  @HiveField(2)
  int updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  String cultura;

  CulturaHive({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    required this.cultura,
  });

  factory CulturaHive.fromJson(Map<String, dynamic> json) {
    return CulturaHive(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: json['idReg'] ?? '',
      cultura: json['cultura'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      'cultura': cultura,
    };
  }

  @override
  String toString() {
    return 'CulturaHive{objectId: $objectId, cultura: $cultura}';
  }
}