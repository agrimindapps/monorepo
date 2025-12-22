import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_tabs.dart';

/// Login page for email/password authentication
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // Navigate to home on success
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.currentUser != null && authState.errorMessage == null) {
          context.go(AppConstants.homeRoute);
        }
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (_signupFormKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).signUp(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text,
          );

      // Navigate to home on success
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.currentUser != null && authState.errorMessage == null) {
          context.go(AppConstants.homeRoute);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: _buildResponsiveLayout(context),
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final isMobile = size.width <= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1a237e), const Color(0xFF0d47a1)]
              : [const Color(0xFF673AB7), const Color(0xFF3F51B5)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).padding.top + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? size.width * 0.9 : (isTablet ? 500 : 1000),
              maxHeight: isMobile ? size.height * 0.9 : (isTablet ? 700 : 700),
            ),
            child: Card(
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildBrandingSide()),
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: _buildAuthContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMobileBranding(),
              const SizedBox(height: 24),
              _buildAuthContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a237e), const Color(0xFF0d47a1)]
                : [const Color(0xFF673AB7), const Color(0xFF3F51B5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(isWhite: true, size: 32),
              const SizedBox(height: 30),
              const Text(
                'Organize sua Vida',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 50,
                height: 4,
                color: isDark ? const Color(0xFF64B5F6) : Colors.amber.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'Gerencie suas tarefas, listas e projetos de forma simples e eficiente. Sincronize em todos os seus dispositivos.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.checklist_rtl,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Seus dados estão seguros',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBranding() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF673AB7);

    return Column(
      children: [
        _buildLogo(
          isWhite: false,
          size: 28,
          color: primaryColor,
        ),
        const SizedBox(height: 10),
        Text(
          'Organize sua Vida',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Container(width: 50, height: 4, color: primaryColor),
      ],
    );
  }

  Widget _buildLogo({
    required bool isWhite,
    required double size,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.checklist,
          color: isWhite ? Colors.white : color,
          size: size + 12,
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Nebula',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  color: isWhite ? Colors.white : color,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'List',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w400,
                  color: isWhite ? Colors.white : color,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthContent() {
    final isSignUpMode = ref.watch(authModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthTabsWidget(),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSignUpMode ? _buildSignUpForm() : _buildLoginForm(),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF673AB7);

    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bem-vindo de volta!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faça login para acessar suas listas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (authState.errorMessage != null) ...[
            AuthErrorMessage(
              message: authState.errorMessage!,
              onDismiss: () {
                ref.read(authProvider.notifier).clearError();
              },
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          AuthTextField(
            controller: _passwordController,
            labelText: 'Senha',
            hintText: 'Sua senha',
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha é obrigatória';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Remember me & Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: authState.isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lembrar-me',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        context.push(AppConstants.forgotPasswordRoute);
                      },
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    color: authState.isLoading ? Colors.grey : primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Login button
          AuthButton(
            onPressed: _handleLogin,
            text: 'Entrar',
            isLoading: authState.isLoading &&
                authState.currentOperation == AuthOperation.signIn,
          ),
          const SizedBox(height: 16),

          // Divider
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Anonymous login button
          OutlinedButton(
            onPressed: authState.isLoading
                ? null
                : () async {
                    await ref.read(authProvider.notifier).signInAnonymously();
                    if (mounted) {
                      final authState = ref.read(authProvider);
                      if (authState.currentUser != null &&
                          authState.errorMessage == null) {
                        context.go(AppConstants.homeRoute);
                      }
                    }
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authState.isLoading &&
                    authState.currentOperation == AuthOperation.signInAnonymously
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Continuar sem cadastro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crie sua conta',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os dados para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (authState.errorMessage != null) ...[
            AuthErrorMessage(
              message: authState.errorMessage!,
              onDismiss: () {
                ref.read(authProvider.notifier).clearError();
              },
            ),
            const SizedBox(height: 16),
          ],

          // Name field
          AuthTextField(
            controller: _nameController,
            labelText: 'Nome completo',
            hintText: 'Seu nome',
            prefixIcon: Icons.person_outline,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nome é obrigatório';
              }
              if (value.trim().length < 2) {
                return 'Nome deve ter pelo menos 2 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email field
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          AuthTextField(
            controller: _passwordController,
            labelText: 'Senha',
            hintText: 'Mínimo 6 caracteres',
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha é obrigatória';
              }
              if (value.length < 6) {
                return 'Senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm password field
          AuthTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmar senha',
            hintText: 'Digite novamente',
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmação de senha é obrigatória';
              }
              if (value != _passwordController.text) {
                return 'Senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Sign up button
          AuthButton(
            onPressed: _handleSignUp,
            text: 'Criar Conta',
            isLoading: authState.isLoading &&
                authState.currentOperation == AuthOperation.signUp,
          ),
        ],
      ),
    );
  }
}
