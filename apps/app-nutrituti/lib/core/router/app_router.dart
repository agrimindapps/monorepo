import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/promo/presentation/pages/promo_page.dart';
import '../../pages/home/home_page.dart';

// Global navigator key for dialogs, snackbars, etc.
final rootNavigatorKey = GlobalKey<NavigatorState>();

// Initial route: Web goes to promo page, mobile goes directly to home
const _initialRoute = kIsWeb ? '/promo' : '/';

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: _initialRoute,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        // Use mobile or desktop based on screen width
        // Note: This will be determined by responsive layout in the widget itself
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/promo',
      name: 'promo',
      builder: (context, state) => const PromoPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const HomePage(), // TODO: Create dedicated login page
    ),
    // TODO: Add all other feature routes
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Página não encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Caminho: ${state.uri.path}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Voltar ao Início'),
          ),
        ],
      ),
    ),
  ),
);
