import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Base abstract class for all authentication guards
abstract class AuthGuard {
  Future<String?> check(BuildContext context, GoRouterState state);
}

/// Guard that ensures user is authenticated
class AuthenticatedGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    
    return null; // Temporarily allow all access - implement with actual auth check
  }
}

/// Guard that ensures user has premium subscription
class PremiumGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    final authGuard = AuthenticatedGuard();
    final authCheck = await authGuard.check(context, state);
    if (authCheck != null) {
      return authCheck; // Not authenticated, redirect to login
    }
    
    return null; // Temporarily allow all access - implement with actual subscription check
  }
}

/// Guard that ensures user is not authenticated (for login/register pages)
class UnauthenticatedGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    
    return null; // Temporarily allow all access - implement with actual auth check
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
    return false;
  }
  
  void showPremiumUpgrade(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Required'),
        content: Text(
          'The feature "$premiumFeatureName" requires a premium subscription. '
          'Upgrade now to unlock all veterinary tools.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).push('/subscription');
            },
            child: const Text('Upgrade to Premium'),
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