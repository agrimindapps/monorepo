// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';

/// Plataforma da aplicação
enum AppPlatform {
  mobile,
  web,
  desktop,
}

/// Estado de autenticação do usuário
enum AuthState {
  authenticated, // Usuário logado com conta real
  anonymous, // Usuário logado anonimamente
  unauthenticated, // Usuário não logado
  unavailable, // Sistema de auth indisponível
}

/// Tipo de usuário/role
enum UserRole {
  user,
  guest,
  admin,
  anonymous,
}

/// Destinos possíveis de navegação
enum AppDestination {
  loading, // Tela de loading
  error, // Tela de erro
  loginPage, // Página de login
  novaTarefasView, // Tela principal do app
  degradedView, // Interface degradada
  recoveringView, // Tela de recovery
  offlineView, // Modo offline
}

/// Contexto para decisões de navegação
class NavigationContext {
  final AppPlatform platform;
  final AuthState authState;
  final UserRole userRole;
  final DegradationLevel degradationLevel;
  final bool isRecovering;
  final Map<String, dynamic> additionalData;

  const NavigationContext({
    required this.platform,
    required this.authState,
    required this.userRole,
    required this.degradationLevel,
    this.isRecovering = false,
    this.additionalData = const {},
  });

  /// Cria contexto a partir da plataforma GetX
  factory NavigationContext.fromGetPlatform({
    required AuthState authState,
    required UserRole userRole,
    required DegradationLevel degradationLevel,
    bool isRecovering = false,
    Map<String, dynamic> additionalData = const {},
  }) {
    AppPlatform platform;
    if (GetPlatform.isMobile) {
      platform = AppPlatform.mobile;
    } else if (GetPlatform.isWeb) {
      platform = AppPlatform.web;
    } else {
      platform = AppPlatform.desktop;
    }

    return NavigationContext(
      platform: platform,
      authState: authState,
      userRole: userRole,
      degradationLevel: degradationLevel,
      isRecovering: isRecovering,
      additionalData: additionalData,
    );
  }

  /// Cria uma cópia com modificações
  NavigationContext copyWith({
    AppPlatform? platform,
    AuthState? authState,
    UserRole? userRole,
    DegradationLevel? degradationLevel,
    bool? isRecovering,
    Map<String, dynamic>? additionalData,
  }) {
    return NavigationContext(
      platform: platform ?? this.platform,
      authState: authState ?? this.authState,
      userRole: userRole ?? this.userRole,
      degradationLevel: degradationLevel ?? this.degradationLevel,
      isRecovering: isRecovering ?? this.isRecovering,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'NavigationContext('
        'platform: $platform, '
        'authState: $authState, '
        'userRole: $userRole, '
        'degradationLevel: $degradationLevel, '
        'isRecovering: $isRecovering'
        ')';
  }
}

/// Interface para verificação de estado de autenticação
abstract class IAuthenticationChecker {
  /// Obtém o estado atual de autenticação
  AuthState getCurrentAuthState();

  /// Verifica se o usuário está autenticado (qualquer tipo)
  bool isAuthenticated();

  /// Verifica se o usuário está logado com conta real
  bool isRealUserAuthenticated();

  /// Verifica se o usuário está logado anonimamente
  bool isGuestlyAuthenticated();

  /// Obtém o role/papel do usuário atual
  UserRole getUserRole();

  /// Verifica se o sistema de autenticação está disponível
  bool isAuthSystemAvailable();

  /// Obtém informações adicionais do usuário (se disponível)
  Map<String, dynamic> getUserInfo();

  /// Obtém estatísticas do sistema de autenticação
  Map<String, dynamic> getStats();

  /// Força refresh do estado de autenticação
  void refreshAuthState();

  /// Cria NavigationContext baseado no estado atual
  NavigationContext createNavigationContext({
    DegradationLevel? degradationLevel,
    bool? isRecovering,
    Map<String, dynamic>? additionalData,
  });
}

/// Interface para estratégias de navegação específicas por plataforma
abstract class INavigationStrategy {
  /// Nome da estratégia para logs e debug
  String get name;

  /// Plataformas suportadas por esta estratégia
  List<AppPlatform> get supportedPlatforms;

  /// Resolve o destino de navegação baseado no contexto
  AppDestination resolveDestination(NavigationContext context);

  /// Verifica se esta estratégia pode lidar com o contexto
  bool canHandle(NavigationContext context);

  /// Obtém prioridade desta estratégia (maior número = maior prioridade)
  int getPriority(NavigationContext context);
}

/// Interface para o resolvedor principal de navegação
abstract class INavigationResolver {
  /// Resolve o destino de navegação baseado no contexto
  AppDestination resolveDestination(NavigationContext context);

  /// Registra uma estratégia de navegação
  void registerStrategy(INavigationStrategy strategy);

  /// Remove uma estratégia de navegação
  void unregisterStrategy(String strategyName);

  /// Lista todas as estratégias registradas
  List<INavigationStrategy> getRegisteredStrategies();

  /// Obtém estatísticas de uso das estratégias
  Map<String, dynamic> getUsageStats();
}

/// Interface para factory de widgets baseado no destino
abstract class INavigationWidgetFactory {
  /// Cria widget apropriado para o destino especificado
  Widget createWidget(AppDestination destination, NavigationContext context);

  /// Verifica se pode criar widget para o destino
  bool canCreateWidget(AppDestination destination);

  /// Registra um builder customizado para um destino
  void registerCustomBuilder(
    AppDestination destination,
    Widget Function(NavigationContext context) builder,
  );

  /// Obtém estatísticas de uso dos widgets
  Map<String, dynamic> getUsageStats();
}

/// Interface para o serviço completo de navegação
abstract class INavigationService {
  /// Resolve e retorna o widget apropriado para o contexto atual
  Widget resolveAndBuildWidget(NavigationContext context);

  /// Apenas resolve o destino sem criar o widget
  AppDestination resolveDestination(NavigationContext context);

  /// Cria widget para um destino específico
  Widget createWidget(AppDestination destination, NavigationContext context);

  /// Registra componentes customizados
  void registerStrategy(INavigationStrategy strategy);
  void registerWidgetBuilder(
    AppDestination destination,
    Widget Function(NavigationContext context) builder,
  );

  /// Obtém estatísticas e informações de debug
  Map<String, dynamic> getDebugInfo();
}

/// Resultado de uma resolução de navegação (para debugging/analytics)
class NavigationResolution {
  final AppDestination destination;
  final NavigationContext context;
  final String strategyUsed;
  final Duration resolutionTime;
  final Map<String, dynamic> metadata;

  NavigationResolution({
    required this.destination,
    required this.context,
    required this.strategyUsed,
    required this.resolutionTime,
    this.metadata = const {},
  });

  @override
  String toString() {
    return 'NavigationResolution('
        'destination: $destination, '
        'strategy: $strategyUsed, '
        'time: ${resolutionTime.inMilliseconds}ms'
        ')';
  }
}
