import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/repositories/favoritos_hive_repository.dart';
import '../events/favorito_event_bus.dart';
import '../events/favorito_events.dart';
import '../utils/favorito_retry_manager.dart';

/// Provider Universal para eliminar duplicação de lógica entre providers
/// Centraliza toda a lógica de favoritos em um local único e reutilizável
abstract class UniversalFavoritoProvider extends ChangeNotifier with FavoritoEventListener {
  final FavoritosHiveRepository _repository;
  final String _tipo;

  // Estado comum
  bool _isFavorited = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _itemData;
  String? _itemId;

  UniversalFavoritoProvider({
    required FavoritosHiveRepository repository,
    required String tipo,
  }) : _repository = repository,
       _tipo = tipo {
    _setupEventListeners();
  }

  // Getters públicos
  bool get isFavorited => _isFavorited;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get itemData => _itemData;
  String? get itemId => _itemId;
  String get tipo => _tipo;

  /// Configurar escuta de eventos para sincronização automática
  void _setupEventListeners() {
    // Escutar mudanças no tipo específico
    listenToFavoritoType(_tipo, (event) {
      _handleFavoritoEvent(event);
    });

    // Escutar erros globais
    listenToFavoritoEvents<FavoritoError>((error) {
      if (error.tipo == _tipo && error.itemId == _itemId) {
        _setError(error.errorMessage);
      }
    });
  }

  /// Processar eventos de favorito recebidos
  void _handleFavoritoEvent(FavoritoEvent event) {
    if (event.itemId != _itemId) return;

    switch (event.runtimeType) {
      case FavoritoAdded:
        _setFavorited(true);
        break;
      case FavoritoRemoved:
        _setFavorited(false);
        break;
      case FavoritosCleared:
        _setFavorited(false);
        break;
    }
  }

  /// Inicializar com dados do item
  Future<void> initialize(String itemId, Map<String, dynamic>? itemData) async {
    _itemId = itemId;
    _itemData = itemData;
    
    await _loadFavoritoState();
  }

  /// Recarregar estado de favorito com retry
  Future<void> _loadFavoritoState() async {
    if (_itemId == null) return;

    try {
      _setLoading(true);
      
      final isFav = await FavoritoRetryManager.retryReadOperation<bool>(
        () => _repository.isFavoritoAsync(_tipo, _itemId!),
        _tipo,
        _itemId!,
      );
      
      _setFavorited(isFav ?? false);
      _clearError();
    } catch (e) {
      final customError = customizeErrorMessage('Erro ao carregar estado: $e');
      _setError(customError);
    } finally {
      _setLoading(false);
    }
  }

  /// Alternar estado de favorito com UI otimista e recuperação
  Future<bool> toggleFavorito() async {
    if (_itemId == null) {
      _setError('Item ID não definido');
      return false;
    }

    if (_isLoading) {
      debugPrint('⚠️ Toggle ignorado - operação em andamento');
      return false;
    }

    // Validação específica do tipo
    final canProceed = await validateBeforeToggle();
    if (!canProceed) {
      return false;
    }

    final wasAlreadyFavorited = _isFavorited;
    
    // UI Otimista - atualiza imediatamente
    _setFavorited(!wasAlreadyFavorited);
    _triggerHapticFeedback();

    try {
      _setLoading(true);
      _clearError();

      final itemDataToSave = prepareItemData();
      
      // Operação crítica com retry robusto
      final operation = FavoritoCriticalOperation(
        name: wasAlreadyFavorited ? 'remover_favorito' : 'adicionar_favorito',
        tipo: _tipo,
        itemId: _itemId!,
      );
      
      final success = await operation.execute<bool>(() async {
        return await FavoritoRetryManager.retryFavoritoOperation(
          () => wasAlreadyFavorited
              ? _repository.removeFavorito(_tipo, _itemId!)
              : _repository.addFavorito(_tipo, _itemId!, itemDataToSave),
          _tipo,
          _itemId!,
          wasAlreadyFavorited ? 'remover' : 'adicionar',
        );
      });

      if (success) {
        // Hook para lógica específica do tipo
        await onToggleSuccess(!wasAlreadyFavorited);
        
        // Dispara evento para sincronização global
        if (wasAlreadyFavorited) {
          FavoritoEventBus.instance.fireRemoved(_tipo, _itemId!);
        } else {
          FavoritoEventBus.instance.fireAdded(_tipo, _itemId!, itemData: itemDataToSave);
        }
        return true;
      } else {
        // Falha - reverte estado
        _setFavorited(wasAlreadyFavorited);
        _setError('Falha ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito');
        return false;
      }
    } catch (e) {
      // Erro - reverte estado
      _setFavorited(wasAlreadyFavorited);
      
      final errorMsg = customizeErrorMessage(
        'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito: $e'
      );
      _setError(errorMsg);
      
      // Dispara evento de erro
      FavoritoEventBus.instance.fireError(_tipo, _itemId!, errorMsg, originalError: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Adicionar explicitamente aos favoritos
  Future<bool> addToFavorites() async {
    if (_isFavorited) return true;
    return await toggleFavorito();
  }

  /// Remover explicitamente dos favoritos
  Future<bool> removeFromFavorites() async {
    if (!_isFavorited) return true;
    return await toggleFavorito();
  }

  /// Verificar se é favorito (forçar reload)
  Future<bool> checkIsFavorite() async {
    await _loadFavoritoState();
    return _isFavorited;
  }

  /// Limpar erro
  void clearError() {
    _clearError();
  }

  /// Feedback háptico ao alternar favorito
  void _triggerHapticFeedback() {
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.lightImpact();
    }
  }

  // === MÉTODOS HELPER PROTEGIDOS ===

  @protected
  void setFavorited(bool favorited) {
    if (_isFavorited != favorited) {
      _isFavorited = favorited;
      notifyListeners();
    }
  }

  @protected
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @protected
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
    debugPrint('❌ [UniversalFavoritoProvider] $_tipo: $error');
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // === MÉTODOS HELPER PRIVADOS ===

  void _setFavorited(bool favorited) => setFavorited(favorited);
  void _setLoading(bool loading) => setLoading(loading);
  void _setError(String error) => setError(error);

  @override
  void dispose() {
    disposeEventListeners();
    super.dispose();
  }

  // === MÉTODOS ABSTRATOS PARA ESPECIALIZAÇÃO ===

  /// Hook para validações específicas do tipo antes do toggle
  Future<bool> validateBeforeToggle() async => true;

  /// Hook para lógica adicional após toggle bem-sucedido
  Future<void> onToggleSuccess(bool wasAdded) async {}

  /// Hook para customizar dados do item
  Map<String, dynamic> prepareItemData() => _itemData ?? {};

  /// Hook para customizar mensagem de erro
  String customizeErrorMessage(String originalError) => originalError;
}

/// Estados de favorito para UI
enum FavoritoState {
  initial,
  loading,
  favorited,
  notFavorited,
  error,
}

/// Extension para facilitar uso na UI
extension UniversalFavoritoProviderUI on UniversalFavoritoProvider {
  FavoritoState get state {
    if (isLoading) return FavoritoState.loading;
    if (errorMessage != null) return FavoritoState.error;
    return isFavorited ? FavoritoState.favorited : FavoritoState.notFavorited;
  }

  /// Ícone baseado no estado
  IconData get favoriteIcon {
    return isFavorited ? Icons.favorite : Icons.favorite_border;
  }

  /// Cor baseada no estado  
  Color get favoriteColor {
    return isFavorited ? Colors.red : Colors.grey;
  }

  /// Tooltip baseado no estado
  String get favoriteTooltip {
    return isFavorited ? 'Remover dos favoritos' : 'Adicionar aos favoritos';
  }

  /// Mensagem de sucesso baseada no estado
  String get successMessage {
    return isFavorited ? 'Adicionado aos favoritos' : 'Removido dos favoritos';
  }
}