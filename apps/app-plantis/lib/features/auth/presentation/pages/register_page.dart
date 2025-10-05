import 'package:core/core.dart' hide Consumer, ChangeNotifierProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../providers/register_notifier.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  void _showSocialLoginDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Em Desenvolvimento'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction, size: 48, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'O login social está em desenvolvimento e estará disponível em breve!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: PlantisColors.primary,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo and title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.eco,
                          size: 32,
                          color: PlantisColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Inside Garden',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: PlantisColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuidado de Plantas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PlantisColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tab navigation
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Column(
                              children: [
                                Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 3,
                                  color: Colors.grey.shade300,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: PlantisColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Progress indicator
                    Consumer(
                      builder: (context, ref, _) {
                        final registerState = ref.watch(registerNotifierProvider);
                        final steps = registerState.progressSteps;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(3, (index) {
                                return [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color:
                                          steps[index]
                                              ? PlantisColors.primary
                                              : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  if (index < 2) const SizedBox(width: 8),
                                ];
                              }).expand((widget) => widget).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 48),

                    // Leaf icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: PlantisColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 40,
                        color: PlantisColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Criar Nova Conta',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton('G', 'Google', Colors.red, () {
                          _showSocialLoginDialog(context);
                        }),
                        _buildSocialButton('', 'Apple', Colors.black, () {
                          _showSocialLoginDialog(context);
                        }, icon: Icons.apple),
                        _buildSocialButton('', 'Microsoft', Colors.blue, () {
                          _showSocialLoginDialog(context);
                        }, icon: Icons.window),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Or text
                    const Text(
                      'ou',
                      style: TextStyle(
                        color: PlantisColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Continue button
                    Consumer(
                      builder: (context, ref, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(registerNotifierProvider.notifier).nextStep();
                              context.go('/register/personal-info');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PlantisColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Começar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Terms text
                    const Text(
                      'Ao criar uma conta, você concorda com nossos\nTermos de Serviço e Política de Privacidade',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PlantisColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildSocialButton(
    String text,
    String label,
    Color color,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            icon != null
                ? Icon(icon, color: color, size: 20)
                : Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
      ),
    );
  }
}
