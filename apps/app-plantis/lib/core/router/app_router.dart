import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/account/presentation/pages/account_profile_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/web_login_page.dart';
import '../../features/data_export/presentation/pages/data_export_page.dart';
import '../../features/device_management/presentation/pages/device_management_page.dart';
import '../../features/legal/presentation/pages/account_deletion_page.dart';
import '../../features/legal/presentation/pages/cookies_policy_page.dart';
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
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tasks/presentation/pages/tasks_list_page.dart';
import '../../shared/widgets/desktop_keyboard_shortcuts.dart';
import '../../shared/widgets/web_optimized_navigation.dart';
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
  static const String cookies = '/cookies';
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
    const initialLocation = kIsWeb ? promotional : login;

    return GoRouter(
      navigatorKey: NavigationService.navigatorKey,
      initialLocation: initialLocation,
      redirect: (context, state) {
        final authStateValue = authState.value;
        final isAuthenticated = authStateValue?.isAuthenticated ?? false;
        final isAnonymous = authStateValue?.isAnonymous ?? false;
        final isInitialized = authState.hasValue;
        final isLoggingIn = state.matchedLocation == login;
        final isRegistering = state.matchedLocation == register;
        final isOnLanding = state.matchedLocation == landing;
        final isOnPromotional = state.matchedLocation == promotional;
        final isReallyAuthenticated = isAuthenticated && !isAnonymous;
        final publicRoutes = [
          login,
          register,
          landing,
          promotional,
          termsOfService,
          privacyPolicy,
          accountDeletionPolicy,
          cookies,
        ];

        final isAccessingPublicRoute = publicRoutes.any(
          (route) =>
              state.matchedLocation.startsWith(route) ||
              state.matchedLocation == route,
        );
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
        if (!isInitialized) {
          return null;
        }
        if (isReallyAuthenticated &&
            (isLoggingIn || isRegistering || isOnLanding || isOnPromotional)) {
          return plants;
        }
        if (isAccessingPublicRoute) {
          return null; // Permitir navegação para rotas públicas
        }
        if (!isReallyAuthenticated && isAccessingProtectedRoute) {
          return kIsWeb ? promotional : login;
        }
        if (!kIsWeb && !isReallyAuthenticated) {
          return landing;
        }
        if (kIsWeb && !isReallyAuthenticated) {
          return promotional;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: landing,
          name: 'landing',
          builder: (context, state) => const PromotionalPage(),
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const PromotionalPage(),
        ),
        GoRoute(
          path: promotional,
          name: 'promotional',
          builder: (context, state) => const PromotionalPage(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) {
            // Web: usa página de login simplificada (sem cadastro)
            // Mobile/Desktop App: usa página completa (com login e cadastro)
            return kIsWeb
                ? const WebLoginPage()
                : const AuthPage(initialTab: 0); // Login tab
          },
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) {
            // Web: redireciona para login (cadastro não disponível)
            // Mobile/Desktop App: mostra aba de registro
            if (kIsWeb) {
              // Redirect to login on web
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(login);
              });
              return const SizedBox.shrink();
            }
            return const AuthPage(initialTab: 1); // Register tab
          },
        ),
        ShellRoute(
          builder: (context, state, child) =>
              WebOptimizedNavigationShell(child: child).withKeyboardShortcuts(),
          routes: [
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
            GoRoute(
              path: tasks,
              name: 'tasks',
              builder: (context, state) {
                return const TasksListPage();
              },
            ),
            GoRoute(
              path: premium,
              name: 'premium',
              builder: (context, state) => const PremiumSubscriptionPage(),
            ),
            GoRoute(
              path: settings,
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: accountProfile,
              name: 'account-profile',
              builder: (context, state) => const AccountProfilePage(),
            ),
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
            GoRoute(
              path: cookies,
              name: 'cookies',
              builder: (context, state) => const CookiesPolicyPage(),
            ),
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
              builder: (context, state) => const DeviceManagementPage(),
            ),
            GoRoute(
              path: licenseStatus,
              name: 'license-status',
              builder: (context, state) => const LicenseStatusPage(),
            ),
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
