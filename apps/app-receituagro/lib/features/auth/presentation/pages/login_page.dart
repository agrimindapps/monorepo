import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../core/providers/auth_provider.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_tabs_widget.dart';
import '../widgets/login_background_widget.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/recovery_form_widget.dart';
import '../widgets/signup_form_widget.dart';

/// Página de login do ReceitaAgro seguindo padrões SOLID
/// Adaptada do app-gasometer com tema verde e integração com ReceitaAgroAuthProvider
class LoginPage extends StatefulWidget {
  final bool? showBackButton;

  const LoginPage({
    super.key,
    this.showBackButton,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureOrientation();
  }

  @override
  void dispose() {
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

  void _configureOrientation() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    if (isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider<LoginController>(
      create: (context) => LoginController(
        authProvider: provider.Provider.of<ReceitaAgroAuthProvider>(context, listen: false),
      ),
      child: provider.Consumer<LoginController>(
        builder: (context, controller, child) {
          return Scaffold(
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: LoginBackgroundWidget(
                child: _buildResponsiveLayout(context),
              ),
            ),
          );
        },
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile
                ? size.width * 0.9
                : (isTablet ? 500 : 1000),
            maxHeight: isMobile
                ? double.infinity
                : (isTablet ? 650 : 650),
          ),
          child: Card(
            elevation: 10,
            shadowColor: Theme.of(context).shadowColor,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: isDesktop
                ? _buildDesktopLayout()
                : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Lado esquerdo com branding do ReceitaAgro
        Expanded(
          flex: 5,
          child: _buildBrandingSide(),
        ),
        // Lado direito com formulário
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMobileBranding(),
            const SizedBox(height: 30),
            _buildAuthContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingSide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = _getReceitaAgroPrimaryColor(isDark);
    final secondaryGreen = isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);

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
            colors: [primaryGreen, secondaryGreen],
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
                'ReceitaAgro',
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
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 20),
              const Text(
                'Suas receitas agropecuárias organizadas de forma simples e prática. Acesse diagnósticos, tratamentos e muito mais.',
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
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.agriculture,
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
                  const Icon(
                    Icons.security,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Área restrita - Acesso seguro',
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
    final primaryColor = _getReceitaAgroPrimaryColor(isDark);

    return Column(
      children: [
        _buildLogo(
          isWhite: false,
          size: 28,
          color: primaryColor,
        ),
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
          Icons.agriculture,
          color: isWhite ? Colors.white : color,
          size: size + 12,
        ),
        const SizedBox(width: 10),
        Text(
          'ReceitaAgro',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: isWhite ? Colors.white : color,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthContent() {
    return provider.Consumer<LoginController>(
      builder: (context, controller, child) {
        if (controller.isShowingRecoveryForm) {
          return const RecoveryFormWidget();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthTabsWidget(),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: controller.isSignUpMode
                    ? Container(
                        key: const ValueKey('signup'),
                        child: SignupFormWidget(
                          onSignupSuccess: _handleAuthSuccess,
                        ),
                      )
                    : Container(
                        key: const ValueKey('login'),
                        child: LoginFormWidget(
                          onLoginSuccess: _handleAuthSuccess,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAuthSuccess() {
    if (!mounted) return;
    
    debugPrint('✅ LoginPage: Authentication successful, returning to ProfilePage');
    
    // Return true to indicate successful authentication
    Navigator.of(context).pop(true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Login realizado com sucesso!'),
        backgroundColor: _getReceitaAgroPrimaryColor(
          Theme.of(context).brightness == Brightness.dark
        ),
        duration: const Duration(seconds: 2),
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