import 'package:core/core.dart' hide isAuthenticatedProvider, subscriptionProvider, SubscriptionState;
import 'package:flutter/material.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../logging/entities/log_entry.dart';
import '../logging/services/logging_service.dart';

/// Base abstract class for all authentication guards
abstract class AuthGuard {
  Future<String?> check(BuildContext context, GoRouterState state);
}

/// Guard that ensures user is authenticated
class AuthenticatedGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    try {
      final container = ProviderScope.containerOf(context);
      final isAuthenticated = container.read<bool>(isAuthenticatedProvider);

      if (!isAuthenticated) {
        // Store the intended destination to redirect after login
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      return null; // Allow access
    } catch (e) {
      // If provider is not available, redirect to login for safety
      LoggingService.instance.logError(
        category: LogCategory.auth,
        operation: LogOperation.validate,
        message: 'AuthGuard: Error checking authentication',
        error: e,
      );
      return '/login';
    }
  }
}

/// Guard that ensures user has premium subscription
class PremiumGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    try {
      final container = ProviderScope.containerOf(context);

      // First check authentication
      final isAuthenticated = container.read<bool>(isAuthenticatedProvider);
      if (!isAuthenticated) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      // Then check premium subscription
      final hasPremium = container.read<SubscriptionState>(subscriptionProvider).hasPremium;
      if (!hasPremium) {
        // Redirect to subscription page with the feature they tried to access
        return '/subscription?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      return null; // Allow access
    } catch (e) {
      // If provider is not available, redirect to subscription for safety
      LoggingService.instance.logError(
        category: LogCategory.auth,
        operation: LogOperation.validate,
        message: 'PremiumGuard: Error checking premium status',
        error: e,
      );
      return '/subscription';
    }
  }
}

/// Guard that ensures user is not authenticated (for login/register pages)
class UnauthenticatedGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    try {
      final container = ProviderScope.containerOf(context);
      final isAuthenticated = container.read<bool>(isAuthenticatedProvider);

      if (isAuthenticated) {
        // Already authenticated, redirect to home
        return '/home';
      }

      return null; // Allow access to login/register
    } catch (e) {
      // If provider is not available, allow access (assume not authenticated)
      LoggingService.instance.logError(
        category: LogCategory.auth,
        operation: LogOperation.validate,
        message: 'UnauthenticatedGuard: Error checking authentication',
        error: e,
      );
      return null;
    }
  }
}

/// Middleware factory for creating route guards
class AuthMiddleware {
  static Future<String?> Function(BuildContext, GoRouterState) authenticated() {
    return (context, state) async {
      final guard = AuthenticatedGuard();
      return await guard.check(context, state);
    };
  }

  static Future<String?> Function(BuildContext, GoRouterState) premium() {
    return (context, state) async {
      final guard = PremiumGuard();
      return await guard.check(context, state);
    };
  }

  static Future<String?> Function(BuildContext, GoRouterState) unauthenticated() {
    return (context, state) async {
      final guard = UnauthenticatedGuard();
      return await guard.check(context, state);
    };
  }
}

/// Premium feature access control mixin
mixin PremiumFeatureAccess {
  bool get requiresPremium => true;
  String get premiumFeatureName;

  Future<bool> canAccessPremiumFeature(BuildContext context) async {
    if (!requiresPremium) return true;

    try {
      final container = ProviderScope.containerOf(context);
      final hasPremium = container.read<SubscriptionState>(subscriptionProvider).hasPremium;
      return hasPremium;
    } catch (e) {
      LoggingService.instance.logError(
        category: LogCategory.subscriptions,
        operation: LogOperation.validate,
        message: 'PremiumFeatureAccess: Error checking premium access for $premiumFeatureName',
        error: e,
      );
      return false;
    }
  }

  void showPremiumUpgrade(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Necessário'),
        content: Text(
          'A funcionalidade "$premiumFeatureName" requer uma assinatura premium. '
          'Atualize agora para desbloquear todas as ferramentas veterinárias.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).push('/subscription');
            },
            child: const Text('Assinar Premium'),
          ),
        ],
      ),
    );
  }
}

/// Route protection configuration
class RouteProtection {
  static const Map<String, List<Type>> routeGuards = {
    '/': [],
    '/login': [UnauthenticatedGuard],
    '/register': [UnauthenticatedGuard],
    '/splash': [],
    '/home': [AuthenticatedGuard],
    '/animals': [AuthenticatedGuard],
    '/appointments': [AuthenticatedGuard],
    '/profile': [AuthenticatedGuard],
    '/calculators': [PremiumGuard],
    '/advanced-calculators': [PremiumGuard],
    '/reports': [PremiumGuard],
    '/export': [PremiumGuard],
    '/cloud-sync': [PremiumGuard],
    '/subscription': [AuthenticatedGuard],
    '/subscription/manage': [AuthenticatedGuard],
  };
  
  static bool isProtectedRoute(String path) {
    return routeGuards.containsKey(path) && routeGuards[path]!.isNotEmpty;
  }
  
  static bool isPremiumRoute(String path) {
    final guards = routeGuards[path] ?? [];
    return guards.contains(PremiumGuard);
  }
  
  static bool requiresAuth(String path) {
    final guards = routeGuards[path] ?? [];
    return guards.contains(AuthenticatedGuard) || guards.contains(PremiumGuard);
  }
}
