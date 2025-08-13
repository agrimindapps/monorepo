/// Modelo para representar um defensivo agrícola completo
///
/// Este modelo encapsula todos os dados relacionados a um defensivo,
/// incluindo suas características, informações e diagnósticos associados.
class DefensivoModel {
  /// Identificador único do defensivo
  final String idReg;

  /// Nome comum do defensivo
  final String nomeComum;

  /// Ingrediente ativo do defensivo
  final String ingredienteAtivo;

  /// Quantidade do produto
  final String quantProduto;

  /// Nome técnico do defensivo
  final String nomeTecnico;

  /// Fabricante do defensivo
  final String fabricante;

  /// Classificação toxicológica
  final String classToxicologica;

  /// Classificação ambiental
  final String classAmbiental;

  /// Modo de ação do defensivo
  final String modoAcao;

  /// Classe agronômica
  final String classeAgronomica;

  /// Informação sobre inflamabilidade
  final String inflamavel;

  /// Informação sobre corrosividade
  final String corrosivo;

  /// Formulação do defensivo
  final String formulacao;

  /// Concentração do defensivo
  final String concentracao;

  /// Grupo químico do defensivo
  final String grupoQuimico;

  /// Registro no MAPA (Ministério da Agricultura, Pecuária e Abastecimento)
  final String mapa;

  /// Data de atualização do registro
  final String updatedAt;

  /// Construtor principal
  DefensivoModel({
    required this.idReg,
    required this.nomeComum,
    required this.ingredienteAtivo,
    this.quantProduto = '',
    this.nomeTecnico = '',
    this.fabricante = '',
    this.classToxicologica = '',
    this.classAmbiental = '',
    this.modoAcao = '',
    this.classeAgronomica = '',
    this.inflamavel = '',
    this.corrosivo = '',
    this.formulacao = '',
    this.concentracao = '',
    this.grupoQuimico = '',
    this.mapa = '',
    this.updatedAt = '',
  });

  /// Cria um DefensivoModel a partir de um Map
  factory DefensivoModel.fromMap(Map<String, dynamic> map) {
    return DefensivoModel(
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString() ?? '',
      ingredienteAtivo: map['ingredienteAtivo']?.toString() ?? '',
      quantProduto: map['quantProduto']?.toString() ?? '',
      nomeTecnico: map['nomeTecnico']?.toString() ?? '',
      fabricante: map['fabricante']?.toString() ?? '',
      classToxicologica: map['classToxicologica']?.toString() ?? '',
      classAmbiental: map['classAmbiental']?.toString() ?? '',
      modoAcao: map['modoAcao']?.toString() ?? '',
      classeAgronomica: map['classeAgronomica']?.toString() ?? '',
      inflamavel: map['inflamavel']?.toString() ?? '',
      corrosivo: map['corrosivo']?.toString() ?? '',
      formulacao: map['formulacao']?.toString() ?? '',
      concentracao: map['concentracao']?.toString() ?? '',
      grupoQuimico: map['grupoQuimico']?.toString() ?? '',
      mapa: map['mapa']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
    );
  }

  /// Converte o modelo para um Map
  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'ingredienteAtivo': ingredienteAtivo,
      'quantProduto': quantProduto,
      'nomeTecnico': nomeTecnico,
      'fabricante': fabricante,
      'classToxicologica': classToxicologica,
      'classAmbiental': classAmbiental,
      'modoAcao': modoAcao,
      'classeAgronomica': classeAgronomica,
      'inflamavel': inflamavel,
      'corrosivo': corrosivo,
      'formulacao': formulacao,
      'concentracao': concentracao,
      'grupoQuimico': grupoQuimico,
      'mapa': mapa,
      'updatedAt': updatedAt,
    };
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  DefensivoModel copyWith({
    String? idReg,
    String? nomeComum,
    String? ingredienteAtivo,
    String? quantProduto,
    String? nomeTecnico,
    String? fabricante,
    String? classToxicologica,
    String? classAmbiental,
    String? modoAcao,
    String? classeAgronomica,
    String? inflamavel,
    String? corrosivo,
    String? formulacao,
    String? concentracao,
    String? grupoQuimico,
    String? mapa,
    String? updatedAt,
  }) {
    return DefensivoModel(
      idReg: idReg ?? this.idReg,
      nomeComum: nomeComum ?? this.nomeComum,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      quantProduto: quantProduto ?? this.quantProduto,
      nomeTecnico: nomeTecnico ?? this.nomeTecnico,
      fabricante: fabricante ?? this.fabricante,
      classToxicologica: classToxicologica ?? this.classToxicologica,
      classAmbiental: classAmbiental ?? this.classAmbiental,
      modoAcao: modoAcao ?? this.modoAcao,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      inflamavel: inflamavel ?? this.inflamavel,
      corrosivo: corrosivo ?? this.corrosivo,
      formulacao: formulacao ?? this.formulacao,
      concentracao: concentracao ?? this.concentracao,
      grupoQuimico: grupoQuimico ?? this.grupoQuimico,
      mapa: mapa ?? this.mapa,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DefensivoModel(idReg: $idReg, nomeComum: $nomeComum, ingredienteAtivo: $ingredienteAtivo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoModel &&
        other.idReg == idReg &&
        other.nomeComum == nomeComum &&
        other.ingredienteAtivo == ingredienteAtivo;
  }

  @override
  int get hashCode =>
      idReg.hashCode ^ nomeComum.hashCode ^ ingredienteAtivo.hashCode;
}

/// Modelo para representar informações adicionais do defensivo
class DefensivoInfoModel {
  /// Identificador único da informação
  final String id;

  /// Identificador do defensivo associado
  final String fkIdDefensivo;

  /// Informações sobre tecnologia de aplicação
  final String tecnologia;

  /// Informações sobre embalagens
  final String embalagens;

  /// Informações sobre manejo integrado
  final String manejoIntegrado;

  /// Informações sobre manejo de resistência
  final String manejoResistencia;

  /// Informações sobre precauções humanas
  final String pHumanas;

  /// Informações sobre precauções ambientais
  final String pAmbientais;

  /// Informações sobre compatibilidade
  final String compatibilidade;

  /// Construtor principal
  DefensivoInfoModel({
    required this.id,
    required this.fkIdDefensivo,
    this.tecnologia = '',
    this.embalagens = '',
    this.manejoIntegrado = '',
    this.manejoResistencia = '',
    this.pHumanas = '',
    this.pAmbientais = '',
    this.compatibilidade = '',
  });

  /// Cria um DefensivoInfoModel a partir de um Map
  factory DefensivoInfoModel.fromMap(Map<String, dynamic> map) {
    return DefensivoInfoModel(
      id: map['id']?.toString() ?? '',
      fkIdDefensivo: map['fkIdDefensivo']?.toString() ?? '',
      tecnologia: map['tecnologia']?.toString() ?? '',
      embalagens: map['embalagens']?.toString() ?? '',
      manejoIntegrado: map['manejoIntegrado']?.toString() ?? '',
      manejoResistencia: map['manejoResistencia']?.toString() ?? '',
      pHumanas: map['pHumanas']?.toString() ?? '',
      pAmbientais: map['pAmbientais']?.toString() ?? '',
      compatibilidade: map['compatibilidade']?.toString() ?? '',
    );
  }

  /// Converte o modelo para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fkIdDefensivo': fkIdDefensivo,
      'tecnologia': tecnologia,
      'embalagens': embalagens,
      'manejoIntegrado': manejoIntegrado,
      'manejoResistencia': manejoResistencia,
      'pHumanas': pHumanas,
      'pAmbientais': pAmbientais,
      'compatibilidade': compatibilidade,
    };
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  DefensivoInfoModel copyWith({
    String? id,
    String? fkIdDefensivo,
    String? tecnologia,
    String? embalagens,
    String? manejoIntegrado,
    String? manejoResistencia,
    String? pHumanas,
    String? pAmbientais,
    String? compatibilidade,
  }) {
    return DefensivoInfoModel(
      id: id ?? this.id,
      fkIdDefensivo: fkIdDefensivo ?? this.fkIdDefensivo,
      tecnologia: tecnologia ?? this.tecnologia,
      embalagens: embalagens ?? this.embalagens,
      manejoIntegrado: manejoIntegrado ?? this.manejoIntegrado,
      manejoResistencia: manejoResistencia ?? this.manejoResistencia,
      pHumanas: pHumanas ?? this.pHumanas,
      pAmbientais: pAmbientais ?? this.pAmbientais,
      compatibilidade: compatibilidade ?? this.compatibilidade,
    );
  }

  @override
  String toString() {
    return 'DefensivoInfoModel(id: $id, fkIdDefensivo: $fkIdDefensivo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoInfoModel &&
        other.id == id &&
        other.fkIdDefensivo == fkIdDefensivo;
  }

  @override
  int get hashCode => id.hashCode ^ fkIdDefensivo.hashCode;
}

/// Modelo para representar um diagnóstico de defensivo
class DiagnosticoModel {
  /// Identificador único do diagnóstico
  final String idReg;

  /// Identificador do defensivo associado
  final String fkIdDefensivo;

  /// Nome do defensivo
  final String nomeDefensivo;

  /// Ingrediente ativo
  final String ingredienteAtivo;

  /// Identificador da praga associada
  final String fkIdPraga;

  /// Nome comum da praga
  final String nomePraga;

  /// Nome científico da praga
  final String nomeCientifico;

  /// Identificador da cultura associada
  final String fkIdCultura;

  /// Nome da cultura
  final String cultura;

  /// Informação de dosagem
  final String dosagem;

  /// Informação sobre vazão terrestre
  final String vazaoTerrestre;

  /// Informação sobre vazão aérea
  final String vazaoAerea;

  /// Intervalo de aplicação
  final String intervaloAplicacao;

  /// Intervalo de segurança
  final String intervaloSeguranca;

  /// Construtor principal
  DiagnosticoModel({
    required this.idReg,
    required this.fkIdDefensivo,
    required this.fkIdPraga,
    required this.fkIdCultura,
    this.nomeDefensivo = '',
    this.ingredienteAtivo = '',
    this.nomePraga = '',
    this.nomeCientifico = '',
    this.cultura = '',
    this.dosagem = '',
    this.vazaoTerrestre = '',
    this.vazaoAerea = '',
    this.intervaloAplicacao = '',
    this.intervaloSeguranca = '',
  });

  /// Cria um DiagnosticoModel a partir de um Map
  factory DiagnosticoModel.fromMap(Map<String, dynamic> map) {
    return DiagnosticoModel(
      idReg: map['idReg']?.toString() ?? '',
      fkIdDefensivo: map['fkIdDefensivo']?.toString() ?? '',
      fkIdPraga: map['fkIdPraga']?.toString() ?? '',
      fkIdCultura: map['fkIdCultura']?.toString() ?? '',
      nomeDefensivo: map['nomeDefensivo']?.toString() ?? '',
      ingredienteAtivo: map['ingredienteAtivo']?.toString() ?? '',
      nomePraga: map['nomePraga']?.toString() ?? '',
      nomeCientifico: map['nomeCientifico']?.toString() ?? '',
      cultura: map['cultura']?.toString() ?? '',
      dosagem: map['dosagem']?.toString() ?? '',
      vazaoTerrestre: map['vazaoTerrestre']?.toString() ?? '',
      vazaoAerea: map['vazaoAerea']?.toString() ?? '',
      intervaloAplicacao: map['intervaloAplicacao']?.toString() ?? '',
      intervaloSeguranca: map['intervaloSeguranca']?.toString() ?? '',
    );
  }

  /// Converte o modelo para um Map
  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'fkIdDefensivo': fkIdDefensivo,
      'fkIdPraga': fkIdPraga,
      'fkIdCultura': fkIdCultura,
      'nomeDefensivo': nomeDefensivo,
      'ingredienteAtivo': ingredienteAtivo,
      'nomePraga': nomePraga,
      'nomeCientifico': nomeCientifico,
      'cultura': cultura,
      'dosagem': dosagem,
      'vazaoTerrestre': vazaoTerrestre,
      'vazaoAerea': vazaoAerea,
      'intervaloAplicacao': intervaloAplicacao,
      'intervaloSeguranca': intervaloSeguranca,
    };
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  DiagnosticoModel copyWith({
    String? idReg,
    String? fkIdDefensivo,
    String? fkIdPraga,
    String? fkIdCultura,
    String? nomeDefensivo,
    String? ingredienteAtivo,
    String? nomePraga,
    String? nomeCientifico,
    String? cultura,
    String? dosagem,
    String? vazaoTerrestre,
    String? vazaoAerea,
    String? intervaloAplicacao,
    String? intervaloSeguranca,
  }) {
    return DiagnosticoModel(
      idReg: idReg ?? this.idReg,
      fkIdDefensivo: fkIdDefensivo ?? this.fkIdDefensivo,
      fkIdPraga: fkIdPraga ?? this.fkIdPraga,
      fkIdCultura: fkIdCultura ?? this.fkIdCultura,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      nomePraga: nomePraga ?? this.nomePraga,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      cultura: cultura ?? this.cultura,
      dosagem: dosagem ?? this.dosagem,
      vazaoTerrestre: vazaoTerrestre ?? this.vazaoTerrestre,
      vazaoAerea: vazaoAerea ?? this.vazaoAerea,
      intervaloAplicacao: intervaloAplicacao ?? this.intervaloAplicacao,
      intervaloSeguranca: intervaloSeguranca ?? this.intervaloSeguranca,
    );
  }

  @override
  String toString() {
    return 'DiagnosticoModel(idReg: $idReg, cultura: $cultura, nomePraga: $nomePraga)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticoModel && other.idReg == idReg;
  }

  @override
  int get hashCode => idReg.hashCode;
}
