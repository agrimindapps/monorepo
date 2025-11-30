// Project imports:
import '../../../../../core/models/base_model.dart';

class BeberAgua extends BaseModel {
  final int dataRegistro;
  final double quantidade;
  final String fkIdPerfil;

  const BeberAgua({
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
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'dataRegistro': dataRegistro,
      'quantidade': quantidade,
      'fkIdPerfil': fkIdPerfil,
    };
  }

  factory BeberAgua.fromMap(Map<String, dynamic> map) {
    return BeberAgua(
      id: map['id'] as String?,
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

  factory BeberAgua.fromJson(Map<String, dynamic> json) =>
      BeberAgua.fromMap(json);

  BeberAgua copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? dataRegistro,
    double? quantidade,
    String? fkIdPerfil,
  }) {
    return BeberAgua(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      quantidade: quantidade ?? this.quantidade,
      fkIdPerfil: fkIdPerfil ?? this.fkIdPerfil,
    );
  }
}
