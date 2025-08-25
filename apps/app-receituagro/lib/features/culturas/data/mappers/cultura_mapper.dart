import '../../../../core/models/cultura_hive.dart';
import '../../domain/entities/cultura_entity.dart';

/// Mapper para conversão entre camadas (Data Layer)
/// Converte entre CulturaHive (infraestrutura) e CulturaEntity (domínio)
class CulturaMapper {
  CulturaMapper._(); // Private constructor

  /// Converte CulturaHive para CulturaEntity
  static CulturaEntity fromHive(CulturaHive hive) {
    return CulturaEntity(
      id: hive.idReg,
      nome: hive.cultura,
      isAtiva: true, // Assumindo que todas são ativas por padrão
      familia: _extractFamilia(hive.cultura),
      categoria: _extractCategoria(hive.cultura),
      descricao: _generateDescricao(hive.cultura),
      createdAt: hive.createdAt != 0
          ? DateTime.fromMillisecondsSinceEpoch(hive.createdAt * 1000)
          : null,
      updatedAt: hive.updatedAt != 0
          ? DateTime.fromMillisecondsSinceEpoch(hive.updatedAt * 1000)
          : null,
    );
  }

  /// Converte CulturaEntity para CulturaHive
  static CulturaHive toHive(CulturaEntity entity) {
    return CulturaHive(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? 
          DateTime.now().millisecondsSinceEpoch,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? 
          DateTime.now().millisecondsSinceEpoch,
      idReg: entity.id,
      cultura: entity.nome,
    );
  }

  /// Converte lista de CulturaHive para lista de CulturaEntity
  static List<CulturaEntity> fromHiveList(List<CulturaHive> hiveList) {
    return hiveList.map((hive) => fromHive(hive)).toList();
  }

  /// Converte lista de CulturaEntity para lista de CulturaHive
  static List<CulturaHive> toHiveList(List<CulturaEntity> entities) {
    return entities.map((entity) => toHive(entity)).toList();
  }

  /// Converte estatísticas do Hive para CulturasStats
  static CulturasStats statsFromHiveStats(Map<String, dynamic> hiveStats) {
    final topCulturasData = hiveStats['topCulturas'] as List<Map<String, dynamic>>? ?? [];
    final topCulturas = topCulturasData.map((data) => CulturaPopular(
      nome: data['nome'] as String? ?? '',
      count: (data['count'] as int?) ?? 0,
      tipo: _getTipoFromNome(data['nome'] as String? ?? ''),
    )).toList();

    // Agrupa por tipo para estatísticas
    final porTipo = <CulturaTipo, int>{};
    for (final cultura in topCulturas) {
      porTipo[cultura.tipo] = (porTipo[cultura.tipo] ?? 0) + cultura.count;
    }

    return CulturasStats(
      total: (hiveStats['total'] as int?) ?? 0,
      ativas: (hiveStats['ativas'] as int?) ?? 0,
      porTipo: porTipo,
      topCulturas: topCulturas,
    );
  }

  /// Extrai família da cultura baseado no nome (heurística)
  static String? _extractFamilia(String nome) {
    final nomeClean = nome.toLowerCase().trim();
    
    // Mapeamento básico de culturas para famílias
    final familiaMap = {
      'poaceae': ['milho', 'trigo', 'arroz', 'sorgo', 'aveia', 'centeio', 'cevada', 'capim'],
      'fabaceae': ['soja', 'feijão', 'amendoim', 'grão-de-bico', 'lentilha', 'ervilha'],
      'solanaceae': ['tomate', 'batata', 'pimentão', 'berinjela', 'fumo'],
      'brassicaceae': ['couve', 'repolho', 'brócolis', 'couve-flor', 'mostarda'],
      'rutaceae': ['laranja', 'limão', 'lima', 'tangerina', 'grapefruit'],
      'rosaceae': ['maçã', 'pêra', 'ameixa', 'pêssego', 'morango'],
      'cucurbitaceae': ['abóbora', 'abobrinha', 'pepino', 'melão', 'melancia'],
    };

    for (final familia in familiaMap.keys) {
      final culturas = familiaMap[familia]!;
      if (culturas.any((cultura) => nomeClean.contains(cultura))) {
        return familia;
      }
    }

    return null;
  }

  /// Extrai categoria da cultura baseado no nome (heurística)
  static String? _extractCategoria(String nome) {
    final nomeClean = nome.toLowerCase().trim();
    
    if (_isAnualCultura(nomeClean)) return 'Anual';
    if (_isPereneCultura(nomeClean)) return 'Perene';
    if (_isBienalCultura(nomeClean)) return 'Bienal';
    
    return null;
  }

  /// Verifica se é cultura anual
  static bool _isAnualCultura(String nome) {
    final anuais = [
      'milho', 'soja', 'feijão', 'trigo', 'arroz', 'tomate', 'batata',
      'cebola', 'alho', 'cenoura', 'beterraba', 'alface'
    ];
    return anuais.any((cultura) => nome.contains(cultura));
  }

  /// Verifica se é cultura perene
  static bool _isPereneCultura(String nome) {
    final perenes = [
      'café', 'laranja', 'limão', 'maçã', 'uva', 'banana', 'manga',
      'coco', 'açaí', 'cupuaçu', 'capim', 'brachiaria'
    ];
    return perenes.any((cultura) => nome.contains(cultura));
  }

  /// Verifica se é cultura bienal
  static bool _isBienalCultura(String nome) {
    final bienais = ['cenoura', 'beterraba', 'couve', 'repolho'];
    return bienais.any((cultura) => nome.contains(cultura));
  }

  /// Gera descrição básica da cultura
  static String _generateDescricao(String nome) {
    final nomeClean = nome.toLowerCase().trim();
    
    // Descrições básicas por tipo
    if (nomeClean.contains('milho')) {
      return 'Cultura de grão básico, amplamente cultivada para alimentação humana e animal.';
    } else if (nomeClean.contains('soja')) {
      return 'Leguminosa oleaginosa de grande importância econômica e nutricional.';
    } else if (nomeClean.contains('café')) {
      return 'Cultura perene produtora de grãos para bebida estimulante.';
    } else if (nomeClean.contains('tomate')) {
      return 'Hortaliça de fruto consumido in natura e processado.';
    } else if (nomeClean.contains('capim') || nomeClean.contains('brachiaria')) {
      return 'Forrageira utilizada na alimentação de bovinos e outros ruminantes.';
    }
    
    return 'Cultura agrícola de interesse comercial.';
  }

  /// Obtém tipo da cultura baseado no nome
  static CulturaTipo _getTipoFromNome(String nome) {
    final entity = CulturaEntity(
      id: '',
      nome: nome,
      isAtiva: true,
    );
    return entity.tipo;
  }

  /// Converte CulturaSearchFilters para parâmetros de busca do Hive
  static Map<String, dynamic> filtersToHiveParams(CulturaSearchFilters filters) {
    final params = <String, dynamic>{};

    if (filters.nome?.isNotEmpty == true) {
      params['nome'] = filters.nome;
    }
    if (filters.familia?.isNotEmpty == true) {
      params['familia'] = filters.familia;
    }
    if (filters.categoria?.isNotEmpty == true) {
      params['categoria'] = filters.categoria;
    }
    if (filters.tipo != null) {
      params['tipo'] = filters.tipo!.name;
    }
    if (filters.isAtiva != null) {
      params['isAtiva'] = filters.isAtiva;
    }

    return params;
  }

  /// Validação de dados
  static bool isValidHive(CulturaHive hive) {
    return hive.idReg.isNotEmpty && hive.cultura.isNotEmpty;
  }

  static bool isValidEntity(CulturaEntity entity) {
    return entity.isValid;
  }

  /// Helpers para filtros de UI
  static List<String> extractUniqueValues(
    List<CulturaEntity> entities,
    String Function(CulturaEntity) extractor,
  ) {
    return entities
        .map(extractor)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  static List<String> extractUniqueFamilias(List<CulturaEntity> entities) {
    return extractUniqueValues(entities, (entity) => entity.familia ?? '');
  }

  static List<String> extractUniqueCategorias(List<CulturaEntity> entities) {
    return extractUniqueValues(entities, (entity) => entity.categoria ?? '');
  }

  static List<CulturaTipo> extractUniqueTipos(List<CulturaEntity> entities) {
    return entities
        .map((entity) => entity.tipo)
        .toSet()
        .toList();
  }

  /// Filtros específicos por tipo de cultura
  static List<CulturaEntity> filterByTipo(
    List<CulturaEntity> culturas,
    CulturaTipo tipo,
  ) {
    return culturas.where((cultura) => cultura.tipo == tipo).toList();
  }

  /// Ordenação de culturas
  static List<CulturaEntity> sortByNome(
    List<CulturaEntity> culturas, {
    bool ascending = true,
  }) {
    final sorted = List<CulturaEntity>.from(culturas);
    sorted.sort((a, b) => ascending
        ? a.nome.compareTo(b.nome)
        : b.nome.compareTo(a.nome));
    return sorted;
  }

  static List<CulturaEntity> sortByTipo(
    List<CulturaEntity> culturas, {
    bool ascending = true,
  }) {
    final sorted = List<CulturaEntity>.from(culturas);
    sorted.sort((a, b) => ascending
        ? a.tipo.name.compareTo(b.tipo.name)
        : b.tipo.name.compareTo(a.tipo.name));
    return sorted;
  }

  /// Agrupamento de culturas
  static Map<CulturaTipo, List<CulturaEntity>> groupByTipo(
    List<CulturaEntity> culturas,
  ) {
    final grouped = <CulturaTipo, List<CulturaEntity>>{};
    
    for (final cultura in culturas) {
      grouped[cultura.tipo] ??= [];
      grouped[cultura.tipo]!.add(cultura);
    }
    
    return grouped;
  }

  static Map<String, List<CulturaEntity>> groupByFamilia(
    List<CulturaEntity> culturas,
  ) {
    final grouped = <String, List<CulturaEntity>>{};
    
    for (final cultura in culturas) {
      final familia = cultura.familia ?? 'Outras';
      grouped[familia] ??= [];
      grouped[familia]!.add(cultura);
    }
    
    return grouped;
  }
}