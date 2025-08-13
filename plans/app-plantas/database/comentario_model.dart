// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part 'comentario_model.g.dart';

@HiveType(typeId: 80)
class ComentarioModel extends BaseModel {
  @HiveField(7)
  String conteudo;
  @HiveField(8)
  DateTime? dataAtualizacao;
  @HiveField(9)
  DateTime? dataCriacao;

  ComentarioModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.conteudo,
    this.dataAtualizacao,
    this.dataCriacao,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ComentarioModel(
      id: json['id'] ?? '',
      createdAt: _extractTimestamp(json['createdAt']) ?? now,
      updatedAt: _extractTimestamp(json['updatedAt']) ?? now,
      conteudo: json['conteudo'] ?? '',
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.parse(json['dataAtualizacao'])
          : null,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'conteudo': conteudo,
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'dataCriacao': dataCriacao?.toIso8601String(),
    });
    return baseMap;
  }

  @override
  ComentarioModel copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? conteudo,
    DateTime? dataAtualizacao,
    DateTime? dataCriacao,
  }) {
    return ComentarioModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conteudo: conteudo ?? this.conteudo,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    )..updateBase(
        isDeleted: isDeleted,
        needsSync: needsSync,
        lastSyncAt: lastSyncAt,
        version: version,
      );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComentarioModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Converte Timestamp do Firestore ou int para int
  static int? _extractTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }
}
