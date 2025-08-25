import 'package:collection/collection.dart';

/// Entidade de domínio para Cultura (Domain Layer)
/// Princípios: Entity + Value Objects do DDD
class CulturaEntity {
  final String id;
  final String nome;
  final String? familia;
  final String? categoria;
  final String? descricao;
  final bool isAtiva;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CulturaEntity({
    required this.id,
    required this.nome,
    required this.isAtiva,
    this.familia,
    this.categoria,
    this.descricao,
    this.createdAt,
    this.updatedAt,
  });

  /// Helpers de negócio
  bool get isValid => id.isNotEmpty && nome.isNotEmpty;
  String get displayName => nome;
  bool get hasDescription => descricao?.isNotEmpty == true;
  bool get hasFamilia => familia?.isNotEmpty == true;
  bool get hasCategoria => categoria?.isNotEmpty == true;

  /// Classificação da cultura por tipo (baseada no nome)
  CulturaTipo get tipo {
    final nomeClean = nome.toLowerCase().trim();
    
    // Cereais
    if (_isCereal(nomeClean)) return CulturaTipo.cereal;
    
    // Leguminosas
    if (_isLeguminosa(nomeClean)) return CulturaTipo.leguminosa;
    
    // Oleaginosas
    if (_isOleaginosa(nomeClean)) return CulturaTipo.oleaginosa;
    
    // Frutíferas
    if (_isFrutifera(nomeClean)) return CulturaTipo.frutifera;
    
    // Hortaliças
    if (_isHortalica(nomeClean)) return CulturaTipo.hortalica;
    
    // Forrageiras
    if (_isForrageira(nomeClean)) return CulturaTipo.forrageira;
    
    return CulturaTipo.outros;
  }

  /// Verifica se é cereal
  bool _isCereal(String nome) {
    final cereais = ['milho', 'trigo', 'arroz', 'sorgo', 'aveia', 'centeio', 'cevada'];
    return cereais.any((cereal) => nome.contains(cereal));
  }

  /// Verifica se é leguminosa
  bool _isLeguminosa(String nome) {
    final leguminosas = ['soja', 'feijão', 'amendoim', 'grão-de-bico', 'lentilha', 'ervilha'];
    return leguminosas.any((leguminosa) => nome.contains(leguminosa));
  }

  /// Verifica se é oleaginosa
  bool _isOleaginosa(String nome) {
    final oleaginosas = ['soja', 'girassol', 'canola', 'amendoim', 'mamona', 'linhaça'];
    return oleaginosas.any((oleaginosa) => nome.contains(oleaginosa));
  }

  /// Verifica se é frutífera
  bool _isFrutifera(String nome) {
    final frutiferas = ['laranja', 'limão', 'maçã', 'banana', 'uva', 'manga', 'abacaxi', 'coco', 'café'];
    return frutiferas.any((frutifera) => nome.contains(frutifera));
  }

  /// Verifica se é hortaliça
  bool _isHortalica(String nome) {
    final hortalicas = ['tomate', 'batata', 'cebola', 'alho', 'cenoura', 'beterraba', 'alface', 'couve'];
    return hortalicas.any((hortalica) => nome.contains(hortalica));
  }

  /// Verifica se é forrageira
  bool _isForrageira(String nome) {
    final forrageiras = ['capim', 'brachiaria', 'mombaça', 'tanzânia', 'colonião', 'azevém'];
    return forrageiras.any((forrageira) => nome.contains(forrageira));
  }

  /// Implementação de equality manual
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CulturaEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// CopyWith para imutabilidade
  CulturaEntity copyWith({
    String? id,
    String? nome,
    String? familia,
    String? categoria,
    String? descricao,
    bool? isAtiva,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CulturaEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      familia: familia ?? this.familia,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      isAtiva: isAtiva ?? this.isAtiva,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CulturaEntity{id: $id, nome: $nome, tipo: $tipo}';
  }
}

/// Value Object para tipo de cultura
enum CulturaTipo {
  cereal,
  leguminosa,
  oleaginosa,
  frutifera,
  hortalica,
  forrageira,
  outros;

  String get displayName {
    switch (this) {
      case CulturaTipo.cereal:
        return 'Cereal';
      case CulturaTipo.leguminosa:
        return 'Leguminosa';
      case CulturaTipo.oleaginosa:
        return 'Oleaginosa';
      case CulturaTipo.frutifera:
        return 'Frutífera';
      case CulturaTipo.hortalica:
        return 'Hortaliça';
      case CulturaTipo.forrageira:
        return 'Forrageira';
      case CulturaTipo.outros:
        return 'Outras';
    }
  }

  String get description {
    switch (this) {
      case CulturaTipo.cereal:
        return 'Culturas de grãos básicos';
      case CulturaTipo.leguminosa:
        return 'Plantas que fixam nitrogênio';
      case CulturaTipo.oleaginosa:
        return 'Culturas produtoras de óleo';
      case CulturaTipo.frutifera:
        return 'Árvores e plantas frutíferas';
      case CulturaTipo.hortalica:
        return 'Vegetais e verduras';
      case CulturaTipo.forrageira:
        return 'Pastagens para animais';
      case CulturaTipo.outros:
        return 'Outras culturas';
    }
  }

  /// Cores associadas aos tipos
  int get colorValue {
    switch (this) {
      case CulturaTipo.cereal:
        return 0xFFFFB74D; // Amarelo - grãos
      case CulturaTipo.leguminosa:
        return 0xFF81C784; // Verde - plantas
      case CulturaTipo.oleaginosa:
        return 0xFFFF8A65; // Laranja - oleoso
      case CulturaTipo.frutifera:
        return 0xFFBA68C8; // Roxo - frutas
      case CulturaTipo.hortalica:
        return 0xFF4FC3F7; // Azul - vegetais
      case CulturaTipo.forrageira:
        return 0xFF9CCC65; // Verde claro - pasto
      case CulturaTipo.outros:
        return 0xFF90A4AE; // Cinza - neutro
    }
  }
}

/// Value Object para estatísticas de culturas
class CulturasStats {
  final int total;
  final int ativas;
  final Map<CulturaTipo, int> porTipo;
  final List<CulturaPopular> topCulturas;

  const CulturasStats({
    required this.total,
    required this.ativas,
    required this.porTipo,
    required this.topCulturas,
  });

  double get percentualAtivas => total > 0 ? (ativas / total) * 100 : 0;

  CulturaTipo get tipoMaisComum {
    if (porTipo.isEmpty) return CulturaTipo.outros;
    
    final sorted = porTipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CulturasStats &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          ativas == other.ativas;

  @override
  int get hashCode => Object.hash(total, ativas);

  @override
  String toString() {
    return 'CulturasStats{total: $total, ativas: $ativas, tipoMaisComum: $tipoMaisComum}';
  }
}

/// Value Object para cultura popular
class CulturaPopular {
  final String nome;
  final int count;
  final CulturaTipo tipo;

  const CulturaPopular({
    required this.nome,
    required this.count,
    required this.tipo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CulturaPopular &&
          runtimeType == other.runtimeType &&
          nome == other.nome;

  @override
  int get hashCode => nome.hashCode;

  @override
  String toString() => 'CulturaPopular{nome: $nome, count: $count}';
}

/// Value Object para filtros de busca de culturas
class CulturaSearchFilters {
  final String? nome;
  final String? familia;
  final String? categoria;
  final CulturaTipo? tipo;
  final bool? isAtiva;

  const CulturaSearchFilters({
    this.nome,
    this.familia,
    this.categoria,
    this.tipo,
    this.isAtiva,
  });

  bool get hasFilters =>
    nome != null ||
    familia != null ||
    categoria != null ||
    tipo != null ||
    isAtiva != null;

  CulturaSearchFilters copyWith({
    String? nome,
    String? familia,
    String? categoria,
    CulturaTipo? tipo,
    bool? isAtiva,
  }) {
    return CulturaSearchFilters(
      nome: nome ?? this.nome,
      familia: familia ?? this.familia,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      isAtiva: isAtiva ?? this.isAtiva,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CulturaSearchFilters &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          tipo == other.tipo;

  @override
  int get hashCode => Object.hash(nome, familia, tipo);
}

/// Value Object para dados dos filtros de culturas
class CulturaFiltersData {
  final List<String> familias;
  final List<String> categorias;
  final List<CulturaTipo> tipos;

  const CulturaFiltersData({
    required this.familias,
    required this.categorias,
    required this.tipos,
  });

  bool get isEmpty => familias.isEmpty && categorias.isEmpty && tipos.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CulturaFiltersData &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(familias, other.familias) &&
          const ListEquality().equals(categorias, other.categorias) &&
          const ListEquality().equals(tipos, other.tipos);

  @override
  int get hashCode => Object.hash(
      const ListEquality().hash(familias),
      const ListEquality().hash(categorias),
      const ListEquality().hash(tipos));
}