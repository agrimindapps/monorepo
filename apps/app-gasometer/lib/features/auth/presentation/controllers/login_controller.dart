import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/analytics_service.dart';
import '../providers/auth_provider.dart';

/// Controller para a página de login seguindo princípios SOLID
/// Responsabilidade única: Gerenciar estado e lógica da tela de login
class LoginController extends ChangeNotifier {
  final AuthProvider _authProvider;
  final AnalyticsService _analytics;

  // Controllers dos campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Estado da página
  bool _isSignUpMode = false;
  bool _showRecoveryForm = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _mounted = true; // Controle de lifecycle
  
  // Step control para signup
  int _currentSignUpStep = 0;
  static const int _maxSignUpSteps = 3;

  LoginController({
    required AuthProvider authProvider,
    AnalyticsService? analytics,
  })  : _authProvider = authProvider,
        _analytics = analytics ?? AnalyticsService() {
    _loadSavedData();
    _analytics.logScreenView('LoginPage');
  }

  // Getters
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;

  bool get isSignUpMode => _isSignUpMode;
  bool get isShowingRecoveryForm => _showRecoveryForm;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentSignUpStep => _currentSignUpStep;
  bool get canGoToNextStep => _currentSignUpStep < _maxSignUpSteps - 1;
  bool get canGoToPreviousStep => _currentSignUpStep > 0;

  // Estado do auth provider
  bool get mounted => _mounted;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  bool get isAuthLoading => _authProvider.isLoading;
  String? get authError => _authProvider.errorMessage;
  
  // Estado da sincronização simplificado
  bool get isSyncing => _authProvider.isSyncing;

  @override
  void dispose() {
    _mounted = false; // Marcar como disposed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ===== ACTIONS =====

  /// Toggle entre modo login e signup
  void toggleAuthMode() {
    _isSignUpMode = !_isSignUpMode;
    _clearError();
    _analytics.logUserAction('auth_mode_toggle', parameters: {
      'mode': _isSignUpMode ? 'signup' : 'login',
    });
    notifyListeners();
  }

  /// Mostrar formulário de recuperação de senha
  void showRecoveryForm() {
    _showRecoveryForm = true;
    _clearError();
    _analytics.logUserAction('recovery_form_show');
    notifyListeners();
  }

  /// Esconder formulário de recuperação de senha
  void hideRecoveryForm() {
    _showRecoveryForm = false;
    _clearError();
    _analytics.logUserAction('recovery_form_hide');
    notifyListeners();
  }

  /// Toggle visibilidade da senha
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Toggle visibilidade da confirmação de senha
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  /// Toggle lembrar-me
  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    _analytics.logUserAction('remember_me_toggle', parameters: {
      'enabled': _rememberMe.toString(),
    });
    notifyListeners();
  }

  /// Limpar mensagem de erro
  void _clearError() {
    _errorMessage = null;
    _authProvider.clearError();
  }

  /// Limpar mensagem de erro (método público)
  void clearError() {
    // Só notificar se realmente há uma mensagem de erro para limpar
    if (_errorMessage != null) {
      _clearError();
      _safeNotifyListeners();
    }
  }

  /// Ir para próximo step do signup
  void nextSignUpStep() {
    if (canGoToNextStep) {
      _currentSignUpStep++;
      _analytics.logUserAction('signup_step_next', parameters: {
        'step': _currentSignUpStep.toString(),
      });
      _safeNotifyListeners();
    }
  }

  /// Voltar step do signup
  void previousSignUpStep() {
    if (canGoToPreviousStep) {
      _currentSignUpStep--;
      _analytics.logUserAction('signup_step_previous', parameters: {
        'step': _currentSignUpStep.toString(),
      });
      _safeNotifyListeners();
    }
  }

  /// Resetar steps do signup
  void resetSignUpSteps() {
    _currentSignUpStep = 0;
    _safeNotifyListeners();
  }

  // ===== AUTH ACTIONS =====

  /// Login com email e senha (método original mantido para compatibilidade)
  Future<void> signInWithEmail() async {
    if (!_validateLoginForm()) return;

    _setLoading(true);
    _clearError();

    try {
      await _authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (_authProvider.isAuthenticated) {
        await _saveFormData();
        _analytics.logUserAction('login_success', parameters: {
          'method': 'email',
          'remember_me': _rememberMe.toString(),
        });
      } else if (_authProvider.errorMessage != null) {
        _errorMessage = _authProvider.errorMessage;
        _analytics.logUserAction('login_failed', parameters: {
          'error': _authProvider.errorMessage ?? 'unknown',
        });
      }
    } catch (e) {
      _errorMessage = 'Erro inesperado durante o login';
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'Login error',
        customKeys: {'action': 'signInWithEmail'},
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Login com email e senha com sincronização automática simplificado - padrão app-plantis
  Future<void> signInWithEmailAndSync() async {
    if (kDebugMode) {
      print('🔄 LoginController: Iniciando login com sincronização simplificada');
    }
    
    if (!_validateLoginForm()) return;

    _setLoading(true);
    _clearError();

    try {
      await _authProvider.loginAndSync(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (_authProvider.isAuthenticated) {
        await _saveFormData();
        await _analytics.logUserAction('login_with_sync_success', parameters: {
          'method': 'email_with_sync_simplified',
          'remember_me': _rememberMe.toString(),
        });
      } else if (_authProvider.errorMessage != null) {
        _errorMessage = _authProvider.errorMessage;
        await _analytics.logUserAction('login_with_sync_failed', parameters: {
          'error': _authProvider.errorMessage ?? 'unknown',
        });
      }
    } catch (e) {
      _errorMessage = 'Erro inesperado durante o login com sincronização';
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'Login with sync error',
        customKeys: {'action': 'signInWithEmailAndSync'},
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Cadastro com email e senha
  Future<void> signUpWithEmail() async {
    if (!_validateSignUpForm()) return;

    _setLoading(true);
    _clearError();

    try {
      await _authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (_authProvider.isAuthenticated) {
        await _saveFormData();
        _analytics.logUserAction('signup_success', parameters: {
          'method': 'email',
        });
      } else if (_authProvider.errorMessage != null) {
        _errorMessage = _authProvider.errorMessage;
        _analytics.logUserAction('signup_failed', parameters: {
          'error': _authProvider.errorMessage ?? 'unknown',
        });
      }
    } catch (e) {
      _errorMessage = 'Erro inesperado durante o cadastro';
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'Signup error',
        customKeys: {'action': 'signUpWithEmail'},
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Recuperar senha
  Future<void> resetPassword() async {
    if (!_validateRecoveryForm()) return;

    _setLoading(true);
    _clearError();

    try {
      // Implementar reset password através do AuthProvider
      await _authProvider.sendPasswordReset(_emailController.text.trim());
      
      if (_authProvider.errorMessage != null) {
        _errorMessage = _authProvider.errorMessage;
      } else {
        await _analytics.logUserAction('password_reset_requested', parameters: {
          'email': _emailController.text.trim(),
        });
        
        // Mostrar mensagem de sucesso
        _errorMessage = null;
        hideRecoveryForm();
      }
      
    } catch (e) {
      _errorMessage = 'Erro ao enviar email de recuperação';
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'Password reset error',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Login anônimo
  Future<void> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      await _authProvider.signInAnonymously();
      
      if (_authProvider.isAuthenticated) {
        await _analytics.logUserAction('anonymous_login_success');
      }
    } catch (e) {
      _errorMessage = 'Erro durante login anônimo';
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'Anonymous login error',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ===== VALIDATION =====

  /// Validar formulário de login
  bool _validateLoginForm() {
    if (_emailController.text.trim().isEmpty) {
      _errorMessage = 'Email é obrigatório';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _errorMessage = 'Email inválido';
      notifyListeners();
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _errorMessage = 'Senha é obrigatória';
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Validar formulário de signup
  bool _validateSignUpForm() {
    if (_nameController.text.trim().isEmpty) {
      _errorMessage = 'Nome é obrigatório';
      notifyListeners();
      return false;
    }

    if (_nameController.text.trim().length < 2) {
      _errorMessage = 'Nome deve ter pelo menos 2 caracteres';
      notifyListeners();
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _errorMessage = 'Email é obrigatório';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _errorMessage = 'Email inválido';
      notifyListeners();
      return false;
    }

    if (_passwordController.text.length < 6) {
      _errorMessage = 'Senha deve ter pelo menos 6 caracteres';
      notifyListeners();
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _errorMessage = 'Senhas não coincidem';
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Validar formulário de recuperação
  bool _validateRecoveryForm() {
    if (_emailController.text.trim().isEmpty) {
      _errorMessage = 'Email é obrigatório';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _errorMessage = 'Email inválido';
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Validar email
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // ===== FORM VALIDATORS PARA TEXTFIELDS =====

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_isValidEmail(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  // ===== PRIVATE METHODS =====

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  /// Chama notifyListeners() apenas se o controller não foi disposed
  void _safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  /// Carregar dados salvos
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedName = prefs.getString('gasometer_saved_name');
      final savedEmail = prefs.getString('gasometer_saved_email');
      final savedRememberMe = prefs.getBool('gasometer_remember_me') ?? false;

      if (savedName != null && savedName.isNotEmpty) {
        _nameController.text = savedName;
      }
      
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
      
      _rememberMe = savedRememberMe;
      
      if (_rememberMe && savedEmail != null && savedEmail.isNotEmpty) {
        await _analytics.logUserAction('saved_data_loaded', parameters: {
          'has_name': (savedName != null).toString(),
          'has_email': savedEmail.isNotEmpty.toString(),
        });
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar dados salvos: $e');
      }
    }
  }

  /// Salvar dados do formulário
  Future<void> _saveFormData() async {
    if (!_rememberMe) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_nameController.text.trim().isNotEmpty) {
        await prefs.setString('gasometer_saved_name', _nameController.text.trim());
      }
      
      if (_emailController.text.trim().isNotEmpty) {
        await prefs.setString('gasometer_saved_email', _emailController.text.trim());
      }
      
      await prefs.setBool('gasometer_remember_me', _rememberMe);
      
      await _analytics.logUserAction('form_data_saved');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar dados: $e');
      }
    }
  }
  
  /// Para sincronização em andamento
  void stopSync() {
    _authProvider.stopSync();
    _analytics.logUserAction('sync_stopped_by_user');
  }
}