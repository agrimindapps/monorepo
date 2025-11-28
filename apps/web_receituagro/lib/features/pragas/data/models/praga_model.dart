import '../../domain/entities/praga.dart';
import '../../domain/entities/tipo_praga.dart';

/// Praga model - Data layer
class PragaModel extends Praga {
  const PragaModel({
    required super.id,
    required super.nomeComum,
    required super.nomeCientifico,
    super.nomesSecundarios,
    required super.ordem,
    required super.familia,
    super.tipoPraga,
    super.descricao,
    super.imageUrl,
    super.culturasAfetadas,
    super.danos,
    super.controle,
    required super.createdAt,
    required super.updatedAt,
    // Taxonomia - Reino
    super.dominio,
    super.reino,
    super.subReino,
    // Taxonomia - Clado
    super.clado01,
    super.clado02,
    super.clado03,
    // Taxonomia - Divisão
    super.superDivisao,
    super.divisao,
    super.subDivisao,
    // Taxonomia - Classe
    super.classe,
    super.subClasse,
    // Taxonomia - Família
    super.superFamilia,
    super.subFamilia,
    // Taxonomia - Ordem
    super.superOrdem,
    super.subOrdem,
    super.infraOrdem,
    // Taxonomia - Outros
    super.tribo,
    super.subTribo,
    super.genero,
    super.especie,
  });

  /// Create model from JSON
  factory PragaModel.fromJson(Map<String, dynamic> json) {
    return PragaModel(
      id: json['id'] as String,
      nomeComum: json['nome_comum'] as String,
      nomeCientifico: json['nome_cientifico'] as String,
      nomesSecundarios: json['nomes_secundarios'] as String?,
      ordem: json['ordem'] as String,
      familia: json['familia'] as String,
      tipoPraga: TipoPraga.fromCodigo(json['tipo_praga'] as String?),
      descricao: json['descricao'] as String?,
      imageUrl: json['image_url'] as String?,
      culturasAfetadas: json['culturas_afetadas'] != null
          ? List<String>.from(json['culturas_afetadas'] as List)
          : null,
      danos: json['danos'] as String?,
      controle: json['controle'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Taxonomia - Reino
      dominio: json['dominio'] as String?,
      reino: json['reino'] as String?,
      subReino: json['sub_reino'] as String?,
      // Taxonomia - Clado
      clado01: json['clado_01'] as String?,
      clado02: json['clado_02'] as String?,
      clado03: json['clado_03'] as String?,
      // Taxonomia - Divisão
      superDivisao: json['super_divisao'] as String?,
      divisao: json['divisao'] as String?,
      subDivisao: json['sub_divisao'] as String?,
      // Taxonomia - Classe
      classe: json['classe'] as String?,
      subClasse: json['sub_classe'] as String?,
      // Taxonomia - Família
      superFamilia: json['super_familia'] as String?,
      subFamilia: json['sub_familia'] as String?,
      // Taxonomia - Ordem
      superOrdem: json['super_ordem'] as String?,
      subOrdem: json['sub_ordem'] as String?,
      infraOrdem: json['infra_ordem'] as String?,
      // Taxonomia - Outros
      tribo: json['tribo'] as String?,
      subTribo: json['sub_tribo'] as String?,
      genero: json['genero'] as String?,
      especie: json['especie'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_comum': nomeComum,
      'nome_cientifico': nomeCientifico,
      'nomes_secundarios': nomesSecundarios,
      'ordem': ordem,
      'familia': familia,
      'tipo_praga': tipoPraga?.codigo,
      'descricao': descricao,
      'image_url': imageUrl,
      'culturas_afetadas': culturasAfetadas,
      'danos': danos,
      'controle': controle,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Taxonomia - Reino
      'dominio': dominio,
      'reino': reino,
      'sub_reino': subReino,
      // Taxonomia - Clado
      'clado_01': clado01,
      'clado_02': clado02,
      'clado_03': clado03,
      // Taxonomia - Divisão
      'super_divisao': superDivisao,
      'divisao': divisao,
      'sub_divisao': subDivisao,
      // Taxonomia - Classe
      'classe': classe,
      'sub_classe': subClasse,
      // Taxonomia - Família
      'super_familia': superFamilia,
      'sub_familia': subFamilia,
      // Taxonomia - Ordem
      'super_ordem': superOrdem,
      'sub_ordem': subOrdem,
      'infra_ordem': infraOrdem,
      // Taxonomia - Outros
      'tribo': tribo,
      'sub_tribo': subTribo,
      'genero': genero,
      'especie': especie,
    };
  }

  /// Create model from entity
  factory PragaModel.fromEntity(Praga praga) {
    return PragaModel(
      id: praga.id,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      nomesSecundarios: praga.nomesSecundarios,
      ordem: praga.ordem,
      familia: praga.familia,
      tipoPraga: praga.tipoPraga,
      descricao: praga.descricao,
      imageUrl: praga.imageUrl,
      culturasAfetadas: praga.culturasAfetadas,
      danos: praga.danos,
      controle: praga.controle,
      createdAt: praga.createdAt,
      updatedAt: praga.updatedAt,
      // Taxonomia - Reino
      dominio: praga.dominio,
      reino: praga.reino,
      subReino: praga.subReino,
      // Taxonomia - Clado
      clado01: praga.clado01,
      clado02: praga.clado02,
      clado03: praga.clado03,
      // Taxonomia - Divisão
      superDivisao: praga.superDivisao,
      divisao: praga.divisao,
      subDivisao: praga.subDivisao,
      // Taxonomia - Classe
      classe: praga.classe,
      subClasse: praga.subClasse,
      // Taxonomia - Família
      superFamilia: praga.superFamilia,
      subFamilia: praga.subFamilia,
      // Taxonomia - Ordem
      superOrdem: praga.superOrdem,
      subOrdem: praga.subOrdem,
      infraOrdem: praga.infraOrdem,
      // Taxonomia - Outros
      tribo: praga.tribo,
      subTribo: praga.subTribo,
      genero: praga.genero,
      especie: praga.especie,
    );
  }
}
