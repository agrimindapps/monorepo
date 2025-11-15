import 'package:flutter/foundation.dart';

import '../../../features/auth/presentation/state/auth_state.dart';
import '../../services/platform/platform_service.dart';

/// Guard de rotas centralizado para gerenciar redirecionamentos baseados em autenticação
///
/// Esta classe extrai a lógica complexa de redirecionamento do router principal,
/// melhorando legibilidade, testabilidade e manutenibilidade.
class RouteGuard {

  const RouteGuard(this._authState, this._platformService);
  final AuthState? _authState;
  final PlatformService _platformService;

  /// Determina se deve redirecionar baseado no estado atual da rota e autenticação
  ///
  /// Retorna null se a navegação deve continuar, ou uma string com a rota de destino
  /// se deve redirecionar.
  String? handleRedirect(String currentLocation) {
    if (_authState == null || !_authState.isInitialized) {
      return null;
    }

    final isAuthenticated = _authState.isAuthenticated;
    final hasAuthError = _authState.errorMessage != null;
    final isLoading = _authState.isLoading;
    final routeType = _getRouteType(currentLocation);
    if (hasAuthError && currentLocation == '/login') {
      if (kDebugMode) {
        debugPrint('🛡️ RouteGuard: Erro de auth detectado em /login - mantendo usuário na página');
      }
      return null;
    }
    if (isLoading && currentLocation == '/login') {
      if (kDebugMode) {
        debugPrint('🛡️ RouteGuard: Login em progresso em /login - mantendo usuário na página');
      }
      return null;
    }
    switch (routeType) {
      case RouteType.authProtected:
        return _handleAuthProtectedRoute(isAuthenticated, currentLocation);
      
      case RouteType.publicOnly:
        return _handlePublicOnlyRoute(isAuthenticated);
      
      case RouteType.alwaysPublic:
        return null; // Sempre permitir acesso
      
      case RouteType.appContent:
        return _handleAppContentRoute(isAuthenticated, currentLocation);
    }
  }

  /// Determina a localização inicial baseada no estado de autenticação e plataforma
  String getInitialLocation() {
    return '/';
  }

  /// Classifica o tipo de rota baseado no path
  RouteType _getRouteType(String location) {
    const publicRoutes = [
      '/privacy',
      '/terms', 
      '/about',
      '/contact',
      '/help',
      '/faq',
      '/support',
    ];
    const authOnlyRoutes = ['/promo', '/login'];
    const appRoutes = ['/', '/odometer', '/fuel', '/maintenance', '/reports', '/settings', '/profile'];

    if (publicRoutes.any((route) => location.startsWith(route))) {
      return RouteType.alwaysPublic;
    }
    
    if (authOnlyRoutes.any((route) => location.startsWith(route))) {
      return RouteType.publicOnly;
    }
    
    if (appRoutes.any((route) => location == route || location.startsWith('$route/'))) {
      return RouteType.appContent;
    }
    
    return RouteType.authProtected;
  }

  /// Handle de rotas que requerem autenticação
  String? _handleAuthProtectedRoute(bool isAuthenticated, String location) {
    if (!isAuthenticated) {
      return _platformService.isWeb ? '/promo' : '/login';
    }
    return null;
  }

  /// Handle de rotas que são apenas para usuários não autenticados
  String? _handlePublicOnlyRoute(bool isAuthenticated) {
    if (isAuthenticated) {
      return '/';
    }
    return null;
  }

  /// Handle de rotas de conteúdo da aplicação
  String? _handleAppContentRoute(bool isAuthenticated, String location) {
    if (_platformService.isWeb) {
      if (isAuthenticated) {
        return null;
      }
      return '/promo';
    }
    if (_platformService.isMobile) {
      return null; // Sempre permitir acesso no mobile
    }
    if (!isAuthenticated) {
      return '/login';
    }
    
    return null;
  }
}

/// Tipos de rota para classificação de acesso
enum RouteType {
  /// Rotas que sempre são públicas (termos, privacidade)
  alwaysPublic,
  
  /// Rotas apenas para usuários não autenticados (promo, login)
  publicOnly,
  
  /// Rotas que requerem autenticação
  authProtected,
  
  /// Conteúdo principal da aplicação
  appContent,
}
