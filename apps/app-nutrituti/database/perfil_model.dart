// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../core/models/base_model.dart';

part 'perfil_model.g.dart';

@HiveType(typeId: 52)
class PerfilModel extends BaseModel {
  @HiveField(7)
  String nome;

  @HiveField(8)
  DateTime datanascimento;

  @HiveField(9)
  double altura;

  @HiveField(10)
  double peso;

  @HiveField(11)
  int genero;

  @HiveField(12)
  String? imagePath;

  PerfilModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nome,
    required this.datanascimento,
    required this.altura,
    required this.peso,
    required this.genero,
    this.imagePath,
  });

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'nome': nome,
      'datanascimento': datanascimento.millisecondsSinceEpoch,
      'altura': altura,
      'peso': peso,
      'genero': genero,
      'imagePath': imagePath,
    });
  }

  factory PerfilModel.fromMap(Map<String, dynamic> map) {
    return PerfilModel(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      nome: map['nome'] ?? '',
      datanascimento: DateTime.fromMillisecondsSinceEpoch(map['datanascimento'] ?? 0),
      altura: map['altura']?.toDouble() ?? 0.0,
      peso: map['peso']?.toDouble() ?? 0.0,
      genero: map['genero'] ?? 0,
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
