import 'package:core/core.dart';

import '../../../core/models/favorito_item_hive.dart';
import '../../../core/repositories/favoritos_hive_repository.dart';
import '../models/favorito_defensivo_model.dart';
import '../models/favorito_diagnostico_model.dart';
import '../models/favorito_praga_model.dart';

/// Wrapper service para manter compatibilidade com o módulo de favoritos
/// Usa o FavoritosHiveRepository principal do core
class FavoritosHiveRepositoryService {
  final FavoritosHiveRepository _coreRepository;

  FavoritosHiveRepositoryService() 
    : _coreRepository = GetIt.instance<FavoritosHiveRepository>();

  /// Métodos compatíveis com os models antigos
  Future<List<FavoritoDefensivoModel>> getFavoritosDefensivos() async {
    try {
      await _coreRepository.getFavoritosByTipoAsync('defensivos');
      // Converter para modelo específico se necessário
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<FavoritoPragaModel>> getFavoritosPragas() async {
    try {
      await _coreRepository.getFavoritosByTipoAsync('pragas');
      // Converter para modelo específico se necessário
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<FavoritoDiagnosticoModel>> getFavoritosDiagnosticos() async {
    try {
      await _coreRepository.getFavoritosByTipoAsync('diagnosticos');
      // Converter para modelo específico se necessário
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> removeFavoritoDefensivo(int id) async {
    await _coreRepository.removeFavorito('defensivos', id.toString());
  }

  Future<void> removeFavoritoPraga(int id) async {
    await _coreRepository.removeFavorito('pragas', id.toString());
  }

  Future<void> removeFavoritoDiagnostico(int id) async {
    await _coreRepository.removeFavorito('diagnosticos', id.toString());
  }

  /// Proxy methods to core repository
  Future<bool> addFavorito(String tipo, String itemId, Map<String, dynamic> itemData) async {
    return await _coreRepository.addFavorito(tipo, itemId, itemData);
  }

  Future<bool> isFavorito(String tipo, String itemId) async {
    return await _coreRepository.isFavorito(tipo, itemId);
  }

  Future<void> clearFavoritosByTipo(String tipo) async {
    return await _coreRepository.clearFavoritosByTipo(tipo);
  }

  Future<Map<String, int>> getFavoritosStats() async {
    return await _coreRepository.getFavoritosStats();
  }

  Future<List<FavoritoItemHive>> getFavoritosByTipoAsync(String tipo) async {
    return await _coreRepository.getFavoritosByTipoAsync(tipo);
  }
}