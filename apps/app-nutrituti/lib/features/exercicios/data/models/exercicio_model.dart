// Removendo o import não utilizado
// import 'package:json_annotation/json_annotation.dart';

// Removendo a referência part que estava causando o erro
// part 'exercicio_model.g.dart';

class ExercicioModel {
  String? id;
  final String nome;
  final String categoria;
  final int duracao; // em minutos
  final int caloriasQueimadas;
  final int dataRegistro; // timestamp
  final String? observacoes;

  ExercicioModel({
    this.id,
    required this.nome,
    required this.categoria,
    required this.duracao,
    required this.caloriasQueimadas,
    required this.dataRegistro,
    this.observacoes,
  });

  // Implementando manualmente os métodos que seriam gerados pelo json_serializable
  factory ExercicioModel.fromJson(Map<String, dynamic> json) {
    return ExercicioModel(
      id: json['id'] as String?,
      nome: json['nome'] as String,
      categoria: json['categoria'] as String,
      duracao: json['duracao'] as int,
      caloriasQueimadas: json['caloriasQueimadas'] as int,
      dataRegistro: json['dataRegistro'] as int,
      observacoes: json['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'categoria': categoria,
        'duracao': duracao,
        'caloriasQueimadas': caloriasQueimadas,
        'dataRegistro': dataRegistro,
        'observacoes': observacoes,
      };

  ExercicioModel copyWith({
    String? id,
    String? nome,
    String? categoria,
    int? duracao,
    int? caloriasQueimadas,
    int? dataRegistro,
    String? observacoes,
  }) {
    return ExercicioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      duracao: duracao ?? this.duracao,
      caloriasQueimadas: caloriasQueimadas ?? this.caloriasQueimadas,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}
