import '../../../../core/models/fitossanitario_hive.dart';
import '../../domain/entities/defensivo_entity.dart';

/// Mapper para conversão entre camadas (Data Layer)
/// Converte entre FitossanitarioHive (infraestrutura) e DefensivoEntity (domínio)
class DefensivoMapper {
  DefensivoMapper._(); // Private constructor

  /// Converte FitossanitarioHive para DefensivoEntity
  static DefensivoEntity fromHive(FitossanitarioHive hive) {
    return DefensivoEntity(
      id: hive.idReg,
      nomeComum: hive.nomeComum,
      nomeTecnico: hive.nomeTecnico,
      status: hive.status,
      comercializado: hive.comercializado,
      elegivel: hive.elegivel,
      classeAgronomica: hive.classeAgronomica,
      fabricante: hive.fabricante,
      classAmbiental: hive.classAmbiental,
      formulacao: hive.formulacao,
      modoAcao: hive.modoAcao,
      ingredienteAtivo: hive.ingredienteAtivo,
      quantProduto: hive.quantProduto,
      corrosivo: hive.corrosivo,
      inflamavel: hive.inflamavel,
      toxico: hive.toxico,
      mapa: hive.mapa,
      createdAt: hive.createdAt != null 
          ? DateTime.fromMillisecondsSinceEpoch(hive.createdAt!)
          : null,
      updatedAt: hive.updatedAt != null 
          ? DateTime.fromMillisecondsSinceEpoch(hive.updatedAt!)
          : null,
    );
  }

  /// Converte DefensivoEntity para FitossanitarioHive
  static FitossanitarioHive toHive(DefensivoEntity entity) {
    return FitossanitarioHive(
      objectId: entity.id,
      createdAt: entity.createdAt?.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch,
      idReg: entity.id,
      status: entity.status,
      nomeComum: entity.nomeComum,
      nomeTecnico: entity.nomeTecnico,
      comercializado: entity.comercializado,
      elegivel: entity.elegivel,
      classeAgronomica: entity.classeAgronomica,
      fabricante: entity.fabricante,
      classAmbiental: entity.classAmbiental,
      formulacao: entity.formulacao,
      modoAcao: entity.modoAcao,
      ingredienteAtivo: entity.ingredienteAtivo,
      quantProduto: entity.quantProduto,
      corrosivo: entity.corrosivo,
      inflamavel: entity.inflamavel,
      toxico: entity.toxico,
      mapa: entity.mapa,
    );
  }

  /// Converte lista de FitossanitarioHive para lista de DefensivoEntity
  static List<DefensivoEntity> fromHiveList(List<FitossanitarioHive> hiveList) {
    return hiveList.map((hive) => fromHive(hive)).toList();
  }

  /// Converte lista de DefensivoEntity para lista de FitossanitarioHive
  static List<FitossanitarioHive> toHiveList(List<DefensivoEntity> entities) {
    return entities.map((entity) => toHive(entity)).toList();
  }

  /// Converte estatísticas do Hive para DefensivosStats
  static DefensivosStats statsFromHiveStats(Map<String, dynamic> hiveStats) {
    return DefensivosStats(
      total: (hiveStats['total'] as int?) ?? 0,
      ativos: (hiveStats['ativos'] as int?) ?? 0,
      elegiveis: (hiveStats['elegiveis'] as int?) ?? 0,
      inseticides: _countByClasseAgronomica(hiveStats, 'inseticida'),
      herbicides: _countByClasseAgronomica(hiveStats, 'herbicida'),
      fungicides: _countByClasseAgronomica(hiveStats, 'fungicida'),
      acaricides: _countByClasseAgronomica(hiveStats, 'acaricida'),
      byFabricante: _convertToStringIntMap(hiveStats['byFabricante']),
      byClasseAgronomica: _convertToStringIntMap(hiveStats['byClasseAgronomica']),
    );
  }

  /// Helper para contar por classe agronômica
  static int _countByClasseAgronomica(Map<String, dynamic> stats, String classe) {
    final byClasse = stats['byClasseAgronomica'] as Map<String, dynamic>? ?? {};
    return byClasse.entries
        .where((entry) => entry.key.toLowerCase().contains(classe.toLowerCase()))
        .fold<int>(0, (sum, entry) => sum + (entry.value as int? ?? 0));
  }

  /// Helper para converter Map dynamic para Map<String, int>
  static Map<String, int> _convertToStringIntMap(dynamic input) {
    if (input == null) return {};
    if (input is Map<String, int>) return input;
    if (input is Map<String, dynamic>) {
      return input.map((key, value) => MapEntry(key, value as int? ?? 0));
    }
    return {};
  }

  /// Converte DefensivoSearchFilters para parâmetros de busca do Hive
  static Map<String, dynamic> filtersToHiveParams(DefensivoSearchFilters filters) {
    final params = <String, dynamic>{};

    if (filters.nomeComum?.isNotEmpty == true) {
      params['nomeComum'] = filters.nomeComum;
    }
    if (filters.ingredienteAtivo?.isNotEmpty == true) {
      params['ingredienteAtivo'] = filters.ingredienteAtivo;
    }
    if (filters.fabricante?.isNotEmpty == true) {
      params['fabricante'] = filters.fabricante;
    }
    if (filters.classeAgronomica?.isNotEmpty == true) {
      params['classeAgronomica'] = filters.classeAgronomica;
    }
    if (filters.status != null) {
      params['status'] = filters.status;
    }
    if (filters.comercializado != null) {
      params['comercializado'] = filters.comercializado;
    }
    if (filters.elegivel != null) {
      params['elegivel'] = filters.elegivel;
    }

    return params;
  }

  /// Validação de dados
  static bool isValidHive(FitossanitarioHive hive) {
    return hive.idReg.isNotEmpty && 
           hive.nomeComum.isNotEmpty && 
           hive.nomeTecnico.isNotEmpty;
  }

  static bool isValidEntity(DefensivoEntity entity) {
    return entity.id.isNotEmpty && 
           entity.nomeComum.isNotEmpty && 
           entity.nomeTecnico.isNotEmpty;
  }

  /// Helpers para filtros de UI
  static List<String> extractUniqueValues(
    List<DefensivoEntity> entities, 
    String Function(DefensivoEntity) extractor,
  ) {
    return entities
        .map(extractor)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
  }

  static List<String> extractUniqueFabricantes(List<DefensivoEntity> entities) {
    return extractUniqueValues(entities, (entity) => entity.fabricante ?? '');
  }

  static List<String> extractUniqueClassesAgronomicas(List<DefensivoEntity> entities) {
    return extractUniqueValues(entities, (entity) => entity.classeAgronomica ?? '');
  }

  static List<String> extractUniqueIngredientesAtivos(List<DefensivoEntity> entities) {
    return extractUniqueValues(entities, (entity) => entity.ingredienteAtivo ?? '');
  }
}