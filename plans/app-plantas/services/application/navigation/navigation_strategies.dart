// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';
import 'navigation_interfaces.dart';

/// Estratégia base para navegação com funcionalidades comuns
abstract class BaseNavigationStrategy implements INavigationStrategy {
  @override
  bool canHandle(NavigationContext context) {
    return supportedPlatforms.contains(context.platform);
  }

  @override
  int getPriority(NavigationContext context) {
    // Prioridade padrão - pode ser sobrescrita pelas estratégias filhas
    return canHandle(context) ? 1 : 0;
  }

  /// Método helper para logar decisões de navegação
  void logNavigation(
      NavigationContext context, AppDestination destination, String reason) {
    debugPrint(
        '📍 [$name] ${context.platform.name} → ${destination.name}: $reason');
  }
}

/// Estratégia de navegação para dispositivos móveis
class MobileNavigationStrategy extends BaseNavigationStrategy {
  @override
  String get name => 'MobileNavigationStrategy';

  @override
  List<AppPlatform> get supportedPlatforms => [AppPlatform.mobile];

  @override
  AppDestination resolveDestination(NavigationContext context) {
    // Em modo degradado, usar interface específica
    if (context.degradationLevel != DegradationLevel.none) {
      logNavigation(context, AppDestination.degradedView,
          'Sistema degradado: ${context.degradationLevel.name}');
      return AppDestination.degradedView;
    }

    // Se está em recovery, mostrar tela de recovery
    if (context.isRecovering) {
      logNavigation(
          context, AppDestination.recoveringView, 'Sistema em recovery');
      return AppDestination.recoveringView;
    }

    // Mobile sempre vai para o app principal se autenticado (incluindo anônimo)
    switch (context.authState) {
      case AuthState.authenticated:
      case AuthState.anonymous:
        logNavigation(context, AppDestination.novaTarefasView,
            'Usuário autenticado (${context.authState.name})');
        return AppDestination.novaTarefasView;

      case AuthState.unauthenticated:
        // Mobile sem auth pode ir para modo offline ou app com limitações
        logNavigation(context, AppDestination.novaTarefasView,
            'Mobile sem auth - permitir acesso limitado');
        return AppDestination.novaTarefasView;

      case AuthState.unavailable:
        logNavigation(context, AppDestination.offlineView,
            'Sistema de auth indisponível');
        return AppDestination.offlineView;
    }
  }

  @override
  int getPriority(NavigationContext context) {
    // Prioridade alta para mobile
    return context.platform == AppPlatform.mobile ? 10 : 0;
  }
}

/// Estratégia de navegação para web
class WebNavigationStrategy extends BaseNavigationStrategy {
  @override
  String get name => 'WebNavigationStrategy';

  @override
  List<AppPlatform> get supportedPlatforms => [AppPlatform.web];

  @override
  AppDestination resolveDestination(NavigationContext context) {
    // Em modo degradado, usar interface específica
    if (context.degradationLevel != DegradationLevel.none) {
      logNavigation(context, AppDestination.degradedView,
          'Sistema degradado: ${context.degradationLevel.name}');
      return AppDestination.degradedView;
    }

    // Se está em recovery, mostrar tela de recovery
    if (context.isRecovering) {
      logNavigation(
          context, AppDestination.recoveringView, 'Sistema em recovery');
      return AppDestination.recoveringView;
    }

    // Web requer autenticação explícita
    switch (context.authState) {
      case AuthState.authenticated:
        logNavigation(
            context, AppDestination.novaTarefasView, 'Usuário autenticado');
        return AppDestination.novaTarefasView;

      case AuthState.anonymous:
        // Web com usuário anônimo ainda vai para o app
        logNavigation(context, AppDestination.novaTarefasView,
            'Usuário anônimo - acesso permitido');
        return AppDestination.novaTarefasView;

      case AuthState.unauthenticated:
        logNavigation(context, AppDestination.loginPage,
            'Usuário não autenticado - requer login');
        return AppDestination.loginPage;

      case AuthState.unavailable:
        logNavigation(context, AppDestination.offlineView,
            'Sistema de auth indisponível');
        return AppDestination.offlineView;
    }
  }

  @override
  int getPriority(NavigationContext context) {
    // Prioridade alta para web
    return context.platform == AppPlatform.web ? 10 : 0;
  }
}

/// Estratégia de navegação para desktop
class DesktopNavigationStrategy extends BaseNavigationStrategy {
  @override
  String get name => 'DesktopNavigationStrategy';

  @override
  List<AppPlatform> get supportedPlatforms => [AppPlatform.desktop];

  @override
  AppDestination resolveDestination(NavigationContext context) {
    // Comportamento similar ao web para desktop

    // Em modo degradado, usar interface específica
    if (context.degradationLevel != DegradationLevel.none) {
      logNavigation(context, AppDestination.degradedView,
          'Sistema degradado: ${context.degradationLevel.name}');
      return AppDestination.degradedView;
    }

    // Se está em recovery, mostrar tela de recovery
    if (context.isRecovering) {
      logNavigation(
          context, AppDestination.recoveringView, 'Sistema em recovery');
      return AppDestination.recoveringView;
    }

    // Desktop requer autenticação como web
    switch (context.authState) {
      case AuthState.authenticated:
      case AuthState.anonymous:
        logNavigation(context, AppDestination.novaTarefasView,
            'Usuário autenticado (${context.authState.name})');
        return AppDestination.novaTarefasView;

      case AuthState.unauthenticated:
        logNavigation(
            context, AppDestination.loginPage, 'Desktop requer autenticação');
        return AppDestination.loginPage;

      case AuthState.unavailable:
        logNavigation(context, AppDestination.offlineView,
            'Sistema de auth indisponível');
        return AppDestination.offlineView;
    }
  }

  @override
  int getPriority(NavigationContext context) {
    return context.platform == AppPlatform.desktop ? 10 : 0;
  }
}

/// Estratégia de navegação para modo guest/offline
class GuestNavigationStrategy extends BaseNavigationStrategy {
  @override
  String get name => 'GuestNavigationStrategy';

  @override
  List<AppPlatform> get supportedPlatforms =>
      [AppPlatform.mobile, AppPlatform.web, AppPlatform.desktop];

  @override
  bool canHandle(NavigationContext context) {
    // Esta estratégia lida com usuários guest ou quando auth está indisponível
    return context.authState == AuthState.unavailable ||
        context.userRole == UserRole.guest ||
        context.degradationLevel == DegradationLevel.critical;
  }

  @override
  AppDestination resolveDestination(NavigationContext context) {
    // Se está em recovery, mostrar tela de recovery
    if (context.isRecovering) {
      logNavigation(
          context, AppDestination.recoveringView, 'Recovery em modo guest');
      return AppDestination.recoveringView;
    }

    // Para modo guest, mostrar interface apropriada baseada na plataforma
    if (context.platform == AppPlatform.mobile) {
      // Mobile guest pode acessar funcionalidades limitadas
      logNavigation(context, AppDestination.novaTarefasView,
          'Mobile guest - acesso limitado');
      return AppDestination.novaTarefasView;
    } else {
      // Web/Desktop guest mostra tela offline
      logNavigation(context, AppDestination.offlineView,
          'Web/Desktop guest - modo offline');
      return AppDestination.offlineView;
    }
  }

  @override
  int getPriority(NavigationContext context) {
    // Prioridade baixa - só usa se outras estratégias não puderem lidar
    if (canHandle(context)) {
      return 5;
    }
    return 0;
  }
}

/// Estratégia de navegação para administradores
class AdminNavigationStrategy extends BaseNavigationStrategy {
  @override
  String get name => 'AdminNavigationStrategy';

  @override
  List<AppPlatform> get supportedPlatforms =>
      [AppPlatform.mobile, AppPlatform.web, AppPlatform.desktop];

  @override
  bool canHandle(NavigationContext context) {
    // Apenas para usuários com role de admin
    return context.userRole == UserRole.admin;
  }

  @override
  AppDestination resolveDestination(NavigationContext context) {
    // Admins podem acessar o app mesmo em modo degradado (com limitações)
    if (context.degradationLevel == DegradationLevel.critical) {
      logNavigation(
          context, AppDestination.degradedView, 'Admin em modo crítico');
      return AppDestination.degradedView;
    }

    // Se está em recovery, admins ainda veem recovery
    if (context.isRecovering) {
      logNavigation(
          context, AppDestination.recoveringView, 'Admin durante recovery');
      return AppDestination.recoveringView;
    }

    // Admins sempre podem acessar o app principal
    logNavigation(
        context, AppDestination.novaTarefasView, 'Admin - acesso total');
    return AppDestination.novaTarefasView;
  }

  @override
  int getPriority(NavigationContext context) {
    // Prioridade máxima para admins
    return context.userRole == UserRole.admin ? 20 : 0;
  }
}

/// Estratégia fallback para casos não cobertos por outras estratégias
class FallbackNavigationStrategy extends BaseNavigationStrategy {
  @override
  String get name => 'FallbackNavigationStrategy';

  @override
  List<AppPlatform> get supportedPlatforms =>
      [AppPlatform.mobile, AppPlatform.web, AppPlatform.desktop];

  @override
  bool canHandle(NavigationContext context) {
    // Esta estratégia sempre pode lidar com qualquer contexto
    return true;
  }

  @override
  AppDestination resolveDestination(NavigationContext context) {
    logNavigation(context, AppDestination.offlineView,
        'Fallback - nenhuma estratégia específica aplicável');

    // Em último caso, mostrar modo offline
    return AppDestination.offlineView;
  }

  @override
  int getPriority(NavigationContext context) {
    // Prioridade mínima - só usa se nenhuma outra estratégia funcionar
    return 1;
  }
}
