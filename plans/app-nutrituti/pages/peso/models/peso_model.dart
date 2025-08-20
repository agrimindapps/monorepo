// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../core/models/base_model.dart';

part 'peso_model.g.dart';

@HiveType(typeId: 53)
class PesoModel extends BaseModel {
  @HiveField(7)
  int dataRegistro;

  @HiveField(8)
  double peso;

  @HiveField(9)
  String fkIdPerfil;

  PesoModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.dataRegistro,
    required this.peso,
    required this.fkIdPerfil,
  });

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'dataRegistro': dataRegistro,
      'peso': peso,
      'fkIdPerfil': fkIdPerfil,
    });
  }

  factory PesoModel.fromMap(Map<String, dynamic> map) {
    return PesoModel(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      dataRegistro: map['dataRegistro'] ?? 0,
      peso: map['peso']?.toDouble() ?? 0.0,
      fkIdPerfil: map['fkIdPerfil'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
