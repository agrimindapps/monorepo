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
      objectId: (json['objectId']?.toString()) ?? '',
      createdAt: _parseIntSafely(json['createdAt']),
      updatedAt: _parseIntSafely(json['updatedAt']),
      idReg: (json['idReg']?.toString()) ?? '',
      cultura: (json['cultura']?.toString()) ?? '',
    );
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return int.tryParse(value.toString()) ?? 0;
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