// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../debug/memory_leak_detector.dart';
import '../utils/composite_subscription.dart';

/// Mixin para tracking automático de recursos e cleanup adequado
/// 
/// Este mixin permite que controllers automáticamente registrem recursos
/// que precisam ser limpos (timers, subscriptions, listeners) e garante
/// que todos sejam adequadamente descartados no onClose().
/// 
/// Inclui leak detection em debug mode para identificar vazamentos.
/// 
/// Exemplo de uso:
/// ```dart
/// class MyController extends GetxController with DisposableMixin {
///   Timer? timer;
///   StreamSubscription? subscription;
///   
///   @override
///   void onInit() {
///     super.onInit();
///     
///     // Registra recursos automaticamente
///     timer = registerTimer(Timer.periodic(Duration(seconds: 1), (_) {}));
///     subscription = registerSubscription(stream.listen((_) {}));
///   }
/// }
/// ```
mixin DisposableMixin on GetxController {
  static const String _logTag = '[DISPOSABLE_MIXIN]';
  
  // Collections para tracking de recursos
  final Set<Timer> _timers = <Timer>{};
  final Set<StreamSubscription> _subscriptions = <StreamSubscription>{};
  final Set<AnimationController> _animationControllers = <AnimationController>{};
  final Set<ScrollController> _scrollControllers = <ScrollController>{};
  final Set<TextEditingController> _textControllers = <TextEditingController>{};
  final Set<FocusNode> _focusNodes = <FocusNode>{};
  final Set<Worker> _workers = <Worker>{};
  final Set<VoidCallback> _customDisposables = <VoidCallback>{};
  
  // Controle de estado
  bool _isDisposed = false;
  final Stopwatch _lifecycleStopwatch = Stopwatch();
  
  /// Indica se este controller foi descartado
  bool get isDisposed => _isDisposed;
  
  /// Tempo desde a criação do controller
  Duration get uptime => _lifecycleStopwatch.elapsed;
  
  @override
  void onInit() {
    super.onInit();
    _lifecycleStopwatch.start();
    
    // Registra no detector de vazamentos se habilitado
    if (kDebugMode) {
      MemoryLeakDetector.instance.registerController(this);
    }
    
    _logResourceTracking('Controller initialized');
  }
  
  // ========== MÉTODOS DE REGISTRO ==========
  
  /// Registra um Timer para cleanup automático
  T registerTimer<T extends Timer>(T timer) {
    _ensureNotDisposed('registerTimer');
    _timers.add(timer);
    _logResourceTracking('Timer registered: ${timer.runtimeType}');
    return timer;
  }
  
  /// Registra uma StreamSubscription para cleanup automático
  T registerSubscription<T extends StreamSubscription>(T subscription) {
    _ensureNotDisposed('registerSubscription');
    _subscriptions.add(subscription);
    _logResourceTracking('Subscription registered: ${subscription.runtimeType}');
    return subscription;
  }
  
  /// Registra um AnimationController para cleanup automático
  T registerAnimationController<T extends AnimationController>(T controller) {
    _ensureNotDisposed('registerAnimationController');
    _animationControllers.add(controller);
    _logResourceTracking('AnimationController registered');
    return controller;
  }
  
  /// Registra um ScrollController para cleanup automático
  T registerScrollController<T extends ScrollController>(T controller) {
    _ensureNotDisposed('registerScrollController');
    _scrollControllers.add(controller);
    _logResourceTracking('ScrollController registered');
    return controller;
  }
  
  /// Registra um TextEditingController para cleanup automático
  T registerTextController<T extends TextEditingController>(T controller) {
    _ensureNotDisposed('registerTextController');
    _textControllers.add(controller);
    _logResourceTracking('TextEditingController registered');
    return controller;
  }
  
  /// Registra um FocusNode para cleanup automático
  T registerFocusNode<T extends FocusNode>(T focusNode) {
    _ensureNotDisposed('registerFocusNode');
    _focusNodes.add(focusNode);
    _logResourceTracking('FocusNode registered');
    return focusNode;
  }
  
  /// Registra um GetX Worker para cleanup automático
  T registerWorker<T extends Worker>(T worker) {
    _ensureNotDisposed('registerWorker');
    _workers.add(worker);
    _logResourceTracking('Worker registered: ${worker.runtimeType}');
    return worker;
  }
  
  /// Registra uma função de cleanup customizada
  void registerCustomDisposable(VoidCallback disposer) {
    _ensureNotDisposed('registerCustomDisposable');
    _customDisposables.add(disposer);
    _logResourceTracking('Custom disposable registered');
  }
  
  /// Cria um CompositeSubscription que será automaticamente descartado
  CompositeSubscription createCompositeSubscription() {
    _ensureNotDisposed('createCompositeSubscription');
    final composite = CompositeSubscription();
    registerCustomDisposable(() => composite.dispose());
    _logResourceTracking('CompositeSubscription created and registered');
    return composite;
  }
  
  // ========== MÉTODOS DE REMOÇÃO MANUAL ==========
  
  /// Remove um Timer do tracking (útil quando limpo manualmente)
  void unregisterTimer(Timer timer) {
    if (_timers.remove(timer)) {
      _logResourceTracking('Timer unregistered manually');
    }
  }
  
  /// Remove uma StreamSubscription do tracking
  void unregisterSubscription(StreamSubscription subscription) {
    if (_subscriptions.remove(subscription)) {
      _logResourceTracking('Subscription unregistered manually');
    }
  }
  
  /// Remove um AnimationController do tracking
  void unregisterAnimationController(AnimationController controller) {
    if (_animationControllers.remove(controller)) {
      _logResourceTracking('AnimationController unregistered manually');
    }
  }
  
  /// Remove outros tipos de controllers do tracking
  void unregisterScrollController(ScrollController controller) {
    _scrollControllers.remove(controller);
  }
  
  void unregisterTextController(TextEditingController controller) {
    _textControllers.remove(controller);
  }
  
  void unregisterFocusNode(FocusNode focusNode) {
    _focusNodes.remove(focusNode);
  }
  
  void unregisterWorker(Worker worker) {
    _workers.remove(worker);
  }
  
  // ========== MÉTODOS DE CONSULTA ==========
  
  /// Retorna estatísticas dos recursos registrados
  Map<String, int> getResourceStats() {
    return {
      'timers': _timers.length,
      'subscriptions': _subscriptions.length,
      'animationControllers': _animationControllers.length,
      'scrollControllers': _scrollControllers.length,
      'textControllers': _textControllers.length,
      'focusNodes': _focusNodes.length,
      'workers': _workers.length,
      'customDisposables': _customDisposables.length,
      'totalResources': getTotalResourcesCount(),
    };
  }
  
  /// Retorna o número total de recursos registrados
  int getTotalResourcesCount() {
    return _timers.length +
        _subscriptions.length +
        _animationControllers.length +
        _scrollControllers.length +
        _textControllers.length +
        _focusNodes.length +
        _workers.length +
        _customDisposables.length;
  }
  
  /// Verifica se há recursos não limpos (para debug)
  bool hasActiveResources() {
    return getTotalResourcesCount() > 0;
  }
  
  // ========== CLEANUP AUTOMÁTICO ==========
  
  @override
  void onClose() {
    // Remove do detector de vazamentos antes do cleanup
    if (kDebugMode) {
      MemoryLeakDetector.instance.unregisterController(this);
    }
    
    _performCleanup();
    super.onClose();
  }
  
  /// Executa cleanup de todos os recursos registrados
  void _performCleanup() {
    if (_isDisposed) {
      _logResourceTracking('WARNING: Duplicate cleanup call detected');
      return;
    }
    
    _lifecycleStopwatch.stop();
    final resourceStats = getResourceStats();
    _logResourceTracking('Starting cleanup - Resources: $resourceStats');
    
    int cleanedCount = 0;
    final cleanupStopwatch = Stopwatch()..start();
    
    // Cleanup timers
    for (final timer in List.from(_timers)) {
      try {
        if (timer.isActive) {
          timer.cancel();
          cleanedCount++;
        }
      } catch (e) {
        _logError('Error canceling timer: $e');
      }
    }
    _timers.clear();
    
    // Cleanup subscriptions
    for (final subscription in List.from(_subscriptions)) {
      try {
        subscription.cancel();
        cleanedCount++;
      } catch (e) {
        _logError('Error canceling subscription: $e');
      }
    }
    _subscriptions.clear();
    
    // Cleanup animation controllers
    for (final controller in List.from(_animationControllers)) {
      try {
        controller.dispose();
        cleanedCount++;
      } catch (e) {
        _logError('Error disposing animation controller: $e');
      }
    }
    _animationControllers.clear();
    
    // Cleanup scroll controllers
    for (final controller in List.from(_scrollControllers)) {
      try {
        controller.dispose();
        cleanedCount++;
      } catch (e) {
        _logError('Error disposing scroll controller: $e');
      }
    }
    _scrollControllers.clear();
    
    // Cleanup text controllers
    for (final controller in List.from(_textControllers)) {
      try {
        controller.dispose();
        cleanedCount++;
      } catch (e) {
        _logError('Error disposing text controller: $e');
      }
    }
    _textControllers.clear();
    
    // Cleanup focus nodes
    for (final focusNode in List.from(_focusNodes)) {
      try {
        focusNode.dispose();
        cleanedCount++;
      } catch (e) {
        _logError('Error disposing focus node: $e');
      }
    }
    _focusNodes.clear();
    
    // Cleanup workers
    for (final worker in List.from(_workers)) {
      try {
        worker.dispose();
        cleanedCount++;
      } catch (e) {
        _logError('Error disposing worker: $e');
      }
    }
    _workers.clear();
    
    // Cleanup custom disposables
    for (final disposer in List.from(_customDisposables)) {
      try {
        disposer();
        cleanedCount++;
      } catch (e) {
        _logError('Error calling custom disposer: $e');
      }
    }
    _customDisposables.clear();
    
    cleanupStopwatch.stop();
    
    // Leak detection em debug mode
    if (kDebugMode) {
      _performLeakDetection(resourceStats, cleanedCount, cleanupStopwatch.elapsed);
    }
    
    _isDisposed = true;
    _logResourceTracking('Cleanup completed - Cleaned $cleanedCount resources in ${cleanupStopwatch.elapsedMilliseconds}ms');
  }
  
  // ========== LEAK DETECTION ==========
  
  /// Executa verificação de vazamentos de memória
  void _performLeakDetection(Map<String, int> resourceStats, int cleanedCount, Duration cleanupTime) {
    final totalResources = resourceStats['totalResources']!;
    
    // Verifica se todos os recursos foram limpos
    if (cleanedCount < totalResources) {
      final missedResources = totalResources - cleanedCount;
      _logError('MEMORY LEAK DETECTED: $missedResources resources not properly cleaned');
      
      // Em modo debug, força um assert para chamar atenção do desenvolvedor
      assert(false, 'Memory leak detected in $runtimeType: $missedResources resources not cleaned');
    }
    
    // Warning para cleanup muito lento
    if (cleanupTime.inMilliseconds > 100) {
      _logResourceTracking('WARNING: Cleanup took ${cleanupTime.inMilliseconds}ms - Consider optimizing');
    }
    
    // Log detalhado dos recursos
    final leakDetails = StringBuffer();
    leakDetails.writeln('LEAK DETECTION REPORT for $runtimeType:');
    leakDetails.writeln('  Controller uptime: ${uptime.inMilliseconds}ms');
    leakDetails.writeln('  Resources registered: $totalResources');
    leakDetails.writeln('  Resources cleaned: $cleanedCount');
    leakDetails.writeln('  Cleanup time: ${cleanupTime.inMilliseconds}ms');
    
    if (totalResources > 0) {
      leakDetails.writeln('  Resource breakdown:');
      resourceStats.forEach((type, count) {
        if (count > 0 && type != 'totalResources') {
          leakDetails.writeln('    - $type: $count');
        }
      });
    }
    
    _logResourceTracking(leakDetails.toString());
  }
  
  // ========== MÉTODOS HELPER ==========
  
  /// Garante que o controller não foi descartado
  void _ensureNotDisposed(String operation) {
    if (_isDisposed) {
      throw StateError('Cannot perform $operation on disposed controller $runtimeType');
    }
  }
  
  /// Log específico para tracking de recursos
  void _logResourceTracking(String message) {
    if (kDebugMode) {
      debugPrint('$_logTag [$runtimeType] $message');
    }
  }
  
  /// Log de erros
  void _logError(String message) {
    if (kDebugMode) {
      debugPrint('$_logTag [ERROR] [$runtimeType] $message');
    }
    // Em produção, poderia enviar para crash reporting
  }
}