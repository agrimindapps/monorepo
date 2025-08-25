// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  final bool? showBackButton;

  const LoginPage({super.key, this.showBackButton});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late GasometerAuthController _controller;

  // Animação para entrada dos elementos
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final _loginFormKey = GlobalKey<FormState>();

  // Controle do PageView para steps de cadastro
  final PageController _signUpPageController = PageController();
  int _currentSignUpStep = 0;
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

  // Cores do tema específicas para o GasOMeter usando design tokens
  Color primaryColor(BuildContext context) => ThemeManager().isDark.value
      ? Colors.amber.shade600
      : Colors.blue.shade700;
  Color accentColor(BuildContext context) => ThemeManager().isDark.value
      ? Colors.amber.shade400
      : Colors.blue.shade400;

  @override
  void initState() {
    super.initState();
    _controller = GasometerAuthController();

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

  /// Carrega os dados salvos do formulário
  Future<void> _loadSavedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('gasometer_saved_name');
      final savedEmail = prefs.getString('gasometer_saved_email');

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

  /// Configura validação em tempo real
  void _setupRealTimeValidation() {
    // Adicionar listeners para validação em tempo real se necessário
    _controller.emailController.addListener(() {
      // Validação em tempo real pode ser adicionada aqui
    });
  }

  /// Salva dados do formulário
  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_controller.nameController.text.isNotEmpty) {
        await prefs.setString(
            'gasometer_saved_name', _controller.nameController.text);
      }
      if (_controller.emailController.text.isNotEmpty) {
        await prefs.setString(
            'gasometer_saved_email', _controller.emailController.text);
      }
    } catch (e) {
      debugPrint('Erro ao salvar dados: $e');
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }
    await _controller.signInWithEmail();

    // Se login bem-sucedido, salvar dados
    if (_controller.getCurrentUser() != null) {
      await _saveFormData();
    }
  }

  Future<void> _signUpWithEmail() async {
    final currentForm = _stepFormKeys[_currentSignUpStep];

    // Validar step atual
    if (_currentSignUpStep == 0) {
      // Step de boas-vindas, apenas avançar
      _nextSignUpStep();
      return;
    } else if (_currentSignUpStep == 1) {
      // Step de nome e email
      if (currentForm.currentState!.validate()) {
        await _saveFormData();
        _nextSignUpStep();
      }
      return;
    } else if (_currentSignUpStep == 2) {
      // Step final de senha
      if (currentForm.currentState!.validate()) {
        await _controller.signUpWithEmail();
        await _saveFormData();
      }
    }
  }

  void _nextSignUpStep() {
    if (_currentSignUpStep < 2) {
      setState(() {
        _currentSignUpStep++;
      });
      _signUpPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousSignUpStep() {
    if (_currentSignUpStep > 0) {
      setState(() {
        _currentSignUpStep--;
      });
      _signUpPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _resetPassword() async {
    await _controller.resetPassword();
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
        // como no exemplo do Calculei
        if (isMobile) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }

        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ThemeManager().isDark.value
                      ? [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          const Color(0xFF0F3460),
                        ]
                      : [
                          Colors.blue.shade700,
                          Colors.blue.shade600,
                          Colors.blue.shade500,
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  CustomPaint(
                    painter: _BackgroundPatternPainter(isDark: isDark),
                    size: Size.infinite,
                  ),

                  // Conteúdo principal
                  Center(
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
                          shadowColor:
                              isDark ? Colors.black38 : Colors.blue.shade100,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: isDesktop
                              ? _buildDesktopLayout(size)
                              : _buildMobileLayout(size),
                        ),
                      ),
                    ),
                  ),

                  // Botão de tema no canto superior direito
                  if (GetPlatform.isWeb)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(
                            ThemeManager().isDark.value
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: ThemeManager().isDark.value
                              ? 'Mudar para tema claro'
                              : 'Mudar para tema escuro',
                          onPressed: () {
                            ThemeManager().toggleTheme();
                          },
                        ),
                      ),
                    ),

                  // Footer com copyright no mobile
                  if (isMobile)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          '© ${DateTime.now().year} GasOMeter - Todos os direitos reservados',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(Size size) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      children: [
        // Lado esquerdo com imagem/banner
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F3460),
                          const Color(0xFF16213E),
                        ]
                      : [
                          Colors.blue.shade600,
                          Colors.blue.shade800,
                        ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'GasOMeter',
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
                      'Controle de Consumo',
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
                      color:
                          isDark ? Colors.amber.shade400 : Colors.blue.shade300,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Acompanhe o desempenho e consumo de combustível dos seus veículos de forma simples e eficiente.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ilustração ou ícone temático
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car,
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
          ),
        ),

        // Lado direito com formulário
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Container(
              padding: const EdgeInsets.all(30.0),
              child: _controller.showRecoveryForm
                  ? _buildRecoveryForm()
                  : _buildAuthForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo e título
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: isDark ? Colors.amber.shade400 : Colors.blue.shade700,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  'GasOMeter',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.amber.shade400 : Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Controle de Consumo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Container(
              width: 50,
              height: 4,
              color: accentColor(context),
            ),
            const SizedBox(height: 30),

            // Formulário
            _controller.showRecoveryForm
                ? _buildRecoveryForm()
                : _buildAuthForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs minimalistas
        _buildAuthTabs(),
        const SizedBox(height: 30),

        // Formulário com animação de fade
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
          child: (_controller.isSignUp && !GetPlatform.isWeb)
              ? Container(
                  key: const ValueKey('signup'),
                  child: _buildSignUpSteps(),
                )
              : Container(
                  key: const ValueKey('login'),
                  child: _buildLoginForm(),
                ),
        ),
      ],
    );
  }

  Widget _buildAuthTabs() {
    final isDark = ThemeManager().isDark.value;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (_controller.isSignUp) {
                _controller.toggleAuthMode();
              }
            },
            child: Column(
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: !_controller.isSignUp
                        ? (isDark ? Colors.white : Colors.grey[800])
                        : (isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  width: 60,
                  decoration: BoxDecoration(
                    color: !_controller.isSignUp
                        ? primaryColor(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Hide signup tab on web
          if (!GetPlatform.isWeb) ...[
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                if (!_controller.isSignUp) {
                  _controller.toggleAuthMode();
                }
              },
              child: Column(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _controller.isSignUp
                          ? (isDark ? Colors.white : Colors.grey[800])
                          : (isDark ? Colors.grey[400] : Colors.grey[500]),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      color: _controller.isSignUp
                          ? primaryColor(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildLoginForm() {
    final isDark = ThemeManager().isDark.value;

    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acesse sua conta para gerenciar seu consumo',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),

          // Campo de email com validação melhorada
          TextFormField(
            controller: _controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Insira seu email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: primaryColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12), // Aumento do arredondamento
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: primaryColor(context),
                    width: 2), // Borda mais forte no foco
              ),
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              filled: true, // Adicionando preenchimento
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!, // Cor suave de fundo
            ),
            keyboardType: TextInputType.emailAddress,
            focusNode: _loginEmailFocusNode,
            validator: _controller.validateEmail,
            onFieldSubmitted: (_) {
              _loginPasswordFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 20),

          // Campo de senha com design atualizado
          TextFormField(
            controller: _controller.passwordController,
            obscureText: _controller.obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Insira sua senha',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor(context),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: primaryColor(context),
                ),
                onPressed: _controller.togglePasswordVisibility,
                tooltip: _controller.obscurePassword
                    ? 'Mostrar senha'
                    : 'Ocultar senha',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor(context), width: 2),
              ),
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            focusNode: _loginPasswordFocusNode,
            validator: _controller.validatePassword,
            onFieldSubmitted: (_) {
              _signInWithEmail();
            },
          ),
          const SizedBox(height: 15),

          // Lembrar-me e Esqueceu sua senha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _controller.rememberMe,
                      activeColor: primaryColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) => _controller.toggleRememberMe(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lembrar-me',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _controller.showRecoveryFormAction,
                child: Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color: primaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 30),

          // Botão de login
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _controller.isLoading ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor(context),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _controller.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white70 : Colors.white,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 30),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ou continue com',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),

          // Opções de login social (desabilitadas)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                color: Colors.red.shade600,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                color: isDark ? Colors.white : Colors.black,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.window,
                label: 'Microsoft',
                color: Colors.blue.shade600,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '* Opções de login social estarão disponíveis em breve',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpSteps() {
    return Column(
      children: [
        // Indicador de progresso
        _buildProgressIndicator(),
        const SizedBox(height: 20),

        // Container com altura fixa para o PageView
        SizedBox(
          height: 400,
          child: PageView(
            controller: _signUpPageController,
            physics: const NeverScrollableScrollPhysics(), // Desabilita swipe
            onPageChanged: (index) {
              setState(() {
                _currentSignUpStep = index;
              });
            },
            children: [
              _buildWelcomeStep(),
              _buildPersonalInfoStep(),
              _buildPasswordStep(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = ThemeManager().isDark.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= _currentSignUpStep;
        return Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? primaryColor(context)
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (index < 2) ...[
              Container(
                width: 40,
                height: 2,
                color: index < _currentSignUpStep
                    ? primaryColor(context)
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildWelcomeStep() {
    final isDark = ThemeManager().isDark.value;

    return Form(
      key: _stepFormKeys[0],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_gas_station,
            size: 80,
            color: primaryColor(context),
          ),
          const SizedBox(height: 20),
          Text(
            'Bem-vindo ao GasOMeter!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Vamos criar sua conta em alguns passos simples',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _signUpWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Começar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    final isDark = ThemeManager().isDark.value;

    return Form(
      key: _stepFormKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seus dados pessoais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 30),

          // Campo de nome
          TextFormField(
            controller: _controller.nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              hintText: 'Insira seu nome completo',
              prefixIcon: Icon(
                Icons.person_outline,
                color: primaryColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor(context), width: 2),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            validator: _controller.validateName,
            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
          ),
          const SizedBox(height: 20),

          // Campo de email
          TextFormField(
            controller: _controller.emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Insira seu email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: primaryColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor(context), width: 2),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _controller.validateEmail,
          ),

          const Spacer(),

          // Botões de navegação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousSignUpStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Voltar',
                    style: TextStyle(color: primaryColor(context)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    final isDark = ThemeManager().isDark.value;

    return Form(
      key: _stepFormKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defina sua senha',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 30),

          // Campo de senha
          TextFormField(
            controller: _controller.passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _controller.obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor(context),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: primaryColor(context),
                ),
                onPressed: _controller.togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor(context), width: 2),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            validator: _controller.validatePassword,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 20),

          // Campo de confirmação de senha
          TextFormField(
            controller: _controller.confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: _controller.obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              hintText: 'Digite novamente sua senha',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor(context),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: primaryColor(context),
                ),
                onPressed: _controller.toggleConfirmPasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor(context), width: 2),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            validator: _controller.validateConfirmPassword,
          ),

          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],

          const Spacer(),

          // Botões de navegação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousSignUpStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Voltar',
                    style: TextStyle(color: primaryColor(context)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _controller.isLoading ? null : _signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
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
                      : const Text('Criar Conta'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Texto de termos
          Center(
            child: Text(
              'Ao criar uma conta, você concorda com nossos\nTermos de Serviço e Política de Privacidade',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryForm() {
    final isDark = ThemeManager().isDark.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Recuperar Senha',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviaremos um link para redefinir sua senha',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),

        // Campo de email com design atualizado
        TextFormField(
          controller: _controller.emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Insira seu email de cadastro',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: primaryColor(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor(context), width: 2),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey[900]!.withValues(alpha: 0.5)
                : Colors.grey[50]!,
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        if (_controller.errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(),
        ],
        const SizedBox(height: 30),

        // Botão de enviar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _controller.isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
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
                    'Enviar Link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Voltar para o login
        Center(
          child: TextButton.icon(
            onPressed: _controller.hideRecoveryFormAction,
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Voltar para o login'),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor(context),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorMessage() {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _controller.errorMessage!,
              style: TextStyle(
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Tooltip(
      message: 'Login com $label (Em breve)',
      child: OutlinedButton.icon(
        onPressed: null, // Desabilitado conforme solicitado
        icon: Icon(
          icon,
          size: 20,
          color: color.withValues(alpha: 0.5),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade500
                : Colors.grey.shade600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

// Pintor personalizado para criar o padrão de fundo com design melhorado
class _BackgroundPatternPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Cores baseadas no tema
    final Color primaryColor = isDark
        ? Colors.amber.withValues(alpha: 0.03)
        : Colors.blue.shade700.withValues(alpha: 0.03);

    final Color secondaryColor = isDark
        ? Colors.amber.shade200.withValues(alpha: 0.02)
        : Colors.blue.shade200.withValues(alpha: 0.03);

    // Desenhar linhas diagonais finas como no exemplo do Calculei
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2;

    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), linePaint);
      canvas.drawLine(
          Offset(size.width - i, 0), Offset(size.width, i), linePaint);
    }

    // Desenhar pequenos círculos no fundo para dar textura
    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width; i += 50) {
      for (int j = 0; j < size.height; j += 50) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 2.5, dotPaint);
      }
    }

    // Adicionar alguns círculos maiores espaçados aleatoriamente
    final accentPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.blue.shade700.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 10; i++) {
      final x = ((random + i * 7919) % size.width.toInt()).toDouble();
      final y = ((random + i * 6029) % size.height.toInt()).toDouble();
      final radius = 20.0 + (random + i * 104729) % 60;

      canvas.drawCircle(Offset(x, y), radius, accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
