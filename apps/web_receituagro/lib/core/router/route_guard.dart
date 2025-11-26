import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// Route guard widget to protect routes
class RouteGuard extends ConsumerWidget {
  final Widget child;
  final bool requiresAuth;
  final List<UserRole>? allowedRoles;

  const RouteGuard({
    super.key,
    required this.child,
    this.requiresAuth = true,
    this.allowedRoles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        // Check authentication
        if (requiresAuth && user == null) {
          return const LoginPage();
        }

        // Check authorization (roles)
        if (allowedRoles != null &&
            user != null &&
            !allowedRoles!.contains(user.role)) {
          return _buildUnauthorized(context);
        }

        return child;
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const LoginPage(),
    );
  }

  Widget _buildUnauthorized(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acesso Negado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Acesso Negado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Você não tem permissão para acessar esta página.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to easily wrap routes with guard
extension RouteGuardExtension on Widget {
  /// Wrap widget with authentication guard
  Widget requireAuth() {
    return RouteGuard(child: this);
  }

  /// Wrap widget with role-based authorization guard
  Widget requireRoles(List<UserRole> roles) {
    return RouteGuard(
      allowedRoles: roles,
      child: this,
    );
  }

  /// Wrap widget with admin-only guard
  Widget requireAdmin() {
    return RouteGuard(
      allowedRoles: const [UserRole.admin],
      child: this,
    );
  }

  /// Wrap widget with write permission guard (admin + editor)
  Widget requireWrite() {
    return RouteGuard(
      allowedRoles: const [UserRole.admin, UserRole.editor],
      child: this,
    );
  }
}
