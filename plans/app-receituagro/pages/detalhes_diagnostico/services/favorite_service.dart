// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/localstorage_service.dart';
import '../interfaces/i_favorite_service.dart';

/// Serviço para gerenciamento de favoritos de diagnósticos
class DiagnosticoFavoriteService implements IFavoriteService {
  final LocalStorageService _localStorageService;

  DiagnosticoFavoriteService({LocalStorageService? localStorageService})
      : _localStorageService = localStorageService ?? Get.find<LocalStorageService>();

  @override
  Future<bool> isFavorite(String category, String itemId) async {
    try {
      return await _localStorageService.isFavorite(category, itemId);
    } catch (e) {
      // Log error in production
      return false;
    }
  }

  @override
  Future<bool> toggleFavorite(String category, String itemId) async {
    try {
      return await _localStorageService.setFavorite(category, itemId);
    } catch (e) {
      // Log error in production
      rethrow;
    }
  }

  @override
  Future<void> addFavorite(String category, String itemId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(category, itemId);
      if (!isCurrentlyFavorite) {
        await _localStorageService.setFavorite(category, itemId);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite(String category, String itemId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(category, itemId);
      if (isCurrentlyFavorite) {
        await _localStorageService.setFavorite(category, itemId);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Método utilitário para diagnósticos específicos
  Future<bool> toggleDiagnosticoFavorite(String diagnosticoId) async {
    return await toggleFavorite('favDiagnosticos', diagnosticoId);
  }

  /// Método utilitário para verificar se um diagnóstico é favorito
  Future<bool> isDiagnosticoFavorite(String diagnosticoId) async {
    return await isFavorite('favDiagnosticos', diagnosticoId);
  }
}
