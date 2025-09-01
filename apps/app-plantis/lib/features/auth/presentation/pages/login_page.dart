import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/enhanced_loading_states.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../utils/auth_validators.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin, LoadingStateMixin, AccessibilityFocusMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  // Focus nodes para navegação por teclado
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _loginButtonFocusNode;

  // Enhanced animations
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializar focus nodes
    _emailFocusNode = getFocusNode('email');
    _passwordFocusNode = getFocusNode('password');
    _loginButtonFocusNode = getFocusNode('login_button');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      showLoading(message: 'Fazendo login...');
      
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(_emailController.text, _passwordController.text);

      hideLoading();
      
      if (authProvider.isAuthenticated && mounted) {
        context.go('/plants');
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
              await authProvider.signInAnonymously();
              
              hideLoading();
              
              if (authProvider.isAuthenticated && mounted) {
                context.go('/plants');
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
    final isMobile = size.width <= 600;
    
    return buildWithLoading(
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlantisColors.primary,
                  PlantisColors.primary.withValues(alpha: 0.8),
                  PlantisColors.primary.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background pattern
                _buildAnimatedBackground(),
                
                // Floating elements
                _buildFloatingElements(),
                
                // Main content
                Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isMobile 
                                    ? size.width * 0.9 
                                    : (isDesktop ? 900 : 450),
                                minHeight: 0,
                              ),
                              child: Card(
                                elevation: 25,
                                shadowColor: Colors.black.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                color: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Modern header with enhanced logo
                                      _buildEnhancedHeader(context),
                                      SizedBox(height: isMobile ? 32 : 40),

                                      // Modern tab navigation
                                      _buildModernTabNavigation(context),
                                      SizedBox(height: isMobile ? 24 : 32),

                                      // Form
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Enhanced Email field
                                            AccessibleTextField(
                                              controller: _emailController,
                                              focusNode: _emailFocusNode,
                                              nextFocusNode: _passwordFocusNode,
                                              labelText: 'E-mail',
                                              hintText: 'Digite seu email',
                                              semanticLabel: 'Campo de e-mail para login',
                                              keyboardType: TextInputType.emailAddress,
                                              textInputAction: TextInputAction.next,
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
                                              controller: _passwordController,
                                              focusNode: _passwordFocusNode,
                                              labelText: 'Senha',
                                              hintText: 'Digite sua senha',
                                              semanticLabel: 'Campo de senha para login',
                                              obscureText: _obscurePassword,
                                              textInputAction: TextInputAction.done,
                                              isRequired: true,
                                              validator: (value) {
                                                return AuthValidators.validatePassword(value ?? '', isRegistration: false);
                                              },
                                              prefixIcon: const Icon(Icons.lock_outline),
                                              suffixIcon: Semantics(
                                                label: _obscurePassword 
                                                    ? AccessibilityTokens.getSemanticLabel('show_password', 'Mostrar senha')
                                                    : AccessibilityTokens.getSemanticLabel('hide_password', 'Ocultar senha'),
                                                button: true,
                                                child: IconButton(
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons.visibility_outlined
                                                        : Icons.visibility_off_outlined,
                                                    color: PlantisColors.primary.withValues(alpha: 0.7),
                                                    size: 22,
                                                  ),
                                                  onPressed: () {
                                                    AccessibilityTokens.performHapticFeedback('light');
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                    // Anunciar mudança para screen readers
                                                    final message = _obscurePassword ? 'Senha oculta' : 'Senha visível';
                                                    SemanticsService.announce(message, TextDirection.ltr);
                                                  },
                                                ),
                                              ),
                                              onSubmitted: (value) {
                                                _loginButtonFocusNode.requestFocus();
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // Enhanced footer
                _buildModernFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced UI Components
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: BackgroundPatternPainter(
              animation: _backgroundAnimation.value,
              primaryColor: PlantisColors.primary,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Top floating leaves
        Positioned(
          top: 100,
          right: 30,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundAnimation.value * 2 * 3.14159,
                child: Icon(
                  Icons.eco,
                  color: Colors.white.withValues(alpha: 0.1),
                  size: 40,
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 150,
          left: 20,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_backgroundAnimation.value * 1.5 * 3.14159,
                child: Icon(
                  Icons.local_florist,
                  color: Colors.white.withValues(alpha: 0.1),
                  size: 35,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildEnhancedHeader(BuildContext context) {
    return Column(
      children: [
        // Logo with glow effect
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                PlantisColors.primary.withValues(alpha: 0.2),
                PlantisColors.primary.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PlantisColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: PlantisColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.eco,
              size: 40,
              color: PlantisColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // App name with modern typography
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [PlantisColors.primary, PlantisColors.primary.withValues(alpha: 0.7)],
          ).createShader(bounds),
          child: Text(
            'PlantApp',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Cuidado inteligente de plantas',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernTabNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PlantisColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Entrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PlantisColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/register'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Cadastrar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
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
                  onPressed: null, // Disabled for now
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
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: (authProvider.isLoading || isAnonymousLoading)
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : [PlantisColors.primary, PlantisColors.primary.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (authProvider.isLoading || isAnonymousLoading)
                      ? Colors.grey.withValues(alpha: 0.3)
                      : PlantisColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
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
  
  Widget _buildModernFooter() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: Text(
              '© 2025 PlantApp - Cuidado inteligente de plantas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  
  BackgroundPatternPainter({
    required this.animation,
    required this.primaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    // Draw floating circles
    for (int i = 0; i < 5; i++) {
      final x = (size.width * (i + 1) / 6) + (50 * math.sin(animation * 2 + i));
      final y = (size.height * (i + 1) / 7) + (30 * math.cos(animation * 1.5 + i));
      final radius = 20 + (10 * math.sin(animation * 3 + i));
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}