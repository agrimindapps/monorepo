import 'dart:async';

import 'package:core/core.dart' hide Consumer, FormState;
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
  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  FocusNode? _emailFocusNode;
  FocusNode? _passwordFocusNode;
  FocusNode? _loginButtonFocusNode;
  FocusNode? _registerNameFocusNode;
  FocusNode? _registerEmailFocusNode;
  FocusNode? _registerPasswordFocusNode;
  FocusNode? _registerConfirmPasswordFocusNode;
  FocusNode? _registerButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _emailFocusNode = getFocusNode('email');
    _passwordFocusNode = getFocusNode('password');
    _loginButtonFocusNode = getFocusNode('login_button');
    _registerNameFocusNode = getFocusNode('register_name');
    _registerEmailFocusNode = getFocusNode('register_email');
    _registerPasswordFocusNode = getFocusNode('register_password');
    _registerConfirmPasswordFocusNode = getFocusNode(
      'register_confirm_password',
    );
    _registerButtonFocusNode = getFocusNode('register_button');
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
    _tabController.dispose();
    _animationController.dispose();
    _backgroundController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
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

  Future<void> _handleRegister() async {
    await _submitAuthAction(
      formKey: _registerFormKey,
      loadingMessage: 'Criando conta...',
      authFuture: () => ref.read(authProvider.notifier).register(
            _registerEmailController.text,
            _registerPasswordController.text,
            _registerNameController.text,
          ),
    );
  }

  Future<void> _handleAnonymousLogin() async {
    await _submitAuthAction(
      loadingMessage: 'Entrando anonimamente...',
      authFuture: () => ref.read(authProvider.notifier).signInAnonymously(),
    );
  }

  void _showSocialLoginDialog() {
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

  void _showAnonymousLoginDialog() {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Anônimo'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como funciona o login anônimo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Você pode usar o app sem criar conta'),
                Text('• Seus dados ficam apenas no dispositivo'),
                Text(
                  '• Limitação: dados podem ser perdidos se o app for desinstalado',
                ),
                Text('• Sem backup na nuvem'),
                Text('• Sem sincronização entre dispositivos'),
                SizedBox(height: 16),
                Text(
                  'Deseja prosseguir?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleAnonymousLogin();
                },
                child: const Text('Prosseguir'),
              ),
            ],
          ),
    );
  }

  /// Exibe o dialog com os Termos de Serviço
  void _showTermsOfService() {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
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
                    position: Tween<Offset>(
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
              child:
                  _tabController.index == 0
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
        SocialLoginSection(
          onGoogleLogin: _showSocialLoginDialog,
          onAppleLogin: _showSocialLoginDialog,
          onMicrosoftLogin: _showSocialLoginDialog,
        ),
        const SizedBox(height: 16),
        AnonymousLoginSection(
          onAnonymousLogin: _showAnonymousLoginDialog,
        ),
      ],
    );
  }

  /// Register form with enhanced fields
  Widget _buildRegisterTab() {
    return RegisterForm(
      formKey: _registerFormKey,
      nameController: _registerNameController,
      emailController: _registerEmailController,
      passwordController: _registerPasswordController,
      confirmPasswordController: _registerConfirmPasswordController,
      obscurePassword: _obscureRegisterPassword,
      obscureConfirmPassword: _obscureRegisterConfirmPassword,
      nameFocusNode: _registerNameFocusNode,
      emailFocusNode: _registerEmailFocusNode,
      passwordFocusNode: _registerPasswordFocusNode,
      confirmPasswordFocusNode: _registerConfirmPasswordFocusNode,
      registerButtonFocusNode: _registerButtonFocusNode,
      onObscurePasswordChanged: (value) {
        setState(() {
          _obscureRegisterPassword = value;
        });
      },
      onObscureConfirmPasswordChanged: (value) {
        setState(() {
          _obscureRegisterConfirmPassword = value;
        });
      },
      onRegister: _handleRegister,
      onTermsOfService: _showTermsOfService,
      onPrivacyPolicy: _showPrivacyPolicy,
    );
  }
}
