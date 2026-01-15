import 'package:app_agrihurbi/core/constants/app_constants.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/core/utils/error_handler.dart';
import 'package:app_agrihurbi/core/validators/input_validators.dart';
import 'package:app_agrihurbi/features/auth/domain/services/auth_rate_limiter.dart';
import 'package:app_agrihurbi/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_di_providers.dart';
import 'package:app_agrihurbi/features/auth/presentation/widgets/rate_limit_info_widget.dart';
import 'package:app_agrihurbi/features/auth/presentation/widgets/recovery_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Login page with password recovery and rate limiting
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showRecoveryForm = false;
  AuthRateLimitInfo? _rateLimitInfo;

  @override
  void initState() {
    super.initState();
    _checkRateLimitStatus();
  }

  Future<void> _checkRateLimitStatus() async {
    final rateLimiter = ref.read(authRateLimiterProvider);
    final info = await rateLimiter.getRateLimitInfo();
    if (mounted) {
      setState(() {
        _rateLimitInfo = info;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundColor,
      body: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: DesignTokens.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: DesignTokens.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: DesignTokens.surfaceColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: DesignTokens.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          size: 60,
                          color: DesignTokens.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Show recovery form or login form
                    if (_showRecoveryForm) ...[
                      RecoveryFormWidget(
                        onBackToLogin: () {
                          setState(() {
                            _showRecoveryForm = false;
                          });
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.textPrimaryColor,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acesse sua conta para gerenciar sua propriedade',
                        style: TextStyle(
                          fontSize: 16,
                          color: DesignTokens.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Rate Limit Info
                      if (_rateLimitInfo != null) ...[
                        RateLimitInfoWidget(rateLimitInfo: _rateLimitInfo!),
                        if (_rateLimitInfo!.isLocked ||
                            _rateLimitInfo!.warningMessage.isNotEmpty)
                          const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 16),

                      // Login Form Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: DesignTokens.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !(_rateLimitInfo?.isLocked ?? false),
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  hintText: 'seu@email.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: DesignTokens.borderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: DesignTokens.borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: DesignTokens.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: DesignTokens.backgroundColor,
                                ),
                                validator: InputValidators.validateEmail,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                enabled: !(_rateLimitInfo?.isLocked ?? false),
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  hintText: 'Sua senha segura',
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: DesignTokens.borderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: DesignTokens.borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: DesignTokens.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: DesignTokens.backgroundColor,
                                ),
                                validator: PasswordValidator.validatePassword,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showRecoveryForm = true;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        DesignTokens.textSecondaryColor,
                                  ),
                                  child: const Text('Esqueceu a senha?'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Consumer(
                                builder: (context, ref, child) {
                                  final authState = ref.watch(authProvider);
                                  final isLocked =
                                      _rateLimitInfo?.isLocked ?? false;
                                  return ElevatedButton(
                                    onPressed: authState.isLoading ||
                                            authState.isLoggingIn ||
                                            isLocked
                                        ? null
                                        : () => _handleLogin(context, ref),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          DesignTokens.primaryColor,
                                      foregroundColor:
                                          DesignTokens.textLightColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: authState.isLoading ||
                                            authState.isLoggingIn
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                DesignTokens.textLightColor,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            isLocked
                                                ? 'Login Bloqueado'
                                                : 'Entrar',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Anonymous Login Button
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authProvider);
                          return OutlinedButton.icon(
                            onPressed: authState.isLoading ||
                                    authState.isLoggingIn
                                ? null
                                : () => _handleAnonymousLogin(context, ref),
                            icon: const Icon(Icons.person_outline),
                            label: authState.isLoggingIn
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Entrar como Visitante'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DesignTokens.textSecondaryColor,
                              side: const BorderSide(
                                color: DesignTokens.borderColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Social Login (Visual Only)
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: DesignTokens.borderColor),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Ou continue com',
                              style: TextStyle(
                                color: DesignTokens.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: DesignTokens.borderColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            onPressed: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não tem uma conta? ',
                            style: TextStyle(
                              color: DesignTokens.textSecondaryColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: DesignTokens.primaryColor,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Cadastre-se'),
                          ),
                        ],
                      ),

                      // Error Message Display
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authProvider);
                          if (authState.errorMessage != null) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: DesignTokens.errorColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: DesignTokens.errorColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: DesignTokens.errorColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: const TextStyle(
                                        color: DesignTokens.errorColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: DesignTokens.errorColor,
                                      size: 18,
                                    ),
                                    onPressed: () => ref
                                        .read(authProvider.notifier)
                                        .clearError(),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: DesignTokens.borderColor),
          borderRadius: BorderRadius.circular(12),
          color: DesignTokens.surfaceColor,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: DesignTokens.textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    // Check rate limit before attempting login
    final rateLimiter = ref.read(authRateLimiterProvider);
    final canAttempt = await rateLimiter.canAttemptLogin();

    if (!canAttempt) {
      await _checkRateLimitStatus();
      return;
    }

    if (_formKey.currentState!.validate()) {
      final result = await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      result.fold(
        (failure) async {
          // Record failed attempt
          await rateLimiter.recordFailedAttempt();
          await _checkRateLimitStatus();

          if (mounted) {
            ErrorHandler.showErrorSnackbar(context, failure);
          }
        },
        (user) async {
          // Record successful attempt (clears rate limit)
          await rateLimiter.recordSuccessfulAttempt();

          if (mounted) {
            ErrorHandler.showSuccessSnackbar(
              context,
              SuccessMessages.loginSuccess,
            );
            context.go('/home');
          }
        },
      );
    }
  }

  Future<void> _handleAnonymousLogin(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(authProvider.notifier).loginAnonymously();

    if (!mounted) return;

    result.fold(
      (failure) {
        if (mounted) {
          ErrorHandler.showErrorSnackbar(context, failure);
        }
      },
      (user) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bem-vindo! Você está usando o modo visitante.'),
              backgroundColor: DesignTokens.successColor,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/home');
        }
      },
    );
  }
}
