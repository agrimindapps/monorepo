// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../core/models/base_model.dart';

part 'beber_agua_model.g.dart';

@HiveType(typeId: 51)
class BeberAgua extends BaseModel {
  @HiveField(7)
  int dataRegistro;

  @HiveField(8)
  double quantidade;

  @HiveField(9)
  String fkIdPerfil;

  BeberAgua({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.dataRegistro,
    required this.quantidade,
    required this.fkIdPerfil,
  });

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'dataRegistro': dataRegistro,
      'quantidade': quantidade,
      'fkIdPerfil': fkIdPerfil,
    });
  }

  factory BeberAgua.fromMap(Map<String, dynamic> map) {
    return BeberAgua(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      dataRegistro: map['dataRegistro'] ?? 0,
      quantidade: map['quantidade']?.toDouble() ?? 0.0,
      fkIdPerfil: map['fkIdPerfil'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
