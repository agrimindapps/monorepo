import 'package:equatable/equatable.dart';

/// Defensivo (Fitossanitário) entity - Domain layer
/// Representa um produto defensivo agrícola completo
class Defensivo extends Equatable {
  final String id;
  final String nomeComum;
  final String? nomeTecnico;
  final String fabricante;
  final String ingredienteAtivo;
  final String? quantProduto;
  final String? mapa; // Número de registro MAPA
  final String? formulacao; // EC, SC, WG, etc
  final String? modoAcao; // Sistêmico, contato, etc
  final String? classeAgronomica;
  final String? toxico; // Classe toxicológica (I, II, III, IV)
  final String? classAmbiental; // Classe ambiental (I, II, III, IV)
  final String? inflamavel;
  final String? corrosivo;
  final String? comercializado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Defensivo({
    required this.id,
    required this.nomeComum,
    this.nomeTecnico,
    required this.fabricante,
    required this.ingredienteAtivo,
    this.quantProduto,
    this.mapa,
    this.formulacao,
    this.modoAcao,
    this.classeAgronomica,
    this.toxico,
    this.classAmbiental,
    this.inflamavel,
    this.corrosivo,
    this.comercializado,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nomeComum,
        nomeTecnico,
        fabricante,
        ingredienteAtivo,
        quantProduto,
        mapa,
        formulacao,
        modoAcao,
        classeAgronomica,
        toxico,
        classAmbiental,
        inflamavel,
        corrosivo,
        comercializado,
        createdAt,
        updatedAt,
      ];

  Defensivo copyWith({
    String? id,
    String? nomeComum,
    String? nomeTecnico,
    String? fabricante,
    String? ingredienteAtivo,
    String? quantProduto,
    String? mapa,
    String? formulacao,
    String? modoAcao,
    String? classeAgronomica,
    String? toxico,
    String? classAmbiental,
    String? inflamavel,
    String? corrosivo,
    String? comercializado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Defensivo(
      id: id ?? this.id,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeTecnico: nomeTecnico ?? this.nomeTecnico,
      fabricante: fabricante ?? this.fabricante,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      quantProduto: quantProduto ?? this.quantProduto,
      mapa: mapa ?? this.mapa,
      formulacao: formulacao ?? this.formulacao,
      modoAcao: modoAcao ?? this.modoAcao,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      toxico: toxico ?? this.toxico,
      classAmbiental: classAmbiental ?? this.classAmbiental,
      inflamavel: inflamavel ?? this.inflamavel,
      corrosivo: corrosivo ?? this.corrosivo,
      comercializado: comercializado ?? this.comercializado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
