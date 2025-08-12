// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../core/models/auth_models.dart';
import '../../core/services/auth_validation_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../utils/composite_subscription.dart';

// import '../../core/services/auth_navigation_service.dart';

/// Controller padronizado para autenticação do módulo Todoist
/// Migrado para GetX para consistência de estado
class TodoistAuthController extends GetxController
    with SubscriptionManagerMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthValidationService _validationService = AuthValidationService();
  // final AuthNavigationService _navigationService = AuthNavigationService();

  // static const ModuleAuthConfig _moduleConfig = ModuleAuthConfig.todoist;

  // Estado reativo do controller
  final Rxn<AuthUser> _currentUser = Rxn<AuthUser>();
  final RxBool _isLoading = RxBool(false);
  final RxnString _errorMessage = RxnString();
  final RxBool _isGuestMode = RxBool(false);
  final RxBool _hasChosenGuestMode = RxBool(false);
  final RxBool _isSignUp = RxBool(false);
  SharedPreferences? _prefs;

  // Getters reativos
  AuthUser? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isGuestMode => _isGuestMode.value;
  bool get hasChosenGuestMode => _hasChosenGuestMode.value;
  bool get isSignUp => _isSignUp.value;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  // Inicialização
  void _init() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    _setLoading(true);

    await _loadPreferences();

    // Verificar se o usuário estava em modo guest
    if (_hasChosenGuestMode.value && _currentUser.value == null) {
      // Guest mode recovery logic
      debugPrint('🔄 Recuperando sessão guest...');
    }

    // Listener de mudanças de auth
    addSubscription(
      _authService.authStateChanges.listen((user) {
        _currentUser.value = user;
        if (user == null) {
          debugPrint('👤 Usuário deslogado');
        } else {
          _currentUser.value = user;
          debugPrint('👤 Usuário logado: ${user.displayName ?? user.email}');
        }
      }),
    );

    // Verificar se estava em modo guest
    if (_hasChosenGuestMode.value && _currentUser.value == null) {
      _enterGuestMode(skipSave: true);
    }

    _setLoading(false);
  }

  Future<void> _loadPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _hasChosenGuestMode.value = _prefs?.getBool('has_chosen_guest_mode') ?? false;

      if (_hasChosenGuestMode.value) {
        _isGuestMode.value = true;
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar preferências: $e');
    }
  }

  Future<void> _saveGuestModePreference(bool hasChosen) async {
    try {
      await _prefs?.setBool('has_chosen_guest_mode', hasChosen);
      _hasChosenGuestMode.value = hasChosen;
    } catch (e) {
      debugPrint('❌ Erro ao salvar preferência guest mode: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  void _clearError() {
    _errorMessage.value = null;
  }

  void _setError(String? error) {
    _errorMessage.value = error;
  }

  // Login
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result =
          await _authService.signInWithEmailAndPassword(email, password);

      if (result.success && result.user != null) {
        _currentUser.value = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro no login');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erro interno: $e');
      _setLoading(false);
      return false;
    }
  }

  // Cadastro
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result =
          await _authService.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      if (result.success && result.user != null) {
        _currentUser.value = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro no cadastro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erro interno: $e');
      _setLoading(false);
      return false;
    }
  }

  // Guest mode
  Future<void> enterGuestMode() async {
    await _enterGuestMode();
  }

  Future<void> _enterGuestMode({bool skipSave = false}) async {
    _currentUser.value = AuthUser.guest();
    _isGuestMode.value = true;

    if (!skipSave) {
      await _saveGuestModePreference(true);
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      if (!_isGuestMode.value) {
        await _authService.signOut();
      } else {
        await _prefs?.setBool('has_chosen_guest_mode', false);
      }
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
    }

    _currentUser.value = null;
    _isGuestMode.value = false;
    _hasChosenGuestMode.value = false;
  }

  // Exit guest mode and force login
  Future<void> exitGuestMode() async {
    await _prefs?.setBool('has_chosen_guest_mode', false);
    _hasChosenGuestMode.value = false;
    await signOut();
  }

  // Profile management
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser.value == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // TODO: Implementar updateProfile no FirebaseAuthService
      // final result = await _authService.updateProfile(
      //   displayName: displayName,
      //   photoURL: photoURL,
      // );
      _setLoading(false);
      return false; // Temporário

      // TODO: Implementar lógica de update quando FirebaseAuthService suportar
    } catch (e) {
      _setError('Erro interno: $e');
      _setLoading(false);
      return false;
    }
  }

  // Password reset
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.sendPasswordResetEmail(email);

      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro ao enviar email');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erro interno: $e');
      _setLoading(false);
      return false;
    }
  }

  // Toggle between sign in and sign up
  void toggleAuthMode() {
    _isSignUp.value = !_isSignUp.value;
  }

  // Validation helpers
  String? validateEmail(String? value) {
    return _validationService.validateEmail(value);
  }

  String? validatePassword(String? value) {
    return _validationService.validatePassword(value);
  }

  String? validatePasswordConfirmation(String? value, String? password) {
    if (value != password) {
      return 'Senhas não conferem';
    }
    return null;
  }

  // Navigation helpers (se ainda for necessário)
  Future<void> navigateAfterAuth() async {
    try {
      // Navigation logic - implementar conforme necessário
      // final result = await _authService.createUserWithEmailAndPassword(
      //     'email', 'password');

      // TODO: Implementar navegação quando necessário"
    } catch (e) {
      debugPrint('❌ Erro na navegação pós-auth: $e');
    }
  }

  // Debug helpers (apenas em debug mode)
  Map<String, dynamic> getDebugInfo() {
    // Verificar se está em debug mode
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    
    if (!isDebug) {
      return {'message': 'Debug info only available in debug mode'};
    }
    
    if (_currentUser.value == null) return {'user': 'null'};

    final user = _currentUser.value!;
    return {
      'isAuthenticated': isLoggedIn,
      'isGuest': _currentUser.value?.isGuest ?? false,
      'isLoading': isLoading,
      'hasError': errorMessage != null,
      // Sanitizar informações sensíveis mesmo em debug
      'userId': _sanitizeUserId(user.id),
      'email': _sanitizeEmail(user.email),
      'displayName': _sanitizeDisplayName(user.displayName),
      'hasChosenGuestMode': hasChosenGuestMode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Sanitizar user ID para debug (mostrar apenas parte)
  String _sanitizeUserId(String userId) {
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 4)}***${userId.substring(userId.length - 4)}';
  }

  /// Sanitizar email para debug (ocultar domínio)
  String _sanitizeEmail(String? email) {
    if (email == null || !email.contains('@')) return email ?? 'null';
    final parts = email.split('@');
    return '${parts[0]}@***';
  }

  /// Sanitizar display name para debug
  String _sanitizeDisplayName(String? displayName) {
    if (displayName == null || displayName.length <= 2) return displayName ?? 'null';
    return '${displayName.substring(0, 1)}***';
  }

  @override
  void onClose() {
    // Cleanup é feito automaticamente pelo SubscriptionManagerMixin
    super.onClose();
  }
}
