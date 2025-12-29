import 'package:core/core.dart' ;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/notifiers/auth_notifier.dart';
import '../../features/activities/presentation/pages/activities_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/web_login_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/legal/presentation/pages/account_deletion_policy_page.dart';
import '../../features/legal/presentation/pages/privacy_policy_page.dart';
import '../../features/legal/presentation/pages/terms_of_service_page.dart';
import '../../features/maintenance/presentation/pages/add_maintenance_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/odometer/presentation/pages/add_odometer_page.dart';
import '../../features/odometer/presentation/pages/odometer_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import '../../features/tools/presentation/pages/dashboard_indicator_detail_page.dart';
import '../../features/tools/presentation/pages/dashboard_indicators_page.dart';
import '../../features/tools/presentation/pages/flex_calculator_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/vehicles/presentation/pages/add_vehicle_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../shared/widgets/adaptive_main_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  const initialRoute = kIsWeb ? '/promo' : '/login';

  // Cria um notifier para mudanças de autenticação
  final authStateNotifier = ValueNotifier<bool>(false);

  // Observa mudanças no estado de autenticação
  ref.listen(authProvider, (previous, next) {
    authStateNotifier.value = next.isAuthenticated;
  });

  // Inicializa com o estado atual
  authStateNotifier.value = ref.read(authProvider).isAuthenticated;

  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      // Rotas de autenticação (login/promo)
      const authRoutes = ['/login', '/promo'];
      
      // Rotas públicas que não precisam de autenticação
      const publicRoutes = [
        '/login',
        '/promo',
        '/privacy-policy',
        '/terms-of-service',
        '/account-deletion-policy',
      ];

      final isAuthenticated = authStateNotifier.value;
      final currentLocation = state.matchedLocation;

      // Se está autenticado e está em rota de auth (login/promo), redireciona para home
      if (isAuthenticated && authRoutes.contains(currentLocation)) {
        return '/timeline';
      }

      // Se estiver em uma rota pública, permite
      if (publicRoutes.contains(currentLocation)) {
        return null;
      }

      // Apenas protege rotas no Web
      if (!kIsWeb) {
        return null;
      }

      // Se não está autenticado e está tentando acessar rota protegida, redireciona para login
      if (!isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveMainNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Timeline (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                redirect: (context, state) => '/timeline',
              ),
              GoRoute(
                path: '/timeline',
                name: 'timeline',
                builder: (context, state) => const TimelinePage(),
              ),
            ],
          ),

          // Branch 1: Vehicles
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vehicles',
                name: 'vehicles',
                builder: (context, state) => const VehiclesPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-vehicle',
                    builder: (context, state) => const AddVehiclePage(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Activities (Recent records from all categories)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activities',
                name: 'activities',
                builder: (context, state) => const ActivitiesPage(),
              ),
            ],
          ),

          // Branch 3: Tools
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                name: 'tools',
                builder: (context, state) => const ToolsPage(),
              ),
              // Reports now accessible via Tools
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const ReportsPage(),
              ),
              // Flex Calculator
              GoRoute(
                path: '/tools/flex-calculator',
                name: 'flex-calculator',
                builder: (context, state) => const FlexCalculatorPage(),
              ),
              // Dashboard Indicators
              GoRoute(
                path: '/tools/dashboard-indicators',
                name: 'dashboard-indicators',
                builder: (context, state) => const DashboardIndicatorsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'dashboard-indicator-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return DashboardIndicatorDetailPage(indicatorId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 4: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: '/privacy-policy',
                name: 'privacy-policy',
                builder: (context, state) => const PrivacyPolicyPage(),
              ),
              GoRoute(
                path: '/terms-of-service',
                name: 'terms-of-service',
                builder: (context, state) => const TermsOfServicePage(),
              ),
              GoRoute(
                path: '/account-deletion-policy',
                name: 'account-deletion-policy',
                builder: (context, state) => const AccountDeletionPolicyPage(),
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

          // Branch 5: Fuel
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fuel',
                name: 'fuel',
                builder: (context, state) => const FuelPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-fuel',
                    builder: (context, state) {
                      final vehicleId = state.uri.queryParameters['vehicleId'];
                      return AddFuelPage(vehicleId: vehicleId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 6: Maintenance
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/maintenance',
                name: 'maintenance',
                builder: (context, state) => const MaintenancePage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-maintenance',
                    builder: (context, state) {
                      final vehicleId = state.uri.queryParameters['vehicleId'];
                      return AddMaintenancePage(vehicleId: vehicleId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 7: Expenses
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                name: 'expenses',
                builder: (context, state) => const ExpensesPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-expense',
                    builder: (context, state) {
                      final vehicleId = state.uri.queryParameters['vehicleId'];
                      return AddExpensePage(vehicleId: vehicleId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 8: Odometer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/odometer',
                name: 'odometer',
                builder: (context, state) => const OdometerPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-odometer',
                    builder: (context, state) {
                      final vehicleId = state.uri.queryParameters['vehicleId'];
                      return AddOdometerPage(vehicleId: vehicleId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          // Web usa página sem opção de cadastro
          // Mobile/Desktop usam página completa com cadastro
          return kIsWeb ? const WebLoginPage() : const LoginPage();
        },
      ),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
              onPressed: () => context.go('/timeline'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
});
