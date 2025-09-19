import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/enhanced_loading_states.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../shared/widgets/sync/simple_sync_loading.dart';
import '../../utils/auth_validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/forgot_password_dialog.dart';

// Constantes para SharedPreferences
const String _kRememberedEmailKey = 'remembered_email';
const String _kRememberMeKey = 'remember_me';

// Data class for granular Selector optimization
class AuthLoadingState {
  final bool isLoading;
  final String? currentOperation;

  const AuthLoadingState({
    required this.isLoading,
    this.currentOperation,
  });

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
class AuthPage extends StatefulWidget {
  final int initialTab; // 0 = login, 1 = register
  final bool? showBackButton;

  const AuthPage({
    super.key, 
    this.initialTab = 0,
    this.showBackButton,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> 
    with TickerProviderStateMixin, LoadingStateMixin, AccessibilityFocusMixin {
  late TabController _tabController;
  
  // Enhanced animations inspired by gasometer
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoAnimation;

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _rememberMe = false;

  // Register controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  
  // Focus nodes para navegação por teclado - inicialização segura
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
    
    // Initialize TabController
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    // Inicializar focus nodes de forma imediata mas segura
    _emailFocusNode = getFocusNode('email');
    _passwordFocusNode = getFocusNode('password');
    _loginButtonFocusNode = getFocusNode('login_button');
    _registerNameFocusNode = getFocusNode('register_name');
    _registerEmailFocusNode = getFocusNode('register_email');
    _registerPasswordFocusNode = getFocusNode('register_password');
    _registerConfirmPasswordFocusNode = getFocusNode('register_confirm_password');
    _registerButtonFocusNode = getFocusNode('register_button');
    
    // Enhanced animation setup inspired by gasometer
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
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.linear,
      ),
    );

    // Logo animation for modern branding
    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Delay animation start slightly to ensure proper layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
        // Carregar credenciais lembradas após a inicialização
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
      // Salvar email e estado do "Lembrar-me"
      await prefs.setString(_kRememberedEmailKey, _loginEmailController.text);
      await prefs.setBool(_kRememberMeKey, true);
    } else {
      // Limpar email salvo se "Lembrar-me" foi desmarcado
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

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      showLoading(message: 'Fazendo login...');
      
      final authProvider = context.read<AuthProvider>();
      final router = GoRouter.of(context);
      
      // Salvar email se "Lembrar-me" estiver marcado
      await _saveRememberedCredentials();
      
      // Usar novo método loginAndSync em vez do login tradicional
      await authProvider.loginAndSync(_loginEmailController.text, _loginPasswordController.text);

      if (!mounted) return;
      
      hideLoading();
      
      if (authProvider.isAuthenticated) {
        // Mostrar loading simples se sync estiver ativo
        if (authProvider.isSyncInProgress) {
          _showSimpleSyncLoading(authProvider, router);
        } else {
          // Navegar imediatamente se não há sync em progresso
          router.go('/plants');
        }
      }
    }
  }

  /// Mostra loading simples de sincronização que navega automaticamente
  void _showSimpleSyncLoading(AuthProvider authProvider, GoRouter router) {
    SimpleSyncLoading.show(
      context,
      message: authProvider.syncMessage,
    );
    
    // Navegar quando sync terminar
    _navigateAfterSync(authProvider, router);
  }
  
  /// Navega para plantas quando sync terminar
  void _navigateAfterSync(AuthProvider authProvider, GoRouter router) {
    late StreamSubscription subscription;
    
    subscription = Stream.periodic(const Duration(milliseconds: 500))
        .listen((_) {
      if (!authProvider.isSyncInProgress) {
        subscription.cancel();
        
        // Pequeno delay para garantir que o loading foi fechado
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            router.go('/plants');
          }
        });
      }
    });
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      showLoading(message: 'Criando conta...');
      
      final authProvider = context.read<AuthProvider>();
      final router = GoRouter.of(context);
      await authProvider.register(
        _registerEmailController.text,
        _registerPasswordController.text,
        _registerNameController.text,
      );

      if (!mounted) return;
      
      hideLoading();
      
      if (authProvider.isAuthenticated) {
        router.go('/plants');
      }
    }
  }

  void _showSocialLoginDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em Desenvolvimento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Colors.orange,
            ),
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
      builder: (context) => AlertDialog(
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
            Text('• Limitação: dados podem ser perdidos se o app for desinstalado'),
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
            onPressed: () async {
              Navigator.of(context).pop();
              showLoading(message: 'Entrando anonimamente...');
              
              final authProvider = context.read<AuthProvider>();
              final router = GoRouter.of(context);
              await authProvider.signInAnonymously();
              
              if (!mounted) return;
              
              hideLoading();
              
              if (authProvider.isAuthenticated) {
                router.go('/plants');
              }
            },
            child: const Text('Prosseguir'),
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
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _buildModernBackground(
              child: _buildResponsiveLayout(context, size, isDesktop, isTablet, isMobile),
            ),
          ),
        ),
      ),
    );
  }

  /// Modern background with plant-themed gradient and animations
  Widget _buildModernBackground({required Widget child}) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary,
            PlantisColors.primaryLight,
            Color(0xFF2ECC71), // Fresh plant green
          ],
        ),
      ),
      child: Stack(
        children: [
          // Enhanced background pattern with plant motifs
          _buildPlantBackgroundPattern(),
          // Floating plant elements
          _buildFloatingPlantElements(),
          // Main content
          child,
        ],
      ),
    );
  }

  /// Responsive layout inspired by gasometer design
  Widget _buildResponsiveLayout(BuildContext context, Size size, bool isDesktop, bool isTablet, bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 40,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? size.width * 0.9
                  : (isTablet ? 500 : 1000),
              maxHeight: isMobile
                  ? double.infinity
                  : (isTablet ? 650 : 650),
            ),
            child: RepaintBoundary(
              child: Card(
                elevation: 20,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: isDesktop
                    ? _buildDesktopLayout()
                    : _buildMobileLayout(),
              ),
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
        // Left side with Inside Garden branding
        Expanded(
          flex: 5,
          child: _buildPlantBrandingSide(),
        ),
        // Right side with form
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMobileBranding(),
                  const SizedBox(height: 32),
                  _buildAuthContent(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Plant-themed branding sidebar for desktop
  Widget _buildPlantBrandingSide() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PlantisColors.primary,
              PlantisColors.primaryLight,
              Color(0xFF27AE60),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced logo with animation
              ScaleTransition(
                scale: _logoAnimation,
                child: _buildModernLogo(isWhite: true, size: 40),
              ),
              const SizedBox(height: 40),
              const Text(
                'Inside Garden',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Transforme seu lar em um jardim inteligente. Cuidado personalizado para cada planta.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              // Animated plant illustration
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.1 * math.sin(_backgroundAnimation.value * 2 * math.pi)),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Security indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cuidado seguro e personalizado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
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

  /// Mobile branding with compact design
  Widget _buildMobileBranding() {
    return Column(
      children: [
        ScaleTransition(
          scale: _logoAnimation,
          child: _buildModernLogo(
            isWhite: false,
            size: 32,
            color: PlantisColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Inside Garden',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PlantisColors.primary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Cuidado inteligente de plantas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: PlantisColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Enhanced logo component
  Widget _buildModernLogo({
    required bool isWhite,
    required double size,
    Color? color,
  }) {
    final logoColor = isWhite ? Colors.white : (color ?? PlantisColors.primary);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: logoColor.withValues(alpha: 0.1),
            border: Border.all(
              color: logoColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.eco,
            color: logoColor,
            size: size,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Inside Garden',
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.w700,
            color: logoColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  /// Auth content with modern tabs and form
  Widget _buildAuthContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Modern tab navigation inspired by gasometer
        _buildModernTabNavigation(),
        const SizedBox(height: 32),
        // Form content
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
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
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
              // Login Tab
              _buildTab(
                title: 'Entrar',
                isActive: _tabController.index == 0,
                onTap: () {
                  _tabController.animateTo(0);
                },
              ),
              const SizedBox(width: 40),
              // Register Tab  
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
              color: isActive
                  ? PlantisColors.primary
                  : Colors.grey.shade500,
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
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Enhanced Email field
          AccessibleTextField(
            controller: _loginEmailController,
            focusNode: _emailFocusNode,
            nextFocusNode: _passwordFocusNode,
            labelText: 'E-mail',
            hintText: 'Digite seu email',
            semanticLabel: 'Campo de e-mail para login',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocomplete: AutofillHints.email,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!AuthValidators.isValidEmail(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 20),

          // Enhanced Password field
          AccessibleTextField(
            controller: _loginPasswordController,
            focusNode: _passwordFocusNode,
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            semanticLabel: 'Campo de senha para login',
            obscureText: _obscureLoginPassword,
            textInputAction: TextInputAction.done,
            autocomplete: AutofillHints.password,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validatePassword(value ?? '', isRegistration: false);
            },
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: Semantics(
              label: _obscureLoginPassword 
                  ? AccessibilityTokens.getSemanticLabel('show_password', 'Mostrar senha')
                  : AccessibilityTokens.getSemanticLabel('hide_password', 'Ocultar senha'),
              button: true,
              child: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: PlantisColors.primary.withValues(alpha: 0.7),
                  size: 22,
                ),
                onPressed: () {
                  AccessibilityTokens.performHapticFeedback('light');
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                  // Anunciar mudança para screen readers
                  final message = _obscureLoginPassword ? 'Senha oculta' : 'Senha visível';
                  SemanticsService.announce(message, TextDirection.ltr);
                },
              ),
            ),
            onSubmitted: (value) {
              _loginButtonFocusNode?.requestFocus();
            },
          ),
          const SizedBox(height: 20),

          // Enhanced remember me and forgot password
          _buildRememberAndForgotSection(),
          const SizedBox(height: 28),

          // Enhanced error message
          _buildErrorMessage(),

          // Enhanced login button
          _buildAccessibleLoginButton(),
          const SizedBox(height: 32),

          // Enhanced divider with social login
          _buildSocialLoginSection(),
          
          const SizedBox(height: 24),
          
          // Enhanced anonymous login
          _buildAnonymousLoginSection(),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgotSection() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.2),
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                      // Salvar ou limpar credenciais imediatamente quando o estado mudar
                      _saveRememberedCredentials();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _rememberMe 
                                  ? PlantisColors.primary 
                                  : Colors.transparent,
                              border: Border.all(
                                color: _rememberMe 
                                    ? PlantisColors.primary 
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _rememberMe
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lembrar-me',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showForgotPasswordDialog,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: PlantisColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.errorMessage != null) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildAccessibleLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isAnonymousLoading = authProvider.currentOperation == AuthOperation.anonymous;
        return AccessibleButton(
          focusNode: _loginButtonFocusNode,
          onPressed: (authProvider.isLoading || isAnonymousLoading)
              ? null
              : _handleLogin,
          semanticLabel: AccessibilityTokens.getSemanticLabel('login_button', 'Fazer login'),
          tooltip: 'Entrar com suas credenciais',
          minimumSize: const Size(
            double.infinity, 
            AccessibilityTokens.largeTouchTargetSize,
          ),
          hapticPattern: 'medium',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: (authProvider.isLoading || isAnonymousLoading)
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : [PlantisColors.primary, PlantisColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: (authProvider.isLoading || isAnonymousLoading)
                      ? Colors.grey.withValues(alpha: 0.3)
                      : PlantisColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(
              child: authProvider.isLoading
                  ? Semantics(
                      label: AccessibilityTokens.getSemanticLabel('loading', 'Fazendo login'),
                      liveRegion: true,
                      child: const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou continue com',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Enhanced Social buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildModernSocialButton(
              'G',
              Colors.red,
              _showSocialLoginDialog,
            ),
            _buildModernSocialButton(
              null,
              Colors.black,
              _showSocialLoginDialog,
              icon: Icons.apple,
            ),
            _buildModernSocialButton(
              null,
              Colors.blue,
              _showSocialLoginDialog,
              icon: Icons.window,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAnonymousLoginSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PlantisColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: OutlinedButton(
            onPressed: authProvider.isLoading
                ? null
                : _showAnonymousLoginDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: PlantisColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PlantisColors.primary,
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 22,
                        color: PlantisColors.primary,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Continuar sem conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PlantisColors.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
  
  Widget _buildModernSocialButton(
    String? text,
    Color color,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: icon != null
                ? Icon(icon, color: color, size: 24)
                : Text(
                    text!,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Register form with enhanced fields
  Widget _buildRegisterTab() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Enhanced Name field
          AccessibleTextField(
            controller: _registerNameController,
            focusNode: _registerNameFocusNode,
            nextFocusNode: _registerEmailFocusNode,
            labelText: 'Nome completo',
            hintText: 'Digite seu nome completo',
            semanticLabel: 'Campo de nome para cadastro',
            textInputAction: TextInputAction.next,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validateName(value ?? '');
            },
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 20),

          // Enhanced Email field
          AccessibleTextField(
            controller: _registerEmailController,
            focusNode: _registerEmailFocusNode,
            nextFocusNode: _registerPasswordFocusNode,
            labelText: 'E-mail',
            hintText: 'Digite seu email',
            semanticLabel: 'Campo de e-mail para cadastro',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocomplete: AutofillHints.email,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!AuthValidators.isValidEmail(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 20),

          // Enhanced Password field
          AccessibleTextField(
            controller: _registerPasswordController,
            focusNode: _registerPasswordFocusNode,
            nextFocusNode: _registerConfirmPasswordFocusNode,
            labelText: 'Senha',
            hintText: 'Mínimo 8 caracteres',
            semanticLabel: 'Campo de senha para cadastro',
            obscureText: _obscureRegisterPassword,
            textInputAction: TextInputAction.next,
            autocomplete: AutofillHints.newPassword,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validatePassword(value ?? '', isRegistration: true);
            },
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: Semantics(
              label: _obscureRegisterPassword 
                  ? AccessibilityTokens.getSemanticLabel('show_password', 'Mostrar senha')
                  : AccessibilityTokens.getSemanticLabel('hide_password', 'Ocultar senha'),
              button: true,
              child: IconButton(
                icon: Icon(
                  _obscureRegisterPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: PlantisColors.primary.withValues(alpha: 0.7),
                  size: 22,
                ),
                onPressed: () {
                  AccessibilityTokens.performHapticFeedback('light');
                  setState(() {
                    _obscureRegisterPassword = !_obscureRegisterPassword;
                  });
                  // Anunciar mudança para screen readers
                  final message = _obscureRegisterPassword ? 'Senha oculta' : 'Senha visível';
                  SemanticsService.announce(message, TextDirection.ltr);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Enhanced Confirm Password field
          AccessibleTextField(
            controller: _registerConfirmPasswordController,
            focusNode: _registerConfirmPasswordFocusNode,
            labelText: 'Confirmar senha',
            hintText: 'Digite a senha novamente',
            semanticLabel: 'Campo de confirmação de senha',
            obscureText: _obscureRegisterConfirmPassword,
            textInputAction: TextInputAction.done,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validatePasswordConfirmation(
                _registerPasswordController.text,
                value ?? '',
              );
            },
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: Semantics(
              label: _obscureRegisterConfirmPassword 
                  ? AccessibilityTokens.getSemanticLabel('show_password', 'Mostrar confirmação de senha')
                  : AccessibilityTokens.getSemanticLabel('hide_password', 'Ocultar confirmação de senha'),
              button: true,
              child: IconButton(
                icon: Icon(
                  _obscureRegisterConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: PlantisColors.primary.withValues(alpha: 0.7),
                  size: 22,
                ),
                onPressed: () {
                  AccessibilityTokens.performHapticFeedback('light');
                  setState(() {
                    _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword;
                  });
                  // Anunciar mudança para screen readers
                  final message = _obscureRegisterConfirmPassword ? 'Confirmação de senha oculta' : 'Confirmação de senha visível';
                  SemanticsService.announce(message, TextDirection.ltr);
                },
              ),
            ),
            onSubmitted: (value) {
              _registerButtonFocusNode?.requestFocus();
            },
          ),
          const SizedBox(height: 28),

          // Enhanced error message
          _buildErrorMessage(),

          // Enhanced register button
          _buildAccessibleRegisterButton(),
          const SizedBox(height: 20),

          // Terms text
          Text(
            'Ao criar uma conta, você concorda com nossos\nTermos de Serviço e Política de Privacidade',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AccessibleButton(
          focusNode: _registerButtonFocusNode,
          onPressed: authProvider.isLoading
              ? null
              : _handleRegister,
          semanticLabel: AccessibilityTokens.getSemanticLabel('register_button', 'Criar conta'),
          tooltip: 'Criar nova conta',
          minimumSize: const Size(
            double.infinity, 
            AccessibilityTokens.largeTouchTargetSize,
          ),
          hapticPattern: 'medium',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: authProvider.isLoading
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : [PlantisColors.primary, PlantisColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: authProvider.isLoading
                      ? Colors.grey.withValues(alpha: 0.3)
                      : PlantisColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(
              child: authProvider.isLoading
                  ? Semantics(
                      label: AccessibilityTokens.getSemanticLabel('loading', 'Criando conta'),
                      liveRegion: true,
                      child: const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  /// Exibe o dialog para reset de senha
  void _showForgotPasswordDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }


  /// Enhanced background pattern with plant motifs
  Widget _buildPlantBackgroundPattern() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: PlantBackgroundPatternPainter(
              animation: _backgroundAnimation.value,
              primaryColor: PlantisColors.primary,
            ),
          ),
        );
      },
    );
  }
  
  /// Floating plant elements with enhanced animations
  Widget _buildFloatingPlantElements() {
    return Stack(
      children: [
        // Top right floating leaf
        Positioned(
          top: 80,
          right: 40,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundAnimation.value * 2 * math.pi * 0.5,
                child: Transform.translate(
                  offset: Offset(
                    10 * math.sin(_backgroundAnimation.value * 2 * math.pi),
                    5 * math.cos(_backgroundAnimation.value * 2 * math.pi),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Colors.white.withValues(alpha: 0.12),
                    size: 45,
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom left flower
        Positioned(
          bottom: 120,
          left: 30,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_backgroundAnimation.value * 1.3 * math.pi,
                child: Transform.scale(
                  scale: 1.0 + (0.1 * math.sin(_backgroundAnimation.value * 3 * math.pi)),
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.white.withValues(alpha: 0.1),
                    size: 38,
                  ),
                ),
              );
            },
          ),
        ),
        // Middle floating seed
        Positioned(
          top: 200,
          left: 60,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  15 * math.sin(_backgroundAnimation.value * 1.5 * math.pi),
                  8 * math.cos(_backgroundAnimation.value * 1.8 * math.pi),
                ),
                child: Icon(
                  Icons.grain,
                  color: Colors.white.withValues(alpha: 0.08),
                  size: 28,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Enhanced plant-themed background painter
class PlantBackgroundPatternPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  
  PlantBackgroundPatternPainter({
    required this.animation,
    required this.primaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Base organic shapes
    final basePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    
    // Floating organic circles (like seeds)
    for (int i = 0; i < 6; i++) {
      final x = (size.width * (i + 1) / 7) + (40 * math.sin(animation * 1.5 + i));
      final y = (size.height * (i + 1) / 8) + (25 * math.cos(animation * 1.2 + i));
      final radius = 15 + (8 * math.sin(animation * 2.5 + i));
      
      canvas.drawCircle(Offset(x, y), radius, basePaint);
    }
    
    // Leaf-like curved lines
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.04)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final startX = size.width * (i + 1) / 5;
      final startY = size.height * 0.2 + (100 * math.sin(animation + i));
      
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 30 + (20 * math.cos(animation * 0.8 + i)),
        startY + 40 + (15 * math.sin(animation * 0.6 + i)),
        startX + 10 + (25 * math.sin(animation * 0.5 + i)),
        startY + 80 + (20 * math.cos(animation * 0.7 + i)),
      );
      
      canvas.drawPath(path, linePaint);
    }
    
    // Subtle dots pattern (like pollen or small seeds)
    final dotPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < size.width; i += 60) {
      for (int j = 0; j < size.height; j += 60) {
        final offsetX = 10 * math.sin(animation * 0.3 + i * 0.01);
        final offsetY = 8 * math.cos(animation * 0.4 + j * 0.01);
        canvas.drawCircle(
          Offset(i.toDouble() + offsetX, j.toDouble() + offsetY), 
          2.5, 
          dotPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(PlantBackgroundPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
