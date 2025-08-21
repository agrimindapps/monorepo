import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/plants/presentation/providers/plant_details_provider.dart';
import '../../features/plants/presentation/providers/plant_form_provider.dart';
import '../di/injection_container.dart';
import '../../features/plants/presentation/pages/plants_list_page.dart';
import '../../features/plants/presentation/pages/plant_details_page.dart';
import '../../features/plants/presentation/pages/plant_form_page.dart';
import '../../features/tasks/presentation/pages/tasks_list_page.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../presentation/pages/landing_page.dart';
import '../utils/navigation_service.dart';

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
  static const String profile = '/profile';
  static const String settings = '/settings';

  static GoRouter router(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      navigatorKey: NavigationService.instance.navigatorKey,
      initialLocation: landing,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isInitialized = authProvider.isInitialized;
        final isLoggingIn = state.matchedLocation == login;
        final isRegistering = state.matchedLocation == register;
        final isOnLanding = state.matchedLocation == landing;

        // Lista de rotas protegidas que requerem autenticação
        final protectedRoutes = [
          plants,
          plantDetails,
          plantAdd,
          plantEdit,
          tasks,
          premium,
          profile,
          settings,
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

        // Se autenticado e não está no app, redireciona para plantas
        if (isAuthenticated && (isLoggingIn || isRegistering || isOnLanding)) {
          return plants;
        }

        // Se não autenticado e tentando acessar rota protegida
        if (!isAuthenticated && isAccessingProtectedRoute) {
          // Só mostra mensagem se não está inicializando modo anônimo
          if (isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              NavigationService.instance.showAccessDeniedMessage();
            });
          }
          return login;
        }

        // Se não autenticado e tentando acessar outras rotas não protegidas, vai para landing
        if (!isAuthenticated &&
            !isLoggingIn &&
            !isRegistering &&
            !isOnLanding) {
          return landing;
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

        // Main Shell Route with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
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
                    return ChangeNotifierProvider(
                      create: (context) => sl<PlantFormProvider>(),
                      child: const PlantFormPage(),
                    );
                  },
                ),
                GoRoute(
                  path: ':id',
                  name: 'plant-details',
                  builder: (context, state) {
                    final plantId = state.pathParameters['id']!;
                    return ChangeNotifierProvider(
                      create: (context) => sl<PlantDetailsProvider>(),
                      child: PlantDetailsPage(plantId: plantId),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit/:id',
                  name: 'plant-edit',
                  builder: (context, state) {
                    final plantId = state.pathParameters['id']!;
                    return ChangeNotifierProvider(
                      create: (context) => sl<PlantFormProvider>(),
                      child: PlantFormPage(plantId: plantId),
                    );
                  },
                ),
              ],
            ),

            // Tasks Route
            GoRoute(
              path: tasks,
              name: 'tasks',
              builder: (context, state) {
                return ChangeNotifierProvider(
                  create: (context) => sl<TasksProvider>(),
                  child: const TasksListPage(),
                );
              },
            ),

            // Premium Route
            GoRoute(
              path: premium,
              name: 'premium',
              builder: (context, state) => const PremiumPage(),
            ),

            // Profile Route
            GoRoute(
              path: profile,
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),

            // Settings Route
            GoRoute(
              path: settings,
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
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

// ProfilePage is implemented in features/auth/presentation/pages/
// SettingsPage remains as placeholder

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings Page'));
  }
}
