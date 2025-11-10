import 'package:core/core.dart' hide Column;

import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';
import '../services/favoritos_service.dart';

/// Repositório simplificado para Favoritos usando o FavoritosService consolidado
/// Princípio: Simplicidade e redução de complexidade desnecessária
@LazySingleton(as: IFavoritosRepository)
class FavoritosRepositorySimplified implements IFavoritosRepository {
  final FavoritosService _service;

  const FavoritosRepositorySimplified({required FavoritosService service})
    : _service = service;

  @override
  Future<List<FavoritoEntity>> getAll() async {
    try {
      final futures = await Future.wait([
        getByTipo(TipoFavorito.defensivo),
        getByTipo(TipoFavorito.praga),
        getByTipo(TipoFavorito.diagnostico),
        getByTipo(TipoFavorito.cultura),
      ]);

      final List<FavoritoEntity> allFavoritos = [];
      for (final typeList in futures) {
        allFavoritos.addAll(typeList);
      }
      allFavoritos.sort((a, b) => a.nomeDisplay.compareTo(b.nomeDisplay));

      return allFavoritos;
    } catch (e) {
      throw FavoritosException('Erro ao buscar todos os favoritos: $e');
    }
  }

  @override
  Future<List<FavoritoEntity>> getByTipo(String tipo) async {
    try {
      final ids = await _service.getFavoriteIds(tipo);
      final favoritos = <FavoritoEntity>[];

      for (final id in ids) {
        final entity = await _getEntityById(tipo, id);
        if (entity != null) {
          favoritos.add(entity);
        }
      }

      return favoritos;
    } catch (e) {
      throw FavoritosException(
        'Erro ao buscar favoritos por tipo: $e',
        tipo: tipo,
      );
    }
  }

  @override
  Future<FavoritosStats> getStats() async {
    try {
      return await _service.getStats();
    } catch (e) {
      throw FavoritosException('Erro ao buscar estatísticas de favoritos: $e');
    }
  }

  @override
  Future<bool> isFavorito(String tipo, String id) async {
    try {
      return await _service.isFavoriteId(tipo, id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao verificar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  /// Implementação genérica: adiciona qualquer tipo de FavoritoEntity
  /// Novo padrão: substitui addDefensivo, addPraga, addDiagnostico, addCultura
  @override
  Future<bool> addFavorito(FavoritoEntity favorito) async {
    try {
      return await _service.addFavoriteId(favorito.tipo, favorito.id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao adicionar favorito: $e',
        tipo: favorito.tipo,
        id: favorito.id,
      );
    }
  }

  /// Implementação: remove favorito genérico
  /// Novo padrão: substitui removeDefensivo, removePraga, removeDiagnostico, removeCultura
  @override
  Future<bool> removeFavorito(String tipo, String id) async {
    try {
      return await _service.removeFavoriteId(tipo, id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao remover favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  /// Implementação: alterna favorito genérico
  @override
  Future<bool> toggleFavorito(String tipo, String id) async {
    try {
      final isFav = await isFavorito(tipo, id);

      if (isFav) {
        return await removeFavorito(tipo, id);
      } else {
        // Usa o método antigo por enquanto (compatibilidade)
        return await _addFavoritoSimples(tipo, id);
      }
    } catch (e) {
      throw FavoritosException(
        'Erro ao alternar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  /// Helper privado: adiciona favorito (padrão antigo, mantido para compatibilidade)
  Future<bool> _addFavoritoSimples(String tipo, String id) async {
    try {
      return await _service.addFavoriteId(tipo, id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao adicionar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  @override
  Future<List<FavoritoEntity>> search(String query) async {
    try {
      final allFavoritos = await getAll();
      final queryLower = query.toLowerCase();

      return allFavoritos.where((favorito) {
        return favorito.nomeDisplay.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw FavoritosException('Erro ao buscar favoritos: $e');
    }
  }

  Future<void> clearFavorites(String tipo) async {
    try {
      await _service.clearFavorites(tipo);
    } catch (e) {
      throw FavoritosException('Erro ao limpar favoritos: $e', tipo: tipo);
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _service.clearAllFavorites();
    } catch (e) {
      throw FavoritosException('Erro ao limpar todos os favoritos: $e');
    }
  }

  Future<void> syncFavorites() async {
    try {
      await _service.syncFavorites();
    } catch (e) {
      throw FavoritosException('Erro ao sincronizar favoritos: $e');
    }
  }

  /// Helper privado para obter entidade por ID
  Future<FavoritoEntity?> _getEntityById(String tipo, String id) async {
    try {
      final data = await _service.resolveItemData(tipo, id);
      if (data != null) {
        return _service.createEntity(tipo: tipo, id: id, data: data);
      }
      return null;
    } catch (e) {
      throw FavoritosException(
        'Erro ao buscar entidade por ID: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  /// Obtém defensivos favoritos
  Future<List<FavoritoDefensivoEntity>> getDefensivos() async {
    final favoritos = await getByTipo(TipoFavorito.defensivo);
    return favoritos.whereType<FavoritoDefensivoEntity>().toList();
  }

  /// Obtém pragas favoritas
  Future<List<FavoritoPragaEntity>> getPragas() async {
    final favoritos = await getByTipo(TipoFavorito.praga);
    return favoritos.whereType<FavoritoPragaEntity>().toList();
  }

  /// Obtém diagnósticos favoritos
  Future<List<FavoritoDiagnosticoEntity>> getDiagnosticos() async {
    final favoritos = await getByTipo(TipoFavorito.diagnostico);
    return favoritos.whereType<FavoritoDiagnosticoEntity>().toList();
  }

  /// Obtém culturas favoritas
  Future<List<FavoritoCulturaEntity>> getCulturas() async {
    final favoritos = await getByTipo(TipoFavorito.cultura);
    return favoritos.whereType<FavoritoCulturaEntity>().toList();
  }

  /// Verifica se defensivo é favorito
  Future<bool> isDefensivoFavorito(String id) async {
    return await isFavorito(TipoFavorito.defensivo, id);
  }

  /// Verifica se praga é favorita
  Future<bool> isPragaFavorito(String id) async {
    return await isFavorito(TipoFavorito.praga, id);
  }

  /// Verifica se diagnóstico é favorito
  Future<bool> isDiagnosticoFavorito(String id) async {
    return await isFavorito(TipoFavorito.diagnostico, id);
  }

  /// Verifica se cultura é favorita
  Future<bool> isCulturaFavorito(String id) async {
    return await isFavorito(TipoFavorito.cultura, id);
  }

  /// Adiciona defensivo aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<bool> addDefensivo(String id) async {
    return await _addFavoritoSimples(TipoFavorito.defensivo, id);
  }

  /// Adiciona praga aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<bool> addPraga(String id) async {
    return await _addFavoritoSimples(TipoFavorito.praga, id);
  }

  /// Adiciona diagnóstico aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<bool> addDiagnostico(String id) async {
    return await _addFavoritoSimples(TipoFavorito.diagnostico, id);
  }

  /// Adiciona cultura aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<bool> addCultura(String id) async {
    return await _addFavoritoSimples(TipoFavorito.cultura, id);
  }

  /// Remove defensivo dos favoritos
  Future<bool> removeDefensivo(String id) async {
    return await removeFavorito(TipoFavorito.defensivo, id);
  }

  /// Remove praga dos favoritos
  Future<bool> removePraga(String id) async {
    return await removeFavorito(TipoFavorito.praga, id);
  }

  /// Remove diagnóstico dos favoritos
  Future<bool> removeDiagnostico(String id) async {
    return await removeFavorito(TipoFavorito.diagnostico, id);
  }

  /// Remove cultura dos favoritos
  Future<bool> removeCultura(String id) async {
    return await removeFavorito(TipoFavorito.cultura, id);
  }
}
