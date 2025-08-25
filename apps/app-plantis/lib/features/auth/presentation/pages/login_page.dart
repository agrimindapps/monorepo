import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animação para as abas
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(_emailController.text, _passwordController.text);

      if (authProvider.isAuthenticated && mounted) {
        context.go('/plants');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlantisColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // Moon icon (top right)
            Positioned(
              top: 24,
              right: 24,
              child: Icon(
                Icons.brightness_2,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: IntrinsicHeight(
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
                              'PlantApp',
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: PlantisColors.textSecondary),
                        ),
                        const SizedBox(height: 32),

                        // Tab navigation with animation
                        AnimatedBuilder(
                          animation: _fadeInAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: FadeTransition(
                                opacity: _fadeInAnimation,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: PlantisColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Entrar',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: PlantisColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: PlantisColors.primary
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => context.go('/register'),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Cadastrar',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // "Entrar" title
                        Text(
                          'Entrar',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 32),
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                            color: PlantisColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email field
                              AnimatedBuilder(
                                animation: _fadeInAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      _slideAnimation.value * 0.5,
                                    ),
                                    child: FadeTransition(
                                      opacity: _fadeInAnimation,
                                      child: TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Insira seu email',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: PlantisColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.email_outlined,
                                              color: PlantisColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: PlantisColors.primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: PlantisColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, insira seu email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Por favor, insira um email válido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              AnimatedBuilder(
                                animation: _fadeInAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      _slideAnimation.value * 0.3,
                                    ),
                                    child: FadeTransition(
                                      opacity: _fadeInAnimation,
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Senha',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: PlantisColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.lock_outline,
                                              color: PlantisColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          suffixIcon: Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: PlantisColors.primary,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: PlantisColors.primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: PlantisColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, insira sua senha';
                                          }
                                          if (value.length < 6) {
                                            return 'A senha deve ter pelo menos 6 caracteres';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Remember me and forgot password
                              AnimatedBuilder(
                                animation: _fadeInAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      _slideAnimation.value * 0.2,
                                    ),
                                    child: FadeTransition(
                                      opacity: _fadeInAnimation,
                                      child: Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                              activeColor:
                                                  PlantisColors.primary,
                                              checkColor: Colors.white,
                                              side: BorderSide(
                                                color: PlantisColors.primary
                                                    .withValues(alpha: 0.5),
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Lembrar-me',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              // TODO: Implement forgot password
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              'Esqueceu sua senha?',
                                              style: TextStyle(
                                                color: PlantisColors.primary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Error message
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  if (authProvider.errorMessage != null) {
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: PlantisColors.errorLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: PlantisColors.error,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              authProvider.errorMessage!,
                                              style: const TextStyle(
                                                color: PlantisColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                              // Login button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed:
                                          authProvider.isLoading
                                              ? null
                                              : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: PlantisColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child:
                                          authProvider.isLoading
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                              : const Text(
                                                'Entrar',
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

                              // Or continue with
                              const Text(
                                'ou continue com',
                                style: TextStyle(
                                  color: PlantisColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Social login buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildSocialButton(
                                    'G',
                                    'Google',
                                    Colors.red,
                                    () {
                                      // TODO: Implement Google login
                                    },
                                  ),
                                  _buildSocialButton(
                                    '',
                                    'Apple',
                                    Colors.black,
                                    () {
                                      // TODO: Implement Apple login
                                    },
                                    icon: Icons.apple,
                                  ),
                                  _buildSocialButton(
                                    '',
                                    'Microsoft',
                                    Colors.blue,
                                    () {
                                      // TODO: Implement Microsoft login
                                    },
                                    icon: Icons.window,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Anonymous login button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed:
                                          authProvider.isLoading
                                              ? null
                                              : () async {
                                                final navigator = context;
                                                await authProvider
                                                    .signInAnonymously();
                                                if (authProvider
                                                        .isAuthenticated &&
                                                    mounted) {
                                                  // ignore: use_build_context_synchronously
                                                  navigator.go('/plants');
                                                }
                                              },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: PlantisColors.primary,
                                        side: BorderSide(
                                          color: PlantisColors.primary
                                              .withValues(alpha: 0.3),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child:
                                          authProvider.isLoading
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(PlantisColors.primary),
                                                ),
                                              )
                                              : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.person_outline,
                                                    size: 20,
                                                    color:
                                                        PlantisColors.primary,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Continuar sem conta',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          PlantisColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Copyright footer
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Text(
                '© 2025 PlantApp - Todos os direitos reservados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ],
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
