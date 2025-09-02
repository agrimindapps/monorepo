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
      objectId: (json['objectId'] as String?) ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: (json['idReg'] as String?) ?? '',
      cultura: (json['cultura'] as String?) ?? '',
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

  // Getters convenientes para compatibilidade com código legado
  String get nome => cultura;
  String get nomeComum => cultura;
  String get nomeCientifico => cultura; // Por enquanto, vamos usar o mesmo valor

  @override
  String toString() {
    return 'CulturaHive{objectId: $objectId, cultura: $cultura}';
  }
}