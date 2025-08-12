/// Utilitário para gerenciar múltiplas stream subscriptions e prevenir memory leaks
library;

// Dart imports:
import 'dart:async';

/// Helper class para gerenciar múltiplas StreamSubscriptions
/// Facilita o dispose adequado para prevenir vazamentos de memória
class CompositeSubscription {
  final List<StreamSubscription> _subscriptions = [];

  /// Adiciona uma subscription ao composite
  void add(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Adiciona uma subscription criada a partir de um stream.listen()
  StreamSubscription<T> addListen<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    add(subscription);
    return subscription;
  }

  /// Cancela todas as subscriptions e limpa a lista
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Cancela uma subscription específica e a remove da lista
  void cancel(StreamSubscription subscription) {
    subscription.cancel();
    _subscriptions.remove(subscription);
  }

  /// Remove uma subscription da lista sem cancelá-la
  void remove(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  /// Retorna o número de subscriptions ativas
  int get length => _subscriptions.length;

  /// Verifica se há subscriptions ativas
  bool get isEmpty => _subscriptions.isEmpty;

  /// Verifica se há subscriptions ativas
  bool get isNotEmpty => _subscriptions.isNotEmpty;

  /// Cancela todas as subscriptions (alias para dispose)
  void clear() => dispose();
}

/// Extensão para facilitar o uso do CompositeSubscription
extension StreamExtension<T> on Stream<T> {
  /// Listen com CompositeSubscription automático
  StreamSubscription<T> listenWithComposite(
    CompositeSubscription composite,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return composite.addListen(
      this,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// Mixin para classes que precisam gerenciar subscriptions
mixin SubscriptionManagerMixin {
  final CompositeSubscription _subscriptions = CompositeSubscription();

  /// Getter para acessar o composite subscription
  CompositeSubscription get subscriptions => _subscriptions;

  /// Adiciona uma subscription ao manager
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Listen que automaticamente adiciona ao composite
  StreamSubscription<T> listenTo<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _subscriptions.addListen(
      stream,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Deve ser chamado no dispose para cancelar todas as subscriptions
  void disposeSubscriptions() {
    _subscriptions.dispose();
  }
}
