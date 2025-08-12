import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_details_page.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/maintenance/presentation/pages/add_maintenance_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/promo/presentation/pages/privacy_policy_page.dart';
import '../../features/promo/presentation/pages/terms_conditions_page.dart';
import '../../shared/widgets/main_navigation.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }
        
        if (isAuthenticated && isLoginRoute) {
          return '/';
        }
        
        return null;
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
            // Dashboard/Home
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const VehiclesPage(),
            ),
            
            // Vehicles
            GoRoute(
              path: '/vehicles',
              name: 'vehicles',
              builder: (context, state) => const VehiclesPage(),
              routes: [
                GoRoute(
                  path: '/details/:vehicleId',
                  name: 'vehicle_details',
                  builder: (context, state) {
                    final vehicleId = state.pathParameters['vehicleId']!;
                    return VehicleDetailsPage(vehicleId: vehicleId);
                  },
                ),
              ],
            ),
            
            // Fuel
            GoRoute(
              path: '/fuel',
              name: 'fuel',
              builder: (context, state) => const FuelPage(),
              routes: [
                GoRoute(
                  path: '/add',
                  name: 'add_fuel',
                  builder: (context, state) => const AddFuelPage(),
                ),
              ],
            ),
            
            // Maintenance
            GoRoute(
              path: '/maintenance',
              name: 'maintenance',
              builder: (context, state) => const MaintenancePage(),
              routes: [
                GoRoute(
                  path: '/add',
                  name: 'add_maintenance',
                  builder: (context, state) => const AddMaintenancePage(),
                ),
              ],
            ),
            
            // Reports
            GoRoute(
              path: '/reports',
              name: 'reports',
              builder: (context, state) => const ReportsPage(),
            ),
            
            // Profile
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
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
                'A página "${state.matchedLocation}" não existe.',
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
  }
}