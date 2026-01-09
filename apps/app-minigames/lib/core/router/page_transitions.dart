import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for smoother navigation
/// 
/// Provides fade and slide transitions instead of the default
/// Material page transitions that come from the edge of the screen

/// Duration for page transitions
const Duration _transitionDuration = Duration(milliseconds: 250);

/// Creates a fade transition page
/// 
/// Use this for most navigations - provides a smooth fade in/out effect
CustomTransitionPage<T> fadeTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
  Duration duration = _transitionDuration,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

/// Creates a fade + scale transition page
/// 
/// Provides a subtle zoom effect along with fade - good for modal-like pages
CustomTransitionPage<T> fadeScaleTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
  Duration duration = _transitionDuration,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Creates a slide up + fade transition page
/// 
/// Good for pages that feel like they're coming from below (like modals)
CustomTransitionPage<T> slideUpFadeTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
  Duration duration = _transitionDuration,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Creates a shared axis transition (horizontal)
/// 
/// Subtle horizontal movement - good for navigation between sibling pages
CustomTransitionPage<T> sharedAxisTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
  Duration duration = _transitionDuration,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Extension on GoRoute for easier transition configuration
extension GoRouteTransitions on GoRoute {
  /// Creates a GoRoute with fade transition
  static GoRoute fade({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
    String? name,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      pageBuilder: (context, state) => fadeTransitionPage(
        child: builder(context, state),
        state: state,
      ),
    );
  }
}
