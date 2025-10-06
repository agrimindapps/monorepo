import 'package:flutter/material.dart';

/// Interface for navigation services
abstract class INavigationService {
  /// Navigate to a named route
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments});
  
  /// Push a new page
  Future<T?> push<T extends Object?>(Widget page);
  
  /// Pop current page
  void pop<T extends Object?>([T? result]);
  
  /// Show snackbar
  void showSnackBar(SnackBar snackBar);
  
  /// Get current context
  BuildContext? get currentContext;
}

/// Mock implementation for development
class MockNavigationService implements INavigationService {
  BuildContext? _context;
  
  void setContext(BuildContext context) {
    _context = context;
  }
  
  @override
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) async {
    if (_context == null) return null;
    debugPrint('Navigate to: $routeName');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return null;
  }
  
  @override
  Future<T?> push<T extends Object?>(Widget page) async {
    if (_context == null) return null;
    
    return Navigator.of(_context!).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  @override
  void pop<T extends Object?>([T? result]) {
    if (_context == null) return;
    Navigator.of(_context!).pop(result);
  }
  
  @override
  void showSnackBar(SnackBar snackBar) {
    if (_context == null) return;
    ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
  }
  
  @override
  BuildContext? get currentContext => _context;
}