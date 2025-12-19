import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/login_background_widget.dart';

/// Login page for email/password authentication
/// Refactored to be responsive and visually consistent with the monorepo standard
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: LoginBackgroundWidget(
          child: _buildResponsiveLayout(context),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final isMobile = size.width <= 600;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).padding.top + 16,
          horizontal: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? size.width : (isTablet ? 500 : 1000),
          ),
          child: isDesktop 
              ? _buildDesktopLayout() 
              : _buildMobileCard(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _buildBrandingSide(),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: _buildFormContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMobileHeader(),
              const SizedBox(height: 32),
              _buildFormContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSide() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1065), Color(0xFF4C1D95)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_queue, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'NebulaList',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text(
                'Organize suas ideias, planeje seu dia e alcance as estrelas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_queue,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bem-vindo de volta',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Faça login para acessar suas listas',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (authState.errorMessage != null) ...[
            AuthErrorMessage(
              message: authState.errorMessage!,
              onDismiss: () {
                ref.read(authProvider.notifier).clearError();
              },
            ),
            const SizedBox(height: 16),
          ],

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
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: authState.isLoading
                  ? null
                  : () => context.push(AppConstants.forgotPasswordRoute),
              child: const Text('Esqueceu a senha?'),
            ),
          ),
          
          const SizedBox(height: 24),

          AuthButton(
            onPressed: _handleLogin,
            text: 'Entrar',
            isLoading: authState.isLoading &&
                authState.currentOperation == AuthOperation.signIn,
          ),
          
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Não tem uma conta? ',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () => context.push(AppConstants.signUpRoute),
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
