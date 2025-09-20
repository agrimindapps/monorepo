import 'dart:developer' as developer;

import 'package:core/core.dart' as core;

import '../../../../core/di/injection_container.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/services/receituagro_hive_service_stub.dart'; // Stub service for compatibility
import '../../../../core/sync/receituagro_sync_config.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../domain/entities/favorito_sync_entity.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Service consolidado para Favoritos - Unifica storage, cache, resolver, factory e validator
/// Princípio: Consolidação de responsabilidades similares para reduzir complexidade
class FavoritosService {
  final FavoritosHiveRepository _repository = sl<FavoritosHiveRepository>();
  final ReceitaAgroAuthProvider? _authProvider = sl.isRegistered<ReceitaAgroAuthProvider>() ? sl<ReceitaAgroAuthProvider>() : null;
  
  // Cache interno consolidado
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Constantes para chaves de storage
  static const Map<String, String> _storageKeys = {
    'defensivo': 'defensivos',
    'praga': 'pragas',
    'diagnostico': 'diagnosticos',
    'cultura': 'culturas',
  };

  // ========== STORAGE OPERATIONS ==========

  Future<List<String>> getFavoriteIds(String tipo) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return [];

      final favoritos = _repository.getFavoritosByTipo(tipoKey);
      return favoritos.map((f) => f.itemId).toList();
    } catch (e) {
      throw FavoritosException('Erro ao buscar IDs favoritos: $e', tipo: tipo);
    }
  }

  Future<bool> addFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) {
        developer.log('Tipo inválido: $tipo', name: 'FavoritosService');
        return false;
      }

      // Valida antes de adicionar
      if (!await canAddToFavorites(tipo, id)) {
        developer.log('Não é possível adicionar favorito: tipo=$tipo, id=$id', name: 'FavoritosService');
        return false;
      }

      // Adiciona com dados básicos para cache
      final itemData = {
        'id': id,
        'tipo': tipo,
        'adicionadoEm': DateTime.now().toIso8601String(),
      };
      
      final result = await _repository.addFavorito(tipoKey, id, itemData);
      
      // Limpa cache após mudança
      if (result) {
        await _clearCacheForTipo(tipo);
        
        // Sincroniza com Firestore se usuário autenticado
        await _queueSyncOperation('create', tipo, id, itemData);
        
        developer.log('Favorito adicionado com sucesso: tipo=$tipo, id=$id', name: 'FavoritosService');
      } else {
        developer.log('Falha ao adicionar favorito: tipo=$tipo, id=$id', name: 'FavoritosService');
      }
      
      return result;
    } catch (e) {
      developer.log('Erro ao adicionar favorito: $e', name: 'FavoritosService', error: e);
      throw FavoritosException('Erro ao adicionar favorito: $e', tipo: tipo, id: id);
    }
  }

  Future<bool> removeFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) {
        developer.log('Tipo inválido: $tipo', name: 'FavoritosService');
        return false;
      }

      final result = await _repository.removeFavorito(tipoKey, id);
      
      // Limpa cache após mudança
      if (result) {
        await _clearCacheForTipo(tipo);
        
        // Sincroniza com Firestore se usuário autenticado
        await _queueSyncOperation('delete', tipo, id, null);
        
        developer.log('Favorito removido com sucesso: tipo=$tipo, id=$id', name: 'FavoritosService');
      } else {
        developer.log('Falha ao remover favorito: tipo=$tipo, id=$id', name: 'FavoritosService');
      }
      
      return result;
    } catch (e) {
      developer.log('Erro ao remover favorito: $e', name: 'FavoritosService', error: e);
      throw FavoritosException('Erro ao remover favorito: $e', tipo: tipo, id: id);
    }
  }

  Future<bool> isFavoriteId(String tipo, String id) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return false;

      return _repository.isFavorito(tipoKey, id);
    } catch (e) {
      throw FavoritosException('Erro ao verificar favorito: $e', tipo: tipo, id: id);
    }
  }

  Future<void> clearFavorites(String tipo) async {
    try {
      final tipoKey = _storageKeys[tipo];
      if (tipoKey == null) return;

      await _repository.clearFavoritosByTipo(tipoKey);
      await _clearCacheForTipo(tipo);
    } catch (e) {
      throw FavoritosException('Erro ao limpar favoritos: $e', tipo: tipo);
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      for (final tipo in TipoFavorito.todos) {
        await clearFavorites(tipo);
      }
    } catch (e) {
      throw FavoritosException('Erro ao limpar todos os favoritos: $e');
    }
  }

  // ========== DATA RESOLVER OPERATIONS ==========

  Future<Map<String, dynamic>?> resolveItemData(String tipo, String id) async {
    final cacheKey = 'resolve_${tipo}_$id';
    
    // Tenta pegar do cache primeiro
    final cached = await _getFromCache<Map<String, dynamic>?>(cacheKey);
    if (cached != null) return cached;

    Map<String, dynamic>? data;
    
    try {
      switch (tipo) {
        case TipoFavorito.defensivo:
          data = await _resolveDefensivo(id);
          break;
        case TipoFavorito.praga:
          data = await _resolvePraga(id);
          break;
        case TipoFavorito.diagnostico:
          data = await _resolveDiagnostico(id);
          break;
        case TipoFavorito.cultura:
          data = await _resolveCultura(id);
          break;
      }

      // Armazena no cache
      if (data != null) {
        await _putToCache(cacheKey, data);
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _resolveDefensivo(String id) async {
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
      
      return {
        'nomeComum': 'Defensivo $id',
        'ingredienteAtivo': 'Não disponível',
        'fabricante': 'Não disponível',
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _resolvePraga(String id) async {
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
      
      return {
        'nomeComum': 'Praga $id',
        'nomeCientifico': 'Não disponível',
        'tipoPraga': '1',
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _resolveDiagnostico(String id) async {
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

  Future<Map<String, dynamic>?> _resolveCultura(String id) async {
    try {
      final cultura = ReceitaAgroHiveService.getCulturaById(id);
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

  // ========== ENTITY FACTORY OPERATIONS ==========

  FavoritoEntity createEntity({
    required String tipo,
    required String id,
    required Map<String, dynamic> data,
  }) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return FavoritoDefensivoEntity(
          id: id,
          nomeComum: data['nomeComum'] as String? ?? '',
          ingredienteAtivo: data['ingredienteAtivo'] as String? ?? '',
          fabricante: data['fabricante'] as String?,
          adicionadoEm: DateTime.now(),
        );
      case TipoFavorito.praga:
        return FavoritoPragaEntity(
          id: id,
          nomeComum: data['nomeComum'] as String? ?? '',
          nomeCientifico: data['nomeCientifico'] as String? ?? '',
          tipoPraga: data['tipoPraga'] as String? ?? '1',
          adicionadoEm: DateTime.now(),
        );
      case TipoFavorito.diagnostico:
        return FavoritoDiagnosticoEntity(
          id: id,
          nomePraga: data['nomePraga'] as String? ?? '',
          nomeDefensivo: data['nomeDefensivo'] as String? ?? '',
          cultura: data['cultura'] as String? ?? '',
          dosagem: data['dosagem'] as String? ?? '',
          adicionadoEm: DateTime.now(),
        );
      case TipoFavorito.cultura:
        return FavoritoCulturaEntity(
          id: id,
          nomeCultura: data['nomeCultura'] as String? ?? '',
          descricao: data['descricao'] as String?,
          adicionadoEm: DateTime.now(),
        );
      default:
        throw ArgumentError('Tipo de favorito não suportado: $tipo');
    }
  }

  // ========== VALIDATOR OPERATIONS ==========

  Future<bool> canAddToFavorites(String tipo, String id) async {
    return isValidTipo(tipo) && isValidId(id) && await existsInData(tipo, id);
  }

  Future<bool> existsInData(String tipo, String id) async {
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

  bool isValidTipo(String tipo) {
    return TipoFavorito.isValid(tipo);
  }

  bool isValidId(String id) {
    return id.trim().isNotEmpty;
  }

  // ========== STATS OPERATIONS ==========

  Future<FavoritosStats> getStats() async {
    try {
      final stats = _repository.getFavoritosStats();
      return FavoritosStats(
        totalDefensivos: stats['defensivos'] ?? 0,
        totalPragas: stats['pragas'] ?? 0,
        totalDiagnosticos: stats['diagnosticos'] ?? 0,
        totalCulturas: stats['culturas'] ?? 0,
      );
    } catch (e) {
      return FavoritosStats.empty();
    }
  }

  // ========== CACHE OPERATIONS ==========

  Future<T?> _getFromCache<T>(String key) async {
    try {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null) {
        // Verifica se ainda está válido (5 minutos)
        if (DateTime.now().difference(timestamp).inMinutes > 5) {
          await _removeFromCache(key);
          return null;
        }
      }

      return _memoryCache[key] as T?;
    } catch (e) {
      return null;
    }
  }

  Future<void> _putToCache<T>(String key, T data) async {
    try {
      _memoryCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();
    } catch (e) {
      // Ignora erros de cache
    }
  }

  Future<void> _removeFromCache(String key) async {
    try {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    } catch (e) {
      // Ignora erros de cache
    }
  }

  Future<void> _clearCacheForTipo(String tipo) async {
    try {
      final keysToRemove = _memoryCache.keys
          .where((key) => key.contains('resolve_${tipo}_'))
          .toList();
      
      for (final key in keysToRemove) {
        await _removeFromCache(key);
      }
    } catch (e) {
      // Ignora erros de cache
    }
  }

  Future<void> clearAllCache() async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();
    } catch (e) {
      // Ignora erros de cache
    }
  }

  // ========== SYNC OPERATIONS ==========

  Future<void> syncFavorites() async {
    try {
      // Implementação para sincronização local - força reload do cache
      await clearAllCache();
      
      // Log para debug
      final stats = await getStats();
      developer.log('Favoritos sincronizados - Stats: $stats', name: 'FavoritosService');
    } catch (e) {
      throw FavoritosException('Erro ao sincronizar favoritos: $e');
    }
  }

  /// Sincroniza favorito usando sistema core
  Future<void> _queueSyncOperation(String operation, String tipo, String id, Map<String, dynamic>? data) async {
    try {
      // Verifica se o usuário está autenticado
      if (_authProvider == null || !_authProvider!.isAuthenticated || _authProvider!.isAnonymous) {
        developer.log('Usuário não autenticado - pulando sincronização de favorito', name: 'FavoritosService');
        return;
      }

      // Verifica se há dados válidos para sincronização
      if (id.isEmpty || tipo.isEmpty) {
        developer.log('Dados inválidos para sincronização - pulando', name: 'FavoritosService');
        return;
      }

      // Resolve dados do item para sincronização
      final resolvedData = data ?? await resolveItemData(tipo, id);
      if (resolvedData == null) {
        developer.log('Não foi possível resolver dados do favorito para sincronização: tipo=$tipo, id=$id', name: 'FavoritosService');
        return;
      }

      // Cria entidade de sincronização
      final syncEntity = FavoritoSyncEntity(
        id: 'favorite_${tipo}_$id',
        tipo: tipo,
        itemId: id,
        itemData: resolvedData,
        adicionadoEm: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: _authProvider!.currentUser?.id,
      );

      // Executa operação de sincronização via ReceitaAgroSyncConfig
      if (operation == 'create') {
        final result = await ReceitaAgroSyncConfig.createFavorito(syncEntity);
        result.fold(
          (core.Failure failure) {
            developer.log('Erro na sincronização de favorito (create): ${failure.message}', name: 'FavoritosService');
          },
          (String entityId) {
            developer.log('Favorito criado com sucesso: id=$entityId', name: 'FavoritosService');
          },
        );
      } else if (operation == 'delete') {
        final result = await ReceitaAgroSyncConfig.deleteFavorito(syncEntity.id);
        result.fold(
          (core.Failure failure) {
            developer.log('Erro na sincronização de favorito (delete): ${failure.message}', name: 'FavoritosService');
          },
          (_) {
            developer.log('Favorito deletado com sucesso: tipo=$tipo, id=$id', name: 'FavoritosService');
          },
        );
      } else {
        final result = await ReceitaAgroSyncConfig.updateFavorito(syncEntity.id, syncEntity);
        result.fold(
          (core.Failure failure) {
            developer.log('Erro na sincronização de favorito (update): ${failure.message}', name: 'FavoritosService');
          },
          (_) {
            developer.log('Favorito atualizado com sucesso: tipo=$tipo, id=$id', name: 'FavoritosService');
          },
        );
      }
      
    } catch (e) {
      developer.log('Erro ao sincronizar favorito: $e', name: 'FavoritosService', error: e);
      // Não relança a exceção para não quebrar a operação local
    }
  }
}