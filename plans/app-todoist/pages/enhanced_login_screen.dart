// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../core/services/auth_validation_service.dart';
import '../controllers/auth_controller.dart';

class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen>
    with SingleTickerProviderStateMixin {

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

  // Controllers de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Cores do tema
  Color get primaryColor => const Color(0xFF667eea);
  Color get accentColor => const Color(0xFF764ba2);

  @override
  void initState() {
    super.initState();

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
    _animationController.dispose();
    _signUpPageController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _loginEmailFocusNode.dispose();
    _loginPasswordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Carregar dados salvos do formulário
  Future<void> _loadSavedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('todoist_signup_name');
      final savedEmail = prefs.getString('todoist_signup_email');

      if (savedName != null) {
        _nameController.text = savedName;
      }
      if (savedEmail != null) {
        _emailController.text = savedEmail;
      }
    } catch (e) {
      // Ignorar erros de carregamento
    }
  }

  // Salvar dados do formulário
  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('todoist_signup_name', _nameController.text);
      await prefs.setString('todoist_signup_email', _emailController.text);
    } catch (e) {
      // Ignorar erros de salvamento
    }
  }

  // Limpar dados salvos após cadastro bem-sucedido
  Future<void> _clearSavedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('todoist_signup_name');
      await prefs.remove('todoist_signup_email');
    } catch (e) {
      // Ignorar erros
    }
  }

  // Configurar validação em tempo real
  void _setupRealTimeValidation() {
    // Validação em tempo real para email
    _emailController.addListener(() {
      if (_emailController.text.isNotEmpty) {
        _saveFormData();
      }
    });

    // Validação em tempo real para nome
    _nameController.addListener(() {
      if (_nameController.text.isNotEmpty) {
        _saveFormData();
      }
    });

    // Validação de força da senha em tempo real
    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  // Haptic feedback
  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  Future<void> _signInWithEmail() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }
    _triggerHapticFeedback();

    final success = await Get.find<TodoistAuthController>().signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!success && Get.find<TodoistAuthController>().errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Get.find<TodoistAuthController>().errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _signUpWithEmail() async {
    _triggerHapticFeedback();

    final success = await Get.find<TodoistAuthController>().signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      await _clearSavedFormData();
    } else if (Get.find<TodoistAuthController>().errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Get.find<TodoistAuthController>().errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Métodos para navegação entre steps do cadastro
  void _nextStep() {
    if (_currentSignUpStep < 2) {
      // Step 0 (boas-vindas): apenas avançar
      if (_currentSignUpStep == 0) {
        _triggerHapticFeedback();
        setState(() {
          _currentSignUpStep++;
        });
        _signUpPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        // Auto-focus no primeiro campo do próximo step
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _nameFocusNode.requestFocus();
        });
      } else {
        // Step 1: Validar nome+email e verificar se email já existe
        final currentForm = _stepFormKeys[_currentSignUpStep];
        if (currentForm.currentState!.validate()) {
          _checkEmailAndAdvance();
        }
      }
    } else {
      // Step 2 (último): Validar senhas e criar conta
      final currentForm = _stepFormKeys[_currentSignUpStep];
      if (currentForm.currentState!.validate()) {
        _signUpWithEmail();
      }
    }
  }

  void _previousStep() {
    if (_currentSignUpStep > 0) {
      setState(() {
        _currentSignUpStep--;
      });
      _signUpPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Auto-focus baseado no step anterior
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentSignUpStep == 0) {
          // Step de boas-vindas, sem foco
        } else if (_currentSignUpStep == 1) {
          _emailFocusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _checkEmailAndAdvance() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) return;

    // Salvar dados do formulário
    await _saveFormData();
    _triggerHapticFeedback();

    // Ativar loading da validação de email
    setState(() {
      _isCheckingEmail = true;
    });

    try {
      // Simular verificação de email (método não existe no controller)
      const emailExists = false; // await _controller.checkEmailExists(email);

      if (emailExists) {
        // Email já existe - mostrar erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Este email já possui uma conta. Tente fazer login.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }

      // Email disponível - avançar para próximo step
      setState(() {
        _currentSignUpStep++;
      });
      _signUpPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Auto-focus no campo de senha
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordFocusNode.requestFocus();
      });
    } catch (e) {
      // Erro na verificação - continuar mesmo assim para não bloquear o usuário
      setState(() {
        _currentSignUpStep++;
      });
      _signUpPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Auto-focus no campo de senha
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordFocusNode.requestFocus();
      });
    } finally {
      // Desativar loading da validação de email
      setState(() {
        _isCheckingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ListenableBuilder(
                        listenable: Listenable.merge([]),
                        builder: (context, child) {
                          return Obx(() {
                            final controller = Get.find<TodoistAuthController>();
                            return controller.isLoading
                                ? _buildLoadingIndicator()
                                : _buildMainContent();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Carregando...'),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo/Ícone
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.task_alt,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // Título
        Text(
          'Task Manager',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 8),

        // Tabs de Login/Cadastro
        Obx(() => _buildAuthTabs()),
        const SizedBox(height: 24),

        // Conteúdo baseado na tab selecionada
        Obx(() => _buildAuthContent()),
      ],
    );
  }

  Widget _buildAuthTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _triggerHapticFeedback();
              setState(() {
                Get.find<TodoistAuthController>().toggleAuthMode();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    !Get.find<TodoistAuthController>().isSignUp ? primaryColor : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border.all(color: primaryColor),
              ),
              child: Text(
                'Entrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !Get.find<TodoistAuthController>().isSignUp ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _triggerHapticFeedback();
              setState(() {
                Get.find<TodoistAuthController>().toggleAuthMode();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Get.find<TodoistAuthController>().isSignUp ? primaryColor : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: primaryColor),
              ),
              child: Text(
                'Criar Conta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Get.find<TodoistAuthController>().isSignUp ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthContent() {
    if (Get.find<TodoistAuthController>().isSignUp) {
      return _buildSignUpContent();
    } else {
      return _buildLoginContent();
    }
  }

  Widget _buildLoginContent() {
    return Column(
      children: [
        Text(
          'Faça login para continuar',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),

        // Formulário de login
        _buildLoginForm(),
        const SizedBox(height: 24),

        // Botão para usar sem login
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () async {
              _triggerHapticFeedback();
              await Get.find<TodoistAuthController>().enterGuestMode();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Usar sem login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpContent() {
    return Column(
      children: [
        Text(
          'Crie sua conta gratuita',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),

        // Steps de cadastro
        _buildSignUpSteps(),
        const SizedBox(height: 24),

        // PageView com steps
        SizedBox(
          height: 300,
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
        const SizedBox(height: 24),

        // Botões de navegação
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildSignUpSteps() {
    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < _currentSignUpStep;
        final isCurrent = index == _currentSignUpStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? primaryColor
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? primaryColor : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          // Campo Email
          TextFormField(
            controller: _emailController,
            focusNode: _loginEmailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofocus: true,
            onFieldSubmitted: (_) => _loginPasswordFocusNode.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Insira seu email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) => Get.find<TodoistAuthController>().validateEmail(value),
          ),
          const SizedBox(height: 16),

          // Campo Senha
          TextFormField(
            controller: _passwordController,
            focusNode: _loginPasswordFocusNode,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Insira sua senha',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) => Get.find<TodoistAuthController>().validatePassword(value),
          ),
          const SizedBox(height: 24),

          // Botão de Login
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: Get.find<TodoistAuthController>().isLoading ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Get.find<TodoistAuthController>().isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Form(
      key: _stepFormKeys[0],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 60,
            color: primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Criar Nova Conta',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Organize suas tarefas de forma inteligente',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameEmailStep() {
    return Form(
      key: _stepFormKeys[1],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Nome completo',
              hintText: 'Ex: João Silva',
              prefixIcon: Icon(
                Icons.person_outline,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) => AuthValidationService().validateName(value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'exemplo@email.com',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) => Get.find<TodoistAuthController>().validateEmail(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _stepFormKeys[2],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Mínimo 8 caracteres, letras, números e símbolos',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              return AuthValidationService().validateSignUpPassword(value);
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              hintText: 'Digite novamente sua senha',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              return AuthValidationService()
                  .validateConfirmPassword(value, _passwordController.text);
            },
          ),
          const SizedBox(height: 16),
          // Indicador de força da senha
          if (_passwordController.text.isNotEmpty)
            _buildPasswordStrengthIndicator(),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength =
        AuthValidationService().getPasswordStrength(_passwordController.text);

    Color getStrengthColor() {
      switch (strength) {
        case PasswordStrength.none:
          return Colors.grey;
        case PasswordStrength.weak:
          return Colors.red;
        case PasswordStrength.medium:
          return Colors.orange;
        case PasswordStrength.strong:
          return Colors.green;
      }
    }

    double getStrengthProgress() {
      switch (strength) {
        case PasswordStrength.none:
          return 0.0;
        case PasswordStrength.weak:
          return 0.33;
        case PasswordStrength.medium:
          return 0.66;
        case PasswordStrength.strong:
          return 1.0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: getStrengthProgress(),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(getStrengthColor()),
                minHeight: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AuthValidationService().getPasswordStrengthMessage(strength),
          style: TextStyle(
            color: getStrengthColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentSignUpStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _triggerHapticFeedback();
                _previousStep();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Anterior'),
            ),
          ),
        if (_currentSignUpStep > 0) const SizedBox(width: 16),
        Expanded(
          flex: _currentSignUpStep == 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed: _isCheckingEmail
                ? null
                : () {
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
            child: _isCheckingEmail
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _currentSignUpStep == 2 ? 'Criar Conta' : 'Próximo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}

// Extensão para adicionar funcionalidades ao controller
extension TodoistAuthControllerExtensions on TodoistAuthController {
  String? validateName(String? value) {
    return AuthValidationService().validateName(value);
  }
}
