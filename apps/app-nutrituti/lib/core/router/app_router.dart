import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app-page.dart';

// Global navigator key for dialogs, snackbars, etc.
final rootNavigatorKey = GlobalKey<NavigatorState>();

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NutriTutiAppPage(),
    ),
    // TODO: Add all other routes from routes.dart
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.uri.path}'),
    ),
  ),
);
