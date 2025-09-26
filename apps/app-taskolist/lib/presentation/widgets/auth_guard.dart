import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../pages/auth/login_page.dart';
import '../providers/auth_providers.dart';

class AuthGuard extends ConsumerWidget {
  const AuthGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const LoginPage(),
      data: (user) {
        if (user == null) {
          return const LoginPage();
        }
        return child;
      },
    );
  }
}