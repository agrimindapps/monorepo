import 'package:core/core.dart';

/// Entidade de domínio que representa um diagnóstico
///
/// Esta entidade representa a relação entre defensivo, praga e cultura,
/// seguindo os princípios de Clean Architecture
class DiagnosticoEntity extends Equatable {
  final String id;
  final String idDefensivo;
  final String? nomeDefensivo;
  final String? nomeCultura;
  final String? nomePraga;
  final String dosagem;
  final String? unidadeDosagem;
  final String? modoAplicacao;
  final int? intervaloDias;
  final String? observacoes;
  final String ingredienteAtivo;
  final String cultura;
  final String grupo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DiagnosticoEntity({
    required this.id,
    required this.idDefensivo,
    this.nomeDefensivo,
    this.nomeCultura,
    this.nomePraga,
    required this.dosagem,
    this.unidadeDosagem,
    this.modoAplicacao,
    this.intervaloDias,
    this.observacoes,
    required this.ingredienteAtivo,
    required this.cultura,
    required this.grupo,
    this.createdAt,
    this.updatedAt,
  });

  /// Getters computados
  String get dosagemFormatada => dosagem + (unidadeDosagem ?? '');

  String get intervaloFormatado =>
      intervaloDias != null ? '$intervaloDias dias' : 'Não especificado';

  bool get hasCompleteInfo =>
      nomeDefensivo != null &&
      nomeCultura != null &&
      nomePraga != null &&
      dosagem.isNotEmpty;

  String get aplicacaoInfo => modoAplicacao ?? 'Pulverização foliar';

  String get nome => nomeDefensivo ?? 'Defensivo não identificado';

  DiagnosticoEntity copyWith({
    String? id,
    String? idDefensivo,
    String? nomeDefensivo,
    String? nomeCultura,
    String? nomePraga,
    String? dosagem,
    String? unidadeDosagem,
    String? modoAplicacao,
    int? intervaloDias,
    String? observacoes,
    String? ingredienteAtivo,
    String? cultura,
    String? grupo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiagnosticoEntity(
      id: id ?? this.id,
      idDefensivo: idDefensivo ?? this.idDefensivo,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      nomeCultura: nomeCultura ?? this.nomeCultura,
      nomePraga: nomePraga ?? this.nomePraga,
      dosagem: dosagem ?? this.dosagem,
      unidadeDosagem: unidadeDosagem ?? this.unidadeDosagem,
      modoAplicacao: modoAplicacao ?? this.modoAplicacao,
      intervaloDias: intervaloDias ?? this.intervaloDias,
      observacoes: observacoes ?? this.observacoes,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      cultura: cultura ?? this.cultura,
      grupo: grupo ?? this.grupo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    idDefensivo,
    nomeDefensivo,
    nomeCultura,
    nomePraga,
    dosagem,
    unidadeDosagem,
    modoAplicacao,
    intervaloDias,
    observacoes,
    ingredienteAtivo,
    cultura,
    grupo,
    createdAt,
    updatedAt,
  ];
}
