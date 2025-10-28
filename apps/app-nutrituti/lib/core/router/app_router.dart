import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/mobile_page.dart';

// Global navigator key for dialogs, snackbars, etc.
final rootNavigatorKey = GlobalKey<NavigatorState>();

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // Use mobile or desktop based on screen width
        // Note: This will be determined by responsive layout in the widget itself
        return const MobilePageNutriTuti();
      },
    ),
    // TODO: Add all other feature routes
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.uri.path}'),
    ),
  ),
);
