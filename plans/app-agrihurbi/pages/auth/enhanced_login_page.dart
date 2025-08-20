// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../../../core/services/auth_validation_service.dart';
import '../../controllers/auth_controller.dart';

class EnhancedLoginPage extends StatefulWidget {
  const EnhancedLoginPage({super.key});

  @override
  State<EnhancedLoginPage> createState() => _EnhancedLoginPageState();
}

class _EnhancedLoginPageState extends State<EnhancedLoginPage>
    with SingleTickerProviderStateMixin {
  late AgrihurbiAuthController _controller;

  // Animação para entrada dos elementos
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final _loginFormKey = GlobalKey<FormState>();

  // Controle do PageView para steps de cadastro
  final PageController _signUpPageController = PageController();
  int _currentSignUpStep = 0;
  bool _isCheckingEmail = false;
  final List<GlobalKey<FormState>> _stepFormKeys = [
    GlobalKey<FormState>(), // Boas-vindas
    GlobalKey<FormState>(), // Nome + Email
    GlobalKey<FormState>(), // Senha
  ];

  // FocusNodes para controle de foco
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _loginEmailFocusNode = FocusNode();
  final FocusNode _loginPasswordFocusNode = FocusNode();

  // Cores do tema específicas para o AgriHurbi (agrícola)
  Color get primaryColor => ThemeManager().isDark.value
      ? Colors.green.shade700
      : Colors.green.shade700;
  Color get accentColor => ThemeManager().isDark.value
      ? Colors.green.shade400
      : Colors.green.shade600;

  @override
  void initState() {
    super.initState();
    _controller = AgrihurbiAuthController();

    // Ensure web users start in login mode (not signup)
    if (GetPlatform.isWeb && _controller.isSignUp) {
      _controller.toggleAuthMode();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Carregar dados salvos se houver
    _loadSavedFormData();

    // Configurar validação em tempo real
    _setupRealTimeValidation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _signUpPageController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _loginEmailFocusNode.dispose();
    _loginPasswordFocusNode.dispose();
    super.dispose();
  }

  // Carregar dados salvos do formulário
  Future<void> _loadSavedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('agrihurbi_signup_name');
      final savedEmail = prefs.getString('agrihurbi_signup_email');

      if (savedName != null) {
        _controller.nameController.text = savedName;
      }
      if (savedEmail != null) {
        _controller.emailController.text = savedEmail;
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados salvos: $e');
    }
  }

  // Salvar dados do formulário
  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'agrihurbi_signup_name', _controller.nameController.text);
      await prefs.setString(
          'agrihurbi_signup_email', _controller.emailController.text);
    } catch (e) {
      debugPrint('Erro ao salvar dados: $e');
    }
  }

  // Configurar validação em tempo real
  void _setupRealTimeValidation() {
    _controller.nameController.addListener(() {
      if (_controller.nameController.text.isNotEmpty) {
        _saveFormData();
      }
    });

    _controller.emailController.addListener(() {
      if (_controller.emailController.text.isNotEmpty) {
        _saveFormData();
      }
    });

    _controller.passwordController.addListener(() {
      if (mounted) setState(() {}); // Para atualizar indicador de força
    });
  }

  // Haptic feedback
  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  // Ir para próximo step
  void _nextStep() {
    _triggerHapticFeedback();
    if (_currentSignUpStep < 2) {
      setState(() => _currentSignUpStep++);
      _signUpPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _setFocusForStep(_currentSignUpStep);
    }
  }

  // Voltar step anterior
  void _previousStep() {
    _triggerHapticFeedback();
    if (_currentSignUpStep > 0) {
      setState(() => _currentSignUpStep--);
      _signUpPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _setFocusForStep(_currentSignUpStep);
    }
  }

  // Configurar focus para cada step
  void _setFocusForStep(int step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (step) {
        case 1:
          _nameFocusNode.requestFocus();
          break;
        case 2:
          _passwordFocusNode.requestFocus();
          break;
      }
    });
  }

  // Verificar email e avançar
  Future<void> _checkEmailAndAdvance() async {
    if (!_stepFormKeys[1].currentState!.validate()) return;

    setState(() => _isCheckingEmail = true);

    final email = _controller.emailController.text.trim();
    final emailExists = await _controller.checkEmailExists(email);

    setState(() => _isCheckingEmail = false);

    if (!mounted) return;

    if (emailExists) {
      _showEmailExistsDialog();
    } else {
      _nextStep();
    }
  }

  // Dialog quando email já existe
  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Email já cadastrado'),
          ],
        ),
        content: const Text(
          'Este email já possui uma conta. Deseja fazer login ou usar outro email?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Trocar Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.toggleAuthMode(); // Muda para login
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Fazer Login',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Finalizar cadastro
  Future<void> _finishSignUp() async {
    if (!_stepFormKeys[2].currentState!.validate()) return;

    _triggerHapticFeedback();
    await _controller.signUpWithEmail();

    // Limpar dados salvos após sucesso
    if (_controller.getCurrentUser() != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('agrihurbi_signup_name');
      await prefs.remove('agrihurbi_signup_email');
    }
  }

  // Indicador de força da senha
  Widget _buildPasswordStrengthIndicator() {
    final strength = _controller.getPasswordStrength();
    final message = _controller.getPasswordStrengthMessage();

    Color strengthColor;
    double strengthValue;

    switch (strength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        strengthValue = 0.33;
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        strengthValue = 0.66;
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        strengthValue = 1.0;
        break;
      default:
        strengthColor = Colors.red.shade300;
        strengthValue = 0.15;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strengthValue,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 4,
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final bool isDesktop = size.width > 900;
        final bool isTablet = size.width > 600 && size.width <= 900;
        final bool isMobile = size.width <= 600;
        final isDark = ThemeManager().isDark.value;

        // Forçar orientação retrato para melhor experiência em dispositivos móveis
        if (isMobile) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }

        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: Stack(
              children: [
                // Background com imagem agrícola
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/bg_01.jpg',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black54,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop
                              ? 1000
                              : (isTablet ? 600 : size.width * 0.9),
                          maxHeight: isDesktop ? 700 : double.infinity,
                        ),
                        child: Card(
                          elevation: isDesktop ? 16 : 8,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isDesktop ? 20 : 16),
                          ),
                          child: isDesktop
                              ? _buildDesktopLayout(size)
                              : _buildMobileLayout(size),
                        ),
                      ),
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

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // Lado esquerdo com banner temático agrícola
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/bg_02.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.green.shade900.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo e título
                      const Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'AgriHurbi',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Tecnologia que transforma o agronegócio',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Soluções digitais que simplificam o trabalho e aumentam a produtividade no campo.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Features list agrícolas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFeatureItem(
                                '🌱', 'Gestão de Plantio e Colheita'),
                            _buildFeatureItem(
                                '🐄', 'Controle de Gado e Rebanho'),
                            _buildFeatureItem('🧮', 'Calculadoras Agrícolas'),
                            _buildFeatureItem('🌦️', 'Monitoramento Climático'),
                            _buildFeatureItem(
                                '📊', 'Relatórios de Produtividade'),
                            _buildFeatureItem('🔒', 'Dados Seguros na Nuvem'),
                          ],
                        ),
                      ),

                      // Footer com ícone de segurança
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Plataforma segura e confiável',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Lado direito com formulário
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: _buildAuthContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header com logo e título
          _buildMobileHeader(),
          const SizedBox(height: 32),

          // Conteúdo principal
          Expanded(
            child: _buildAuthContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        // Logo e título
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              color: primaryColor,
              size: 36,
            ),
            const SizedBox(width: 12),
            Text(
              'AgriHurbi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Agronegócio Digital',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthContent() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Column(
        children: [
          // Tabs Login/Cadastro
          _buildAuthTabs(),
          const SizedBox(height: 24),

          // Conteúdo do formulário
          Expanded(
            child:
                _controller.isSignUp ? _buildSignUpSteps() : _buildLoginForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_controller.isSignUp) {
                  _triggerHapticFeedback();
                  _controller.toggleAuthMode();
                  setState(() => _currentSignUpStep = 0);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      !_controller.isSignUp ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_controller.isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        !_controller.isSignUp ? primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_controller.isSignUp) {
                  _triggerHapticFeedback();
                  _controller.toggleAuthMode();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _controller.isSignUp ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _controller.isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Cadastro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        _controller.isSignUp ? primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo de volta!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse sua conta AgriHurbi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Campo email
          TextFormField(
            controller: _controller.emailController,
            focusNode: _loginEmailFocusNode,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _loginPasswordFocusNode.requestFocus(),
            validator: _controller.validateEmail,
          ),
          const SizedBox(height: 16),

          // Campo senha
          TextFormField(
            controller: _controller.passwordController,
            focusNode: _loginPasswordFocusNode,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  _triggerHapticFeedback();
                  _controller.togglePasswordVisibility();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            obscureText: _controller.obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _controller.signInWithEmail(),
            validator: _controller.validatePassword,
          ),
          const SizedBox(height: 8),

          // Esqueceu a senha
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _triggerHapticFeedback();
                _controller.showRecoveryFormAction();
              },
              child: Text(
                'Esqueceu a senha?',
                style: TextStyle(color: accentColor),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botão de login
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _controller.isLoading
                  ? null
                  : () {
                      _triggerHapticFeedback();
                      _controller.signInWithEmail();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Mensagem de erro
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Footer de recovery
          if (_controller.showRecoveryForm) _buildRecoveryForm(),
        ],
      ),
    );
  }

  Widget _buildSignUpSteps() {
    return Column(
      children: [
        // Indicador de progresso
        _buildStepIndicator(),
        const SizedBox(height: 24),

        // Conteúdo dos steps
        Expanded(
          child: PageView(
            controller: _signUpPageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildWelcomeStep(),
              _buildNameEmailStep(),
              _buildPasswordStep(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentSignUpStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.eco,
          size: 80,
          color: primaryColor,
        ),
        const SizedBox(height: 24),
        const Text(
          'Bem-vindo ao AgriHurbi!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vamos criar sua conta para revolucionar sua gestão agrícola.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _triggerHapticFeedback();
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Começar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameEmailStep() {
    return Form(
      key: _stepFormKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Básicas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Como podemos te chamar?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Campo nome
          TextFormField(
            controller: _controller.nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
            validator: _controller.validateName,
          ),
          const SizedBox(height: 16),

          // Campo email
          TextFormField(
            controller: _controller.emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _checkEmailAndAdvance(),
            validator: _controller.validateEmail,
          ),

          const Spacer(),

          // Botões
          Row(
            children: [
              TextButton(
                onPressed: _previousStep,
                child: const Text('Voltar'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isCheckingEmail ? null : _checkEmailAndAdvance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCheckingEmail
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _stepFormKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criar Senha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha uma senha segura',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Campo senha
          TextFormField(
            controller: _controller.passwordController,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  _triggerHapticFeedback();
                  _controller.togglePasswordVisibility();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            obscureText: _controller.obscurePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            validator: _controller.validateSignUpPassword,
          ),

          // Indicador de força da senha
          if (_controller.passwordController.text.isNotEmpty)
            _buildPasswordStrengthIndicator(),

          const SizedBox(height: 16),

          // Campo confirmar senha
          TextFormField(
            controller: _controller.confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  _triggerHapticFeedback();
                  _controller.toggleConfirmPasswordVisibility();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            obscureText: _controller.obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _finishSignUp(),
            validator: _controller.validateConfirmPassword,
          ),

          const Spacer(),

          // Botões
          Row(
            children: [
              TextButton(
                onPressed: _previousStep,
                child: const Text('Voltar'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _controller.isLoading ? null : _finishSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Criar Conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),

          // Mensagem de erro
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecoveryForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Recuperar Senha',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Digite seu email para receber o link de recuperação',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _controller.isLoading
                  ? null
                  : () {
                      _triggerHapticFeedback();
                      _controller.resetPassword();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Enviar Email'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _triggerHapticFeedback();
              _controller.hideRecoveryFormAction();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
