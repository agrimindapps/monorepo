import 'package:collection/collection.dart';

/// Entidade de domínio para Diagnóstico (Domain Layer)
/// Representa a relação entre Defensivo, Cultura e Praga com dosagens e aplicações
class DiagnosticoEntity {
  final String id;
  final String idDefensivo;
  final String? nomeDefensivo;
  final String idCultura;
  final String? nomeCultura;
  final String idPraga;
  final String? nomePraga;
  final DosagemEntity dosagem;
  final AplicacaoEntity aplicacao;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DiagnosticoEntity({
    required this.id,
    required this.idDefensivo,
    required this.idCultura,
    required this.idPraga,
    required this.dosagem,
    required this.aplicacao,
    this.nomeDefensivo,
    this.nomeCultura,
    this.nomePraga,
    this.createdAt,
    this.updatedAt,
  });

  /// Helpers de negócio
  bool get isValid => id.isNotEmpty && 
      idDefensivo.isNotEmpty && 
      idCultura.isNotEmpty && 
      idPraga.isNotEmpty;

  bool get hasDefensivoInfo => nomeDefensivo?.isNotEmpty == true;
  bool get hasCulturaInfo => nomeCultura?.isNotEmpty == true;
  bool get hasPragaInfo => nomePraga?.isNotEmpty == true;
  bool get isComplete => hasDefensivoInfo && hasCulturaInfo && hasPragaInfo;

  /// Displayable information
  String get displayDefensivo => nomeDefensivo ?? 'Defensivo ${idDefensivo.substring(0, 8)}';
  String get displayCultura => nomeCultura ?? 'Cultura ${idCultura.substring(0, 8)}';
  String get displayPraga => nomePraga ?? 'Praga ${idPraga.substring(0, 8)}';

  /// Validação de dosagem
  bool get hasDosagemValida => dosagem.isValid;

  /// Validação de aplicação
  bool get hasAplicacaoValida => aplicacao.isValid;

  /// Nível de completude dos dados
  DiagnosticoCompletude get completude {
    int score = 0;
    
    if (hasDefensivoInfo) score++;
    if (hasCulturaInfo) score++;
    if (hasPragaInfo) score++;
    if (hasDosagemValida) score++;
    if (hasAplicacaoValida) score++;

    if (score >= 4) return DiagnosticoCompletude.completo;
    if (score >= 3) return DiagnosticoCompletude.parcial;
    return DiagnosticoCompletude.incompleto;
  }

  /// Implementação de equality manual
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// CopyWith para imutabilidade
  DiagnosticoEntity copyWith({
    String? id,
    String? idDefensivo,
    String? nomeDefensivo,
    String? idCultura,
    String? nomeCultura,
    String? idPraga,
    String? nomePraga,
    DosagemEntity? dosagem,
    AplicacaoEntity? aplicacao,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiagnosticoEntity(
      id: id ?? this.id,
      idDefensivo: idDefensivo ?? this.idDefensivo,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      idCultura: idCultura ?? this.idCultura,
      nomeCultura: nomeCultura ?? this.nomeCultura,
      idPraga: idPraga ?? this.idPraga,
      nomePraga: nomePraga ?? this.nomePraga,
      dosagem: dosagem ?? this.dosagem,
      aplicacao: aplicacao ?? this.aplicacao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DiagnosticoEntity{id: $id, defensivo: $displayDefensivo, cultura: $displayCultura, praga: $displayPraga}';
  }
}

/// Value Object para informações de dosagem
class DosagemEntity {
  final double? dosagemMinima;
  final double dosagemMaxima;
  final String unidadeMedida;

  const DosagemEntity({
    this.dosagemMinima,
    required this.dosagemMaxima,
    required this.unidadeMedida,
  });

  bool get isValid => dosagemMaxima > 0 && unidadeMedida.isNotEmpty;
  
  bool get hasRange => dosagemMinima != null && dosagemMinima! < dosagemMaxima;

  /// Compatibilidade - alias para unidadeMedida
  String get unidade => unidadeMedida;
  
  String get displayDosagem {
    if (hasRange) {
      return '${dosagemMinima!.toStringAsFixed(2)} - ${dosagemMaxima.toStringAsFixed(2)} $unidadeMedida';
    }
    return '${dosagemMaxima.toStringAsFixed(2)} $unidadeMedida';
  }

  double get dosageAverage => hasRange 
      ? (dosagemMinima! + dosagemMaxima) / 2
      : dosagemMaxima;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DosagemEntity &&
          runtimeType == other.runtimeType &&
          dosagemMinima == other.dosagemMinima &&
          dosagemMaxima == other.dosagemMaxima &&
          unidadeMedida == other.unidadeMedida;

  @override
  int get hashCode => Object.hash(dosagemMinima, dosagemMaxima, unidadeMedida);

  @override
  String toString() {
    return 'DosagemEntity{$displayDosagem}';
  }
}

/// Value Object para informações de aplicação
class AplicacaoEntity {
  final AplicacaoTerrestrefEntity? terrestre;
  final AplicacaoAereaEntity? aerea;
  final String? intervaloReaplicacao;
  final String? intervaloReaplicacao2;
  final String? epocaAplicacao;

  const AplicacaoEntity({
    this.terrestre,
    this.aerea,
    this.intervaloReaplicacao,
    this.intervaloReaplicacao2,
    this.epocaAplicacao,
  });

  bool get isValid => terrestre != null || aerea != null;
  
  bool get hasTerrestre => terrestre != null;
  bool get hasAerea => aerea != null;
  bool get hasIntervalo => intervaloReaplicacao?.isNotEmpty == true;
  bool get hasEpoca => epocaAplicacao?.isNotEmpty == true;

  List<TipoAplicacao> get tiposDisponiveis {
    final tipos = <TipoAplicacao>[];
    if (hasTerrestre) tipos.add(TipoAplicacao.terrestre);
    if (hasAerea) tipos.add(TipoAplicacao.aerea);
    return tipos;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AplicacaoEntity &&
          runtimeType == other.runtimeType &&
          terrestre == other.terrestre &&
          aerea == other.aerea;

  @override
  int get hashCode => Object.hash(terrestre, aerea, intervaloReaplicacao);

  @override
  String toString() {
    final tipos = tiposDisponiveis.map((t) => t.displayName).join(', ');
    return 'AplicacaoEntity{tipos: $tipos}';
  }
}

/// Value Object para aplicação terrestre
class AplicacaoTerrestrefEntity {
  final double? volumeMinimo;
  final double? volumeMaximo;
  final String? unidadeMedida;

  const AplicacaoTerrestrefEntity({
    this.volumeMinimo,
    this.volumeMaximo,
    this.unidadeMedida,
  });

  bool get isValid => volumeMaximo != null && volumeMaximo! > 0;
  
  bool get hasRange => volumeMinimo != null && volumeMaximo != null && 
                       volumeMinimo! < volumeMaximo!;
  
  String get displayVolume {
    if (!isValid) return 'Volume não especificado';
    
    final unit = unidadeMedida ?? 'L/ha';
    if (hasRange) {
      return '${volumeMinimo!.toStringAsFixed(1)} - ${volumeMaximo!.toStringAsFixed(1)} $unit';
    }
    return '${volumeMaximo!.toStringAsFixed(1)} $unit';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AplicacaoTerrestrefEntity &&
          volumeMinimo == other.volumeMinimo &&
          volumeMaximo == other.volumeMaximo;

  @override
  int get hashCode => Object.hash(volumeMinimo, volumeMaximo);
}

/// Value Object para aplicação aérea
class AplicacaoAereaEntity {
  final double? volumeMinimo;
  final double? volumeMaximo;
  final String? unidadeMedida;

  const AplicacaoAereaEntity({
    this.volumeMinimo,
    this.volumeMaximo,
    this.unidadeMedida,
  });

  bool get isValid => volumeMaximo != null && volumeMaximo! > 0;
  
  bool get hasRange => volumeMinimo != null && volumeMaximo != null && 
                       volumeMinimo! < volumeMaximo!;
  
  String get displayVolume {
    if (!isValid) return 'Volume não especificado';
    
    final unit = unidadeMedida ?? 'L/ha';
    if (hasRange) {
      return '${volumeMinimo!.toStringAsFixed(1)} - ${volumeMaximo!.toStringAsFixed(1)} $unit';
    }
    return '${volumeMaximo!.toStringAsFixed(1)} $unit';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AplicacaoAereaEntity &&
          volumeMinimo == other.volumeMinimo &&
          volumeMaximo == other.volumeMaximo;

  @override
  int get hashCode => Object.hash(volumeMinimo, volumeMaximo);
}

/// Enum para tipos de aplicação
enum TipoAplicacao {
  terrestre,
  aerea;

  String get displayName {
    switch (this) {
      case TipoAplicacao.terrestre:
        return 'Terrestre';
      case TipoAplicacao.aerea:
        return 'Aérea';
    }
  }

  String get description {
    switch (this) {
      case TipoAplicacao.terrestre:
        return 'Aplicação com pulverizador terrestre';
      case TipoAplicacao.aerea:
        return 'Aplicação via pulverização aérea';
    }
  }
}

/// Enum para nível de completude dos dados
enum DiagnosticoCompletude {
  completo,
  parcial,
  incompleto;

  String get displayName {
    switch (this) {
      case DiagnosticoCompletude.completo:
        return 'Completo';
      case DiagnosticoCompletude.parcial:
        return 'Parcial';
      case DiagnosticoCompletude.incompleto:
        return 'Incompleto';
    }
  }

  String get description {
    switch (this) {
      case DiagnosticoCompletude.completo:
        return 'Todos os dados estão disponíveis';
      case DiagnosticoCompletude.parcial:
        return 'Alguns dados podem estar faltando';
      case DiagnosticoCompletude.incompleto:
        return 'Dados insuficientes para recomendação completa';
    }
  }

  int get colorValue {
    switch (this) {
      case DiagnosticoCompletude.completo:
        return 0xFF4CAF50; // Verde
      case DiagnosticoCompletude.parcial:
        return 0xFFFF9800; // Laranja
      case DiagnosticoCompletude.incompleto:
        return 0xFFF44336; // Vermelho
    }
  }
}

/// Value Object para estatísticas de diagnósticos
class DiagnosticosStats {
  final int total;
  final int completos;
  final int parciais;
  final int incompletos;
  final Map<String, int> porDefensivo;
  final Map<String, int> porCultura;
  final Map<String, int> porPraga;
  final List<DiagnosticoPopular> topDiagnosticos;

  const DiagnosticosStats({
    required this.total,
    required this.completos,
    required this.parciais,
    required this.incompletos,
    required this.porDefensivo,
    required this.porCultura,
    required this.porPraga,
    required this.topDiagnosticos,
  });

  double get percentualCompletos => total > 0 ? (completos / total) * 100 : 0;
  double get percentualParciais => total > 0 ? (parciais / total) * 100 : 0;
  double get percentualIncompletos => total > 0 ? (incompletos / total) * 100 : 0;

  String get defensivoMaisComum {
    if (porDefensivo.isEmpty) return '';
    
    final sorted = porDefensivo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  String get culturaMaisComum {
    if (porCultura.isEmpty) return '';
    
    final sorted = porCultura.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticosStats &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          completos == other.completos;

  @override
  int get hashCode => Object.hash(total, completos, parciais);

  @override
  String toString() {
    return 'DiagnosticosStats{total: $total, completos: $completos, qualidade: ${percentualCompletos.toStringAsFixed(1)}%}';
  }
}

/// Value Object para diagnóstico popular
class DiagnosticoPopular {
  final String defensivo;
  final String cultura;
  final String praga;
  final int count;

  const DiagnosticoPopular({
    required this.defensivo,
    required this.cultura,
    required this.praga,
    required this.count,
  });

  String get displayName => '$defensivo para $praga em $cultura';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticoPopular &&
          runtimeType == other.runtimeType &&
          defensivo == other.defensivo &&
          cultura == other.cultura &&
          praga == other.praga;

  @override
  int get hashCode => Object.hash(defensivo, cultura, praga);

  @override
  String toString() => 'DiagnosticoPopular{$displayName, count: $count}';
}

/// Value Object para filtros de busca de diagnósticos
class DiagnosticoSearchFilters {
  final String? idDefensivo;
  final String? idCultura;
  final String? idPraga;
  final String? nomeDefensivo;
  final String? nomeCultura;
  final String? nomePraga;
  final TipoAplicacao? tipoAplicacao;
  final DiagnosticoCompletude? completude;
  final double? dosagemMinima;
  final double? dosagemMaxima;
  final int? limit;

  const DiagnosticoSearchFilters({
    this.idDefensivo,
    this.idCultura,
    this.idPraga,
    this.nomeDefensivo,
    this.nomeCultura,
    this.nomePraga,
    this.tipoAplicacao,
    this.completude,
    this.dosagemMinima,
    this.dosagemMaxima,
    this.limit,
  });

  /// Compatibilidade com API antiga
  String? get defensivo => nomeDefensivo ?? idDefensivo;
  String? get cultura => nomeCultura ?? idCultura;
  String? get praga => nomePraga ?? idPraga;

  bool get hasFilters =>
    idDefensivo != null ||
    idCultura != null ||
    idPraga != null ||
    nomeDefensivo != null ||
    nomeCultura != null ||
    nomePraga != null ||
    tipoAplicacao != null ||
    completude != null ||
    dosagemMinima != null ||
    dosagemMaxima != null ||
    limit != null;

  DiagnosticoSearchFilters copyWith({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
    String? nomeDefensivo,
    String? nomeCultura,
    String? nomePraga,
    TipoAplicacao? tipoAplicacao,
    DiagnosticoCompletude? completude,
    double? dosagemMinima,
    double? dosagemMaxima,
    int? limit,
  }) {
    return DiagnosticoSearchFilters(
      idDefensivo: idDefensivo ?? this.idDefensivo,
      idCultura: idCultura ?? this.idCultura,
      idPraga: idPraga ?? this.idPraga,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      nomeCultura: nomeCultura ?? this.nomeCultura,
      nomePraga: nomePraga ?? this.nomePraga,
      tipoAplicacao: tipoAplicacao ?? this.tipoAplicacao,
      completude: completude ?? this.completude,
      dosagemMinima: dosagemMinima ?? this.dosagemMinima,
      dosagemMaxima: dosagemMaxima ?? this.dosagemMaxima,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticoSearchFilters &&
          runtimeType == other.runtimeType &&
          idDefensivo == other.idDefensivo &&
          idCultura == other.idCultura &&
          idPraga == other.idPraga &&
          nomeDefensivo == other.nomeDefensivo &&
          nomeCultura == other.nomeCultura &&
          nomePraga == other.nomePraga;

  @override
  int get hashCode => Object.hash(idDefensivo, idCultura, idPraga, nomeDefensivo, nomeCultura, nomePraga);
}

/// Value Object para dados dos filtros de diagnósticos
class DiagnosticoFiltersData {
  final List<String> defensivos;
  final List<String> culturas;
  final List<String> pragas;
  final List<String> unidadesMedida;
  final List<TipoAplicacao> tiposAplicacao;

  const DiagnosticoFiltersData({
    required this.defensivos,
    required this.culturas,
    required this.pragas,
    required this.unidadesMedida,
    required this.tiposAplicacao,
  });

  bool get isEmpty => 
      defensivos.isEmpty && 
      culturas.isEmpty && 
      pragas.isEmpty &&
      unidadesMedida.isEmpty &&
      tiposAplicacao.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticoFiltersData &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(defensivos, other.defensivos) &&
          const ListEquality().equals(culturas, other.culturas) &&
          const ListEquality().equals(pragas, other.pragas) &&
          const ListEquality().equals(unidadesMedida, other.unidadesMedida) &&
          const ListEquality().equals(tiposAplicacao, other.tiposAplicacao);

  @override
  int get hashCode => Object.hash(
      const ListEquality().hash(defensivos),
      const ListEquality().hash(culturas),
      const ListEquality().hash(pragas),
      const ListEquality().hash(unidadesMedida),
      const ListEquality().hash(tiposAplicacao));
}