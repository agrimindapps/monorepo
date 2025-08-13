// Enhanced navigation controller for nested navigation management
// Solves navigation lifecycle issues with proper state management

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../router.dart';

/// Navigation state tracking
class NavigationState {
  final int currentTabIndex;
  final String currentRoute;
  final List<String> navigationHistory;
  final Map<int, String> tabRouteMapping;
  final DateTime lastNavigationTime;

  NavigationState({
    required this.currentTabIndex,
    required this.currentRoute,
    required this.navigationHistory,
    required this.tabRouteMapping,
    required this.lastNavigationTime,
  });

  NavigationState copyWith({
    int? currentTabIndex,
    String? currentRoute,
    List<String>? navigationHistory,
    Map<int, String>? tabRouteMapping,
    DateTime? lastNavigationTime,
  }) {
    return NavigationState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentRoute: currentRoute ?? this.currentRoute,
      navigationHistory: navigationHistory ?? List<String>.from(this.navigationHistory),
      tabRouteMapping: tabRouteMapping ?? Map<int, String>.from(this.tabRouteMapping),
      lastNavigationTime: lastNavigationTime ?? this.lastNavigationTime,
    );
  }
}

/// Enhanced navigation controller with proper lifecycle management
class EnhancedNavigationController extends GetxController {
  static const int _nestedNavigatorId = 1;
  
  // Navigation state
  final Rx<NavigationState> _state = NavigationState(
    currentTabIndex: 0,
    currentRoute: AppRoutes.defensivosHome,
    navigationHistory: [AppRoutes.defensivosHome],
    tabRouteMapping: {
      0: AppRoutes.defensivosHome,
      1: AppRoutes.pragasHome,
      2: AppRoutes.favoritos,
      3: AppRoutes.comentarios,
      4: AppRoutes.config,
    },
    lastNavigationTime: DateTime.now(),
  ).obs;

  // Navigator key for nested navigation
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  // Navigation guards
  bool _isNavigating = false;
  DateTime _lastNavigationAttempt = DateTime.now();
  
  // Getters
  NavigationState get state => _state.value;
  int get currentTabIndex => _state.value.currentTabIndex;
  String get currentRoute => _state.value.currentRoute;
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  List<String> get navigationHistory => _state.value.navigationHistory;
  bool get canGoBack => _state.value.navigationHistory.length > 1;

  @override
  void onInit() {
    super.onInit();
    _initializeNavigation();
  }

  /// Initialize navigation with safe defaults
  void _initializeNavigation() {
    debugPrint('Enhanced NavigationController initialized');
    debugPrint('Initial route: ${_state.value.currentRoute}');
    debugPrint('Initial tab: ${_state.value.currentTabIndex}');
  }

  /// Changes tab with proper navigation handling
  Future<bool> changeTab(int index) async {
    if (_isNavigating || index < 0 || index > 4) {
      debugPrint('Navigation blocked: isNavigating=$_isNavigating, index=$index');
      return false;
    }

    // Prevent rapid navigation
    final now = DateTime.now();
    if (now.difference(_lastNavigationAttempt).inMilliseconds < 300) {
      debugPrint('Navigation throttled: too rapid');
      return false;
    }

    _lastNavigationAttempt = now;
    _isNavigating = true;

    try {
      final route = _getRouteForTab(index);
      
      // Update state before navigation
      _updateState(
        currentTabIndex: index,
        currentRoute: route,
        lastNavigationTime: now,
      );

      final success = await _navigateToRoute(route);
      if (success) {
        _addToHistory(route);
        debugPrint('Tab changed successfully to: $index -> $route');
      } else {
        // Revert state on failure
        _revertStateOnFailure();
        debugPrint('Tab change failed for: $index -> $route');
      }

      return success;
    } catch (e) {
      debugPrint('Navigation error: $e');
      _revertStateOnFailure();
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to specific route with arguments
  Future<bool> navigateToRoute(String route, {dynamic arguments, bool preventDuplicates = true}) async {
    if (_isNavigating) {
      debugPrint('Navigation blocked: already navigating');
      return false;
    }

    // Prevent duplicate navigation
    if (preventDuplicates && route == _state.value.currentRoute) {
      debugPrint('Navigation prevented: duplicate route $route');
      return true; // Consider it successful since we're already there
    }

    _isNavigating = true;

    try {
      final success = await _navigateToRoute(route, arguments: arguments);
      if (success) {
        _updateState(
          currentRoute: route,
          lastNavigationTime: DateTime.now(),
        );
        _addToHistory(route);
        debugPrint('Navigation successful to: $route');
      }
      return success;
    } catch (e) {
      debugPrint('Navigation error: $e');
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Go back in navigation stack
  Future<bool> goBack() async {
    if (_isNavigating || !canGoBack) {
      debugPrint('Back navigation blocked: isNavigating=$_isNavigating, canGoBack=$canGoBack');
      return false;
    }

    _isNavigating = true;

    try {
      final navigator = _getNavigatorState();
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
        _removeFromHistory();
        debugPrint('Back navigation successful');
        return true;
      } else {
        // Fallback: navigate to previous route in history
        final history = _state.value.navigationHistory;
        if (history.length > 1) {
          final previousRoute = history[history.length - 2];
          _removeFromHistory(); // Remove current
          final success = await _navigateToRoute(previousRoute);
          if (success) {
            _updateState(currentRoute: previousRoute);
          }
          return success;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Back navigation error: $e');
      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// Clear navigation history (useful for deep links)
  void clearHistory() {
    _updateState(
      navigationHistory: [_state.value.currentRoute],
    );
    debugPrint('Navigation history cleared');
  }

  /// Get navigation statistics for debugging
  Map<String, dynamic> getNavigationStats() {
    return {
      'currentTabIndex': _state.value.currentTabIndex,
      'currentRoute': _state.value.currentRoute,
      'historyLength': _state.value.navigationHistory.length,
      'navigationHistory': _state.value.navigationHistory,
      'canGoBack': canGoBack,
      'isNavigating': _isNavigating,
      'lastNavigationTime': _state.value.lastNavigationTime.toIso8601String(),
    };
  }

  /// Handle deep links or external navigation
  Future<bool> handleDeepLink(String route, {dynamic arguments}) async {
    debugPrint('Handling deep link: $route');
    
    // Clear history for deep links
    clearHistory();
    
    // Update tab index if the route matches a tab
    final tabIndex = _getTabIndexForRoute(route);
    if (tabIndex != null) {
      _updateState(currentTabIndex: tabIndex);
    }
    
    return await navigateToRoute(route, arguments: arguments, preventDuplicates: false);
  }

  /// Reset navigation to initial state
  void resetNavigation() {
    _state.value = NavigationState(
      currentTabIndex: 0,
      currentRoute: AppRoutes.defensivosHome,
      navigationHistory: [AppRoutes.defensivosHome],
      tabRouteMapping: _state.value.tabRouteMapping,
      lastNavigationTime: DateTime.now(),
    );
    
    _isNavigating = false;
    debugPrint('Navigation reset to initial state');
  }

  // Private helper methods

  Future<bool> _navigateToRoute(String route, {dynamic arguments}) async {
    try {
      // Try nested navigation first
      final navigator = _getNavigatorState();
      if (navigator != null) {
        await navigator.pushReplacementNamed(route, arguments: arguments);
        return true;
      }

      // Fallback to GetX navigation
      Get.offAndToNamed(route, id: _nestedNavigatorId, arguments: arguments);
      return true;
    } catch (e) {
      debugPrint('Route navigation failed: $e');
      
      // Final fallback: direct GetX navigation without ID
      try {
        Get.offAndToNamed(route, arguments: arguments);
        return true;
      } catch (e2) {
        debugPrint('Fallback navigation also failed: $e2');
        return false;
      }
    }
  }

  NavigatorState? _getNavigatorState() {
    try {
      return _navigatorKey.currentState;
    } catch (e) {
      debugPrint('Could not get navigator state: $e');
      return null;
    }
  }

  String _getRouteForTab(int tabIndex) {
    return _state.value.tabRouteMapping[tabIndex] ?? AppRoutes.defensivosHome;
  }

  int? _getTabIndexForRoute(String route) {
    for (final entry in _state.value.tabRouteMapping.entries) {
      if (entry.value == route) {
        return entry.key;
      }
    }
    return null;
  }

  void _updateState({
    int? currentTabIndex,
    String? currentRoute,
    List<String>? navigationHistory,
    DateTime? lastNavigationTime,
  }) {
    _state.value = _state.value.copyWith(
      currentTabIndex: currentTabIndex,
      currentRoute: currentRoute,
      navigationHistory: navigationHistory,
      lastNavigationTime: lastNavigationTime,
    );
  }

  void _addToHistory(String route) {
    final currentHistory = _state.value.navigationHistory;
    
    // Prevent duplicates at the end
    if (currentHistory.isEmpty || currentHistory.last != route) {
      final newHistory = List<String>.from(currentHistory);
      newHistory.add(route);
      
      // Limit history size
      if (newHistory.length > 20) {
        newHistory.removeAt(0);
      }
      
      _updateState(navigationHistory: newHistory);
    }
  }

  void _removeFromHistory() {
    final currentHistory = _state.value.navigationHistory;
    if (currentHistory.length > 1) {
      final newHistory = List<String>.from(currentHistory);
      newHistory.removeLast();
      _updateState(
        navigationHistory: newHistory,
        currentRoute: newHistory.last,
      );
    }
  }

  void _revertStateOnFailure() {
    // In case of navigation failure, we could implement state reversion
    // For now, just log the issue
    debugPrint('Navigation failed, state may be inconsistent');
  }

  @override
  void onClose() {
    debugPrint('Enhanced NavigationController disposing');
    super.onClose();
  }
}