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
    // If AuthProvider is not available yet, allow navigation to continue
    // (will be handled once provider is ready)
    final isAuthenticated = _authProvider?.isAuthenticated ?? false;
    final routeType = _getRouteType(currentLocation);

    // Aplicar regras de redirecionamento baseadas no tipo de rota
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