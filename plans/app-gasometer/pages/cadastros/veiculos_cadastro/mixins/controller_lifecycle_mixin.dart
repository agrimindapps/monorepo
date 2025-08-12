// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

/// Mixin para padronizar lifecycle e cleanup de controllers GetX
///
/// Fornece funcionalidades comuns para:
/// - Gestão de workers e subscriptions
/// - Cleanup automático de recursos
/// - Sincronização de estados
/// - Prevenção de vazamentos de memória
mixin ControllerLifecycleMixin on GetxController {
  // Listas para tracking de recursos que precisam de cleanup
  final List<Worker> _workers = [];
  final List<StreamSubscription> _subscriptions = [];
  final List<RxInterface> _rxVariables = [];

  /// Registra um worker para cleanup automático
  T registerWorker<T extends Worker>(T worker) {
    _workers.add(worker);
    return worker;
  }

  /// Registra uma subscription para cleanup automático
  StreamSubscription<T> registerSubscription<T>(
      StreamSubscription<T> subscription) {
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Registra uma variável reativa para cleanup automático
  T registerRx<T extends RxInterface>(T rx) {
    _rxVariables.add(rx);
    return rx;
  }

  /// Cria um debounced worker com registro automático
  Worker registerDebouncedWorker<T>(
    RxInterface<T> observable,
    Function(T value) callback, {
    Duration time = const Duration(milliseconds: 500),
  }) {
    return registerWorker(
      debounce<T>(observable, callback, time: time),
    );
  }

  /// Cria um ever worker com registro automático
  Worker registerEverWorker<T>(
    RxInterface<T> observable,
    Function(T value) callback,
  ) {
    return registerWorker(
      ever<T>(observable, callback),
    );
  }

  /// Cria um once worker com registro automático
  Worker registerOnceWorker<T>(
    RxInterface<T> observable,
    Function(T value) callback,
  ) {
    return registerWorker(
      once<T>(observable, callback),
    );
  }

  /// Inicialização segura de dependências
  T safeFindDependency<T>({
    String? tag,
    String? errorMessage,
  }) {
    try {
      return Get.find<T>(tag: tag);
    } catch (e) {
      final message = errorMessage ??
          'Dependency ${T.toString()} not found. Make sure it\'s properly registered in bindings.';

      throw DependencyNotFoundException(
        dependencyType: T.toString(),
        originalError: e,
        message: message,
      );
    }
  }

  /// Verifica se uma dependência está disponível
  bool isDependencyAvailable<T>({String? tag}) {
    return Get.isRegistered<T>(tag: tag);
  }

  /// Aguarda uma dependência ficar disponível (com timeout)
  Future<T> waitForDependency<T>({
    String? tag,
    Duration timeout = const Duration(seconds: 5),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (isDependencyAvailable<T>(tag: tag)) {
        return safeFindDependency<T>(tag: tag);
      }
      await Future.delayed(checkInterval);
    }

    throw TimeoutException(
      'Dependency ${T.toString()} not available within timeout of ${timeout.inMilliseconds}ms',
      timeout,
    );
  }

  /// Método de inicialização que deve ser chamado por subclasses
  void initializeController() {
    onInit();
  }

  /// Override do onClose para cleanup automático
  @override
  void onClose() {
    _performCleanup();
    super.onClose();
  }

  /// Realiza cleanup de todos os recursos registrados
  void _performCleanup() {
    // Dispose workers
    for (final worker in _workers) {
      try {
        worker.dispose();
      } catch (e) {
        _logCleanupError('Worker', e);
      }
    }
    _workers.clear();

    // Cancel subscriptions
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        _logCleanupError('Subscription', e);
      }
    }
    _subscriptions.clear();

    // Close reactive variables
    for (final rx in _rxVariables) {
      try {
        rx.close();
      } catch (e) {
        _logCleanupError('RxVariable', e);
      }
    }
    _rxVariables.clear();
  }

  /// Log de erros durante cleanup (não deve quebrar o processo)
  void _logCleanupError(String resourceType, dynamic error) {
    // Em produção, use um logging framework apropriado
    debugPrint(
        'Warning: Failed to cleanup $resourceType in ${runtimeType.toString()}: $error');
  }

  /// Helper para update seguro com verificação de ciclo de vida
  void safeUpdate([List<Object>? ids]) {
    if (!isClosed) {
      update(ids);
    }
  }

  /// Helper para update com debounce automático
  Timer? _updateTimer;
  void debouncedUpdate([
    List<Object>? ids,
    Duration delay = const Duration(milliseconds: 100),
  ]) {
    _updateTimer?.cancel();
    _updateTimer = Timer(delay, () {
      if (!isClosed) {
        update(ids);
      }
    });
  }

  /// Diagnóstico do estado do controller
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'controllerType': runtimeType.toString(),
      'isClosed': isClosed,
      'workersCount': _workers.length,
      'subscriptionsCount': _subscriptions.length,
      'rxVariablesCount': _rxVariables.length,
      'hasUpdateTimer': _updateTimer?.isActive ?? false,
    };
  }
}

/// Exception customizada para dependências não encontradas
class DependencyNotFoundException implements Exception {
  final String dependencyType;
  final dynamic originalError;
  final String message;

  const DependencyNotFoundException({
    required this.dependencyType,
    required this.originalError,
    required this.message,
  });

  @override
  String toString() {
    return 'DependencyNotFoundException: $message (Original: $originalError)';
  }
}
