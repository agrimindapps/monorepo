// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Utilitário para gerenciar múltiplas StreamSubscriptions
/// 
/// Permite agrupar várias subscriptions e cancelar todas de uma vez,
/// evitando vazamentos de memória e simplificando o cleanup.
/// 
/// Exemplo de uso:
/// ```dart
/// class MyController extends GetxController {
///   final CompositeSubscription _subscriptions = CompositeSubscription();
///   
///   @override
///   void onInit() {
///     super.onInit();
///     
///     // Adiciona múltiplas subscriptions
///     _subscriptions.add(stream1.listen(handler1));
///     _subscriptions.add(stream2.listen(handler2));
///     _subscriptions.add(stream3.listen(handler3));
///   }
///   
///   @override
///   void onClose() {
///     _subscriptions.dispose(); // Cancela todas automaticamente
///     super.onClose();
///   }
/// }
/// ```
class CompositeSubscription {
  static const String _logTag = '[COMPOSITE_SUBSCRIPTION]';
  
  final Set<StreamSubscription> _subscriptions = <StreamSubscription>{};
  bool _isDisposed = false;
  final Stopwatch _lifecycleStopwatch = Stopwatch();
  
  /// Indica se este composite foi descartado
  bool get isDisposed => _isDisposed;
  
  /// Número de subscriptions ativas
  int get length => _subscriptions.length;
  
  /// Indica se não há subscriptions
  bool get isEmpty => _subscriptions.isEmpty;
  
  /// Indica se há subscriptions
  bool get isNotEmpty => _subscriptions.isNotEmpty;
  
  /// Tempo desde a criação
  Duration get uptime => _lifecycleStopwatch.elapsed;
  
  /// Construtor
  CompositeSubscription() {
    _lifecycleStopwatch.start();
    _logDebug('CompositeSubscription created');
  }
  
  /// Adiciona uma subscription ao composite
  /// 
  /// A subscription será automaticamente cancelada quando dispose() for chamado.
  /// Retorna a própria subscription para convenience.
  T add<T extends StreamSubscription>(T subscription) {
    _ensureNotDisposed('add');
    
    if (_subscriptions.add(subscription)) {
      _logDebug('Subscription added (total: ${_subscriptions.length})');
    }
    
    return subscription;
  }
  
  /// Remove uma subscription do composite sem cancelá-la
  /// 
  /// Útil quando você quer gerenciar o lifecycle da subscription manualmente
  /// mas ainda quer removê-la do composite.
  bool remove(StreamSubscription subscription) {
    _ensureNotDisposed('remove');
    
    final removed = _subscriptions.remove(subscription);
    if (removed) {
      _logDebug('Subscription removed (total: ${_subscriptions.length})');
    }
    
    return removed;
  }
  
  /// Cancela e remove uma subscription específica
  /// 
  /// Retorna true se a subscription foi encontrada e cancelada.
  Future<bool> cancel(StreamSubscription subscription) async {
    _ensureNotDisposed('cancel');
    
    if (_subscriptions.remove(subscription)) {
      try {
        await subscription.cancel();
        _logDebug('Subscription canceled and removed (total: ${_subscriptions.length})');
        return true;
      } catch (e) {
        _logError('Error canceling subscription: $e');
        return false;
      }
    }
    
    return false;
  }
  
  /// Cancela todas as subscriptions
  /// 
  /// Este método pode ser chamado múltiplas vezes sem problemas.
  /// Retorna o número de subscriptions que foram canceladas com sucesso.
  Future<int> cancelAll() async {
    if (_isDisposed) {
      _logDebug('cancelAll() called on already disposed CompositeSubscription');
      return 0;
    }
    
    final subscriptionsToCancel = List<StreamSubscription>.from(_subscriptions);
    _subscriptions.clear();
    
    int canceledCount = 0;
    final cancelStopwatch = Stopwatch()..start();
    
    for (final subscription in subscriptionsToCancel) {
      try {
        await subscription.cancel();
        canceledCount++;
      } catch (e) {
        _logError('Error canceling subscription during cancelAll: $e');
      }
    }
    
    cancelStopwatch.stop();
    _logDebug('cancelAll() completed: $canceledCount/${subscriptionsToCancel.length} canceled in ${cancelStopwatch.elapsedMilliseconds}ms');
    
    return canceledCount;
  }
  
  /// Descarta o composite, cancelando todas as subscriptions
  /// 
  /// Após chamar dispose(), este composite não pode mais ser usado.
  /// Este método é idempotente - pode ser chamado múltiplas vezes.
  Future<void> dispose() async {
    if (_isDisposed) {
      _logDebug('dispose() called on already disposed CompositeSubscription');
      return;
    }
    
    _lifecycleStopwatch.stop();
    final initialCount = _subscriptions.length;
    
    final canceledCount = await cancelAll();
    
    _isDisposed = true;
    
    _logDebug('CompositeSubscription disposed: $canceledCount/$initialCount subscriptions canceled, uptime: ${uptime.inMilliseconds}ms');
    
    // Leak detection em debug mode
    if (kDebugMode && canceledCount < initialCount) {
      _logError('POTENTIAL LEAK: ${initialCount - canceledCount} subscriptions failed to cancel during dispose');
    }
  }
  
  /// Retorna informações de diagnóstico
  Map<String, dynamic> getDiagnostics() {
    return {
      'subscriptionsCount': _subscriptions.length,
      'isDisposed': _isDisposed,
      'uptimeMs': uptime.inMilliseconds,
      'isEmpty': isEmpty,
      'isNotEmpty': isNotEmpty,
    };
  }
  
  /// Cria um novo CompositeSubscription a partir de uma lista de subscriptions
  static CompositeSubscription from(Iterable<StreamSubscription> subscriptions) {
    final composite = CompositeSubscription();
    for (final subscription in subscriptions) {
      composite.add(subscription);
    }
    return composite;
  }
  
  /// Método para adicionar subscription (sintaxe mais limpa que add)
  void operator <<(StreamSubscription subscription) {
    add(subscription);
  }
  
  // ========== MÉTODOS HELPER ==========
  
  /// Garante que o composite não foi descartado
  void _ensureNotDisposed(String operation) {
    if (_isDisposed) {
      throw StateError('Cannot perform $operation on disposed CompositeSubscription');
    }
  }
  
  /// Log de debug
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('$_logTag $message');
    }
  }
  
  /// Log de erro
  void _logError(String message) {
    if (kDebugMode) {
      debugPrint('$_logTag [ERROR] $message');
    }
  }
}

/// Extensão para facilitar o uso de CompositeSubscription
extension StreamSubscriptionExtension on StreamSubscription {
  /// Adiciona esta subscription a um CompositeSubscription
  StreamSubscription addTo(CompositeSubscription composite) {
    return composite.add(this);
  }
}