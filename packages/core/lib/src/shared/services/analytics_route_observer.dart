import 'package:flutter/material.dart';

import '../../domain/repositories/i_analytics_repository.dart';
import 'navigation_analytics_service.dart';

/// A NavigatorObserver that automatically tracks screen views with Firebase Analytics.
///
/// This observer integrates with GoRouter and any Navigator-based routing to provide:
/// - Automatic screen view tracking on navigation
/// - Page exit tracking with time spent calculation
/// - Back navigation tracking
/// - Support for custom screen names via route settings
///
/// **Usage with GoRouter:**
/// ```dart
/// final router = GoRouter(
///   observers: [
///     AnalyticsRouteObserver(
///       analyticsRepository: ref.read(analyticsRepositoryProvider),
///       navigationAnalytics: ref.read(navigationAnalyticsServiceProvider),
///     ),
///   ],
///   routes: [...],
/// );
/// ```
///
/// **Custom screen names:**
/// Use route name or provide custom names in route settings:
/// ```dart
/// GoRoute(
///   path: '/dashboard',
///   name: 'dashboard', // This will be used as screen name
///   builder: (context, state) => const DashboardPage(),
/// )
/// ```
class AnalyticsRouteObserver extends NavigatorObserver {
  final IAnalyticsRepository? _analyticsRepository;
  final NavigationAnalyticsService? _navigationAnalytics;
  final bool _enableDebugLogging;
  final String? _appPrefix;

  /// Stack to track current routes for time calculation
  final List<_RouteInfo> _routeStack = [];

  /// Creates an AnalyticsRouteObserver
  ///
  /// Parameters:
  /// - [analyticsRepository]: Repository for logging screen views to Firebase
  /// - [navigationAnalytics]: Optional service for detailed navigation analytics
  /// - [enableDebugLogging]: Enable debug prints (default: false)
  /// - [appPrefix]: Optional prefix for screen names (e.g., 'gasometer_')
  AnalyticsRouteObserver({
    IAnalyticsRepository? analyticsRepository,
    NavigationAnalyticsService? navigationAnalytics,
    bool enableDebugLogging = false,
    String? appPrefix,
  })  : _analyticsRepository = analyticsRepository,
        _navigationAnalytics = navigationAnalytics,
        _enableDebugLogging = enableDebugLogging,
        _appPrefix = appPrefix;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreenView(route, NavigationType.push);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackScreenExit(route);
    
    if (previousRoute != null) {
      _trackBackNavigation(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    
    if (oldRoute != null) {
      _trackScreenExit(oldRoute);
    }
    
    if (newRoute != null) {
      _trackScreenView(newRoute, NavigationType.replace);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _trackScreenExit(route);
  }

  /// Extracts screen name from route
  String _extractScreenName(Route<dynamic> route) {
    // Try to get name from route settings
    final settings = route.settings;
    String? screenName = settings.name;

    // Handle GoRouter paths
    if (screenName != null && screenName.isNotEmpty) {
      // Remove leading slash and query parameters
      screenName = screenName.split('?').first;
      if (screenName.startsWith('/')) {
        screenName = screenName.substring(1);
      }
      
      // Convert path to readable name (e.g., 'fuel/add' -> 'fuel_add')
      screenName = screenName.replaceAll('/', '_');
      
      // Handle empty path (root)
      if (screenName.isEmpty) {
        screenName = 'home';
      }
    } else {
      // Fallback to route type
      screenName = route.runtimeType.toString();
    }

    // Add app prefix if specified
    if (_appPrefix != null && _appPrefix.isNotEmpty) {
      screenName = '$_appPrefix$screenName';
    }

    return screenName;
  }

  /// Tracks screen view
  Future<void> _trackScreenView(
    Route<dynamic> route,
    NavigationType type,
  ) async {
    final screenName = _extractScreenName(route);
    final timestamp = DateTime.now();

    // Add to route stack
    _routeStack.add(_RouteInfo(
      screenName: screenName,
      entryTime: timestamp,
      route: route,
    ));

    if (_enableDebugLogging) {
      debugPrint('📱 [Analytics] Screen view: $screenName (${type.name})');
    }

    // Log to Firebase Analytics
    try {
      await _analyticsRepository?.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: route.runtimeType.toString(),
      );
    } catch (e) {
      if (_enableDebugLogging) {
        debugPrint('❌ [Analytics] Error logging screen view: $e');
      }
    }

    // Log to Navigation Analytics Service
    try {
      await _navigationAnalytics?.trackPageView(
        screenName,
        {
          'navigation_type': type.name,
          'timestamp': timestamp.millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      if (_enableDebugLogging) {
        debugPrint('❌ [Analytics] Error tracking page view: $e');
      }
    }
  }

  /// Tracks screen exit with time spent
  Future<void> _trackScreenExit(Route<dynamic> route) async {
    final screenName = _extractScreenName(route);

    // Find and remove from stack
    final routeIndex = _routeStack.lastIndexWhere(
      (info) => info.screenName == screenName,
    );

    if (routeIndex >= 0) {
      final routeInfo = _routeStack.removeAt(routeIndex);
      final timeSpent = DateTime.now().difference(routeInfo.entryTime);

      if (_enableDebugLogging) {
        debugPrint(
          '📱 [Analytics] Screen exit: $screenName (${timeSpent.inSeconds}s)',
        );
      }

      // Log to Navigation Analytics Service
      try {
        await _navigationAnalytics?.trackPageExit(screenName);
      } catch (e) {
        if (_enableDebugLogging) {
          debugPrint('❌ [Analytics] Error tracking page exit: $e');
        }
      }
    }
  }

  /// Tracks back navigation
  Future<void> _trackBackNavigation(
    Route<dynamic> fromRoute,
    Route<dynamic> toRoute,
  ) async {
    final fromScreen = _extractScreenName(fromRoute);
    final toScreen = _extractScreenName(toRoute);

    if (_enableDebugLogging) {
      debugPrint('📱 [Analytics] Back navigation: $fromScreen -> $toScreen');
    }

    try {
      await _navigationAnalytics?.trackBackNavigation(fromScreen, toScreen);
    } catch (e) {
      if (_enableDebugLogging) {
        debugPrint('❌ [Analytics] Error tracking back navigation: $e');
      }
    }
  }

  /// Gets current screen name
  String? get currentScreenName {
    return _routeStack.isNotEmpty ? _routeStack.last.screenName : null;
  }

  /// Gets navigation stack as list of screen names
  List<String> get navigationPath {
    return _routeStack.map((info) => info.screenName).toList();
  }

  /// Clears tracking data (call on logout/session end)
  void clearTrackingData() {
    _routeStack.clear();
    _navigationAnalytics?.clearSessionData();
    
    if (_enableDebugLogging) {
      debugPrint('📱 [Analytics] Tracking data cleared');
    }
  }
}

/// Navigation type for analytics
enum NavigationType {
  push,
  replace,
  pop,
}

/// Internal class to track route information
class _RouteInfo {
  final String screenName;
  final DateTime entryTime;
  final Route<dynamic> route;

  _RouteInfo({
    required this.screenName,
    required this.entryTime,
    required this.route,
  });
}
