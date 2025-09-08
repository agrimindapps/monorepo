/// Sistema de eventos para sincronização global de favoritos
/// Substitui o método estático frágil por um sistema robusto de notificações
abstract class FavoritoEvent {
  final String tipo;
  final String itemId;
  final DateTime timestamp;

  FavoritoEvent({
    required this.tipo,
    required this.itemId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'FavoritoEvent{tipo: $tipo, itemId: $itemId}';
}

/// Evento disparado quando um favorito é adicionado
class FavoritoAdded extends FavoritoEvent {
  final Map<String, dynamic>? itemData;

  FavoritoAdded({
    required super.tipo,
    required super.itemId,
    this.itemData,
    super.timestamp,
  });

  @override
  String toString() => 'FavoritoAdded{tipo: $tipo, itemId: $itemId}';
}

/// Evento disparado quando um favorito é removido
class FavoritoRemoved extends FavoritoEvent {
  FavoritoRemoved({
    required super.tipo,
    required super.itemId,
    super.timestamp,
  });

  @override
  String toString() => 'FavoritoRemoved{tipo: $tipo, itemId: $itemId}';
}

/// Evento disparado quando múltiplos favoritos são alterados
class FavoritosBatchChanged extends FavoritoEvent {
  final List<String> itemIds;
  final bool added;

  FavoritosBatchChanged({
    required super.tipo,
    required this.itemIds,
    required this.added,
    super.timestamp,
  }) : super(itemId: '');

  @override
  String toString() => 
      'FavoritosBatchChanged{tipo: $tipo, count: ${itemIds.length}, added: $added}';
}

/// Evento disparado quando favoritos de um tipo são limpos
class FavoritosCleared extends FavoritoEvent {
  FavoritosCleared({
    required super.tipo,
    super.timestamp,
  }) : super(itemId: '');

  @override
  String toString() => 'FavoritosCleared{tipo: $tipo}';
}

/// Evento disparado quando há erro nas operações de favorito
class FavoritoError extends FavoritoEvent {
  final String errorMessage;
  final dynamic originalError;

  FavoritoError({
    required super.tipo,
    required super.itemId,
    required this.errorMessage,
    this.originalError,
    super.timestamp,
  });

  @override
  String toString() => 'FavoritoError{tipo: $tipo, itemId: $itemId, error: $errorMessage}';
}