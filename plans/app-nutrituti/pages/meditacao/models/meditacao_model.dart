// Package imports:
import 'package:uuid/uuid.dart';

class MeditacaoModel {
  final String id;
  final DateTime dataRegistro;
  final int duracao; // em minutos
  final String tipo; // tipo de meditação (respiração, corpo, etc.)
  final String humor; // humor antes/depois da meditação

  MeditacaoModel({
    String? id,
    required this.dataRegistro,
    required this.duracao,
    required this.tipo,
    required this.humor,
  }) : id = id ?? const Uuid().v4();

  // Factory para criar um novo registro
  factory MeditacaoModel.create({
    required int duracao,
    required String tipo,
    required String humor,
  }) {
    return MeditacaoModel(
      dataRegistro: DateTime.now(),
      duracao: duracao,
      tipo: tipo,
      humor: humor,
    );
  }

  // Converter para Map para salvar no SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataRegistro': dataRegistro.toIso8601String(),
      'duracao': duracao,
      'tipo': tipo,
      'humor': humor,
    };
  }

  // Construir a partir de um Map (do SharedPreferences)
  factory MeditacaoModel.fromMap(Map<String, dynamic> map) {
    return MeditacaoModel(
      id: map['id'],
      dataRegistro: DateTime.parse(map['dataRegistro']),
      duracao: map['duracao'],
      tipo: map['tipo'],
      humor: map['humor'],
    );
  }

  // Cópia do objeto com alterações (para edições)
  MeditacaoModel copyWith({
    String? id,
    DateTime? dataRegistro,
    int? duracao,
    String? tipo,
    String? humor,
  }) {
    return MeditacaoModel(
      id: id ?? this.id,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      duracao: duracao ?? this.duracao,
      tipo: tipo ?? this.tipo,
      humor: humor ?? this.humor,
    );
  }
}
