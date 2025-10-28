import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/items/presentation/pages/items_bank_page.dart';
import '../../features/items/presentation/pages/list_detail_page.dart';
import '../../features/lists/presentation/pages/lists_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/settings/presentation/pages/notifications_settings_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../config/app_constants.dart';

/// Application router configuration using GoRouter with auth protection
class AppRouter {
  AppRouter._();

  /// Creates GoRouter with authentication redirect logic
  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppConstants.homeRoute,
      routes: [
        // Home route (protected)
        GoRoute(
          path: AppConstants.homeRoute,
          name: 'home',
          builder: (context, state) => const _HomePage(),
        ),

        // Auth routes (public)
        GoRoute(
          path: AppConstants.loginRoute,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppConstants.signUpRoute,
          name: 'signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: AppConstants.forgotPasswordRoute,
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Settings route (protected)
        GoRoute(
          path: AppConstants.settingsRoute,
          name: 'settings',
          builder: (context, state) => const _SettingsPage(),
        ),

        // Settings Page (protected)
        GoRoute(
          path: AppConstants.settingsPageRoute,
          name: 'settings-page',
          builder: (context, state) => const SettingsPage(),
        ),

        // Profile route (protected)
        GoRoute(
          path: AppConstants.profileRoute,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Notifications settings route (protected)
        GoRoute(
          path: AppConstants.notificationsRoute,
          name: 'notifications-settings',
          builder: (context, state) => const NotificationsSettingsPage(),
        ),

        // Promo route (public)
        GoRoute(
          path: AppConstants.promoRoute,
          name: 'promo',
          builder: (context, state) => const PromoPage(),
        ),

        // Premium route (protected)
        GoRoute(
          path: AppConstants.premiumRoute,
          name: 'premium',
          builder: (context, state) => const PremiumPage(),
        ),

        // List detail route (protected)
        GoRoute(
          path: AppConstants.listDetailRoute,
          name: 'list-detail',
          builder: (context, state) {
            final listId = state.pathParameters['id']!;
            return ListDetailPage(listId: listId);
          },
        ),
      ],
      errorBuilder: (context, state) => _ErrorPage(error: state.error),

      // Redirect logic for authentication
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);
        final isLoggedIn = authState.currentUser != null;
        final isAuthRoute = state.matchedLocation == AppConstants.loginRoute ||
            state.matchedLocation == AppConstants.signUpRoute ||
            state.matchedLocation == AppConstants.forgotPasswordRoute;
        final isPublicRoute = isAuthRoute ||
            state.matchedLocation == AppConstants.promoRoute;

        // Redirect to login if not authenticated and trying to access protected route
        if (!isLoggedIn && !isPublicRoute) {
          return AppConstants.loginRoute;
        }

        // Redirect to home if authenticated and trying to access auth route
        if (isLoggedIn && isAuthRoute) {
          return AppConstants.homeRoute;
        }

        return null; // No redirect needed
      },
    );
  }
}

/// Home page with bottom navigation
class _HomePage extends ConsumerStatefulWidget {
  const _HomePage();

  @override
  ConsumerState<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<_HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;

    // Define pages for each tab
    final List<Widget> pages = [
      const ListsPage(),
      const ItemsBankPage(),
      _ConfiguracoesTab(user: user),
    ];

    // Define titles for each tab
    final List<String> titles = [
      'Listas',
      'Itens',
      'Configurações',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Listas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Itens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

/// Configurações tab content
class _ConfiguracoesTab extends ConsumerWidget {
  const _ConfiguracoesTab({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (user != null) ...[
          Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
        ],
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Perfil'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(AppConstants.profileRoute);
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notificações'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(AppConstants.notificationsRoute);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configurações Gerais'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(AppConstants.settingsPageRoute);
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Idioma'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navegar para idioma
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Ajuda'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navegar para ajuda
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Sobre'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navegar para sobre
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sair', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
            if (context.mounted) {
              context.go(AppConstants.loginRoute);
            }
          },
        ),
      ],
    );
  }
}

/// Settings page (placeholder)
class _SettingsPage extends ConsumerWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Error page displayed when route is not found
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
      ),
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
              error?.toString() ?? 'Página não encontrada',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar para Início'),
            ),
          ],
        ),
      ),
    );
  }
}
