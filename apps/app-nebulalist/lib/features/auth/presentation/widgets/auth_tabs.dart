import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_tabs.g.dart';

/// Provider para gerenciar o estado do modo de autenticação (login/cadastro)
@riverpod
class AuthMode extends _$AuthMode {
  @override
  bool build() => false; // false = login, true = signup

  void setSignUpMode(bool value) => state = value;
  void toggle() => state = !state;
}

/// Widget para tabs de autenticação (Login/Cadastro)
class AuthTabsWidget extends ConsumerWidget {
  const AuthTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignUpMode = ref.watch(authModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF673AB7);

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
                ref.read(authModeProvider.notifier).setSignUpMode(false);
              }
            },
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 40),
          _buildTab(
            context: context,
            title: 'Cadastrar',
            isActive: isSignUpMode,
            onTap: () {
              if (!isSignUpMode) {
                ref.read(authModeProvider.notifier).setSignUpMode(true);
              }
            },
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
    required Color primaryColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  : (isDark ? Colors.grey[500] : Colors.grey[500]),
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
