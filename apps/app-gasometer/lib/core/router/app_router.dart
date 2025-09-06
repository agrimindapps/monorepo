import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/ui_constants.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/odometer/presentation/pages/odometer_page.dart';
import '../../features/promo/presentation/pages/privacy_policy_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/promo/presentation/pages/terms_conditions_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../shared/widgets/main_navigation.dart';
import '../services/platform_service.dart';
import 'guards/route_guard.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    // Safely get AuthProvider with null check during initialization
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
    } catch (e) {
      // Provider not ready yet during initialization - will be set later
      authProvider = null;
    }

    const platformService = PlatformService();
    final routeGuard = RouteGuard(authProvider, platformService);

    return GoRouter(
      initialLocation: '/', // Always start with home - let redirect handle the logic
      redirect: (context, state) {
        // Update authProvider on each redirect check
        AuthProvider? currentAuthProvider;
        try {
          currentAuthProvider = Provider.of<AuthProvider>(context, listen: false);
        } catch (e) {
          currentAuthProvider = null;
        }
        
        final updatedRouteGuard = RouteGuard(currentAuthProvider, platformService);
        return updatedRouteGuard.handleRedirect(state.matchedLocation);
      },
      routes: [
        // Promo Routes (Landing Page and Policies)
        GoRoute(
          path: '/promo',
          name: 'promo',
          builder: (context, state) => const PromoPage(),
        ),

        // Privacy Policy Route
        GoRoute(
          path: '/privacy',
          name: 'privacy',
          builder: (context, state) => const PrivacyPolicyPage(),
        ),

        // Terms & Conditions Route
        GoRoute(
          path: '/terms',
          name: 'terms',
          builder: (context, state) => const TermsConditionsPage(),
        ),

        // Auth Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // Main Shell Route
        ShellRoute(
          builder: (context, state, child) => MainNavigation(child: child),
          routes: [
            // Home - Vehicles
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const VehiclesPage(),
            ),

            // Odometer
            GoRoute(
              path: '/odometer',
              name: 'odometer',
              builder: (context, state) => const OdometerPage(),
            ),

            // Fuel
            GoRoute(
              path: '/fuel',
              name: 'fuel',
              builder: (context, state) => const FuelPage(),
            ),

            // Expenses
            GoRoute(
              path: '/expenses',
              name: 'expenses',
              builder: (context, state) => const ExpensesPage(),
            ),

            // Maintenance
            GoRoute(
              path: '/maintenance',
              name: 'maintenance',
              builder: (context, state) => const MaintenancePage(),
            ),

            // Reports
            GoRoute(
              path: '/reports',
              name: 'reports',
              builder: (context, state) => const ReportsPage(),
            ),

            // Settings
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppSizes.iconXXL,
                color: Colors.red,
              ),
              const SizedBox(height: AppSpacing.large),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'A página "${state.matchedLocation}" não existe.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxlarge),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
