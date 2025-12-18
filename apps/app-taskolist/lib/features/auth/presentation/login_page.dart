import 'dart:async';
import 'dart:math' as math;

import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/failures.dart' as local;
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/sync/task_sync_loading.dart';
import '../../tasks/presentation/pages/home_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isAnonymousLoading = false;
  bool _rememberMe = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      _shakeForm();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      await ref
          .read(authProvider.notifier)
          .loginAndSync(_emailController.text.trim(), _passwordController.text);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showAnimatedSnackBar(message: _getErrorMessage(e), isError: true);
      }
    }
  }

  Future<void> _handleAnonymousLogin() async {
    debugPrint('🔄 Iniciando login anônimo...');
    setState(() {
      _isLoading = true;
      _isAnonymousLoading = true;
    });
    HapticFeedback.lightImpact();

    try {
      debugPrint('🔄 Chamando signInAnonymously...');
      await ref.read(authProvider.notifier).signInAnonymously();
      debugPrint('✅ Login anônimo concluído com sucesso');
    } catch (e) {
      debugPrint('❌ Erro no login anônimo: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAnonymousLoading = false;
        });
        _showAnimatedSnackBar(
          message: 'Erro no login anônimo: ${_getErrorMessage(e)}',
          isError: true,
        );
      }
    }
  }

  Future<void> _showAnonymousLoginDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withAlpha(26)
                      : Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withAlpha(51)
                        : const Color(0xFF667eea).withAlpha(51),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF667eea).withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              backgroundBlendMode: isDarkMode ? BlendMode.overlay : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withAlpha(102),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.visibility_off_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Login Anônimo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O que é o login anônimo?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF2C3E50),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No modo anônimo você pode:\n'
                        '• ✅ Testar todas as funcionalidades do app\n'
                        '• ✅ Criar e gerenciar suas tarefas\n'
                        '• ✅ Usar sem fornecer dados pessoais',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color:
                              isDarkMode
                                  ? Colors.white.withAlpha(204)
                                  : const Color(0xFF5A6C7D),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF9800).withAlpha(26),
                              const Color(0xFFFF5722).withAlpha(13),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF9800).withAlpha(77),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withAlpha(51),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF6F00),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Atenção: Seus dados serão perdidos se você sair do app.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDarkMode
                                          ? Colors.white.withAlpha(230)
                                          : const Color(0xFF5D4037),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDarkMode
                                  ? Colors.white.withAlpha(179)
                                  : Colors.grey[600],
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withAlpha(102),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: const Text('Continuar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _handleAnonymousLogin();
    }
  }

  Future<void> _handleGoogleLogin() async {
    _showSocialLoginDialog('Google');
  }

  Future<void> _handleAppleLogin() async {
    _showSocialLoginDialog('Apple');
  }

  void _showSocialLoginDialog(String provider) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Em Desenvolvimento'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login com $provider',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'O login social está em desenvolvimento e estará disponível em uma futura atualização!',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withAlpha(51)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Por enquanto, use o login com email ou modo anônimo.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendi'),
              ),
            ],
          ),
    );
  }

  void _shakeForm() {
    HapticFeedback.mediumImpact();
  }

  String _getErrorMessage(dynamic error) {
    if (error is local.Failure) {
      return error.message;
    }
    return error.toString();
  }

  void _showAnimatedSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Mostra loading simples de sincronização que navega automaticamente
  void _showSimpleSyncLoading() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder:
          (context) => SimpleTaskSyncLoading(
            message: 'Sincronizando suas tarefas...',
            primaryColor: Theme.of(context).primaryColor,
          ),
    );
    _navigateAfterSync();
  }

  /// Navega para HomePage quando sync terminar ou imediatamente
  void _navigateAfterSync() {
    late StreamSubscription<dynamic> subscription;

    subscription = Stream<dynamic>.periodic(
      const Duration(milliseconds: 500),
    ).listen((_) {
      subscription.cancel();
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          _navigateToHomePage();
        }
      });
    });
  }

  /// Navega para a HomePage principal
  void _navigateToHomePage() {
    debugPrint('🚀 Navegando para HomePage...');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<dynamic>(
        pageBuilder:
            (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(authProvider, (previous, next) {
      debugPrint('🔄 Auth listener: Estado mudou');
      next.when(
        data: (user) {
          debugPrint('✅ Auth listener: Usuário autenticado: ${user?.id}');
          if (user != null && mounted) {
            setState(() {
              _isLoading = false;
              _isAnonymousLoading = false;
            });
            _navigateToHomePage();
          }
        },
        loading: () {
          debugPrint('🔄 Auth listener: Estado de loading');
          setState(() => _isLoading = true);
        },
        error: (error, stackTrace) {
          debugPrint('❌ Auth listener: Erro na autenticação: $error');
          setState(() => _isLoading = false);
          _showAnimatedSnackBar(
            message: _getErrorMessage(error),
            isError: true,
          );
        },
      );
    });

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF0f0f1e),
                      const Color(0xFF16213e),
                    ]
                    : [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                      const Color(0xFF6B8DD6),
                    ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundPattern(),
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogoSection(isDarkMode),
                          const SizedBox(height: 48),
                          _buildGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildWelcomeText(isDarkMode),
                                  const SizedBox(height: 32),
                                  _buildModernTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildModernTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    label: 'Senha',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    validator: _validatePassword,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildOptionsRow(),
                                  const SizedBox(height: 32),
                                  _buildGradientButton(
                                    onPressed:
                                        (_isLoading || _isAnonymousLoading)
                                            ? null
                                            : _handleLogin,
                                    text: 'Entrar',
                                    isLoading:
                                        _isLoading && !_isAnonymousLoading,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSocialLoginSection(),
                                  const SizedBox(height: 24),
                                  _buildDemoButton(),
                                  const SizedBox(height: 20),
                                  _buildRegisterLink(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: BackgroundPatternPainter(
              rotation: _rotationAnimation.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection(bool isDarkMode) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      ..rotateY(_rotationAnimation.value * 0.5)
                      ..rotateZ(_rotationAnimation.value * 0.1),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(230),
                        Colors.white.withAlpha(179),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFF667eea).withAlpha(102),
                        blurRadius: 30,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 50,
                    color: Color(0xFF667eea),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ).createShader(bounds),
            child: Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withAlpha(64),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(51), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withAlpha(26),
            BlendMode.overlay,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildWelcomeText(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Bem-vindo de volta!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para continuar organizando suas tarefas',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(179),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isFocused
                ? [
                  BoxShadow(
                    color: const Color(0xFF667eea).withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isFocused ? Colors.white : Colors.white.withAlpha(153),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: isFocused ? Colors.white : Colors.white.withAlpha(128),
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.white.withAlpha(153),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white.withAlpha(13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha(51), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withAlpha(179),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          errorStyle: TextStyle(color: Colors.red[300], fontSize: 12),
        ),
        validator: validator,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFF667eea),
                checkColor: Colors.white,
                side: BorderSide(color: Colors.white.withAlpha(128), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Lembrar-me',
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 14,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                  },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('Esqueci a senha'),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child:
                isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withAlpha(77), thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou continue com',
                style: TextStyle(
                  color: Colors.white.withAlpha(179),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withAlpha(77), thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              onPressed: _isLoading ? null : _handleGoogleLogin,
              icon: Icons.g_mobiledata_rounded,
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              onPressed: _isLoading ? null : _handleAppleLogin,
              icon: Icons.apple_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              onPressed: _isLoading ? null : _handleAnonymousLogin,
              icon: Icons.person_outline_rounded,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(51), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: Icon(icon, color: color, size: 28)),
        ),
      ),
    );
  }

  Widget _buildDemoButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _showAnonymousLoginDialog,
      icon: const Icon(Icons.visibility_off_rounded),
      label: const Text('Login Anônimo'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withAlpha(128), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 14),
        ),
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    Navigator.of(context).push(
                      PageRouteBuilder<dynamic>(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const RegisterPage(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Registre-se'),
        ),
      ],
    );
  }
}
class BackgroundPatternPainter extends CustomPainter {
  final double rotation;

  BackgroundPatternPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * (0.2 + i * 0.2) + math.sin(rotation + i) * 20,
        size.height * 0.1 + math.cos(rotation + i) * 30,
      );

      paint.color = Colors.white.withAlpha((10 + i * 5));
      canvas.drawCircle(offset, 30 + i * 10.0, paint);
    }
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white.withAlpha(5);
    paint.strokeWidth = 0.5;

    for (int i = 0; i < 20; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 20),
        Offset(size.width * i / 20, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return rotation != oldDelegate.rotation;
  }
}
