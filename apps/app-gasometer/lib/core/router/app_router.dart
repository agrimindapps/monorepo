import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Start with a simple initial route - we'll handle auth redirect logic in splash
  final initialRoute = '/vehicles';

  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Simple auth redirect logic for now
      try {
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.isAuthenticated;
        final isOnAuthPage = state.matchedLocation.startsWith('/login');

        // If not authenticated and not on auth page, redirect to login
        if (!isAuthenticated && !isOnAuthPage) {
          return '/login';
        }

        // If authenticated and on auth page, redirect to vehicles
        if (isAuthenticated && isOnAuthPage) {
          return '/vehicles';
        }

        return null; // No redirect needed
      } catch (e) {
        // If authProvider not ready, allow current navigation
        return null;
      }
    },
    routes: [
      // Main app routes
      GoRoute(
        path: '/vehicles',
        name: 'vehicles',
        builder: (context, state) => const VehiclesPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-vehicle',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Vehicle Page - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/fuel',
        name: 'fuel',
        builder: (context, state) => const FuelPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-fuel',
            builder: (context, state) => const AddFuelPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/maintenance',
        name: 'maintenance',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Maintenance Page - Coming Soon'),
          ),
        ),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-maintenance',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Maintenance Page - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpensesPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-expense',
            builder: (context, state) => const AddExpensePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Reports Page - Coming Soon'),
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Auth routes (outside main navigation)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/vehicles'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
});