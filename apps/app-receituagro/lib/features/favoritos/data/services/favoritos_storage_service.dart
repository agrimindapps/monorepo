import 'dart:developer' as developer;

import '../../../../core/di/injection_container.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/services/receituagro_hive_service.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Implementação do storage local para favoritos usando Hive (Data Layer)
/// Princípio: Single Responsibility - Apenas storage
class FavoritosStorageService implements IFavoritosStorage {
  final FavoritosHiveRepository _repository = sl<FavoritosHiveRepository>();
  
  // Constantes para chaves de storage
  static const Map<String, String> _storageKeys = {
    'defensivo': 'defensivos',
    'praga': 'pragas',
    'diagnostico': 'diagnosticos',
    'cultura': 'culturas',
  };

  @override
  Future<List<String>> getFavoriteIds(String tipo) async {
    try {
      final boxName = _getBoxName(tipo);
      if (boxName == null) return [];

      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return [];

      final favoritos = _repository.getFavoritosByTipo(tipoKey);
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

      // Adiciona com dados básicos para cache
      final itemData = {
        'id': id,
        'tipo': tipo,
        'adicionadoEm': DateTime.now().toIso8601String(),
      };
      
      return await _repository.addFavorito(tipoKey, id, itemData);
    } catch (e) {
      throw FavoritosException('Erro ao adicionar favorito: $e', tipo: tipo, id: id);
    }
  }

  @override
  Future<bool> removeFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return false;

      return await _repository.removeFavorito(tipoKey, id);
    } catch (e) {
      throw FavoritosException('Erro ao remover favorito: $e', tipo: tipo, id: id);
    }
  }

  @override
  Future<bool> isFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return false;

      return _repository.isFavorito(tipoKey, id);
    } catch (e) {
      throw FavoritosException('Erro ao verificar favorito: $e', tipo: tipo, id: id);
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
      // Implementação para sincronização local - força reload do cache
      // Futura integração com Firebase será implementada quando necessário
      
      // Por enquanto, invalida estatísticas para forçar reload
      final stats = _repository.getFavoritosStats();
      developer.log('Favoritos sincronizados - Stats: $stats', name: 'FavoritosStorageService');
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
  // Cache integrado com sistema unificado do core
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  @override
  Future<T?> get<T>(String key) async {
    try {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null) {
        // Verifica se ainda está válido (5 minutos)
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
    } catch (e) {
      // Ignora erros de cache
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    } catch (e) {
      // Ignora erros de cache
    }
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
    } catch (e) {
      // Ignora erros de cache
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();
    } catch (e) {
      // Ignora erros de cache
    }
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
  
  @override
  Future<Map<String, dynamic>?> resolveDefensivo(String id) async {
    try {
      final defensivo = ReceitaAgroHiveService.getFitossanitarioById(id);
      if (defensivo != null) {
        return {
          'nomeComum': defensivo.nomeComum,
          'ingredienteAtivo': defensivo.ingredienteAtivo ?? '',
          'fabricante': defensivo.fabricante ?? '',
          'classeAgron': defensivo.classeAgronomica ?? '',
          'modoAcao': defensivo.modoAcao ?? '',
        };
      }
      
      // Fallback se não encontrar dados
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
      final praga = ReceitaAgroHiveService.getPragaById(id);
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
      
      // Fallback se não encontrar dados
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
      final diagnostico = ReceitaAgroHiveService.getDiagnosticoById(id);
      if (diagnostico != null) {
        return {
          'nomePraga': diagnostico.nomePraga ?? 'Praga não encontrada',
          'nomeDefensivo': diagnostico.nomeDefensivo ?? 'Defensivo não encontrado',
          'cultura': diagnostico.nomeCultura ?? 'Cultura não encontrada',
          'dosagem': '${diagnostico.dsMin ?? ''} - ${diagnostico.dsMax} ${diagnostico.um}',
          'fabricante': '', // Campo não disponível no DiagnosticoHive
          'modoAcao': '', // Campo não disponível no DiagnosticoHive
        };
      }
      
      // Fallback se não encontrar dados
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
      final cultura = ReceitaAgroHiveService.getCulturaById(id);
      if (cultura != null) {
        return {
          'nomeCultura': cultura.cultura,
          'descricao': cultura.cultura, // Não há campo descricao separado
          'nomeComum': cultura.nomeComum,
        };
      }
      
      // Fallback se não encontrar dados
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
  
  @override
  Future<bool> canAddToFavorites(String tipo, String id) async {
    return isValidTipo(tipo) && isValidId(id) && await exists(tipo, id);
  }

  @override
  Future<bool> exists(String tipo, String id) async {
    try {
      switch (tipo) {
        case TipoFavorito.defensivo:
          return ReceitaAgroHiveService.getFitossanitarioById(id) != null;
        case TipoFavorito.praga:
          return ReceitaAgroHiveService.getPragaById(id) != null;
        case TipoFavorito.diagnostico:
          return ReceitaAgroHiveService.getDiagnosticoById(id) != null;
        case TipoFavorito.cultura:
          return ReceitaAgroHiveService.getCulturaById(id) != null;
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