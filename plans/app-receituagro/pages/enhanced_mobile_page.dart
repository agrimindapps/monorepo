// Enhanced mobile page with proper navigation lifecycle management
// Provides deep linking support and proper back button handling

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/mobile_page_controller_refactored.dart';
import '../router.dart';

/// Enhanced mobile page with proper lifecycle management
class EnhancedMobilePage extends GetView<MobilePageController> {
  const EnhancedMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Custom back button handling
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBackButton();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (!controller.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return _buildNavigationStructure();
    });
  }

  Widget _buildNavigationStructure() {
    return Navigator(
      key: controller.navigatorKey,
      initialRoute: AppRoutes.defensivosHome,
      onGenerateRoute: _onGenerateRoute,
      observers: [
        NavigationObserver(),
      ],
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');

    // Find matching route in AppPages
    final matchingPage = AppPages.routes.firstWhereOrNull(
      (page) => page.name == settings.name,
    );

    if (matchingPage != null) {
      return _createPageRoute(matchingPage, settings);
    }

    // Fallback to default route
    final defaultPage = AppPages.routes.firstWhereOrNull(
      (page) => page.name == AppRoutes.defensivosHome,
    );

    if (defaultPage != null) {
      debugPrint('Using default route: ${AppRoutes.defensivosHome}');
      return _createPageRoute(defaultPage, settings);
    }

    // Ultimate fallback - error page
    return _createErrorRoute(settings);
  }

  PageRoute _createPageRoute(GetPage page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        // Apply bindings before building page
        if (page.binding != null) {
          try {
            page.binding!.dependencies();
          } catch (e) {
            debugPrint('Warning: Failed to apply binding for ${page.name}: $e');
          }
        }

        return page.page();
      },
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth slide transition
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  PageRoute _createErrorRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        appBar: AppBar(
          title: const Text('Página não encontrada'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.goBack(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'A rota "${settings.name}" não existe.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.resetNavigation(),
                child: const Text('Ir para início'),
              ),
            ],
          ),
        ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  Future<void> _handleBackButton() async {
    try {
      if (controller.canGoBack) {
        await controller.goBack();
      } else {
        // If cannot go back, show exit confirmation
        await _showExitConfirmation();
      }
    } catch (e) {
      debugPrint('Back button handling error: $e');
    }
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sair do aplicativo'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }
}

/// Custom navigation observer for debugging and analytics
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('Navigation: Pushed ${route.settings.name}');
    
    // Here you could add analytics tracking
    _trackNavigation('push', route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('Navigation: Popped ${route.settings.name}');
    
    _trackNavigation('pop', route.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint('Navigation: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
    
    _trackNavigation('replace', newRoute?.settings.name);
  }

  void _trackNavigation(String action, String? routeName) {
    // Placeholder for navigation analytics
    // You could integrate with Firebase Analytics, etc.
    try {
      // Example: Analytics.track('navigation', {'action': action, 'route': routeName});
    } catch (e) {
      debugPrint('Navigation tracking error: $e');
    }
  }
}