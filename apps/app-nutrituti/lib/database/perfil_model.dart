// Project imports:
import '../../../core/models/base_model.dart';

class PerfilModel extends BaseModel {
  @override
  final String? id;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  final String nome;

  final DateTime datanascimento;

  final double altura;

  final double peso;

  final int genero;

  final String? imagePath;

  const PerfilModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.nome,
    required this.datanascimento,
    required this.altura,
    required this.peso,
    required this.genero,
    this.imagePath,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

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

  PerfilModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nome,
    DateTime? datanascimento,
    double? altura,
    double? peso,
    int? genero,
    String? imagePath,
  }) {
    return PerfilModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nome: nome ?? this.nome,
      datanascimento: datanascimento ?? this.datanascimento,
      altura: altura ?? this.altura,
      peso: peso ?? this.peso,
      genero: genero ?? this.genero,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
