import 'dart:async';

import 'package:core/core.dart' hide Column, Consumer, FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/enhanced_loading_states.dart';
import '../widgets/auth_background_widgets.dart';
import '../widgets/auth_branding_widgets.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/device_validation_overlay.dart';
import '../widgets/forgot_password_dialog.dart';

const String _kRememberedEmailKey = 'remembered_email';
const String _kRememberMeKey = 'remember_me';

/// Web-only login page (without registration)
/// This page is used exclusively for the web version of the app
class WebLoginPage extends ConsumerStatefulWidget {
  final bool? showBackButton;

  const WebLoginPage({super.key, this.showBackButton});

  @override
  ConsumerState<WebLoginPage> createState() => _WebLoginPageState();
}

class _WebLoginPageState extends ConsumerState<WebLoginPage>
    with TickerProviderStateMixin, LoadingStateMixin, AccessibilityFocusMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoAnimation;
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _rememberMe = false;
  FocusNode? _emailFocusNode;
  FocusNode? _passwordFocusNode;
  FocusNode? _loginButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = getFocusNode('email');
    _passwordFocusNode = getFocusNode('password');
    _loginButtonFocusNode = getFocusNode('login_button');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
        _loadRememberedCredentials();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  /// Salva ou remove as credenciais lembradas baseado no estado do checkbox
  Future<void> _saveRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setString(_kRememberedEmailKey, _loginEmailController.text);
      await prefs.setBool(_kRememberMeKey, true);
    } else {
      await prefs.remove(_kRememberedEmailKey);
      await prefs.setBool(_kRememberMeKey, false);
    }
  }

  /// Carrega email salvo e estado do "Lembrar-me" na inicialização
  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberedEmail = prefs.getString(_kRememberedEmailKey);
    final rememberMe = prefs.getBool(_kRememberMeKey) ?? false;

    if (rememberedEmail != null && rememberMe) {
      setState(() {
        _loginEmailController.text = rememberedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _submitAuthAction({
    GlobalKey<FormState>? formKey,
    required String loadingMessage,
    required Future<void> Function() authFuture,
  }) async {
    if (formKey == null || formKey.currentState!.validate()) {
      showLoading(message: loadingMessage);
      try {
        await authFuture();
        if (!mounted) return;
        hideLoading();
        final authState = ref.read(authProvider);
        if (authState.hasValue && authState.value!.isAuthenticated) {
          GoRouter.of(context).go('/plants');
        }
      } catch (e) {
        if (mounted) {
          hideLoading();
        }
      }
    }
  }

  Future<void> _handleLogin() async {
    await _saveRememberedCredentials();
    await _submitAuthAction(
      formKey: _loginFormKey,
      loadingMessage: 'Fazendo login...',
      authFuture: () => ref.read(authProvider.notifier).login(
            _loginEmailController.text,
            _loginPasswordController.text,
          ),
    );
  }

  void _showSocialLoginDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final isMobile = size.width <= 600;

    return buildWithLoading(
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: _buildModernBackground(
                  child: _buildResponsiveLayout(
                    context,
                    size,
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                ),
              ),
              const DeviceValidationOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern background with plant-themed gradient and animations
  Widget _buildModernBackground({required Widget child}) {
    return ModernBackground(
      animation: _backgroundAnimation,
      primaryColor: PlantisColors.primary,
      child: child,
    );
  }

  /// Responsive layout inspired by gasometer design
  Widget _buildResponsiveLayout(
    BuildContext context,
    Size size,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).padding.top +
              (keyboardHeight > 0 ? 8 : 16),
          horizontal: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? size.width * 0.9 : (isTablet ? 500 : 1000),
            maxHeight: isMobile ? size.height * 0.9 : (isTablet ? 700 : 650),
          ),
          child: RepaintBoundary(
            child: Card(
              elevation: 20,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              margin: EdgeInsets.symmetric(
                vertical: keyboardHeight > 0 ? 8 : 16,
                horizontal: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  /// Desktop layout with branding sidebar
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PlantBrandingSide(
            logoAnimation: _logoAnimation,
            backgroundAnimation: _backgroundAnimation,
          ),
        ),
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: _buildLoginContent(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile layout with compact branding
  Widget _buildMobileLayout() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: isKeyboardVisible ? 12.0 : 20.0,
      ),
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isKeyboardVisible) ...[
                    MobileBranding(logoAnimation: _logoAnimation),
                    const SizedBox(height: 16),
                  ] else ...[
                    const CompactBranding(),
                    const SizedBox(height: 12),
                  ],
                  Flexible(child: _buildLoginContent()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Login content - web version without registration
  Widget _buildLoginContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        const Text(
          'Bem-vindo de volta',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: PlantisColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Faça login para acessar suas plantas',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Login Form
        LoginForm(
          formKey: _loginFormKey,
          emailController: _loginEmailController,
          passwordController: _loginPasswordController,
          obscurePassword: _obscureLoginPassword,
          rememberMe: _rememberMe,
          emailFocusNode: _emailFocusNode,
          passwordFocusNode: _passwordFocusNode,
          loginButtonFocusNode: _loginButtonFocusNode,
          onObscurePasswordChanged: (value) {
            setState(() {
              _obscureLoginPassword = value;
            });
          },
          onRememberMeChanged: (value) {
            setState(() {
              _rememberMe = value;
            });
            _saveRememberedCredentials();
          },
          onLogin: _handleLogin,
          onForgotPassword: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const ForgotPasswordDialog(),
            );
          },
        ),
        const SizedBox(height: 16),

        // Social Login
        SocialLoginSection(
          onGoogleLogin: _showSocialLoginDialog,
          onAppleLogin: _showSocialLoginDialog,
          onMicrosoftLogin: _showSocialLoginDialog,
        ),

      ],
    );
  }
}
