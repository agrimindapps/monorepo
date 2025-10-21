// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';

part 'perfil_model.g.dart';

@HiveType(typeId: 52)
class PerfilModel extends BaseModel {
  @HiveField(7)
  final String nome;

  @HiveField(8)
  final DateTime datanascimento;

  @HiveField(9)
  final double altura;

  @HiveField(10)
  final double peso;

  @HiveField(11)
  final int genero;

  @HiveField(12)
  final String? imagePath;

  const PerfilModel({
    super.id,
    super.createdAt,
    super.updatedAt,
    required this.nome,
    required this.datanascimento,
    required this.altura,
    required this.peso,
    required this.genero,
    this.imagePath,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'nome': nome,
      'datanascimento': datanascimento.millisecondsSinceEpoch,
      'altura': altura,
      'peso': peso,
      'genero': genero,
      'imagePath': imagePath,
    };
  }

  factory PerfilModel.fromMap(Map<String, dynamic> map) {
    return PerfilModel(
      id: map['id'] as String?,
      createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'] as String)
        : null,
      updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'] as String)
        : null,
      nome: map['nome'] as String? ?? '',
      datanascimento: DateTime.fromMillisecondsSinceEpoch(
        (map['datanascimento'] as int?) ?? 0
      ),
      altura: (map['altura'] as num?)?.toDouble() ?? 0.0,
      peso: (map['peso'] as num?)?.toDouble() ?? 0.0,
      genero: map['genero'] as int? ?? 0,
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
