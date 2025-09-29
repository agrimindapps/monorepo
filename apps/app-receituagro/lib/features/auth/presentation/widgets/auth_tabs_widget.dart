import 'package:flutter/material.dart';

import 'package:provider/provider.dart' as provider;

import '../controllers/login_controller.dart';

/// Widget para tabs de autenticação (Login/Cadastro) do ReceitaAgro
/// Adaptado do app-gasometer com tema verde
class AuthTabsWidget extends StatelessWidget {
  const AuthTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<LoginController>(
      builder: (context, controller, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = _getReceitaAgroPrimaryColor(isDark);

        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab Login
              _buildTab(
                context: context,
                title: 'Entrar',
                isActive: !controller.isSignUpMode,
                onTap: () {
                  if (controller.isSignUpMode) {
                    controller.toggleAuthMode();
                  }
                },
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(width: 40),
              // Tab Cadastro
              _buildTab(
                context: context,
                title: 'Cadastrar',
                isActive: controller.isSignUpMode,
                onTap: () {
                  if (!controller.isSignUpMode) {
                    controller.toggleAuthMode();
                  }
                },
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ],
          ),
        );
      },
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