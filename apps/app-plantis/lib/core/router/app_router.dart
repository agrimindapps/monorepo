import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../../features/account/account_profile_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/data_export/presentation/pages/data_export_page.dart';
import '../../features/device_management/presentation/pages/device_management_page.dart';
import '../../features/device_management/presentation/providers/device_management_provider.dart';
import '../../features/legal/presentation/pages/account_deletion_page.dart';
import '../../features/legal/presentation/pages/privacy_policy_page.dart';
import '../../features/legal/presentation/pages/promotional_page.dart';
import '../../features/legal/presentation/pages/terms_of_service_page.dart';
import '../../features/license/pages/license_status_page.dart';
import '../../features/plants/presentation/pages/plant_details_page.dart';
import '../../features/plants/presentation/pages/plant_form_page.dart';
import '../../features/plants/presentation/pages/plants_list_page.dart';
import '../../features/premium/presentation/pages/premium_subscription_page.dart';
import '../../features/settings/presentation/pages/backup_settings_page.dart';
import '../../features/settings/presentation/pages/notifications_settings_page.dart';
import '../../features/tasks/presentation/pages/tasks_list_page.dart';
import '../../features/home/pages/landing_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/desktop_keyboard_shortcuts.dart';
import '../../shared/widgets/web_optimized_navigation.dart';
import '../di/injection_container.dart';
import '../providers/auth_providers.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String landing = '/welcome';
  static const String plants = '/plants';
  static const String plantDetails = '/plants/:id';
  static const String plantAdd = '/plants/add';
  static const String plantEdit = '/plants/edit/:id';
  static const String tasks = '/tasks';
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String accountProfile = '/account-profile';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String accountDeletionPolicy = '/account-deletion-policy';
  static const String promotional = '/promotional';
  static const String notificationsSettings = '/notifications-settings';
  static const String backupSettings = '/backup-settings';
  static const String deviceManagement = '/device-management';
  static const String licenseStatus = '/license-status';
  static const String dataExport = '/data-export';

  /// Helper method to navigate to plant details
  static String plantDetailsPath(String plantId) => '/plants/$plantId';

  static GoRouter router(WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // BUGFIX: Web deve sempre iniciar em promotional, mobile vai direto para login
    const initialLocation = kIsWeb ? promotional : login;

    return GoRouter(
      navigatorKey: NavigationService.navigatorKey,
      initialLocation: initialLocation,
      redirect: (context, state) {
        final authStateValue = authState.valueOrNull;
        final isAuthenticated = authStateValue?.isAuthenticated ?? false;
        final isAnonymous = authStateValue?.isAnonymous ?? false;
        final isInitialized = authState.hasValue;
        final isLoggingIn = state.matchedLocation == login;
        final isRegistering = state.matchedLocation == register;
        final isOnLanding = state.matchedLocation == landing;
        final isOnPromotional = state.matchedLocation == promotional;

        // Para fins de navegação, usuário anônimo é tratado como não autenticado
        final isReallyAuthenticated = isAuthenticated && !isAnonymous;

        // Lista de rotas públicas (acessíveis sem autenticação)
        final publicRoutes = [
          login,
          register,
          landing,
          promotional,
          termsOfService,
          privacyPolicy,
          accountDeletionPolicy,
        ];

        final isAccessingPublicRoute = publicRoutes.any(
          (route) =>
              state.matchedLocation.startsWith(route) ||
              state.matchedLocation == route,
        );

        // Lista de rotas protegidas que requerem autenticação
        final protectedRoutes = [
          plants,
          plantDetails,
          plantAdd,
          plantEdit,
          tasks,
          premium,
          settings,
          notificationsSettings,
          backupSettings,
          deviceManagement,
          accountProfile,
          dataExport,
          home,
        ];

        final isAccessingProtectedRoute = protectedRoutes.any(
          (route) =>
              state.matchedLocation.startsWith(route) ||
              state.matchedLocation == route,
        );

        // Wait for auth initialization
        if (!isInitialized) {
          return null;
        }

        // Se realmente autenticado e não está no app, redireciona para plantas
        if (isReallyAuthenticated &&
            (isLoggingIn || isRegistering || isOnLanding || isOnPromotional)) {
          return plants;
        }

        // Se acessando rota pública, permitir acesso
        if (isAccessingPublicRoute) {
          return null; // Permitir navegação para rotas públicas
        }

        // Se não realmente autenticado e tentando acessar rota protegida
        if (!isReallyAuthenticated && isAccessingProtectedRoute) {
          // BUGFIX: Na web, volta para promotional. No mobile, vai para login
          return kIsWeb ? promotional : login;
        }

        // Mobile: Se não autenticado e não está em rota conhecida, vai para landing
        if (!kIsWeb && !isReallyAuthenticated) {
          return landing;
        }

        // Web: Se não autenticado e não está em rota conhecida, vai para promotional
        if (kIsWeb && !isReallyAuthenticated) {
          return promotional;
        }

        return null;
      },
      routes: [
        // Landing Page Route
        GoRoute(
          path: landing,
          name: 'landing',
          builder: (context, state) => const LandingPage(),
        ),

        // Home Route - Redirects to promotional page
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const PromotionalPage(),
        ),

        // Promotional Page Route (outside of shell for web landing)
        GoRoute(
          path: promotional,
          name: 'promotional',
          builder: (context, state) => const PromotionalPage(),
        ),

        // Auth Routes - Unified Auth Page
        GoRoute(
          path: login,
          name: 'login',
          builder:
              (context, state) => const AuthPage(initialTab: 0), // Login tab
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder:
              (context, state) => const AuthPage(initialTab: 1), // Register tab
        ),

        // Main Shell Route with Web Optimized Navigation
        ShellRoute(
          builder:
              (context, state, child) =>
                  WebOptimizedNavigationShell(
                    child: child,
                  ).withKeyboardShortcuts(),
          routes: [
            // Plants Routes
            GoRoute(
              path: plants,
              name: 'plants',
              builder: (context, state) => const PlantsListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'plant-add',
                  builder: (context, state) {
                    return const PlantFormPage();
                  },
                ),
                GoRoute(
                  path: ':id',
                  name: 'plant-details',
                  builder: (context, state) {
                    final plantId = state.pathParameters['id']!;
                    return PlantDetailsPage(plantId: plantId);
                  },
                ),
                GoRoute(
                  path: 'edit/:id',
                  name: 'plant-edit',
                  builder: (context, state) {
                    final plantId = state.pathParameters['id']!;
                    return PlantFormPage(plantId: plantId);
                  },
                ),
              ],
            ),

            // Tasks Route
            GoRoute(
              path: tasks,
              name: 'tasks',
              builder: (context, state) {
                return const TasksListPage();
              },
            ),

            // Premium Route
            GoRoute(
              path: premium,
              name: 'premium',
              builder: (context, state) => const PremiumSubscriptionPage(),
            ),

            // Settings Route
            GoRoute(
              path: settings,
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),

            // Account Profile Route
            GoRoute(
              path: accountProfile,
              name: 'account-profile',
              builder: (context, state) => const AccountProfilePage(),
            ),

            // Legal Routes
            GoRoute(
              path: termsOfService,
              name: 'terms-of-service',
              builder: (context, state) => const TermsOfServicePage(),
            ),
            GoRoute(
              path: privacyPolicy,
              name: 'privacy-policy',
              builder: (context, state) => const PrivacyPolicyPage(),
            ),
            GoRoute(
              path: accountDeletionPolicy,
              name: 'account-deletion-policy',
              builder: (context, state) => const AccountDeletionPage(),
            ),

            // Settings Routes
            GoRoute(
              path: notificationsSettings,
              name: 'notifications-settings',
              builder: (context, state) {
                return const NotificationsSettingsPage();
              },
            ),
            GoRoute(
              path: backupSettings,
              name: 'backup-settings',
              builder: (context, state) {
                return const BackupSettingsPage();
              },
            ),
            GoRoute(
              path: deviceManagement,
              name: 'device-management',
              builder: (context, state) {
                // CRITICAL: Provide DeviceManagementProvider for the page
                return provider.ChangeNotifierProvider<DeviceManagementProvider>(
                  create: (_) => sl<DeviceManagementProvider>(),
                  child: const DeviceManagementPage(),
                );
              },
            ),
            GoRoute(
              path: licenseStatus,
              name: 'license-status',
              builder: (context, state) => const LicenseStatusPage(),
            ),

            // Data Export Route
            GoRoute(
              path: dataExport,
              name: 'data-export',
              builder: (context, state) {
                return const DataExportPage();
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => ErrorPage(error: state.error),
    );
  }
}

// Error Page
class ErrorPage extends StatelessWidget {
  final Object? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops! Algo deu errado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.plants),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}

// SettingsPage is implemented in presentation/pages/settings_page.dart
