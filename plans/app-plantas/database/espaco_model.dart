// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part 'espaco_model.g.dart';

@HiveType(typeId: 81)
class EspacoModel extends BaseModel {
  @HiveField(7)
  String nome;
  @HiveField(8)
  String? descricao;
  @HiveField(9)
  bool ativo;
  @HiveField(10)
  DateTime? dataCriacao;

  EspacoModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nome,
    this.descricao,
    this.ativo = true,
    this.dataCriacao,
  });

  @override
  EspacoModel copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? nome,
    String? descricao,
    bool? ativo,
    DateTime? dataCriacao,
  }) {
    return EspacoModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    )..updateBase(
        isDeleted: isDeleted,
        needsSync: needsSync,
        lastSyncAt: lastSyncAt,
        version: version,
      );
  }

  Map<String, dynamic> toJson() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'dataCriacao': dataCriacao?.toIso8601String(),
    });
    return baseMap;
  }

  factory EspacoModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return EspacoModel(
      id: json['id'] ?? '',
      createdAt: _extractTimestamp(json['createdAt']) ?? now,
      updatedAt: _extractTimestamp(json['updatedAt']) ?? now,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      ativo: json['ativo'] ?? true,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : null,
    );
  }

  @override
  String toString() {
    return 'EspacoModel(id: $id, nome: $nome, descricao: $descricao, ativo: $ativo, dataCriacao: $dataCriacao)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EspacoModel &&
        other.id == id &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.ativo == ativo &&
        other.dataCriacao == dataCriacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        descricao.hashCode ^
        ativo.hashCode ^
        dataCriacao.hashCode;
  }

  /// Converte Timestamp do Firestore ou int para int
  static int? _extractTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }
}
