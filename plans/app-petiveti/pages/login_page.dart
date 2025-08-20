// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';

class LoginPage extends StatefulWidget {
  final bool? showBackButton;

  const LoginPage({super.key, this.showBackButton});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  // Animação para entrada dos elementos
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final _loginFormKey = GlobalKey<FormState>();

  // Controle do PageView para steps de cadastro
  final PageController _signUpPageController = PageController();
  int _currentSignUpStep = 0;
  bool _isCheckingEmail = false; // Loading da validação de email
  final List<GlobalKey<FormState>> _stepFormKeys = [
    GlobalKey<FormState>(), // Boas-vindas
    GlobalKey<FormState>(), // Nome + Email
    GlobalKey<FormState>(), // Senha
  ];

  // Controllers dos campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // FocusNodes para controle de foco
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _loginEmailFocusNode = FocusNode();
  final FocusNode _loginPasswordFocusNode = FocusNode();

  // Estados
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _showRecoveryForm = false;
  String? _errorMessage;

  // Cores do tema específicas para o PetivetiApp usando design tokens
  Color primaryColor(BuildContext context) => primaryColorLegacy;
  Color accentColor(BuildContext context) => accentColorLegacy;

  // Métodos legacy para compatibilidade (DEPRECATED)
  /// @deprecated Use primaryColor(context) em vez disso
  Color get primaryColorLegacy => ThemeManager().isDark.value
      ? Colors.blue.shade600
      : Colors.blue.shade700;

  /// @deprecated Use accentColor(context) em vez disso
  Color get accentColorLegacy => ThemeManager().isDark.value
      ? Colors.blue.shade400
      : Colors.blue.shade400;

  @override
  void initState() {
    super.initState();

    // Ensure web users start in login mode (not signup)
    if (GetPlatform.isWeb && _isSignUp) {
      _isSignUp = false;
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
    _animationController.dispose();
    _signUpPageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      final savedName = prefs.getString('petiveti_signup_name');
      final savedEmail = prefs.getString('petiveti_signup_email');

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
      await prefs.setString('petiveti_signup_name', _nameController.text);
      await prefs.setString('petiveti_signup_email', _emailController.text);
    } catch (e) {
      // Ignorar erros de salvamento
    }
  }

  // Limpar dados salvos após cadastro bem-sucedido
  Future<void> _clearSavedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('petiveti_signup_name');
      await prefs.remove('petiveti_signup_email');
    } catch (e) {
      // Ignorar erros
    }
  }

  // Configurar validação em tempo real
  void _setupRealTimeValidation() {
    // Validação em tempo real para email
    _emailController.addListener(() {
      if (_emailController.text.isNotEmpty) {
        // Salvar dados automaticamente quando digitando
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
      // Força refresh do estado para mostrar indicador de força da senha
      if (mounted) setState(() {});
    });
  }

  // Haptic feedback
  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  // Toggle auth mode
  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _currentSignUpStep = 0;
    });
    _signUpPageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _toggleRememberMe() {
    setState(() {
      _rememberMe = !_rememberMe;
    });
  }

  void _showRecoveryFormAction() {
    setState(() {
      _showRecoveryForm = true;
      _errorMessage = null;
    });
  }

  void _hideRecoveryFormAction() {
    setState(() {
      _showRecoveryForm = false;
      _errorMessage = null;
    });
  }

  // Validação
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Senha deve conter maiúscula, minúscula e número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  Future<void> _signInWithEmail() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }
    _triggerHapticFeedback();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    _triggerHapticFeedback();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Atualizar nome do usuário
      await credential.user?.updateDisplayName(_nameController.text.trim());
      
      await _clearSavedFormData();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Digite seu email para recuperar a senha';
      });
      return;
    }

    _triggerHapticFeedback();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email de recuperação enviado com sucesso!'),
            backgroundColor: primaryColor(context),
          ),
        );
        _hideRecoveryFormAction();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Conta desabilitada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde';
      default:
        return 'Erro de autenticação';
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
      final emailExists = await _checkEmailExists(email);

      if (emailExists) {
        // Email já existe - mostrar erro
        _showEmailExistsDialog();
      } else {
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
      }
    } catch (e) {
      // Erro na verificação - continuar mesmo assim para não bloquear o usuário
      setState(() {
        _currentSignUpStep++;
      });
      _signUpPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      // Desativar loading da validação de email
      setState(() {
        _isCheckingEmail = false;
      });
    }
  }

  void _showEmailExistsDialog() {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Email já cadastrado',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Este email já possui uma conta.\n\nVocê gostaria de fazer login ou usar outro email?',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Usar outro email'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _toggleAuthMode(); // Trocar para login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Fazer Login'),
            ),
          ],
        );
      },
    );
  }

  void _showSocialLoginDialog(String provider) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: primaryColor(context),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Login com $provider',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Esta funcionalidade estará disponível em breve!\n\nPor enquanto, você pode criar sua conta usando email e senha.',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Entendi',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widgets auxiliares para os steps
  Widget _buildStepIndicator() {
    final isDark = ThemeManager().isDark.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentSignUpStep;
        final isCompleted = index < _currentSignUpStep;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 40 : 20,
                height: 6,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? primaryColor(context)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (index < 2) // Não mostrar após o último
                Container(
                  width: 30,
                  height: 2,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
            ],
          ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: primaryColor(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Criar Nova Conta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Opções de login social no primeiro step
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
                icon: Icons.business,
                label: 'Microsoft',
                color: Colors.blue.shade600,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divisor "ou"
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameEmailStep() {
    final isDark = ThemeManager().isDark.value;

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
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            validator: _validateName,
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
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            validator: _validateEmail,
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Mínimo 8 caracteres, letras, números e símbolos',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor(context),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: primaryColor(context),
                ),
                onPressed: _togglePasswordVisibility,
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
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: _obscureConfirmPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              hintText: 'Digite novamente sua senha',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor(context),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: primaryColor(context),
                ),
                onPressed: _toggleConfirmPasswordVisibility,
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
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
          // Indicador de força da senha
          if (_passwordController.text.isNotEmpty)
            _buildPasswordStrengthIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepNavigation() {
    final isDark = ThemeManager().isDark.value;

    return Row(
      children: [
        // Botão Voltar
        if (_currentSignUpStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Voltar',
                style: TextStyle(
                  color: primaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        if (_currentSignUpStep > 0) const SizedBox(width: 16),

        // Botão Próximo/Criar Conta
        Expanded(
          flex: _currentSignUpStep == 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed:
                (_isLoading || _isCheckingEmail) ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor(context),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: (_isLoading || _isCheckingEmail)
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
                : Text(
                    _currentSignUpStep == 0
                        ? 'Começar'
                        : (_currentSignUpStep == 2 ? 'Criar Conta' : 'Próximo'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final isDark = ThemeManager().isDark.value;

    int strength = 0;
    String message = '';
    Color color = Colors.red;

    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    switch (strength) {
      case 0:
      case 1:
        message = 'Senha muito fraca';
        color = Colors.red;
        break;
      case 2:
        message = 'Senha fraca';
        color = Colors.orange;
        break;
      case 3:
        message = 'Senha média';
        color = Colors.yellow.shade700;
        break;
      case 4:
        message = 'Senha forte';
        color = Colors.lightGreen;
        break;
      case 5:
        message = 'Senha muito forte';
        color = Colors.green;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 5,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      const Color(0xFF1A2E1A),
                      const Color(0xFF213E21),
                      const Color(0xFF2E5A2E),
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
              SafeArea(
                child: Center(
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
              ),

              // Botão discreto de voltar (apenas quando vem das configurações)
              if (widget.showBackButton == true)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'Voltar',
                        onPressed: () {
                          _triggerHapticFeedback();
                          Navigator.of(context).pop();
                        },
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
                      '© ${DateTime.now().year} PetivetiApp - Todos os direitos reservados',
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF2E5A2E),
                          const Color(0xFF213E21),
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
                          Icons.pets,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'PetivetiApp',
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
                      'Cuidado de Pets',
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
                      color: isDark
                          ? Colors.blue.shade400
                          : Colors.blue.shade300,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Cuide dos seus pets com lembretes personalizados, dicas especializadas e acompanhe seu desenvolvimento de forma simples e eficiente.',
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
                            Icons.pets,
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
              child: _showRecoveryForm
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
                  Icons.pets,
                  color: isDark ? Colors.blue.shade400 : Colors.blue.shade700,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  'PetivetiApp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.blue.shade400 : Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Cuidado de Pets',
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
            _showRecoveryForm
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
          child: (_isSignUp && !GetPlatform.isWeb)
              ? Container(
                  key: const ValueKey('signup'),
                  child: _buildSignUpForm(),
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
              if (_isSignUp) {
                _toggleAuthMode();
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
                    color: !_isSignUp
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
                    color: !_isSignUp
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
                if (!_isSignUp) {
                  _toggleAuthMode();
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
                      color: _isSignUp
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
                      color: _isSignUp
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
                color: primaryColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: primaryColor(context),
                    width: 2),
              ),
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!,
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),

          // Campo de senha com design atualizado
          TextFormField(
            controller: _passwordController,
            focusNode: _loginPasswordFocusNode,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Insira sua senha',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor(context),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: primaryColor(context),
                ),
                onPressed: _togglePasswordVisibility,
                tooltip: _obscurePassword
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha é obrigatória';
              }
              return null;
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
                      value: _rememberMe,
                      activeColor: primaryColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        _toggleRememberMe();
                      },
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
                onTap: _showRecoveryFormAction,
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

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 30),

          // Botão de login
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
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
              child: _isLoading
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
                icon: Icons.business,
                label: 'Microsoft',
                color: Colors.blue.shade600,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    final isDark = ThemeManager().isDark.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicadores de step
        _buildStepIndicator(),
        const SizedBox(height: 20),

        // PageView com steps
        SizedBox(
          height: 230,
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

        const SizedBox(height: 20),

        // Botões de navegação
        _buildStepNavigation(),

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(),
        ],

        const SizedBox(height: 30),

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
          controller: _emailController,
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

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(),
        ],
        const SizedBox(height: 30),

        // Botão de enviar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: _isLoading
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
            onPressed: _hideRecoveryFormAction,
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
              _errorMessage ?? '',
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
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        if (isSmallScreen) {
          // Mostrar apenas o ícone em telas pequenas
          return OutlinedButton(
            onPressed: () => _showSocialLoginDialog(label),
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
              minimumSize: const Size(48, 48),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          );
        } else {
          // Mostrar ícone e texto em telas maiores
          return OutlinedButton.icon(
            onPressed: () => _showSocialLoginDialog(label),
            icon: Icon(
              icon,
              size: 20,
              color: color,
            ),
            label: Text(
              label,
              style: TextStyle(
                color: ThemeManager().isDark.value
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
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
          );
        }
      },
    );
  }
}

// Pintor personalizado para criar o padrão de fundo com design melhorado
class _BackgroundPatternPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Cores baseadas no tema azul
    final Color primaryColor = isDark
        ? Colors.blue.withValues(alpha: 0.03)
        : Colors.blue.shade700.withValues(alpha: 0.03);

    final Color secondaryColor = isDark
        ? Colors.blue.shade200.withValues(alpha: 0.02)
        : Colors.blue.shade200.withValues(alpha: 0.03);

    // Desenhar linhas diagonais finas
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
