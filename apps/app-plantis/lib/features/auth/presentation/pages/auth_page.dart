import 'dart:async';

import 'package:core/core.dart' hide Column, Consumer, FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/enhanced_loading_states.dart';
import '../managers/auth_animation_manager.dart';
import '../managers/auth_dialog_manager.dart';
import '../managers/auth_form_manager.dart';
import '../managers/auth_page_controller.dart';
import '../managers/credentials_persistence_manager.dart';
import '../providers/auth_dialog_managers_providers.dart';
import '../widgets/auth_background_widgets.dart';
import '../widgets/auth_branding_widgets.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/device_validation_overlay.dart';
import '../widgets/forgot_password_dialog.dart';

class AuthLoadingState {
  final bool isLoading;
  final String? currentOperation;

  const AuthLoadingState({required this.isLoading, this.currentOperation});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthLoadingState &&
          isLoading == other.isLoading &&
          currentOperation == other.currentOperation;

  @override
  int get hashCode => Object.hash(isLoading, currentOperation);
}

/// Modern unified auth page combining login and register functionality
/// with enhanced UX inspired by gasometer design and adapted for Inside Garden
class AuthPage extends ConsumerStatefulWidget {
  final int initialTab; // 0 = login, 1 = register
  final bool? showBackButton;

  const AuthPage({super.key, this.initialTab = 0, this.showBackButton});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with TickerProviderStateMixin, LoadingStateMixin, AccessibilityFocusMixin {
  late TabController _tabController;
  late AuthAnimationManager _animationManager;
  late AuthFormManager _formManager;
  late AuthPageController _pageController;
  late final AuthDialogManager _dialogManager;
  late final CredentialsPersistenceManager _credentialsManager;

  @override
  void initState() {
    super.initState();

    // Initialize managers and controllers
    _dialogManager = AuthDialogManager();
    _credentialsManager = ref.read(credentialsPersistenceManagerProvider);
    _formManager = AuthFormManager();
    _animationManager = AuthAnimationManager(vsync: this);
    _pageController = AuthPageController(
      ref: ref,
      context: context,
      loadingMixin: this,
      credentialsManager: _credentialsManager,
    );

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    // Initialize accessibility focus nodes (using existing mixin method)
    _formManager.emailFocusNode = getFocusNode('email');
    _formManager.passwordFocusNode = getFocusNode('password');
    _formManager.loginButtonFocusNode = getFocusNode('login_button');
    _formManager.registerNameFocusNode = getFocusNode('register_name');
    _formManager.registerEmailFocusNode = getFocusNode('register_email');
    _formManager.registerPasswordFocusNode = getFocusNode('register_password');
    _formManager.registerConfirmPasswordFocusNode = getFocusNode(
      'register_confirm_password',
    );
    _formManager.registerButtonFocusNode = getFocusNode('register_button');

    // Start animations and load remembered credentials
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationManager.startEntranceAnimation();
        _loadRememberedCredentials();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationManager.dispose();
    _formManager.dispose();
    super.dispose();
  }

  /// Carrega as credenciais salvas anteriormente
  Future<void> _loadRememberedCredentials() async {
    final credentials = await _pageController.loadRememberedCredentials();

    if (credentials.email != null) {
      setState(() {
        _formManager.setLoginCredentials(credentials.email!, '');
        _formManager.rememberMe = credentials.rememberMe;
      });
    }
  }

  /// Salva ou remove as credenciais lembradas
  Future<void> _saveRememberedCredentials() async {
    await _pageController.saveRememberedCredentials(
      email: _formManager.loginEmail,
      rememberMe: _formManager.rememberMe,
    );
  }

  Future<void> _handleLogin() async {
    await _saveRememberedCredentials();
    await _pageController.handleLogin(
      formKey: _formManager.loginFormKey,
      email: _formManager.loginEmail,
      password: _formManager.loginPassword,
      rememberMe: _formManager.rememberMe,
    );
  }

  Future<void> _handleRegister() async {
    await _pageController.handleRegister(
      formKey: _formManager.registerFormKey,
      name: _formManager.registerData['name']!,
      email: _formManager.registerData['email']!,
      password: _formManager.registerData['password']!,
    );
  }

  Future<void> _handleAnonymousLogin() async {
    await _pageController.handleAnonymousLogin();
  }

  /// Exibe o dialog com os Termos de Serviço
  void _showTermsOfService() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Serviço'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Última atualização: Janeiro 2025\n\n'
                '1. ACEITAÇÃO DOS TERMOS\n'
                'Ao usar o Inside Garden, você concorda com estes termos.\n\n'
                '2. DESCRIÇÃO DO SERVIÇO\n'
                'O Inside Garden é um aplicativo para cuidado e gerenciamento de plantas.\n\n'
                '3. RESPONSABILIDADES DO USUÁRIO\n'
                '• Fornecer informações precisas\n'
                '• Usar o serviço de forma apropriada\n'
                '• Manter a segurança da sua conta\n\n'
                '4. PRIVACIDADE\n'
                'Seus dados são protegidos conforme nossa Política de Privacidade.\n\n'
                '5. MODIFICAÇÕES\n'
                'Podemos atualizar estes termos. Você será notificado sobre mudanças importantes.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Exibe o dialog com a Política de Privacidade
  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Última atualização: Janeiro 2025\n\n'
                '1. INFORMAÇÕES QUE COLETAMOS\n'
                '• Dados de conta (email, nome)\n'
                '• Informações sobre suas plantas\n'
                '• Dados de uso do aplicativo\n\n'
                '2. COMO USAMOS SUAS INFORMAÇÕES\n'
                '• Para fornecer e melhorar nossos serviços\n'
                '• Para personalizar sua experiência\n'
                '• Para enviar notificações de cuidados\n\n'
                '3. COMPARTILHAMENTO DE DADOS\n'
                'Não vendemos ou compartilhamos seus dados pessoais com terceiros.\n\n'
                '4. SEGURANÇA\n'
                'Utilizamos medidas de segurança para proteger suas informações.\n\n'
                '5. SEUS DIREITOS\n'
                'Você pode acessar, corrigir ou excluir seus dados a qualquer momento.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
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
      animation: _animationManager.backgroundAnimation,
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
          vertical:
              MediaQuery.of(context).padding.top +
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
            logoAnimation: _animationManager.logoAnimation,
            backgroundAnimation: _animationManager.backgroundAnimation,
          ),
        ),
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _animationManager.fadeInAnimation,
            child: AnimatedBuilder(
              animation: _animationManager.slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animationManager.slideAnimation.value),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: _buildAuthContent(),
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
        opacity: _animationManager.fadeInAnimation,
        child: AnimatedBuilder(
          animation: _animationManager.slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animationManager.slideAnimation.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isKeyboardVisible) ...[
                    MobileBranding(
                      logoAnimation: _animationManager.logoAnimation,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const CompactBranding(),
                    const SizedBox(height: 12),
                  ],
                  Flexible(child: _buildAuthContent()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Auth content with modern tabs and form
  Widget _buildAuthContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildModernTabNavigation(),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: _tabController.index == 0
                  ? Container(
                      key: const ValueKey('login'),
                      child: _buildLoginTab(),
                    )
                  : Container(
                      key: const ValueKey('register'),
                      child: _buildRegisterTab(),
                    ),
            );
          },
        ),
      ],
    );
  }

  /// Modern tab navigation inspired by gasometer design
  Widget _buildModernTabNavigation() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(
                title: 'Entrar',
                isActive: _tabController.index == 0,
                onTap: () {
                  _tabController.animateTo(0);
                },
              ),
              const SizedBox(width: 40),
              _buildTab(
                title: 'Cadastrar',
                isActive: _tabController.index == 1,
                onTap: () {
                  _tabController.animateTo(1);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Individual tab widget with smooth animations
  Widget _buildTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isActive ? PlantisColors.primary : Colors.grey.shade500,
            ),
            child: Text(title),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: isActive ? PlantisColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Login form with enhanced fields
  Widget _buildLoginTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginForm(
          formKey: _formManager.loginFormKey,
          emailController: _formManager.loginEmailController,
          passwordController: _formManager.loginPasswordController,
          obscurePassword: _formManager.obscureLoginPassword,
          rememberMe: _formManager.rememberMe,
          emailFocusNode: _formManager.emailFocusNode,
          passwordFocusNode: _formManager.passwordFocusNode,
          loginButtonFocusNode: _formManager.loginButtonFocusNode,
          onObscurePasswordChanged: (value) {
            setState(() {
              _formManager.toggleLoginPasswordVisibility();
            });
          },
          onRememberMeChanged: (value) {
            setState(() {
              _formManager.toggleRememberMe();
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
        SocialLoginSection(
          onGoogleLogin: () => _dialogManager.showSocialLoginDialog(context),
          onAppleLogin: () => _dialogManager.showSocialLoginDialog(context),
          onMicrosoftLogin: () => _dialogManager.showSocialLoginDialog(context),
        ),
        const SizedBox(height: 16),
        AnonymousLoginSection(
          onAnonymousLogin: () async {
            final confirmed = await _dialogManager.showAnonymousLoginDialog(
              context,
            );
            if (confirmed == true) {
              await _handleAnonymousLogin();
            }
          },
        ),
      ],
    );
  }

  /// Register form with enhanced fields
  Widget _buildRegisterTab() {
    return RegisterForm(
      formKey: _formManager.registerFormKey,
      nameController: _formManager.registerNameController,
      emailController: _formManager.registerEmailController,
      passwordController: _formManager.registerPasswordController,
      confirmPasswordController: _formManager.registerConfirmPasswordController,
      obscurePassword: _formManager.obscureRegisterPassword,
      obscureConfirmPassword: _formManager.obscureRegisterConfirmPassword,
      nameFocusNode: _formManager.registerNameFocusNode,
      emailFocusNode: _formManager.registerEmailFocusNode,
      passwordFocusNode: _formManager.registerPasswordFocusNode,
      confirmPasswordFocusNode: _formManager.registerConfirmPasswordFocusNode,
      registerButtonFocusNode: _formManager.registerButtonFocusNode,
      onObscurePasswordChanged: (value) {
        setState(() {
          _formManager.toggleRegisterPasswordVisibility();
        });
      },
      onObscureConfirmPasswordChanged: (value) {
        setState(() {
          _formManager.toggleRegisterConfirmPasswordVisibility();
        });
      },
      onRegister: _handleRegister,
      onTermsOfService: _showTermsOfService,
      onPrivacyPolicy: _showPrivacyPolicy,
    );
  }
}
