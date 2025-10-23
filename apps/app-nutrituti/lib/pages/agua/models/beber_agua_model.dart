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
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dataRegistro': dataRegistro,
      'quantidade': quantidade,
      'fkIdPerfil': fkIdPerfil,
    };
  }

  factory BeberAgua.fromMap(Map<String, dynamic> map) {
    return BeberAgua(
      id: map['id'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int))
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
              ? map['updatedAt'] as DateTime
              : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int))
          : null,
      dataRegistro: (map['dataRegistro'] as num?)?.toInt() ?? 0,
      quantidade: (map['quantidade'] as num?)?.toDouble() ?? 0.0,
      fkIdPerfil: map['fkIdPerfil'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
