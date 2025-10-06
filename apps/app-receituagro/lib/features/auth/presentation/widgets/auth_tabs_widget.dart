import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/login_notifier.dart';

/// Widget para tabs de autenticação (Login/Cadastro) do ReceitaAgro
/// Adaptado do app-gasometer com tema verde
/// Migrado para Riverpod
class AuthTabsWidget extends ConsumerWidget {
  const AuthTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);
    final loginNotifier = ref.read(loginNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _getReceitaAgroPrimaryColor(isDark);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            context: context,
            title: 'Entrar',
            isActive: !loginState.isSignUpMode,
            onTap: () {
              if (loginState.isSignUpMode) {
                loginNotifier.toggleAuthMode();
              }
            },
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 40),
          _buildTab(
            context: context,
            title: 'Cadastrar',
            isActive: loginState.isSignUpMode,
            onTap: () {
              if (!loginState.isSignUpMode) {
                loginNotifier.toggleAuthMode();
              }
            },
            isDark: isDark,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? (isDark ? Colors.white : Colors.grey[800])
                  : (isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            child: Text(title),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isActive ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Cores primárias do ReceitaAgro
  Color _getReceitaAgroPrimaryColor(bool isDark) {
    if (isDark) {
      return const Color(0xFF81C784); // Verde claro para modo escuro
    } else {
      return const Color(0xFF4CAF50); // Verde padrão para modo claro
    }
  }
}