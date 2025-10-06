import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Widget para tabs de autenticação (Login/Cadastro)
class AuthTabsWidget extends ConsumerWidget {
  const AuthTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignUpMode = ref.watch(_authModeProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            context: context,
            title: 'Entrar',
            isActive: !isSignUpMode,
            onTap: () {
              if (isSignUpMode) {
                ref.read(_authModeProvider.notifier).state = false;
              }
            },
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 40),
          _buildTab(
            context: context,
            title: 'Cadastrar',
            isActive: isSignUpMode,
            onTap: () {
              if (!isSignUpMode) {
                ref.read(_authModeProvider.notifier).state = true;
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
}

/// Provider para gerenciar o estado do modo de autenticação (login/cadastro)
final _authModeProvider = StateProvider<bool>((ref) => false); // false = login, true = signup