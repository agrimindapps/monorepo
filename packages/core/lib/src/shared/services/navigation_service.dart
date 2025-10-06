import 'package:flutter/material.dart';
import '../../features/subscription/subscription_page.dart';

/// Interface for navigation services
abstract class INavigationService {
  /// Navigate to a named route
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments});
  
  /// Navigate to premium/subscription page
  Future<T?> navigateToPremium<T extends Object?>();
  
  /// Push a new page
  Future<T?> push<T extends Object?>(Widget page);
  
  /// Pop current page
  void goBack<T extends Object?>([T? result]);
  
  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor});
  
  /// Open external URL
  Future<void> openUrl(String url);
  
  /// Open external URL (alias for compatibility)
  Future<void> openExternalUrl(String url);
  
  /// Get current context
  BuildContext? get currentContext;
}

/// Production implementation of NavigationService
class NavigationService implements INavigationService {
  /// Global navigator key for accessing navigation context
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('NavigationService: Navigator not available for route: $routeName');
      return null;
    }
    
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }
  
  @override
  Future<T?> navigateToPremium<T extends Object?>() async {
    debugPrint('NavigationService: Navigating to premium page');
    return push<T>(const SubscriptionPage());
  }
  
  @override
  Future<T?> push<T extends Object?>(Widget page) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('NavigationService: Navigator not available for push');
      return null;
    }
    
    return navigator.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  @override
  void goBack<T extends Object?>([T? result]) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('NavigationService: Navigator not available for goBack');
      return;
    }
    
    if (navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }
  
  @override
  void showSnackBar(String message, {Color? backgroundColor}) {
    final context = currentContext;
    if (context == null) {
      debugPrint('NavigationService: Context not available for snackbar: $message');
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  @override
  Future<void> openUrl(String url) async {
    try {
      debugPrint('NavigationService: Opening URL: $url');
      final context = currentContext;
      if (context != null) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Abrir Link'),
            content: SelectableText(
              'Link será aberto no navegador:\n\n$url',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('NavigationService: Error opening URL: $e');
      showSnackBar('Erro ao abrir link', backgroundColor: Colors.red);
    }
  }

  @override
  Future<void> openExternalUrl(String url) async {
    return openUrl(url);
  }
  
  @override
  BuildContext? get currentContext => navigatorKey.currentContext;
}

/// Mock implementation for development and testing
class MockNavigationService implements INavigationService {
  BuildContext? _context;
  
  /// Set the context for mock navigation operations
  
  void setContext(BuildContext context) {
    _context = context;
  }
  
  @override
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) async {
    debugPrint('MockNavigationService: Navigate to $routeName');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return null;
  }
  
  @override
  Future<T?> navigateToPremium<T extends Object?>() async {
    debugPrint('MockNavigationService: Navigate to premium page');
    
    if (_context != null) {
      return Navigator.of(_context!).push<T>(
        MaterialPageRoute(builder: (_) => const SubscriptionPage()),
      );
    }
    
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return null;
  }
  
  @override
  Future<T?> push<T extends Object?>(Widget page) async {
    if (_context == null) {
      debugPrint('MockNavigationService: Context not available for push');
      return null;
    }
    
    return Navigator.of(_context!).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  @override
  void goBack<T extends Object?>([T? result]) {
    if (_context == null) {
      debugPrint('MockNavigationService: Context not available for goBack');
      return;
    }
    
    if (Navigator.of(_context!).canPop()) {
      Navigator.of(_context!).pop<T>(result);
    }
  }
  
  @override
  void showSnackBar(String message, {Color? backgroundColor}) {
    if (_context == null) {
      debugPrint('MockNavigationService: Context not available for snackbar: $message');
      return;
    }
    
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
  
  @override
  Future<void> openUrl(String url) async {
    debugPrint('MockNavigationService: Opening URL: $url');
    
    if (_context != null) {
      await showDialog<void>(
        context: _context!,
        builder: (context) => AlertDialog(
          title: const Text('Abrir Link (Mock)'),
          content: SelectableText(
            'Mock: Link que seria aberto:\n\n$url',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
    
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> openExternalUrl(String url) async {
    return openUrl(url);
  }
  
  @override
  BuildContext? get currentContext => _context;
}