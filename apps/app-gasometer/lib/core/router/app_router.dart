import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/maintenance/presentation/pages/add_maintenance_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/odometer/presentation/pages/add_odometer_page.dart';
import '../../features/odometer/presentation/pages/odometer_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../shared/widgets/adaptive_main_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Web inicia em promo, Mobile/Desktop inicia em login
  const initialRoute = kIsWeb ? '/promo' : '/login';

  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    // Temporarily disable redirect logic to resolve initial route issues
    // redirect: (context, state) {
    //   // Simple auth redirect logic for now
    //   try {
    //     final authState = ref.read(authProvider);
    //     final isAuthenticated = authState.isAuthenticated;
    //     final isOnAuthPage = state.matchedLocation.startsWith('/login');

    //     // If not authenticated and not on auth page, redirect to login
    //     if (!isAuthenticated && !isOnAuthPage) {
    //       return '/login';
    //     }

    //     // If authenticated and on auth page, redirect to vehicles
    //     if (isAuthenticated && isOnAuthPage) {
    //       return '/vehicles';
    //     }

    //     return null; // No redirect needed
    //   } catch (e) {
    //     // If authProvider not ready, allow current navigation
    //     return null;
    //   }
    // },
    routes: [
      // Shell route para páginas principais com navegação
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveMainNavigation(child: child);
        },
        routes: [
          // Rota raiz redireciona para veículos
          GoRoute(
            path: '/',
            redirect: (context, state) => '/vehicles',
          ),
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
            path: '/odometer',
            name: 'odometer',
            builder: (context, state) => const OdometerPage(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-odometer',
                builder: (context, state) => const AddOdometerPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/maintenance',
            name: 'maintenance',
            builder: (context, state) => const MaintenancePage(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-maintenance',
                builder: (context, state) => const AddMaintenancePage(),
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
            builder: (context, state) => const ReportsPage(),
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
          GoRoute(
            path: '/premium',
            name: 'premium',
            builder: (context, state) => const PremiumPage(),
          ),
        ],
      ),

      // Auth routes (outside main navigation)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Promo page (outside main navigation) - Para Web
      GoRoute(
        path: '/promo',
        name: 'promo',
        builder: (context, state) => const PromoPage(),
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