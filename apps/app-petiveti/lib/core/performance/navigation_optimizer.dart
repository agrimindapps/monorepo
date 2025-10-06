import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

/// Sistema avançado de otimização de navegação e roteamento
class NavigationOptimizer {
  static final NavigationOptimizer _instance = NavigationOptimizer._internal();
  factory NavigationOptimizer() => _instance;
  NavigationOptimizer._internal();

  final Map<String, PreloadedRoute> _preloadedRoutes = {};
  final Map<String, NavigationMetrics> _routeMetrics = {};
  final List<String> _navigationHistory = [];
  
  static const int maxPreloadedRoutes = 5;
  static const int maxHistorySize = 50;

  /// Pré-carrega rotas baseado em padrões de navegação
  Future<void> preloadRoute(String routeName, Widget Function() builder) async {
    if (_preloadedRoutes.length >= maxPreloadedRoutes) {
      _clearOldestPreloadedRoute();
    }

    try {
      final widget = builder();
      _preloadedRoutes[routeName] = PreloadedRoute(
        routeName: routeName,
        widget: widget,
        preloadedAt: DateTime.now(),
      );
      
      log('Route preloaded: $routeName', name: 'NavigationOptimizer');
    } catch (e) {
      log('Error preloading route $routeName: $e', name: 'NavigationOptimizer');
    }
  }

  /// Navega usando rota pré-carregada se disponível
  Future<T?> optimizedPush<T>(
    BuildContext context,
    String routeName,
    Widget Function()? builder,
    {Object? arguments}
  ) async {
    final startTime = DateTime.now();
    
    Widget? preloadedWidget = _preloadedRoutes[routeName]?.widget;
    
    final route = MaterialPageRoute<T>(
      builder: (_) => preloadedWidget ?? (builder != null ? builder() : Container()),
      settings: RouteSettings(name: routeName, arguments: arguments),
    );

    _recordNavigation(routeName, startTime);
    
    final result = await Navigator.of(context).push(route);
    
    _updateNavigationMetrics(routeName, startTime);
    _preloadedRoutes.remove(routeName);
    _predictAndPreload();
    
    return result;
  }

  /// Sistema inteligente de predição de rotas
  void _predictAndPreload() {
    final predictions = _predictNextRoutes();
    
    for (final prediction in predictions.take(2)) {
      if (!_preloadedRoutes.containsKey(prediction.routeName)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _preloadPredictedRoute(prediction.routeName);
        });
      }
    }
  }

  List<RoutePrediction> _predictNextRoutes() {
    if (_navigationHistory.length < 2) return [];
    
    final predictions = <String, int>{};
    for (int i = 0; i < _navigationHistory.length - 1; i++) {
      final current = _navigationHistory[i];
      final next = _navigationHistory[i + 1];
      
      final key = '$current->$next';
      predictions[key] = (predictions[key] ?? 0) + 1;
    }
    final sortedPredictions = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedPredictions.map((entry) {
      final parts = entry.key.split('->');
      return RoutePrediction(
        routeName: parts[1],
        confidence: entry.value / _navigationHistory.length,
        frequency: entry.value,
      );
    }).toList();
  }

  void _preloadPredictedRoute(String routeName) {
    switch (routeName) {
      case '/animals':
        preloadRoute(routeName, () => _createAnimalsPage());
        break;
      case '/medications':
        preloadRoute(routeName, () => _createMedicationsPage());
        break;
      case '/calculators':
        preloadRoute(routeName, () => _createCalculatorsPage());
        break;
      default:
        break;
    }
  }

  /// Limpa cache de navegação
  void clearNavigationCache() {
    _preloadedRoutes.clear();
    _navigationHistory.clear();
    _routeMetrics.clear();
    log('Navigation cache cleared', name: 'NavigationOptimizer');
  }

  /// Obtém métricas de navegação
  NavigationReport getNavigationReport() {
    return NavigationReport(
      generatedAt: DateTime.now(),
      preloadedRoutes: _preloadedRoutes.length,
      routeMetrics: Map.from(_routeMetrics),
      mostUsedRoutes: _getMostUsedRoutes(),
      predictions: _predictNextRoutes(),
    );
  }

  void _recordNavigation(String routeName, DateTime timestamp) {
    _navigationHistory.add(routeName);
    
    if (_navigationHistory.length > maxHistorySize) {
      _navigationHistory.removeAt(0);
    }
  }

  void _updateNavigationMetrics(String routeName, DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    
    final metrics = _routeMetrics[routeName] ??= NavigationMetrics(
      routeName: routeName,
      navigations: 0,
      totalTime: Duration.zero,
      lastNavigation: DateTime.now(),
    );

    _routeMetrics[routeName] = NavigationMetrics(
      routeName: routeName,
      navigations: metrics.navigations + 1,
      totalTime: metrics.totalTime + duration,
      lastNavigation: DateTime.now(),
    );
  }

  void _clearOldestPreloadedRoute() {
    if (_preloadedRoutes.isEmpty) return;
    
    final entries = _preloadedRoutes.entries.toList()
      ..sort((a, b) => a.value.preloadedAt.compareTo(b.value.preloadedAt));
    
    _preloadedRoutes.remove(entries.first.key);
  }

  List<NavigationMetrics> _getMostUsedRoutes() {
    final metrics = _routeMetrics.values.toList()
      ..sort((a, b) => b.navigations.compareTo(a.navigations));
    
    return metrics.take(10).toList();
  }
  Widget _createAnimalsPage() => const Scaffold(body: Center(child: Text('Animals')));
  Widget _createMedicationsPage() => const Scaffold(body: Center(child: Text('Medications')));
  Widget _createCalculatorsPage() => const Scaffold(body: Center(child: Text('Calculators')));
}

/// Router otimizado customizado
class OptimizedRouter {
  static final Map<String, WidgetBuilder> _routes = {};
  static final Map<String, Widget> _cachedWidgets = {};
  OptimizedRouter._();
  
  static void registerRoute(String name, WidgetBuilder builder) {
    _routes[name] = builder;
  }

  static Future<T?> push<T>(BuildContext context, String routeName, {Object? arguments}) {
    final optimizer = NavigationOptimizer();
    
    final builder = _routes[routeName];
    return optimizer.optimizedPush<T>(
      context,
      routeName,
      builder != null ? () => builder(context) : null,
      arguments: arguments,
    );
  }

  static Widget? getCachedWidget(String routeName) {
    return _cachedWidgets[routeName];
  }

  static void cacheWidget(String routeName, Widget widget) {
    if (_cachedWidgets.length > 10) {
      final firstKey = _cachedWidgets.keys.first;
      _cachedWidgets.remove(firstKey);
    }
    _cachedWidgets[routeName] = widget;
  }
}

/// Widget que otimiza transições entre páginas
class OptimizedPageRoute<T> extends MaterialPageRoute<T> {
  @override
  final Duration transitionDuration;
  final bool enablePredictiveBack;

  OptimizedPageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.enablePredictiveBack = true,
  });

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/// Classes de apoio
class PreloadedRoute {
  final String routeName;
  final Widget widget;
  final DateTime preloadedAt;

  const PreloadedRoute({
    required this.routeName,
    required this.widget,
    required this.preloadedAt,
  });
}

class NavigationMetrics {
  final String routeName;
  final int navigations;
  final Duration totalTime;
  final DateTime lastNavigation;

  const NavigationMetrics({
    required this.routeName,
    required this.navigations,
    required this.totalTime,
    required this.lastNavigation,
  });

  Duration get averageTime => 
      navigations > 0 ? Duration(milliseconds: totalTime.inMilliseconds ~/ navigations) : Duration.zero;
}

class RoutePrediction {
  final String routeName;
  final double confidence;
  final int frequency;

  const RoutePrediction({
    required this.routeName,
    required this.confidence,
    required this.frequency,
  });
}

class NavigationReport {
  final DateTime generatedAt;
  final int preloadedRoutes;
  final Map<String, NavigationMetrics> routeMetrics;
  final List<NavigationMetrics> mostUsedRoutes;
  final List<RoutePrediction> predictions;

  const NavigationReport({
    required this.generatedAt,
    required this.preloadedRoutes,
    required this.routeMetrics,
    required this.mostUsedRoutes,
    required this.predictions,
  });
}