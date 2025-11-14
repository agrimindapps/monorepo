import 'package:equatable/equatable.dart';

/// Domain entity for exercise data
class Exercicio extends Equatable {
  final String? id;
  final String nome;
  final String categoria;
  final int duracao; // em minutos
  final int caloriasQueimadas;
  final int dataRegistro; // timestamp
  final String? observacoes;

  const Exercicio({
    this.id,
    required this.nome,
    required this.categoria,
    required this.duracao,
    required this.caloriasQueimadas,
    required this.dataRegistro,
    this.observacoes,
  });

  @override
  List<Object?> get props => [
    id,
    nome,
    categoria,
    duracao,
    caloriasQueimadas,
    dataRegistro,
    observacoes,
  ];

  Exercicio copyWith({
    String? id,
    String? nome,
    String? categoria,
    int? duracao,
    int? caloriasQueimadas,
    int? dataRegistro,
    String? observacoes,
  }) {
    return Exercicio(
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
