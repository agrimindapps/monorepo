// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../controllers/auth_controller.dart';
import '../../infrastructure/degraded_mode_service.dart';
import 'navigation_interfaces.dart';

/// Implementação do verificador de estado de autenticação
///
/// Responsável por verificar o estado atual de autenticação do usuário
/// e fornecer informações sobre roles e disponibilidade do sistema de auth
class AuthenticationChecker implements IAuthenticationChecker {
  final DegradedModeService _degradedModeService;

  AuthenticationChecker({
    required DegradedModeService degradedModeService,
  }) : _degradedModeService = degradedModeService;

  @override
  AuthState getCurrentAuthState() {
    // Verificar se sistema de auth está disponível
    if (!isAuthSystemAvailable()) {
      return AuthState.unavailable;
    }

    try {
      // Tentar obter controller de auth
      final authController = Get.find<PlantasAuthController>();

      // Verificar se usuário está logado
      if (!authController.isUserLoggedIn()) {
        return AuthState.unauthenticated;
      }

      // Determinar tipo de autenticação
      final user = authController.getCurrentUser();
      if (user == null) {
        return AuthState.unauthenticated;
      }

      // Se usuário está logado anonimamente
      if (user.isGuest) {
        return AuthState.anonymous;
      }

      // Usuário com conta real
      return AuthState.authenticated;
    } catch (e) {
      debugPrint('⚠️ [AuthenticationChecker] Erro ao verificar auth state: $e');
      return AuthState.unavailable;
    }
  }

  @override
  bool isAuthenticated() {
    final state = getCurrentAuthState();
    return state == AuthState.authenticated || state == AuthState.anonymous;
  }

  @override
  bool isRealUserAuthenticated() {
    return getCurrentAuthState() == AuthState.authenticated;
  }

  @override
  bool isGuestlyAuthenticated() {
    return getCurrentAuthState() == AuthState.anonymous;
  }

  @override
  UserRole getUserRole() {
    final authState = getCurrentAuthState();

    switch (authState) {
      case AuthState.authenticated:
        // Usuário com conta real - verificar se é admin
        return _checkIfAdmin() ? UserRole.admin : UserRole.user;

      case AuthState.anonymous:
        return UserRole.anonymous;

      case AuthState.unauthenticated:
      case AuthState.unavailable:
        return UserRole.guest;
    }
  }

  @override
  bool isAuthSystemAvailable() {
    // Verificar se auth service não falhou
    return _degradedModeService.isServiceAvailable(ServiceType.auth);
  }

  @override
  Map<String, dynamic> getUserInfo() {
    if (!isAuthSystemAvailable()) {
      return {
        'available': false,
        'reason': 'Auth system unavailable',
      };
    }

    try {
      final authController = Get.find<PlantasAuthController>();
      final user = authController.getCurrentUser();

      if (user == null) {
        return {
          'available': true,
          'authenticated': false,
        };
      }

      return {
        'available': true,
        'authenticated': true,
        'user_id': user.id,
        'email': user.email,
        'display_name': user.displayName,
        'is_anonymous': user.isGuest,
        'role': getUserRole().name,
        'auth_state': getCurrentAuthState().name,
      };
    } catch (e) {
      debugPrint('⚠️ [AuthenticationChecker] Erro ao obter user info: $e');
      return {
        'available': false,
        'error': e.toString(),
      };
    }
  }

  /// Verifica se o usuário atual é administrador
  bool _checkIfAdmin() {
    try {
      final authController = Get.find<PlantasAuthController>();
      final user = authController.getCurrentUser();

      if (user == null || user.isGuest) {
        return false;
      }

      // Lógica para verificar se é admin
      // Pode ser baseada em claims, roles, email específico, etc.
      final email = user.email.toLowerCase();

      // Exemplo: considerar emails específicos como admin
      final adminEmails = [
        'admin@plantapp.com',
        'administrador@plantapp.com',
      ];

      return adminEmails.contains(email);
    } catch (e) {
      debugPrint('⚠️ [AuthenticationChecker] Erro ao verificar admin: $e');
      return false;
    }
  }

  /// Obtém estatísticas do authentication checker
  @override
  Map<String, dynamic> getStats() {
    final authState = getCurrentAuthState();
    final userRole = getUserRole();

    return {
      'auth_system_available': isAuthSystemAvailable(),
      'current_auth_state': authState.name,
      'current_user_role': userRole.name,
      'is_authenticated': isAuthenticated(),
      'is_real_user': isRealUserAuthenticated(),
      'is_anonymous': isGuestlyAuthenticated(),
      'degraded_mode_active': _degradedModeService.isDegraded,
      'user_info_available': getUserInfo().containsKey('user_id'),
    };
  }

  /// Força uma re-verificação do estado de autenticação
  @override
  void refreshAuthState() {
    // Este método pode ser usado para forçar uma nova verificação
    // útil após mudanças no estado de autenticação
    debugPrint('🔄 [AuthenticationChecker] Forçando refresh do auth state');

    try {
      final currentState = getCurrentAuthState();
      final currentRole = getUserRole();

      debugPrint('📊 [AuthenticationChecker] Estado atual:');
      debugPrint('   Auth State: ${currentState.name}');
      debugPrint('   User Role: ${currentRole.name}');
      debugPrint('   System Available: ${isAuthSystemAvailable()}');
    } catch (e) {
      debugPrint('❌ [AuthenticationChecker] Erro no refresh: $e');
    }
  }

  /// Cria um NavigationContext baseado no estado atual
  @override
  NavigationContext createNavigationContext({
    DegradationLevel? degradationLevel,
    bool? isRecovering,
    Map<String, dynamic>? additionalData,
  }) {
    return NavigationContext.fromGetPlatform(
      authState: getCurrentAuthState(),
      userRole: getUserRole(),
      degradationLevel: degradationLevel ?? _degradedModeService.currentLevel,
      isRecovering: isRecovering ?? false,
      additionalData: additionalData ?? {},
    );
  }
}
