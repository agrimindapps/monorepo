/// Entidade de domínio para Defensivo (Domain Layer)
/// Princípios: Entity + Value Objects do DDD
class DefensivoEntity {
  final String id;
  final String nomeComum;
  final String nomeTecnico;
  final String? classeAgronomica;
  final String? fabricante;
  final String? classAmbiental;
  final String? formulacao;
  final String? modoAcao;
  final String? ingredienteAtivo;
  final String? quantProduto;
  final bool status;
  final int comercializado;
  final bool elegivel;
  final String? corrosivo;
  final String? inflamavel;
  final String? toxico;
  final String? mapa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DefensivoEntity({
    required this.id,
    required this.nomeComum,
    required this.nomeTecnico,
    required this.status,
    required this.comercializado,
    required this.elegivel,
    this.classeAgronomica,
    this.fabricante,
    this.classAmbiental,
    this.formulacao,
    this.modoAcao,
    this.ingredienteAtivo,
    this.quantProduto,
    this.corrosivo,
    this.inflamavel,
    this.toxico,
    this.mapa,
    this.createdAt,
    this.updatedAt,
  });

  /// Helpers de negócio
  bool get isActive => status && comercializado == 1;
  bool get isElegible => elegivel;
  bool get hasIngredienteAtivo => ingredienteAtivo?.isNotEmpty == true;
  bool get hasFabricante => fabricante?.isNotEmpty == true;
  bool get hasClasseAgronomica => classeAgronomica?.isNotEmpty == true;

  /// Categorias de segurança
  bool get isCorrosivo => corrosivo?.toLowerCase() == 'sim';
  bool get isInflamavel => inflamavel?.toLowerCase() == 'sim';
  bool get isToxico => toxico?.toLowerCase() == 'sim';

  /// Nível de perigo baseado nas características
  DefensivoSafetyLevel get safetyLevel {
    if (isToxico && isCorrosivo && isInflamavel) {
      return DefensivoSafetyLevel.veryHigh;
    }
    if (isToxico || (isCorrosivo && isInflamavel)) {
      return DefensivoSafetyLevel.high;
    }
    if (isCorrosivo || isInflamavel) {
      return DefensivoSafetyLevel.medium;
    }
    return DefensivoSafetyLevel.low;
  }

  /// Implementação de equality manual
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefensivoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// CopyWith para imutabilidade
  DefensivoEntity copyWith({
    String? id,
    String? nomeComum,
    String? nomeTecnico,
    String? classeAgronomica,
    String? fabricante,
    String? classAmbiental,
    String? formulacao,
    String? modoAcao,
    String? ingredienteAtivo,
    String? quantProduto,
    bool? status,
    int? comercializado,
    bool? elegivel,
    String? corrosivo,
    String? inflamavel,
    String? toxico,
    String? mapa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefensivoEntity(
      id: id ?? this.id,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeTecnico: nomeTecnico ?? this.nomeTecnico,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      fabricante: fabricante ?? this.fabricante,
      classAmbiental: classAmbiental ?? this.classAmbiental,
      formulacao: formulacao ?? this.formulacao,
      modoAcao: modoAcao ?? this.modoAcao,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      quantProduto: quantProduto ?? this.quantProduto,
      status: status ?? this.status,
      comercializado: comercializado ?? this.comercializado,
      elegivel: elegivel ?? this.elegivel,
      corrosivo: corrosivo ?? this.corrosivo,
      inflamavel: inflamavel ?? this.inflamavel,
      toxico: toxico ?? this.toxico,
      mapa: mapa ?? this.mapa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DefensivoEntity{id: $id, nomeComum: $nomeComum, fabricante: $fabricante}';
  }
}

/// Value Object para nível de segurança
enum DefensivoSafetyLevel {
  low,
  medium,
  high,
  veryHigh;

  String get displayName {
    switch (this) {
      case DefensivoSafetyLevel.low:
        return 'Baixo';
      case DefensivoSafetyLevel.medium:
        return 'Médio';
      case DefensivoSafetyLevel.high:
        return 'Alto';
      case DefensivoSafetyLevel.veryHigh:
        return 'Muito Alto';
    }
  }

  String get description {
    switch (this) {
      case DefensivoSafetyLevel.low:
        return 'Baixo risco de segurança';
      case DefensivoSafetyLevel.medium:
        return 'Risco moderado - atenção aos EPIs';
      case DefensivoSafetyLevel.high:
        return 'Alto risco - EPIs obrigatórios';
      case DefensivoSafetyLevel.veryHigh:
        return 'Risco muito alto - máxima proteção';
    }
  }
}

/// Value Object para estatísticas de defensivos
class DefensivosStats {
  final int total;
  final int ativos;
  final int elegiveis;
  final int inseticides;
  final int herbicides;
  final int fungicides;
  final int acaricides;
  final Map<String, int> byFabricante;
  final Map<String, int> byClasseAgronomica;

  const DefensivosStats({
    required this.total,
    required this.ativos,
    required this.elegiveis,
    required this.inseticides,
    required this.herbicides,
    required this.fungicides,
    required this.acaricides,
    required this.byFabricante,
    required this.byClasseAgronomica,
  });

  double get percentualAtivos => total > 0 ? (ativos / total) * 100 : 0;
  double get percentualElegiveis => total > 0 ? (elegiveis / total) * 100 : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefensivosStats &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          ativos == other.ativos;

  @override
  int get hashCode => Object.hash(total, ativos, elegiveis);

  @override
  String toString() {
    return 'DefensivosStats{total: $total, ativos: $ativos, elegiveis: $elegiveis}';
  }
}

/// Value Object para filtros de busca
class DefensivoSearchFilters {
  final String? nomeComum;
  final String? ingredienteAtivo;
  final String? fabricante;
  final String? classeAgronomica;
  final bool? status;
  final int? comercializado;
  final bool? elegivel;
  final DefensivoSafetyLevel? safetyLevel;

  const DefensivoSearchFilters({
    this.nomeComum,
    this.ingredienteAtivo,
    this.fabricante,
    this.classeAgronomica,
    this.status,
    this.comercializado,
    this.elegivel,
    this.safetyLevel,
  });

  bool get hasFilters => 
    nomeComum != null ||
    ingredienteAtivo != null ||
    fabricante != null ||
    classeAgronomica != null ||
    status != null ||
    comercializado != null ||
    elegivel != null ||
    safetyLevel != null;

  DefensivoSearchFilters copyWith({
    String? nomeComum,
    String? ingredienteAtivo,
    String? fabricante,
    String? classeAgronomica,
    bool? status,
    int? comercializado,
    bool? elegivel,
    DefensivoSafetyLevel? safetyLevel,
  }) {
    return DefensivoSearchFilters(
      nomeComum: nomeComum ?? this.nomeComum,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      fabricante: fabricante ?? this.fabricante,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      status: status ?? this.status,
      comercializado: comercializado ?? this.comercializado,
      elegivel: elegivel ?? this.elegivel,
      safetyLevel: safetyLevel ?? this.safetyLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefensivoSearchFilters &&
          runtimeType == other.runtimeType &&
          nomeComum == other.nomeComum &&
          ingredienteAtivo == other.ingredienteAtivo;

  @override
  int get hashCode => Object.hash(nomeComum, ingredienteAtivo, fabricante);
}