import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/splash_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/background_pattern_painter.dart';
import '../widgets/desktop_branding_widget.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/mobile_header_widget.dart';
import '../widgets/password_recovery_widget.dart';
import '../widgets/social_login_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Page and animation controllers
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State management
  int _currentStep = 0;
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _showRecoveryForm = false;
  bool _rememberMe = false;
  
  // Email validation
  bool _isEmailValid = false;
  bool _isEmailChecking = false;
  bool _emailExists = false;
  
  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;
  
  // Signup steps
  final List<String> _signupSteps = [
    'Informações Básicas',
    'Configurar Senha',
    'Finalizar Cadastro',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    // Email validation listener
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isMobile = size.width <= 600;
    
    ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/');
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: SplashColors.heroGradient,
            ),
          ),
          child: Stack(
            children: [
              // Animated background pattern
              _buildAnimatedBackground(),
              
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile 
                              ? size.width * 0.9 
                              : (isDesktop ? 1000 : 500),
                        ),
                        child: Card(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: isDesktop
                              ? _buildDesktopLayout(size)
                              : _buildMobileLayout(size),
                        ),
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

  // Email validation
  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _isEmailValid = false;
        _emailExists = false;
      });
      return;
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final isValid = emailRegex.hasMatch(email);
    
    setState(() {
      _isEmailValid = isValid;
    });
    
    if (isValid && !_isLoginMode) {
      _checkEmailExists(email);
    }
  }
  
  Future<void> _checkEmailExists(String email) async {
    setState(() => _isEmailChecking = true);
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For demo purposes, assume some emails exist
    final exists = email.contains('test') || email.contains('admin');
    
    setState(() {
      _isEmailChecking = false;
      _emailExists = exists;
    });
  }
  
  // Password strength checker
  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    String strengthText = '';
    Color strengthColor = Colors.grey;
    
    if (password.isEmpty) {
      strength = 0;
      strengthText = '';
    } else if (password.length < 6) {
      strength = 0.2;
      strengthText = 'Muito fraca';
      strengthColor = Colors.red;
    } else {
      strength = 0.4;
      strengthText = 'Fraca';
      strengthColor = Colors.orange;
      
      if (password.length >= 8) {
        strength = 0.6;
        strengthText = 'Moderada';
        strengthColor = Colors.yellow[700]!;
      }
      
      if (RegExp(r'[A-Z]').hasMatch(password)) {
        strength += 0.1;
      }
      
      if (RegExp(r'[0-9]').hasMatch(password)) {
        strength += 0.1;
      }
      
      if (RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(password)) {
        strength += 0.2;
      }
      
      if (strength >= 0.8) {
        strengthText = 'Forte';
        strengthColor = Colors.green;
      } else if (strength >= 0.6) {
        strengthText = 'Boa';
        strengthColor = Colors.lightGreen;
      }
    }
    
    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  // Animation and background methods
  Widget _buildAnimatedBackground() {
    return CustomPaint(
      painter: BackgroundPatternPainter(),
      size: Size.infinite,
    );
  }
  
  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // Left side with branding
        const Expanded(
          flex: 6,
          child: DesktopBrandingWidget(),
        ),
        // Right side with form
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: _showRecoveryForm 
                ? PasswordRecoveryWidget(
                    emailController: _emailController,
                    isLoading: _isLoading,
                    onSendReset: _sendPasswordReset,
                    onBackToLogin: () => setState(() => _showRecoveryForm = false),
                  )
                : (_isLoginMode 
                    ? Column(
                        children: [
                          LoginFormWidget(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            rememberMe: _rememberMe,
                            isLoading: _isLoading,
                            onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                            onRememberMeChanged: (value) => setState(() => _rememberMe = value ?? false),
                            onLogin: _handleLogin,
                            onForgotPassword: () => setState(() => _showRecoveryForm = true),
                            showAuthToggle: false,
                          ),
                          SocialLoginWidget(
                            isLoading: _isLoading,
                            onSocialAuth: _handleSocialAuth,
                            onAnonymousLogin: _showAnonymousLoginDialog,
                          ),
                        ],
                      )
                    : _buildSignupWizard()
                  ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Mobile header
          const MobileHeaderWidget(),
          const SizedBox(height: 40),
          // Form content
          _showRecoveryForm 
              ? PasswordRecoveryWidget(
                  emailController: _emailController,
                  isLoading: _isLoading,
                  onSendReset: _sendPasswordReset,
                  onBackToLogin: () => setState(() => _showRecoveryForm = false),
                )
              : (_isLoginMode 
                  ? Column(
                      children: [
                        LoginFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          rememberMe: _rememberMe,
                          isLoading: _isLoading,
                          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                          onRememberMeChanged: (value) => setState(() => _rememberMe = value ?? false),
                          onLogin: _handleLogin,
                          onForgotPassword: () => setState(() => _showRecoveryForm = true),
                          onToggleAuth: () => setState(() => _isLoginMode = !_isLoginMode),
                          showAuthToggle: MediaQuery.of(context).size.width <= 600,
                        ),
                        SocialLoginWidget(
                          isLoading: _isLoading,
                          onSocialAuth: _handleSocialAuth,
                          onAnonymousLogin: _showAnonymousLoginDialog,
                        ),
                      ],
                    )
                  : _buildSignupWizard()
                ),
        ],
      ),
    );
  }
  
  
  Widget _buildFeatureHighlights() {
    final features = [
      {'icon': Icons.pets, 'text': 'Gestão Completa de Pets'},
      {'icon': Icons.calendar_month, 'text': 'Agendamentos Inteligentes'},
      {'icon': Icons.analytics, 'text': 'Relatórios Detalhados'},
    ];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              feature['icon'] as IconData,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              feature['text'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
  
  // Auth toggle for mobile
  Widget _buildAuthToggle() {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => setState(() => _isLoginMode = true),
            child: Column(
              children: [
                Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isLoginMode 
                        ? SplashColors.primaryColor 
                        : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  decoration: BoxDecoration(
                    color: _isLoginMode 
                        ? SplashColors.primaryColor 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: GestureDetector(
            onTap: () => setState(() => _isLoginMode = false),
            child: Column(
              children: [
                Text(
                  'Cadastrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: !_isLoginMode 
                        ? SplashColors.primaryColor 
                        : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  decoration: BoxDecoration(
                    color: !_isLoginMode 
                        ? SplashColors.primaryColor 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Login form
  Widget _buildLoginForm() {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Auth toggle for mobile
          if (isMobile) ...[
            _buildAuthToggle(),
            const SizedBox(height: 32),
          ],
          
          // Title
          Text(
            'Entrar',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse sua conta para gerenciar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Email field
          _buildEmailField(),
          const SizedBox(height: 20),
          
          // Password field
          _buildPasswordField(),
          const SizedBox(height: 16),
          
          // Remember me and forgot password
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                activeColor: SplashColors.primaryColor,
              ),
              const Text('Lembrar-me'),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showRecoveryForm = true),
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    color: SplashColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Login button
          _buildActionButton('Entrar', _handleLogin),
          
          // Social login
          _buildSocialLogin(),
        ],
      ),
    );
  }
  
  // Signup wizard
  Widget _buildSignupWizard() {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Auth toggle for mobile
        if (isMobile) ...[
          _buildAuthToggle(),
          const SizedBox(height: 32),
        ],
        
        // Progress indicator
        _buildSignupProgress(),
        const SizedBox(height: 32),
        
        // Content based on current step
        SizedBox(
          height: 400,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSignupStep1(), // Basic info
              _buildSignupStep2(), // Password
              _buildSignupStep3(), // Confirmation
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSignupProgress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(_signupSteps.length, (index) {
            final isActive = index <= _currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: isActive 
                            ? SplashColors.primaryColor 
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < _signupSteps.length - 1) 
                    const SizedBox(width: 8),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          _signupSteps[_currentStep],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: SplashColors.primaryColor,
          ),
        ),
      ],
    );
  }

  // Signup steps
  Widget _buildSignupStep1() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criar Conta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preencha suas informações básicas',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: SplashColors.primaryColor),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Nome é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Email field with validation
          _buildEmailField(showValidation: true),
          
          const SizedBox(height: 40),
          
          // Next button
          _buildActionButton('Continuar', _nextStep),
        ],
      ),
    );
  }
  
  Widget _buildSignupStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configurar Senha',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Crie uma senha segura para sua conta',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        // Password field with strength indicator
        _buildPasswordField(showStrength: true),
        const SizedBox(height: 20),
        
        // Confirm password field
        _buildConfirmPasswordField(),
        
        const SizedBox(height: 40),
        
        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Voltar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton('Continuar', _nextStep),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSignupStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Finalizar Cadastro',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Revise suas informações e finalize o cadastro',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        // Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Nome', _nameController.text),
              _buildSummaryRow('Email', _emailController.text),
              _buildSummaryRow('Senha', '••••••••'),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Voltar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton('Criar Conta', _handleSignup),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Form fields
  Widget _buildEmailField({bool showValidation = false}) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: showValidation && _emailController.text.isNotEmpty
            ? _isEmailChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _isEmailValid
                    ? Icon(
                        _emailExists ? Icons.warning : Icons.check_circle,
                        color: _emailExists ? Colors.orange : Colors.green,
                      )
                    : const Icon(Icons.error, color: Colors.red)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SplashColors.primaryColor),
        ),
        helperText: showValidation && _emailExists 
            ? 'Este email já está cadastrado' 
            : null,
        helperStyle: const TextStyle(color: Colors.orange),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Email é obrigatório';
        }
        if (!_isEmailValid) {
          return 'Email inválido';
        }
        return null;
      },
    );
  }
  
  Widget _buildPasswordField({bool showStrength = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SplashColors.primaryColor),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Senha é obrigatória';
            }
            if (value!.length < 6) {
              return 'Senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
        ),
        if (showStrength && _passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_passwordStrengthColor),
          ),
          const SizedBox(height: 4),
          Text(
            _passwordStrengthText,
            style: TextStyle(
              fontSize: 12,
              color: _passwordStrengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirmar senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SplashColors.primaryColor),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Confirmação de senha é obrigatória';
        }
        if (value != _passwordController.text) {
          return 'Senhas não coincidem';
        }
        return null;
      },
    );
  }
  
  Widget _buildRecoveryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Recuperar Senha',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Digite seu email para receber o link de recuperação',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        _buildEmailField(),
        const SizedBox(height: 32),
        
        _buildActionButton('Enviar Link', _sendPasswordReset),
        const SizedBox(height: 20),
        
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _showRecoveryForm = false),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar para login'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SplashColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  
  Widget _buildSocialLogin() {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou continue com',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                text: 'Google',
                onPressed: () => _handleSocialAuth('google'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.apple,
                text: 'Apple',
                onPressed: () => _handleSocialAuth('apple'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Anonymous login button
        SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _showAnonymousLoginDialog,
            icon: const Icon(Icons.person_outline, size: 18),
            label: const Text('Entrar Anonimamente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: null, // Disabled for now
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Navigation methods
  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_currentStep < _signupSteps.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Auth handlers
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await ref.read(authProvider.notifier).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success && mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await ref.read(authProvider.notifier).signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      
      if (success && mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _sendPasswordReset() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um email válido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperação enviado!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _showRecoveryForm = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _handleSocialAuth(String provider) {
    switch (provider) {
      case 'google':
        ref.read(authProvider.notifier).signInWithGoogle();
        break;
      case 'apple':
        ref.read(authProvider.notifier).signInWithApple();
        break;
    }
  }

  void _showAnonymousLoginDialog() {
    showDialog(
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
              setState(() => _isLoading = true);
              
              final success = await ref.read(authProvider.notifier).signInAnonymously();
              
              setState(() => _isLoading = false);
              
              if (success && mounted) {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Acesso anônimo realizado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Prosseguir'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    const spacing = 50.0;
    
    // Draw grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}