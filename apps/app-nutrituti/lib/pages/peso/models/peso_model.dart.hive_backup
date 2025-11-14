// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../core/models/base_model.dart';

part 'peso_model.g.dart';

@HiveType(typeId: 53)
class PesoModel extends BaseModel {
  @HiveField(0)
  @override
  final String? id;

  @HiveField(1)
  @override
  final DateTime? createdAt;

  @HiveField(2)
  @override
  final DateTime? updatedAt;

  @HiveField(7)
  int dataRegistro;

  @HiveField(8)
  double peso;

  @HiveField(9)
  final String fkIdPerfil;

  @HiveField(10)
  final bool isDeleted;

  PesoModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.dataRegistro,
    required this.peso,
    required this.fkIdPerfil,
    this.isDeleted = false,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = <String, dynamic>{
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    return baseMap..addAll({
      'dataRegistro': dataRegistro,
      'peso': peso,
      'fkIdPerfil': fkIdPerfil,
      'isDeleted': isDeleted,
    });
  }

  factory PesoModel.fromMap(Map<String, dynamic> map) {
    return PesoModel(
      id: map['id'] as String? ?? '',
      createdAt: map['createdAt'] as DateTime?,
      updatedAt: map['updatedAt'] as DateTime?,
      dataRegistro: (map['dataRegistro'] as num?)?.toInt() ?? 0,
      peso: (map['peso'] as num?)?.toDouble() ?? 0.0,
      fkIdPerfil: map['fkIdPerfil'] as String? ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  PesoModel markAsDeleted() {
    return PesoModel(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      dataRegistro: dataRegistro,
      peso: peso,
      fkIdPerfil: fkIdPerfil,
      isDeleted: true,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
