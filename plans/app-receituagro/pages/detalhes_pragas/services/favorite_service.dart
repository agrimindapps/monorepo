// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/localstorage_service.dart';
import 'error_handler_service.dart';

/// Service responsável pelo gerenciamento de favoritos
class FavoriteService {
  final LocalStorageService _localStorageService;
  final ErrorHandlerService _errorHandler;
  final RxBool _isFavorite = false.obs;

  FavoriteService({
    required LocalStorageService localStorageService,
    required ErrorHandlerService errorHandler,
  })  : _localStorageService = localStorageService,
        _errorHandler = errorHandler;

  /// Getter para status de favorito
  bool get isFavorite => _isFavorite.value;
  
  /// Observable para status de favorito
  RxBool get isFavoriteObs => _isFavorite;

  /// Carrega o status de favorito para uma praga
  Future<void> loadFavoriteStatus(String pragaId) async {
    try {
      _isFavorite.value = await _localStorageService.isFavorite('favPragas', pragaId);
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.warning,
        'Erro ao carregar status de favorito',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      _isFavorite.value = false;
    }
  }

  /// Alterna o status de favorito
  Future<bool> toggleFavorite(String pragaId) async {
    try {
      
      // Verificar status atual antes da mudança
      final statusAntes = await _localStorageService.isFavorite('favPragas', pragaId);
      
      _isFavorite.value = await _localStorageService.setFavorite('favPragas', pragaId);
      
      
      // Verificar lista completa de favoritos após mudança
      final allFavorites = await _localStorageService.getFavorites('favPragas');
      
      _errorHandler.log(
        LogLevel.info,
        'Status de favorito alterado',
        metadata: {
          'pragaId': pragaId,
          'newStatus': _isFavorite.value,
        },
      );
      
      return _isFavorite.value;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao alternar favorito',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return _isFavorite.value;
    }
  }

  /// Define manualmente o status de favorito
  void setFavoriteStatus(bool status) {
    _isFavorite.value = status;
  }

  /// Verifica se uma praga está nos favoritos
  Future<bool> checkIsFavorite(String pragaId) async {
    try {
      return await _localStorageService.isFavorite('favPragas', pragaId);
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.warning,
        'Erro ao verificar status de favorito',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }

  /// Adiciona uma praga aos favoritos
  Future<bool> addToFavorites(String pragaId) async {
    try {
      final newStatus = await _localStorageService.setFavorite('favPragas', pragaId);
      if (newStatus) {
        _isFavorite.value = true;
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao adicionar aos favoritos',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }

  /// Remove uma praga dos favoritos
  Future<bool> removeFromFavorites(String pragaId) async {
    try {
      final newStatus = await _localStorageService.setFavorite('favPragas', pragaId);
      if (!newStatus) {
        _isFavorite.value = false;
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao remover dos favoritos',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }


  /// Libera recursos
  void dispose() {
    _isFavorite.close();
  }
}
