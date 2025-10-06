import 'package:app_agrihurbi/core/constants/app_constants.dart';
import 'package:app_agrihurbi/core/di/injection_container.dart';
import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/core/utils/error_handler.dart';
import 'package:app_agrihurbi/core/validators/input_validators.dart';
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';
import 'package:core/core.dart' show Consumer, ChangeNotifierProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Riverpod provider exposing the existing AuthProvider (registered with GetIt)
final authProviderProvider = ChangeNotifierProvider<AuthProvider>(
  (ref) => getIt<AuthProvider>(),
);

/// Login page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo and Title
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 60,
                        color: DesignTokens.textLightColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AgriHurbi',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema de gestão agropecuária',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'Digite seu e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: InputValidators.validateEmail,
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
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
                  ),
                  validator: PasswordValidator.validatePassword,
                ),

                const SizedBox(height: 24),

                // Login Button
                Consumer(
                  builder: (context, ref, child) {
                    final authProvider = ref.watch(authProviderProvider);
                    return ElevatedButton(
                      onPressed:
                          authProvider.isLoading
                              ? null
                              : () => _handleLogin(context, authProvider),
                      child:
                          authProvider.isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    DesignTokens.textLightColor,
                                  ),
                                ),
                              )
                              : const Text('Entrar'),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Cadastre-se'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Error Message
                Consumer(
                  builder: (context, ref, child) {
                    final authProvider = ref.watch(authProviderProvider);
                    if (authProvider.errorMessage != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
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
                                authProvider.errorMessage!,
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
                              onPressed: authProvider.clearError,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final result = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return; // ✅ Safety check

      result.fold(
        (failure) {
          if (mounted) {
            // ✅ Double check before using context
            ErrorHandler.showErrorSnackbar(context, failure);
          }
        },
        (user) {
          if (mounted) {
            // ✅ Double check before using context
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
}
