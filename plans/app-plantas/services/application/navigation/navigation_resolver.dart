// Dart imports:
// Removed unused import

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';
import 'navigation_interfaces.dart';

/// Implementação principal do resolvedor de navegação
///
/// Gerencia múltiplas estratégias de navegação e resolve o destino apropriado
/// baseado no contexto fornecido. Usa sistema de prioridades para escolher
/// a melhor estratégia disponível.
class NavigationResolver implements INavigationResolver {
  final List<INavigationStrategy> _strategies = [];
  final Map<String, int> _usageStats = {};
  final Map<String, Duration> _performanceStats = {};

  NavigationResolver() {
    debugPrint('🧭 [NavigationResolver] Inicializado');
  }

  @override
  AppDestination resolveDestination(NavigationContext context) {
    final stopwatch = Stopwatch()..start();

    try {
      // Encontrar a melhor estratégia para o contexto
      final strategy = _findBestStrategy(context);

      if (strategy == null) {
        debugPrint(
            '❌ [NavigationResolver] Nenhuma estratégia encontrada para: $context');
        _recordUsage('NONE');
        return AppDestination.offlineView; // Fallback seguro
      }

      // Resolver destino usando a estratégia escolhida
      final destination = strategy.resolveDestination(context);

      // Registrar estatísticas
      _recordUsage(strategy.name);
      stopwatch.stop();
      _recordPerformance(strategy.name, stopwatch.elapsed);

      debugPrint(
          '🎯 [NavigationResolver] ${strategy.name} → ${destination.name} '
          '(${stopwatch.elapsedMilliseconds}ms)');

      return destination;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ [NavigationResolver] Erro na resolução: $e');
      _recordUsage('ERROR');
      return AppDestination.error;
    }
  }

  @override
  void registerStrategy(INavigationStrategy strategy) {
    // Verificar se estratégia já está registrada
    if (_strategies.any((s) => s.name == strategy.name)) {
      debugPrint(
          '⚠️ [NavigationResolver] Estratégia ${strategy.name} já registrada - substituindo');
      unregisterStrategy(strategy.name);
    }

    _strategies.add(strategy);
    _usageStats[strategy.name] = 0;
    _performanceStats[strategy.name] = Duration.zero;

    debugPrint(
        '✅ [NavigationResolver] Estratégia registrada: ${strategy.name}');
    debugPrint(
        '   Plataformas suportadas: ${strategy.supportedPlatforms.map((p) => p.name).join(', ')}');
  }

  @override
  void unregisterStrategy(String strategyName) {
    final initialLength = _strategies.length;
    _strategies.removeWhere((s) => s.name == strategyName);
    final removed = initialLength - _strategies.length;

    if (removed > 0) {
      _usageStats.remove(strategyName);
      _performanceStats.remove(strategyName);
      debugPrint('🗑️ [NavigationResolver] Estratégia removida: $strategyName');
    }
  }

  @override
  List<INavigationStrategy> getRegisteredStrategies() {
    return List.unmodifiable(_strategies);
  }

  @override
  Map<String, dynamic> getUsageStats() {
    final totalUsage =
        _usageStats.values.fold<int>(0, (sum, count) => sum + count);

    return {
      'total_resolutions': totalUsage,
      'registered_strategies_count': _strategies.length,
      'strategies': _strategies.map((s) => s.name).toList(),
      'usage_by_strategy': Map.from(_usageStats),
      'usage_percentages': _usageStats.map((name, count) => MapEntry(
          name,
          totalUsage > 0
              ? ((count / totalUsage) * 100).toStringAsFixed(1)
              : '0.0')),
      'average_resolution_times': _performanceStats.map((name, totalTime) =>
          MapEntry(
              name,
              _usageStats[name]! > 0
                  ? (totalTime.inMicroseconds / _usageStats[name]!).round()
                  : 0)),
    };
  }

  /// Encontra a melhor estratégia para o contexto dado
  INavigationStrategy? _findBestStrategy(NavigationContext context) {
    // Filtrar estratégias que podem lidar com o contexto
    final candidateStrategies =
        _strategies.where((strategy) => strategy.canHandle(context)).toList();

    if (candidateStrategies.isEmpty) {
      return null;
    }

    // Ordenar por prioridade (maior prioridade primeiro)
    candidateStrategies.sort(
        (a, b) => b.getPriority(context).compareTo(a.getPriority(context)));

    final selectedStrategy = candidateStrategies.first;

    debugPrint('🔍 [NavigationResolver] Estratégias candidatas para $context:');
    for (final strategy in candidateStrategies) {
      final isSelected = strategy == selectedStrategy;
      debugPrint(
          '   ${isSelected ? "👑" : "  "} ${strategy.name} (prioridade: ${strategy.getPriority(context)})');
    }

    return selectedStrategy;
  }

  /// Registra uso de uma estratégia
  void _recordUsage(String strategyName) {
    _usageStats[strategyName] = (_usageStats[strategyName] ?? 0) + 1;
  }

  /// Registra performance de uma estratégia
  void _recordPerformance(String strategyName, Duration duration) {
    _performanceStats[strategyName] =
        (_performanceStats[strategyName] ?? Duration.zero) + duration;
  }

  /// Obtém estatísticas detalhadas para debug
  Map<String, dynamic> getDetailedStats() {
    final usageStats = getUsageStats();

    return {
      ...usageStats,
      'strategies_detail': _strategies
          .map((strategy) => {
                'name': strategy.name,
                'supported_platforms':
                    strategy.supportedPlatforms.map((p) => p.name).toList(),
                'usage_count': _usageStats[strategy.name] ?? 0,
                'total_time_ms':
                    (_performanceStats[strategy.name]?.inMilliseconds ?? 0),
                'average_time_us': _usageStats[strategy.name]! > 0
                    ? (_performanceStats[strategy.name]!.inMicroseconds /
                            _usageStats[strategy.name]!)
                        .round()
                    : 0,
              })
          .toList(),
    };
  }

  /// Simula resolução para diferentes contextos (útil para testes/debug)
  Map<String, AppDestination> simulateResolutions(
      List<NavigationContext> contexts) {
    final results = <String, AppDestination>{};

    for (final context in contexts) {
      final destination = resolveDestination(context);
      results[context.toString()] = destination;
    }

    return results;
  }

  /// Valida se todas as combinações de contexto têm pelo menos uma estratégia
  List<String> validateCoverage() {
    final issues = <String>[];

    // Testar combinações comuns
    final testContexts = [
      // Mobile scenarios
      NavigationContext.fromGetPlatform(
        authState: AuthState.authenticated,
        userRole: UserRole.user,
        degradationLevel: DegradationLevel.none,
      ),
      NavigationContext.fromGetPlatform(
        authState: AuthState.anonymous,
        userRole: UserRole.anonymous,
        degradationLevel: DegradationLevel.none,
      ),
      NavigationContext.fromGetPlatform(
        authState: AuthState.unauthenticated,
        userRole: UserRole.guest,
        degradationLevel: DegradationLevel.none,
      ),
      // Add more test contexts...
    ];

    for (final context in testContexts) {
      final strategy = _findBestStrategy(context);
      if (strategy == null) {
        issues.add('Nenhuma estratégia para: $context');
      }
    }

    return issues;
  }

  /// Limpa estatísticas de uso
  void clearStats() {
    for (final key in _usageStats.keys) {
      _usageStats[key] = 0;
    }
    for (final key in _performanceStats.keys) {
      _performanceStats[key] = Duration.zero;
    }
    debugPrint('🧹 [NavigationResolver] Estatísticas limpas');
  }
}
