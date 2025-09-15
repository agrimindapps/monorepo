import 'package:flutter/foundation.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../services/platform_service.dart';

/// Guard de rotas centralizado para gerenciar redirecionamentos baseados em autenticação
/// 
/// Esta classe extrai a lógica complexa de redirecionamento do router principal,
/// melhorando legibilidade, testabilidade e manutenibilidade.
class RouteGuard {
  final AuthProvider? _authProvider;
  final PlatformService _platformService;

  const RouteGuard(this._authProvider, this._platformService);

  /// Determina se deve redirecionar baseado no estado atual da rota e autenticação
  /// 
  /// Retorna null se a navegação deve continuar, ou uma string com a rota de destino
  /// se deve redirecionar.
  String? handleRedirect(String currentLocation) {
    // If AuthProvider is not available or not initialized yet, allow navigation to continue
    // This prevents race conditions during app initialization
    if (_authProvider == null || !_authProvider!.isInitialized) {
      return null;
    }
    
    final isAuthenticated = _authProvider!.isAuthenticated;
    final hasAuthError = _authProvider!.errorMessage != null;
    final isLoading = _authProvider!.isLoading;
    final routeType = _getRouteType(currentLocation);

    // SECURITY + UX FIX: If there's an authentication error and we're on login page,
    // don't redirect to prevent login error handling from being interrupted
    if (hasAuthError && currentLocation == '/login') {
      if (kDebugMode) {
        debugPrint('🛡️ RouteGuard: Erro de auth detectado em /login - mantendo usuário na página');
      }
      return null;
    }

    // SECURITY + UX FIX: If authentication is in progress and we're on login page,
    // don't redirect to avoid interrupting the auth flow
    if (isLoading && currentLocation == '/login') {
      if (kDebugMode) {
        debugPrint('🛡️ RouteGuard: Login em progresso em /login - mantendo usuário na página');
      }
      return null;
    }

    // Debug logging for route decisions
    if (kDebugMode) {
      debugPrint('🛡️ RouteGuard: Avaliando rota $currentLocation - Autenticado: $isAuthenticated, Tipo: $routeType');
    }

    // Aplicar regras de redirecionamento baseadas no tipo de rota
    switch (routeType) {
      case RouteType.authProtected:
        final redirect = _handleAuthProtectedRoute(isAuthenticated, currentLocation);
        if (kDebugMode && redirect != null) {
          debugPrint('🛡️ RouteGuard: Redirecionando rota protegida $currentLocation -> $redirect');
        }
        return redirect;
      
      case RouteType.publicOnly:
        final redirect = _handlePublicOnlyRoute(isAuthenticated);
        if (kDebugMode && redirect != null) {
          debugPrint('🛡️ RouteGuard: Redirecionando rota pública $currentLocation -> $redirect');
        }
        return redirect;
      
      case RouteType.alwaysPublic:
        return null; // Sempre permitir acesso
      
      case RouteType.appContent:
        final redirect = _handleAppContentRoute(isAuthenticated, currentLocation);
        if (kDebugMode && redirect != null) {
          debugPrint('🛡️ RouteGuard: Redirecionando rota de app $currentLocation -> $redirect');
        }
        return redirect;
    }
  }

  /// Determina a localização inicial baseada no estado de autenticação e plataforma
  String getInitialLocation() {
    // Always start with home route - redirect logic will handle proper routing
    return '/';
  }

  /// Classifica o tipo de rota baseado no path
  RouteType _getRouteType(String location) {
    // Páginas sempre públicas - não requerem autenticação
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
    // SECURITY + UX FIX: Stay on login/promo pages when not authenticated
    // This prevents unwanted redirects during failed login attempts
    return null;
  }

  /// Handle de rotas de conteúdo da aplicação
  String? _handleAppContentRoute(bool isAuthenticated, String location) {
    // Para web
    if (_platformService.isWeb) {
      // Se autenticado (incluindo anônimo), permitir acesso
      if (isAuthenticated) {
        return null;
      }
      
      // Se não autenticado, redirecionar para promo
      return '/promo';
    }
    
    // Para mobile, permitir acesso direto às funcionalidades (modo anônimo)
    if (_platformService.isMobile) {
      return null; // Sempre permitir acesso no mobile
    }
    
    // Lógica padrão para outras plataformas
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