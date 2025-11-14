import 'package:core/core.dart' ;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/notifiers/auth_notifier.dart';
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
import '../../features/vehicles/presentation/pages/add_vehicle_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../shared/widgets/adaptive_main_navigation.dart';
import 'auth_state_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  const initialRoute = kIsWeb ? '/promo' : '/login';

  // Cria um notifier para mudanças de autenticação
  final authStateNotifier = AuthStateNotifier();

  // Observa mudanças no estado de autenticação
  ref.listen(authProvider, (previous, next) {
    authStateNotifier.updateAuthState(next.isAuthenticated);
  });

  // Inicializa com o estado atual
  authStateNotifier.updateAuthState(ref.read(authProvider).isAuthenticated);

  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      // Rotas públicas que não precisam de autenticação
      const publicRoutes = [
        '/login',
        '/promo',
        '/privacy-policy',
        '/terms-of-service',
        '/account-deletion-policy',
      ];

      // Se estiver em uma rota pública, permite
      if (publicRoutes.contains(state.matchedLocation)) {
        return null;
      }

      // Apenas protege rotas no Web
      if (!kIsWeb) {
        return null;
      }

      // Verifica se está autenticado
      final isAuthenticated = authStateNotifier.isAuthenticated;

      // Se não está autenticado e está tentando acessar rota protegida, redireciona para login
      if (!isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveMainNavigation(child: child);
        },
        routes: [
          GoRoute(path: '/', redirect: (context, state) => '/vehicles'),
          GoRoute(
            path: '/vehicles',
            name: 'vehicles',
            builder: (context, state) => const VehiclesPage(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-vehicle',
                builder: (context, state) => const AddVehiclePage(),
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
              onPressed: () => context.go('/vehicles'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
});
