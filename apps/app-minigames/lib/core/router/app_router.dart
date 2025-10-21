import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_minigames/pages/mobile_page.dart';
import 'package:app_minigames/pages/desktop_page.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // Responsive layout - escolhe mobile ou desktop
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return const MobilePageMain();
            } else {
              return const DesktopPageMain();
            }
          },
        );
      },
    ),
    // TODO: Add game routes
    // GoRoute(
    //   path: '/game-2048',
    //   builder: (context, state) => const Game2048Page(),
    // ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.uri.path}'),
    ),
  ),
);
