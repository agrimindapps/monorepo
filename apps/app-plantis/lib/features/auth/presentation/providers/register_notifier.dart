import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/register_data.dart';
import '../../utils/auth_validators.dart';

part 'register_notifier.g.dart';

/// State for registration form
class RegisterState {
  final RegisterData registerData;
  final String? errorMessage;
  final bool isLoading;

  const RegisterState({
    this.registerData = const RegisterData(),
    this.errorMessage,
    this.isLoading = false,
  });

  RegisterState copyWith({
    RegisterData? registerData,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return RegisterState(
      registerData: registerData ?? this.registerData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get currentStep => registerData.currentStep;
  double get progress {
    switch (registerData.currentStep) {
      case 0:
        return 0.33; // Initial step
      case 1:
        return 0.66; // Personal info step
      case 2:
        return 1.0; // Password step
      default:
        return 0.0;
    }
  }

  List<bool> get progressSteps {
    return [
      registerData.currentStep >= 0, // Step 1 - Initial
      registerData.currentStep >= 1, // Step 2 - Personal Info
      registerData.currentStep >= 2, // Step 3 - Password
    ];
  }
}

/// Notifier for registration form state management
@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  RegisterState build() {
    return const RegisterState();
  }

  /// Updates name field
  void updateName(String name) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(name: name),
      clearError: true,
    );
  }

  /// Updates email field
  void updateEmail(String email) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(email: email),
      clearError: true,
    );
  }

  /// Updates password field
  void updatePassword(String password) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(password: password),
      clearError: true,
    );
  }

  /// Updates confirm password field
  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(
        confirmPassword: confirmPassword,
      ),
      clearError: true,
    );
  }

  /// Moves to next step in registration flow
  void nextStep() {
    if (_canProceedToNextStep()) {
      state = state.copyWith(
        registerData: state.registerData.copyWith(
          currentStep: state.registerData.currentStep + 1,
        ),
        clearError: true,
      );
    }
  }

  /// Moves to previous step in registration flow
  void previousStep() {
    if (state.registerData.currentStep > 0) {
      state = state.copyWith(
        registerData: state.registerData.copyWith(
          currentStep: state.registerData.currentStep - 1,
        ),
        clearError: true,
      );
    }
  }

  /// Goes to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(
        registerData: state.registerData.copyWith(currentStep: step),
        clearError: true,
      );
    }
  }

  /// Validates current step data and returns true if can proceed
  bool _canProceedToNextStep() {
    switch (state.registerData.currentStep) {
      case 0: // Initial step
        return true;
      case 1: // Personal info step
        return _isPersonalInfoValid();
      case 2: // Password step
        return _isPasswordValid();
      default:
        return false;
    }
  }

  /// Checks if personal info is valid (without setting error)
  bool _isPersonalInfoValid() {
    final nameError = AuthValidators.validateName(state.registerData.name);
    final emailValid = AuthValidators.isValidEmail(state.registerData.email);
    return nameError == null && emailValid;
  }

  /// Checks if password is valid (without setting error)
  bool _isPasswordValid() {
    final passwordError = AuthValidators.validatePassword(
      state.registerData.password,
      isRegistration: true,
    );
    final confirmError = AuthValidators.validatePasswordConfirmation(
      state.registerData.password,
      state.registerData.confirmPassword,
    );
    return passwordError == null && confirmError == null;
  }

  /// Validates personal info step
  bool validatePersonalInfo() {
    final nameError = AuthValidators.validateName(state.registerData.name);
    if (nameError != null) {
      _setError(nameError);
      return false;
    }

    if (!AuthValidators.isValidEmail(state.registerData.email)) {
      _setError('Por favor, insira um email válido');
      return false;
    }

    state = state.copyWith(clearError: true);
    return true;
  }

  /// Validates password step
  bool validatePassword() {
    final passwordError = AuthValidators.validatePassword(
      state.registerData.password,
      isRegistration: true,
    );
    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    final confirmPasswordError = AuthValidators.validatePasswordConfirmation(
      state.registerData.password,
      state.registerData.confirmPassword,
    );
    if (confirmPasswordError != null) {
      _setError(confirmPasswordError);
      return false;
    }

    state = state.copyWith(clearError: true);
    return true;
  }

  /// Checks if email already exists (now handled by EmailCheckerManager)
  /// This method is kept for backwards compatibility but should be replaced
  /// with EmailCheckerManager.checkExists() in calling code
  @Deprecated('Use EmailCheckerManager.checkExists() instead')
  Future<bool> checkEmailExists(String email) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final exists = email.toLowerCase() == 'test@test.com';
      return exists;
    } catch (e) {
      _setError('Erro ao verificar email. Tente novamente.');
      if (kDebugMode) {
        debugPrint('Erro verificação email: ${e.toString()}');
      }
      return false;
    }
  }

  /// Validates and proceeds to next step for personal info
  Future<bool> validateAndProceedPersonalInfo() async {
    if (!validatePersonalInfo()) {
      return false;
    }
    final emailExists = await checkEmailExists(state.registerData.email);
    if (emailExists) {
      _setError('Este email já possui uma conta.');
      return false;
    }

    nextStep();
    return true;
  }

  /// Validates and proceeds to registration completion
  bool validateAndProceedPassword() {
    if (!validatePassword()) {
      return false;
    }

    nextStep();
    return true;
  }

  /// Resets all registration data
  void reset() {
    state = const RegisterState();
  }

  /// Sets error message
  void _setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  /// Clears error (public method)
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const registerNotifierProvider = registerProvider;
