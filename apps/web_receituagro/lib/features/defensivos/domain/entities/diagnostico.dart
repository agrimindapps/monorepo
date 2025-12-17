import 'package:equatable/equatable.dart';

/// Diagnostico entity - Domain layer
/// Representa a relação many-to-many entre Defensivo, Cultura e Praga
/// Contém informações de dosagem e aplicação
class Diagnostico extends Equatable {
  final String id;
  final String defensivoId; // FK to defensivos
  final String culturaId; // FK to culturas
  final String pragaId; // FK to pragas

  // Dosagem (L/ha ou kg/ha)
  final String? dsMin;
  final String? dsMax;
  final String? um; // Unidade de medida

  // Aplicação Terrestre (Volume de calda L/ha)
  final String? minAplicacaoT;
  final String? maxAplicacaoT;
  final String? umT; // Unidade de medida terrestre

  // Aplicação Aérea (Volume de calda L/ha)
  final String? minAplicacaoA;
  final String? maxAplicacaoA;
  final String? umA; // Unidade de medida aérea

  // Intervalos e época
  final String? intervalo; // Intervalo de segurança (dias)
  final String? intervalo2; // Intervalo de reentrada
  final String? epocaAplicacao;

  // Campos opcionais para exibição (vindos de views)
  final String? culturaNome;
  final String? pragaNomeComum;
  final String? pragaNomeCientifico;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Diagnostico({
    required this.id,
    required this.defensivoId,
    required this.culturaId,
    required this.pragaId,
    this.dsMin,
    this.dsMax,
    this.um,
    this.minAplicacaoT,
    this.maxAplicacaoT,
    this.umT,
    this.minAplicacaoA,
    this.maxAplicacaoA,
    this.umA,
    this.intervalo,
    this.intervalo2,
    this.epocaAplicacao,
    this.culturaNome,
    this.pragaNomeComum,
    this.pragaNomeCientifico,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        defensivoId,
        culturaId,
        pragaId,
        dsMin,
        dsMax,
        um,
        minAplicacaoT,
        maxAplicacaoT,
        umT,
        minAplicacaoA,
        maxAplicacaoA,
        umA,
        intervalo,
        intervalo2,
        epocaAplicacao,
        culturaNome,
        pragaNomeComum,
        pragaNomeCientifico,
        createdAt,
        updatedAt,
      ];

  Diagnostico copyWith({
    String? id,
    String? defensivoId,
    String? culturaId,
    String? pragaId,
    String? dsMin,
    String? dsMax,
    String? um,
    String? minAplicacaoT,
    String? maxAplicacaoT,
    String? umT,
    String? minAplicacaoA,
    String? maxAplicacaoA,
    String? umA,
    String? intervalo,
    String? intervalo2,
    String? epocaAplicacao,
    String? culturaNome,
    String? pragaNomeComum,
    String? pragaNomeCientifico,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diagnostico(
      id: id ?? this.id,
      defensivoId: defensivoId ?? this.defensivoId,
      culturaId: culturaId ?? this.culturaId,
      pragaId: pragaId ?? this.pragaId,
      dsMin: dsMin ?? this.dsMin,
      dsMax: dsMax ?? this.dsMax,
      um: um ?? this.um,
      minAplicacaoT: minAplicacaoT ?? this.minAplicacaoT,
      maxAplicacaoT: maxAplicacaoT ?? this.maxAplicacaoT,
      umT: umT ?? this.umT,
      minAplicacaoA: minAplicacaoA ?? this.minAplicacaoA,
      maxAplicacaoA: maxAplicacaoA ?? this.maxAplicacaoA,
      umA: umA ?? this.umA,
      intervalo: intervalo ?? this.intervalo,
      intervalo2: intervalo2 ?? this.intervalo2,
      epocaAplicacao: epocaAplicacao ?? this.epocaAplicacao,
      culturaNome: culturaNome ?? this.culturaNome,
      pragaNomeComum: pragaNomeComum ?? this.pragaNomeComum,
      pragaNomeCientifico: pragaNomeCientifico ?? this.pragaNomeCientifico,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
