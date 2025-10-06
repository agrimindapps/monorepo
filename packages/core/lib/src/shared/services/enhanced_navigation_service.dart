import 'dart:async';

import 'package:flutter/material.dart';

import '../interfaces/i_navigation_extension.dart';
import '../models/navigation_state.dart';
import '../services/navigation_service.dart';

/// Enhanced navigation service with stack management, history, and extensions
class EnhancedNavigationService {
  final NavigationService _baseNavigationService;
  static const int _maxHistorySize = 10;
  static const int _maxStackSize = 20;

  final List<NavigationState> _navigationStack = [];
  final List<NavigationHistoryEntry> _navigationHistory = [];
  final Map<String, INavigationExtension> _extensions = {};
  final StreamController<NavigationState> _navigationStateController =
      StreamController<NavigationState>.broadcast();

  NavigationState? _currentState;
  bool _isNavigating = false;

  EnhancedNavigationService([NavigationService? baseNavigationService])
    : _baseNavigationService = baseNavigationService ?? NavigationService();

  /// Stream of navigation state changes
  Stream<NavigationState> get navigationStateStream =>
      _navigationStateController.stream;

  /// Current navigation state
  NavigationState? get currentState => _currentState;

  /// Current navigation stack
  List<NavigationState> get navigationStack =>
      List.unmodifiable(_navigationStack);

  /// Navigation history (last 10 entries)
  List<NavigationHistoryEntry> get navigationHistory =>
      List.unmodifiable(_navigationHistory);

  /// Is currently navigating
  bool get isNavigating => _isNavigating;

  /// Number of pages that can be popped
  int get stackSize => _navigationStack.length;

  void dispose() {
    _navigationStateController.close();
    for (final extension in _extensions.values) {
      extension.dispose();
    }
    _extensions.clear();
    // NavigationService doesn't have dispose method
  }

  /// Register a navigation extension
  void registerExtension(INavigationExtension extension) {
    _extensions[extension.extensionId] = extension;
    debugPrint('NavigationExtension registered: ${extension.extensionName}');
  }

  /// Unregister a navigation extension
  void unregisterExtension(String extensionId) {
    final extension = _extensions.remove(extensionId);
    extension?.dispose();
    debugPrint('NavigationExtension unregistered: $extensionId');
  }

  /// Get registered extension by ID
  INavigationExtension? getExtension(String extensionId) {
    return _extensions[extensionId];
  }

  /// Enhanced navigation with state management
  Future<T?> navigateTo<T>(
    String routeName, {
    Object? arguments,
    String? pageType,
    NavigationConfiguration? configuration,
    String? navigationSource,
  }) async {
    if (_isNavigating) {
      debugPrint('Navigation already in progress, ignoring request');
      return null;
    }

    try {
      _isNavigating = true;

      // Create navigation state
      final navigationState = NavigationState(
        pageType: pageType ?? routeName,
        route: routeName,
        arguments: arguments is Map<String, dynamic> ? arguments : null,
        configuration: configuration,
        timestamp: DateTime.now(),
        navigationSource: navigationSource,
      );

      // Process with extensions
      final processedConfiguration = await _processWithExtensions(
        navigationState.pageType,
        navigationState.arguments,
        configuration,
      );

      final finalState = navigationState.copyWith(
        configuration: processedConfiguration,
      );

      // Try custom navigation first
      final customHandled = await _tryCustomNavigation(finalState);
      if (customHandled) {
        return null;
      }

      // Update navigation stack
      _updateNavigationStack(finalState);

      // Perform navigation
      final result = await _baseNavigationService.navigateTo<T>(
        routeName,
        arguments: arguments,
      );

      // Update current state and notify listeners
      _currentState = finalState;
      _navigationStateController.add(finalState);

      return result;
    } catch (error, stackTrace) {
      debugPrint('Navigation error: $error');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isNavigating = false;
    }
  }

  /// Enhanced push with state management
  Future<T?> push<T>(
    Widget page, {
    String? pageType,
    Map<String, dynamic>? arguments,
    NavigationConfiguration? configuration,
    String? navigationSource,
  }) async {
    if (_isNavigating) {
      debugPrint('Navigation already in progress, ignoring push request');
      return null;
    }

    try {
      _isNavigating = true;

      // Create navigation state
      final navigationState = NavigationState(
        pageType: pageType ?? page.runtimeType.toString(),
        arguments: arguments,
        configuration: configuration,
        timestamp: DateTime.now(),
        navigationSource: navigationSource,
      );

      // Process with extensions
      final processedConfiguration = await _processWithExtensions(
        navigationState.pageType,
        navigationState.arguments,
        configuration,
      );

      final finalState = navigationState.copyWith(
        configuration: processedConfiguration,
      );

      // Update navigation stack
      _updateNavigationStack(finalState);

      // Perform navigation
      final result = await _baseNavigationService.push<T>(page);

      // Update current state and notify listeners
      _currentState = finalState;
      _navigationStateController.add(finalState);

      return result;
    } catch (error, stackTrace) {
      debugPrint('Push navigation error: $error');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isNavigating = false;
    }
  }

  /// Enhanced back navigation with history tracking
  Future<T?> goBack<T>([T? result]) async {
    if (_navigationStack.isEmpty) {
      debugPrint('Navigation stack is empty, cannot go back');
      _baseNavigationService.goBack<T>(result);
      return result;
    }

    // Get current state for history
    final currentState = _currentState;
    if (currentState != null) {
      final timeSpent = DateTime.now().difference(currentState.timestamp);
      _addToHistory(
        NavigationHistoryEntry(
          state: currentState,
          exitTime: DateTime.now(),
          timeSpent: timeSpent,
        ),
      );
    }

    // Remove from stack
    _navigationStack.removeLast();

    // Try extension back navigation
    if (currentState != null) {
      for (final extension in _extensions.values) {
        final handled = await extension.handleBackNavigation(currentState);
        if (handled) {
          return result;
        }
      }
    }

    // Update current state to previous
    _currentState = _navigationStack.isNotEmpty ? _navigationStack.last : null;
    if (_currentState != null) {
      _navigationStateController.add(_currentState!);
    }

    _baseNavigationService.goBack<T>(result);
    return result;
  }

  /// Navigate and replace current page
  Future<T?> navigateAndReplace<T>(
    String routeName, {
    Object? arguments,
    String? pageType,
    NavigationConfiguration? configuration,
  }) async {
    // Remove current page from stack if exists
    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
    }

    return await navigateTo<T>(
      routeName,
      arguments: arguments,
      pageType: pageType,
      configuration: configuration,
      navigationSource: 'replace',
    );
  }

  /// Navigate and clear all previous pages
  Future<T?> navigateAndClearStack<T>(
    String routeName, {
    Object? arguments,
    String? pageType,
    NavigationConfiguration? configuration,
  }) async {
    // Clear navigation stack
    _clearNavigationStack();

    return await navigateTo<T>(
      routeName,
      arguments: arguments,
      pageType: pageType,
      configuration: configuration,
      navigationSource: 'clear_stack',
    );
  }

  /// Can go back in navigation
  bool canGoBack() {
    return _navigationStack.length > 1;
  }

  /// Get navigation path as string list
  List<String> getNavigationPath() {
    return _navigationStack.map((state) => state.pageType).toList();
  }

  /// Get current page configuration
  NavigationConfiguration? getCurrentConfiguration() {
    return _currentState?.configuration;
  }

  /// Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
    debugPrint('Navigation history cleared');
  }

  /// Get analytics data for current session
  Map<String, dynamic> getSessionAnalytics() {
    return {
      'currentStack': _navigationStack.map((s) => s.toJson()).toList(),
      'historySize': _navigationHistory.length,
      'currentState': _currentState?.toJson(),
      'extensionsCount': _extensions.length,
      'isNavigating': _isNavigating,
    };
  }

  /// Process navigation with extensions
  Future<NavigationConfiguration?> _processWithExtensions(
    String pageType,
    Map<String, dynamic>? arguments,
    NavigationConfiguration? baseConfiguration,
  ) async {
    NavigationConfiguration? result = baseConfiguration;

    for (final extension in _extensions.values) {
      try {
        final extensionConfig = await extension.processNavigationRequest(
          pageType,
          arguments,
        );

        if (extensionConfig != null) {
          result =
              result?.copyWith(
                showBottomNavigation: extensionConfig.showBottomNavigation,
                showBackButton: extensionConfig.showBackButton,
                canGoBack: extensionConfig.canGoBack,
                customAppBarTitle:
                    extensionConfig.customAppBarTitle ??
                    result.customAppBarTitle,
                showAppBar: extensionConfig.showAppBar,
                showLoading: extensionConfig.showLoading,
                statusBarColor:
                    extensionConfig.statusBarColor ?? result.statusBarColor,
                extensionData: {
                  ...?result.extensionData,
                  ...?extensionConfig.extensionData,
                },
              ) ??
              extensionConfig;
        }
      } catch (error) {
        debugPrint('Extension processing error: $error');
      }
    }

    return result;
  }

  /// Try custom navigation with extensions
  Future<bool> _tryCustomNavigation(NavigationState state) async {
    for (final extension in _extensions.values) {
      try {
        final handled = await extension.handleCustomNavigation(
          state.pageType,
          state.arguments,
        );
        if (handled) {
          return true;
        }
      } catch (error) {
        debugPrint('Custom navigation error: $error');
      }
    }
    return false;
  }

  /// Update navigation stack
  void _updateNavigationStack(NavigationState state) {
    _navigationStack.add(state);

    // Maintain max stack size
    if (_navigationStack.length > _maxStackSize) {
      _navigationStack.removeAt(0);
    }
  }

  /// Add entry to navigation history
  void _addToHistory(NavigationHistoryEntry entry) {
    _navigationHistory.add(entry);

    // Maintain max history size
    if (_navigationHistory.length > _maxHistorySize) {
      _navigationHistory.removeAt(0);
    }
  }

  /// Clear navigation stack
  void _clearNavigationStack() {
    // Add current states to history before clearing
    for (final state in _navigationStack) {
      final timeSpent = DateTime.now().difference(state.timestamp);
      _addToHistory(
        NavigationHistoryEntry(
          state: state,
          exitTime: DateTime.now(),
          timeSpent: timeSpent,
        ),
      );
    }

    _navigationStack.clear();
    _currentState = null;
  }

  // ==========================================================================
  // BASE NAVIGATION SERVICE DELEGATION
  // ==========================================================================

  /// Show snackbar (delegated to base service)
  void showSnackBar(String message, {Color? backgroundColor}) {
    _baseNavigationService.showSnackBar(
      message,
      backgroundColor: backgroundColor,
    );
  }

  /// Open external URL (delegated to base service)
  Future<void> openUrl(String url) async {
    await _baseNavigationService.openUrl(url);
  }

  /// Navigate to premium page (delegated to base service)
  Future<T?> navigateToPremium<T>() async {
    return await _baseNavigationService.navigateToPremium<T>();
  }

  /// Get current build context (delegated to base service)
  BuildContext? get currentContext => _baseNavigationService.currentContext;
}
