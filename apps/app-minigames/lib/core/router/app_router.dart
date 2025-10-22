import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_minigames/pages/mobile_page.dart';
import 'package:app_minigames/pages/desktop_page.dart';
import 'package:app_minigames/features/tower/presentation/pages/tower_page.dart';
import 'package:app_minigames/features/tictactoe/presentation/pages/tictactoe_page.dart';
import 'package:app_minigames/features/campo_minado/presentation/pages/campo_minado_page.dart';

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
    // Game routes
    GoRoute(
      path: '/tower',
      builder: (context, state) => const TowerPage(),
    ),
    GoRoute(
      path: '/tictactoe',
      builder: (context, state) => const TicTacToePage(),
    ),
    GoRoute(
      path: '/campo-minado',
      builder: (context, state) => const CampoMinadoPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.uri.path}'),
    ),
  ),
);
