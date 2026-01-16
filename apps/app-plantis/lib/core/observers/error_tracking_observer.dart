import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/error_capture_provider.dart';

/// Navigator observer that tracks route changes for error context
class ErrorTrackingNavigatorObserver extends NavigatorObserver {
  ErrorTrackingNavigatorObserver(this.ref);

  final WidgetRef ref;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateRoute(newRoute);
    }
  }

  void _updateRoute(Route<dynamic> route) {
    final routeName = route.settings.name ?? 'unknown';
    try {
      final errorService = ref.read(errorCaptureServiceProvider);
      errorService.setCurrentRoute(routeName);
    } catch (_) {
      // Service might not be initialized yet
    }
  }
}

/// GoRouter listener for route changes
class ErrorTrackingRouterListener {
  ErrorTrackingRouterListener(this.ref);

  final WidgetRef ref;

  void onRouteChanged(GoRouterState state) {
    try {
      final errorService = ref.read(errorCaptureServiceProvider);
      errorService.setCurrentRoute(state.matchedLocation);
    } catch (_) {
      // Service might not be initialized yet
    }
  }
}
