import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';

/// Base abstract class for all authentication guards
abstract class AuthGuard {
  Future<String?> check(BuildContext context, GoRouterState state);
}

/// Guard that ensures user is authenticated
class AuthenticatedGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    // Get the auth state using provider
    // Note: In a real implementation, you'd inject this dependency
    // For now, we'll assume it's available in the widget tree
    
    // If user is not authenticated, redirect to login
    // This should be implemented with proper state management
    // Return null if access is allowed, return redirect path if not
    
    return null; // Temporarily allow all access - implement with actual auth check
  }
}

/// Guard that ensures user has premium subscription
class PremiumGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    // First check if user is authenticated
    final authGuard = AuthenticatedGuard();
    final authCheck = await authGuard.check(context, state);
    if (authCheck != null) {
      return authCheck; // Not authenticated, redirect to login
    }

    // Then check if user has premium subscription
    // This should check the actual subscription status
    // Return null if user has premium access, return redirect path if not
    
    return null; // Temporarily allow all access - implement with actual subscription check
  }
}

/// Guard that ensures user is not authenticated (for login/register pages)
class UnauthenticatedGuard implements AuthGuard {
  @override
  Future<String?> check(BuildContext context, GoRouterState state) async {
    // If user is authenticated, redirect to home
    // Return null if access is allowed (user not authenticated)
    // Return redirect path if user is already authenticated
    
    return null; // Temporarily allow all access - implement with actual auth check
  }
}

/// Middleware factory for creating route guards
class AuthMiddleware {
  static String? Function(BuildContext, GoRouterState) authenticated() {
    return (context, state) async {
      final guard = AuthenticatedGuard();
      return await guard.check(context, state);
    };
  }

  static String? Function(BuildContext, GoRouterState) premium() {
    return (context, state) async {
      final guard = PremiumGuard();
      return await guard.check(context, state);
    };
  }

  static String? Function(BuildContext, GoRouterState) unauthenticated() {
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
    
    // Check subscription status
    // This should be implemented with actual subscription provider
    // For now, return false to force premium upgrade
    return false;
  }
  
  void showPremiumUpgrade(BuildContext context) {
    showDialog(
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
              // Navigate to subscription page
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
    // Public routes (no guards)
    '/': [],
    '/login': [UnauthenticatedGuard],
    '/register': [UnauthenticatedGuard],
    '/splash': [],
    
    // Authenticated routes
    '/home': [AuthenticatedGuard],
    '/animals': [AuthenticatedGuard],
    '/appointments': [AuthenticatedGuard],
    '/profile': [AuthenticatedGuard],
    
    // Premium routes
    '/calculators': [PremiumGuard],
    '/advanced-calculators': [PremiumGuard],
    '/reports': [PremiumGuard],
    '/export': [PremiumGuard],
    '/cloud-sync': [PremiumGuard],
    
    // Subscription management
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