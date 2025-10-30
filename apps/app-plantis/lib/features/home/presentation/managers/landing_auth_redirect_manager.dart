import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Manages authentication-based page navigation and state
/// Isolates auth redirect logic from page widget
class LandingAuthRedirectManager {
  /// Check if should redirect to main app
  static bool shouldRedirect(bool isAuthenticated) {
    return isAuthenticated;
  }

  /// Navigate to main app
  static void redirectToMainApp(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go('/plants');
      }
    });
  }

  /// Navigate to login page
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  /// Navigate to register page
  static void goToRegister(BuildContext context) {
    context.go('/register');
  }
}
