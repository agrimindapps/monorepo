// Flutter imports:
// Removed unused import
import 'package:flutter/material.dart';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';
import 'authentication_checker.dart';
import 'navigation_interfaces.dart';
import 'navigation_resolver.dart';
import 'navigation_strategies.dart';
import 'navigation_widget_factory.dart';

/// Serviço completo de navegação que integra todos os componentes
///
/// Fornece uma interface única para resolver navegação e criar widgets
/// apropriados baseado no contexto atual da aplicação
class NavigationService implements INavigationService {
  final INavigationResolver _resolver;
  final INavigationWidgetFactory _widgetFactory;
  final IAuthenticationChecker _authChecker;

  NavigationService({
    required INavigationResolver resolver,
    required INavigationWidgetFactory widgetFactory,
    required IAuthenticationChecker authChecker,
  })  : _resolver = resolver,
        _widgetFactory = widgetFactory,
        _authChecker = authChecker {
    debugPrint(
        '🧭 [NavigationService] Inicializado com componentes customizados');
  }

  /// Factory method para criar com configuração padrão
  factory NavigationService.withDefaults({
    required DegradedModeService degradedModeService,
  }) {
    final resolver = NavigationResolver();
    final widgetFactory = NavigationWidgetFactory();
    final authChecker = AuthenticationChecker(
      degradedModeService: degradedModeService,
    );

    // Registrar estratégias padrão
    resolver.registerStrategy(AdminNavigationStrategy());
    resolver.registerStrategy(MobileNavigationStrategy());
    resolver.registerStrategy(WebNavigationStrategy());
    resolver.registerStrategy(DesktopNavigationStrategy());
    resolver.registerStrategy(GuestNavigationStrategy());
    resolver.registerStrategy(FallbackNavigationStrategy());

    final service = NavigationService(
      resolver: resolver,
      widgetFactory: widgetFactory,
      authChecker: authChecker,
    );

    debugPrint('🏗️ [NavigationService] Criado com configuração padrão');
    return service;
  }

  @override
  Widget resolveAndBuildWidget(NavigationContext context) {
    final stopwatch = Stopwatch()..start();

    try {
      // Resolver destino
      final destination = _resolver.resolveDestination(context);

      // Criar widget
      final widget = _widgetFactory.createWidget(destination, context);

      stopwatch.stop();
      debugPrint(
          '🎯 [NavigationService] Resolvido e construído: ${destination.name} '
          '(${stopwatch.elapsedMilliseconds}ms)');

      return widget;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ [NavigationService] Erro na resolução/construção: $e');

      // Fallback seguro
      return _widgetFactory.createWidget(
          AppDestination.error,
          context.copyWith(additionalData: {
            ...context.additionalData,
            'error': e.toString(),
          }));
    }
  }

  @override
  AppDestination resolveDestination(NavigationContext context) {
    return _resolver.resolveDestination(context);
  }

  @override
  Widget createWidget(AppDestination destination, NavigationContext context) {
    return _widgetFactory.createWidget(destination, context);
  }

  @override
  void registerStrategy(INavigationStrategy strategy) {
    _resolver.registerStrategy(strategy);
  }

  @override
  void registerWidgetBuilder(
    AppDestination destination,
    Widget Function(NavigationContext context) builder,
  ) {
    _widgetFactory.registerCustomBuilder(destination, builder);
  }

  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'navigation_service': {
        'component_types': {
          'resolver': _resolver.runtimeType.toString(),
          'widget_factory': _widgetFactory.runtimeType.toString(),
          'auth_checker': _authChecker.runtimeType.toString(),
        },
      },
      'resolver_stats': _resolver.getUsageStats(),
      'widget_factory_stats': _widgetFactory.getUsageStats(),
      'auth_checker_stats': _authChecker.getStats(),
      'current_auth_context': _authChecker.createNavigationContext().toString(),
    };
  }

  /// Cria NavigationContext baseado no estado atual
  NavigationContext createCurrentContext({
    bool? isRecovering,
    Map<String, dynamic>? additionalData,
  }) {
    return _authChecker.createNavigationContext(
      isRecovering: isRecovering,
      additionalData: additionalData,
    );
  }

  /// Resolve e constrói widget baseado no estado atual
  Widget buildCurrentWidget({
    bool? isRecovering,
    Map<String, dynamic>? additionalData,
  }) {
    final context = createCurrentContext(
      isRecovering: isRecovering,
      additionalData: additionalData,
    );

    return resolveAndBuildWidget(context);
  }

  /// Simula navegação para diferentes cenários (útil para testes)
  Map<String, AppDestination> simulateNavigation({
    List<AuthState>? authStates,
    List<AppPlatform>? platforms,
    List<DegradationLevel>? degradationLevels,
  }) {
    final results = <String, AppDestination>{};

    final testAuthStates = authStates ?? AuthState.values;
    final testPlatforms = platforms ?? AppPlatform.values;
    final testDegradationLevels = degradationLevels ?? DegradationLevel.values;

    for (final authState in testAuthStates) {
      for (final platform in testPlatforms) {
        for (final degradationLevel in testDegradationLevels) {
          final context = NavigationContext(
            platform: platform,
            authState: authState,
            userRole: _deriveUserRole(authState),
            degradationLevel: degradationLevel,
          );

          final destination = resolveDestination(context);
          final key =
              '${platform.name}_${authState.name}_${degradationLevel.name}';
          results[key] = destination;
        }
      }
    }

    return results;
  }

  UserRole _deriveUserRole(AuthState authState) {
    switch (authState) {
      case AuthState.authenticated:
        return UserRole.user;
      case AuthState.anonymous:
        return UserRole.anonymous;
      case AuthState.unauthenticated:
      case AuthState.unavailable:
        return UserRole.guest;
    }
  }

  /// Valida se a configuração atual de navegação está completa
  List<String> validateConfiguration() {
    final issues = <String>[];

    // Validar resolver
    if (_resolver.getRegisteredStrategies().isEmpty) {
      issues.add('Nenhuma estratégia de navegação registrada');
    }

    // Validar cobertura de estratégias
    final coverageIssues = (_resolver as NavigationResolver).validateCoverage();
    issues.addAll(coverageIssues);

    // Validar widget factory
    const testDestinations = AppDestination.values;
    for (final destination in testDestinations) {
      if (!_widgetFactory.canCreateWidget(destination)) {
        issues.add(
            'Widget factory não pode criar widget para: ${destination.name}');
      }
    }

    // Validar auth checker
    try {
      _authChecker.getCurrentAuthState();
    } catch (e) {
      issues.add('Auth checker não está funcionando: $e');
    }

    return issues;
  }

  /// Obtém estatísticas completas de performance
  Map<String, dynamic> getPerformanceStats() {
    final debugInfo = getDebugInfo();

    return {
      'resolver': {
        'registered_strategies':
            (_resolver as NavigationResolver).getRegisteredStrategies().length,
        'usage_stats': debugInfo['resolver_stats'],
      },
      'widget_factory': {
        'usage_stats': debugInfo['widget_factory_stats'],
      },
      'auth_checker': {
        'stats': debugInfo['auth_checker_stats'],
      },
      'validation_issues': validateConfiguration(),
    };
  }

  /// Força refresh de todos os componentes
  void refresh() {
    debugPrint(
        '🔄 [NavigationService] Forçando refresh de todos os componentes');

    // Refresh auth checker
    _authChecker.refreshAuthState();

    // Limpar estatísticas se necessário
    // (_resolver as NavigationResolver).clearStats();
    // (_widgetFactory as NavigationWidgetFactory).clearStats();

    debugPrint('✅ [NavigationService] Refresh concluído');
  }
}
