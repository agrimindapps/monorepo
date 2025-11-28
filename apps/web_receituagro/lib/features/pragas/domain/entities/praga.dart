import 'package:equatable/equatable.dart';

import 'tipo_praga.dart';

/// Praga (Pest) entity - Domain layer
class Praga extends Equatable {
  final String id;
  final String nomeComum;
  final String nomeCientifico;
  final String? nomesSecundarios; // Pseudo nomes / nomes alternativos
  final String ordem;
  final String familia;
  final TipoPraga? tipoPraga; // 1=Inseto, 2=Doença, 3=Planta Daninha
  final String? descricao;
  final String? imageUrl;
  final List<String>? culturasAfetadas;
  final String? danos;
  final String? controle;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Taxonomia - Reino
  final String? dominio;
  final String? reino;
  final String? subReino;

  // Taxonomia - Clado
  final String? clado01;
  final String? clado02;
  final String? clado03;

  // Taxonomia - Divisão
  final String? superDivisao;
  final String? divisao;
  final String? subDivisao;

  // Taxonomia - Classe
  final String? classe;
  final String? subClasse;

  // Taxonomia - Família (já tem familia, adicionando super e sub)
  final String? superFamilia;
  final String? subFamilia;

  // Taxonomia - Ordem (já tem ordem, adicionando super, sub e infra)
  final String? superOrdem;
  final String? subOrdem;
  final String? infraOrdem;

  // Taxonomia - Outros
  final String? tribo;
  final String? subTribo;
  final String? genero;
  final String? especie;

  const Praga({
    required this.id,
    required this.nomeComum,
    required this.nomeCientifico,
    this.nomesSecundarios,
    required this.ordem,
    required this.familia,
    this.tipoPraga,
    this.descricao,
    this.imageUrl,
    this.culturasAfetadas,
    this.danos,
    this.controle,
    required this.createdAt,
    required this.updatedAt,
    // Taxonomia - Reino
    this.dominio,
    this.reino,
    this.subReino,
    // Taxonomia - Clado
    this.clado01,
    this.clado02,
    this.clado03,
    // Taxonomia - Divisão
    this.superDivisao,
    this.divisao,
    this.subDivisao,
    // Taxonomia - Classe
    this.classe,
    this.subClasse,
    // Taxonomia - Família
    this.superFamilia,
    this.subFamilia,
    // Taxonomia - Ordem
    this.superOrdem,
    this.subOrdem,
    this.infraOrdem,
    // Taxonomia - Outros
    this.tribo,
    this.subTribo,
    this.genero,
    this.especie,
  });

  @override
  List<Object?> get props => [
        id,
        nomeComum,
        nomeCientifico,
        nomesSecundarios,
        ordem,
        familia,
        tipoPraga,
        descricao,
        imageUrl,
        culturasAfetadas,
        danos,
        controle,
        createdAt,
        updatedAt,
        // Taxonomia
        dominio,
        reino,
        subReino,
        clado01,
        clado02,
        clado03,
        superDivisao,
        divisao,
        subDivisao,
        classe,
        subClasse,
        superFamilia,
        subFamilia,
        superOrdem,
        subOrdem,
        infraOrdem,
        tribo,
        subTribo,
        genero,
        especie,
      ];

  /// Create a copy with updated fields
  Praga copyWith({
    String? id,
    String? nomeComum,
    String? nomeCientifico,
    String? nomesSecundarios,
    String? ordem,
    String? familia,
    TipoPraga? tipoPraga,
    String? descricao,
    String? imageUrl,
    List<String>? culturasAfetadas,
    String? danos,
    String? controle,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Taxonomia - Reino
    String? dominio,
    String? reino,
    String? subReino,
    // Taxonomia - Clado
    String? clado01,
    String? clado02,
    String? clado03,
    // Taxonomia - Divisão
    String? superDivisao,
    String? divisao,
    String? subDivisao,
    // Taxonomia - Classe
    String? classe,
    String? subClasse,
    // Taxonomia - Família
    String? superFamilia,
    String? subFamilia,
    // Taxonomia - Ordem
    String? superOrdem,
    String? subOrdem,
    String? infraOrdem,
    // Taxonomia - Outros
    String? tribo,
    String? subTribo,
    String? genero,
    String? especie,
  }) {
    return Praga(
      id: id ?? this.id,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      nomesSecundarios: nomesSecundarios ?? this.nomesSecundarios,
      ordem: ordem ?? this.ordem,
      familia: familia ?? this.familia,
      tipoPraga: tipoPraga ?? this.tipoPraga,
      descricao: descricao ?? this.descricao,
      imageUrl: imageUrl ?? this.imageUrl,
      culturasAfetadas: culturasAfetadas ?? this.culturasAfetadas,
      danos: danos ?? this.danos,
      controle: controle ?? this.controle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Taxonomia
      dominio: dominio ?? this.dominio,
      reino: reino ?? this.reino,
      subReino: subReino ?? this.subReino,
      clado01: clado01 ?? this.clado01,
      clado02: clado02 ?? this.clado02,
      clado03: clado03 ?? this.clado03,
      superDivisao: superDivisao ?? this.superDivisao,
      divisao: divisao ?? this.divisao,
      subDivisao: subDivisao ?? this.subDivisao,
      classe: classe ?? this.classe,
      subClasse: subClasse ?? this.subClasse,
      superFamilia: superFamilia ?? this.superFamilia,
      subFamilia: subFamilia ?? this.subFamilia,
      superOrdem: superOrdem ?? this.superOrdem,
      subOrdem: subOrdem ?? this.subOrdem,
      infraOrdem: infraOrdem ?? this.infraOrdem,
      tribo: tribo ?? this.tribo,
      subTribo: subTribo ?? this.subTribo,
      genero: genero ?? this.genero,
      especie: especie ?? this.especie,
    );
  }
}
