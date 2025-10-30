import 'dart:developer' as developer;

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/diagnostico_hive_repository.dart';
import '../../../../core/data/repositories/favoritos_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Implementação do storage local para favoritos usando Hive (Data Layer)
/// Princípio: Single Responsibility - Apenas storage
///
/// ⚠️ NOTA: Esta classe é mantida por compatibilidade com IFavoritosStorage
/// mas a implementação atual usa FavoritosService consolidado
class FavoritosStorageService implements IFavoritosStorage {
  // Lazy loading para evitar circular dependencies (DIP)
  late final FavoritosHiveRepository _repository;

  bool _repositoryInitialized = false;

  static const Map<String, String> _storageKeys = {
    'defensivo': 'defensivos',
    'praga': 'pragas',
    'diagnostico': 'diagnosticos',
    'cultura': 'culturas',
  };

  /// Inicializa as dependências lazy (chamado na primeira vez que são acessadas)
  void _initializeRepository() {
    if (_repositoryInitialized) return;
    _repository = sl<FavoritosHiveRepository>();
    _repositoryInitialized = true;
  }

  @override
  Future<List<String>> getFavoriteIds(String tipo) async {
    try {
      _initializeRepository();
      final boxName = _getBoxName(tipo);
      if (boxName == null) return [];

      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return [];

      final favoritos = await _repository.getFavoritosByTipoAsync(tipoKey);
      return favoritos.map((f) => f.itemId).toList();
    } catch (e) {
      throw FavoritosException('Erro ao buscar IDs favoritos: $e', tipo: tipo);
    }
  }

  @override
  Future<bool> addFavoriteId(String tipo, String id) async {
    try {
      final boxName = _getBoxName(tipo);
      if (boxName == null) return false;

      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return false;
      final itemData = {
        'id': id,
        'tipo': tipo,
        'adicionadoEm': DateTime.now().toIso8601String(),
      };

      return await _repository.addFavorito(tipoKey, id, itemData);
    } catch (e) {
      throw FavoritosException(
        'Erro ao adicionar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  @override
  Future<bool> removeFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return false;

      return await _repository.removeFavorito(tipoKey, id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao remover favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  @override
  Future<bool> isFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return false;

      return await _repository.isFavorito(tipoKey, id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao verificar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  @override
  Future<void> clearFavorites(String tipo) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return;

      await _repository.clearFavoritosByTipo(tipoKey);
    } catch (e) {
      throw FavoritosException('Erro ao limpar favoritos: $e', tipo: tipo);
    }
  }

  @override
  Future<void> clearAllFavorites() async {
    try {
      for (final tipo in TipoFavorito.todos) {
        await clearFavorites(tipo);
      }
    } catch (e) {
      throw FavoritosException('Erro ao limpar todos os favoritos: $e');
    }
  }

  @override
  Future<void> syncFavorites() async {
    try {
      final stats = await _repository.getFavoritosStats();
      developer.log(
        'Favoritos sincronizados - Stats: $stats',
        name: 'FavoritosStorageService',
      );
    } catch (e) {
      throw FavoritosException('Erro ao sincronizar favoritos: $e');
    }
  }

  String? _getBoxName(String tipo) {
    return _storageKeys[tipo];
  }
}

/// Implementação do cache para favoritos
/// Princípio: Single Responsibility - Apenas cache
class FavoritosCacheService implements IFavoritosCache {
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  @override
  Future<T?> get<T>(String key) async {
    try {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null) {
        if (DateTime.now().difference(timestamp).inMinutes > 5) {
          await remove(key);
          return null;
        }
      }

      return _memoryCache[key] as T?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> put<T>(String key, T data, {Duration? ttl}) async {
    try {
      _memoryCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();
    } catch (e) {}
  }

  @override
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    } catch (e) {}
  }

  @override
  Future<void> clearByPrefix(String prefix) async {
    try {
      final keysToRemove = _memoryCache.keys
          .where((key) => key.startsWith(prefix))
          .toList();

      for (final key in keysToRemove) {
        await remove(key);
      }
    } catch (e) {}
  }

  @override
  Future<void> clearAll() async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();
    } catch (e) {}
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    return {
      'totalItems': _memoryCache.length,
      'memoryUsage': 'unknown', // Poderia calcular uso de memória
      'type': 'memory_cache',
    };
  }

  @override
  Future<List<String>> getKeys() async {
    return _memoryCache.keys.toList();
  }
}

/// Implementação do resolvedor de dados
/// Princípio: Single Responsibility - Apenas resolução de dados
class FavoritosDataResolverService implements IFavoritosDataResolver {
  final FitossanitarioHiveRepository _fitossanitarioRepository =
      sl<FitossanitarioHiveRepository>();
  final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();
  final DiagnosticoHiveRepository _diagnosticoRepository =
      sl<DiagnosticoHiveRepository>();
  final CulturaHiveRepository _culturaRepository = sl<CulturaHiveRepository>();

  @override
  Future<Map<String, dynamic>?> resolveDefensivo(String id) async {
    try {
      final defensivo = await _fitossanitarioRepository.getById(id);
      if (defensivo != null) {
        return {
          'nomeComum': defensivo.nomeComum,
          'ingredienteAtivo': defensivo.ingredienteAtivo ?? '',
          'fabricante': defensivo.fabricante ?? '',
          'classeAgron': defensivo.classeAgronomica ?? '',
          'modoAcao': defensivo.modoAcao ?? '',
        };
      }
      return {
        'nomeComum': 'Defensivo $id',
        'ingredienteAtivo': 'Não disponível',
        'fabricante': 'Não disponível',
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> resolvePraga(String id) async {
    try {
      final praga = await _pragasRepository.getById(id);
      if (praga != null) {
        return {
          'nomeComum': praga.nomeComum,
          'nomeCientifico': praga.nomeCientifico,
          'tipoPraga': praga.tipoPraga,
          'dominio': praga.dominio ?? '',
          'reino': praga.reino ?? '',
          'familia': praga.familia ?? '',
        };
      }
      return {
        'nomeComum': 'Praga $id',
        'nomeCientifico': 'Não disponível',
        'tipoPraga': '1',
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> resolveDiagnostico(String id) async {
    try {
      final diagnostico = await _diagnosticoRepository.getByIdOrObjectId(id);
      if (diagnostico != null) {
        return {
          'nomePraga': diagnostico.nomePraga ?? 'Praga não encontrada',
          'nomeDefensivo':
              diagnostico.nomeDefensivo ?? 'Defensivo não encontrado',
          'cultura': diagnostico.nomeCultura ?? 'Cultura não encontrada',
          'dosagem':
              '${diagnostico.dsMin ?? ''} - ${diagnostico.dsMax} ${diagnostico.um}',
          'fabricante': '', // Campo não disponível no DiagnosticoHive
          'modoAcao': '', // Campo não disponível no DiagnosticoHive
        };
      }
      return {
        'nomePraga': 'Praga $id',
        'nomeDefensivo': 'Defensivo não encontrado',
        'cultura': 'Cultura não encontrada',
        'dosagem': 'Não especificada',
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> resolveCultura(String id) async {
    try {
      final cultura = await _culturaRepository.getById(id);
      if (cultura != null) {
        return {
          'nomeCultura': cultura.cultura,
          'descricao': cultura.cultura, // Não há campo descricao separado
          'nomeComum': cultura.nomeComum,
        };
      }
      return {
        'nomeCultura': 'Cultura $id',
        'descricao': 'Descrição não disponível',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Factory para criação de entidades de favoritos
/// Princípio: Factory Pattern + Single Responsibility
class FavoritosEntityFactoryService implements IFavoritosEntityFactory {
  @override
  FavoritoDefensivoEntity createDefensivo({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoDefensivoEntity(
      id: id,
      nomeComum: data['nomeComum'] as String? ?? '',
      ingredienteAtivo: data['ingredienteAtivo'] as String? ?? '',
      fabricante: data['fabricante'] as String?,
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  FavoritoPragaEntity createPraga({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoPragaEntity(
      id: id,
      nomeComum: data['nomeComum'] as String? ?? '',
      nomeCientifico: data['nomeCientifico'] as String? ?? '',
      tipoPraga: data['tipoPraga'] as String? ?? '1',
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  FavoritoDiagnosticoEntity createDiagnostico({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoDiagnosticoEntity(
      id: id,
      nomePraga: data['nomePraga'] as String? ?? '',
      nomeDefensivo: data['nomeDefensivo'] as String? ?? '',
      cultura: data['cultura'] as String? ?? '',
      dosagem: data['dosagem'] as String? ?? '',
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  FavoritoCulturaEntity createCultura({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoCulturaEntity(
      id: id,
      nomeCultura: data['nomeCultura'] as String? ?? '',
      descricao: data['descricao'] as String?,
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  FavoritoEntity create({
    required String tipo,
    required String id,
    required Map<String, dynamic> data,
  }) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return createDefensivo(id: id, data: data);
      case TipoFavorito.praga:
        return createPraga(id: id, data: data);
      case TipoFavorito.diagnostico:
        return createDiagnostico(id: id, data: data);
      case TipoFavorito.cultura:
        return createCultura(id: id, data: data);
      default:
        throw ArgumentError('Tipo de favorito não suportado: $tipo');
    }
  }
}

/// Validador para favoritos
/// Princípio: Single Responsibility - Apenas validação
class FavoritosValidatorService implements IFavoritosValidator {
  final FitossanitarioHiveRepository _fitossanitarioRepository =
      sl<FitossanitarioHiveRepository>();
  final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();
  final DiagnosticoHiveRepository _diagnosticoRepository =
      sl<DiagnosticoHiveRepository>();
  final CulturaHiveRepository _culturaRepository = sl<CulturaHiveRepository>();

  @override
  Future<bool> canAddToFavorites(String tipo, String id) async {
    return isValidTipo(tipo) && isValidId(id) && await exists(tipo, id);
  }

  @override
  Future<bool> exists(String tipo, String id) async {
    try {
      switch (tipo) {
        case TipoFavorito.defensivo:
          final defensivo = await _fitossanitarioRepository.getById(id);
          return defensivo != null;
        case TipoFavorito.praga:
          final praga = await _pragasRepository.getById(id);
          return praga != null;
        case TipoFavorito.diagnostico:
          final diagnostico = await _diagnosticoRepository.getByIdOrObjectId(
            id,
          );
          return diagnostico != null;
        case TipoFavorito.cultura:
          final cultura = await _culturaRepository.getById(id);
          return cultura != null;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  bool isValidTipo(String tipo) {
    return TipoFavorito.isValid(tipo);
  }

  @override
  bool isValidId(String id) {
    return id.trim().isNotEmpty;
  }
}
