import 'package:flutter/foundation.dart';

import '../../../../core/services/data_sanitization_service.dart';
import '../../domain/entities/register_data.dart';

class RegisterProvider extends ChangeNotifier {
  RegisterData _registerData = const RegisterData();
  String? _errorMessage;
  bool _isLoading = false;

  RegisterData get registerData => _registerData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  int get currentStep => _registerData.currentStep;

  /// Updates name field
  void updateName(String name) {
    _registerData = _registerData.copyWith(name: name);
    _clearError();
    notifyListeners();
  }

  /// Updates email field
  void updateEmail(String email) {
    _registerData = _registerData.copyWith(email: email);
    _clearError();
    notifyListeners();
  }

  /// Updates password field
  void updatePassword(String password) {
    _registerData = _registerData.copyWith(password: password);
    _clearError();
    notifyListeners();
  }

  /// Updates confirm password field
  void updateConfirmPassword(String confirmPassword) {
    _registerData = _registerData.copyWith(confirmPassword: confirmPassword);
    _clearError();
    notifyListeners();
  }

  /// Moves to next step in registration flow
  void nextStep() {
    if (_canProceedToNextStep()) {
      _registerData = _registerData.copyWith(
        currentStep: _registerData.currentStep + 1,
      );
      _clearError();
      notifyListeners();
    }
  }

  /// Moves to previous step in registration flow
  void previousStep() {
    if (_registerData.currentStep > 0) {
      _registerData = _registerData.copyWith(
        currentStep: _registerData.currentStep - 1,
      );
      _clearError();
      notifyListeners();
    }
  }

  /// Goes to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _registerData = _registerData.copyWith(currentStep: step);
      _clearError();
      notifyListeners();
    }
  }

  /// Validates current step data and returns true if can proceed
  bool _canProceedToNextStep() {
    switch (_registerData.currentStep) {
      case 0: // Initial step
        return true;
      case 1: // Personal info step
        return _registerData.isPersonalInfoValid;
      case 2: // Password step
        return _registerData.isPasswordValid;
      default:
        return false;
    }
  }

  /// Validates personal info step
  bool validatePersonalInfo() {
    _clearError();

    final nameError = _registerData.validateName();
    final emailError = _registerData.validateEmail();

    if (nameError != null) {
      _setError(nameError);
      return false;
    }

    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    return true;
  }

  /// Validates password step
  bool validatePassword() {
    _clearError();

    final passwordError = _registerData.validatePassword();
    final confirmPasswordError = _registerData.validateConfirmPassword();

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    if (confirmPasswordError != null) {
      _setError(confirmPasswordError);
      return false;
    }

    return true;
  }

  /// Checks if email already exists (placeholder for real implementation)
  Future<bool> checkEmailExists(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final exists = email.toLowerCase() == 'test@test.com';

      _isLoading = false;
      notifyListeners();

      return exists;
    } catch (e) {
      _isLoading = false;
      _setError('Erro ao verificar email. Tente novamente.');
      if (kDebugMode) {
        debugPrint(
          'Erro verificação email: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
        );
      }
      return false;
    }
  }

  /// Validates and proceeds to next step for personal info
  Future<bool> validateAndProceedPersonalInfo() async {
    if (!validatePersonalInfo()) {
      return false;
    }
    final emailExists = await checkEmailExists(_registerData.email);
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
    _registerData = const RegisterData();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clears current error
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }

  /// Sets error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clears error (public method)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Gets progress as percentage (0.0 to 1.0)
  double get progress {
    switch (_registerData.currentStep) {
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

  /// Gets progress step indicators
  List<bool> get progressSteps {
    return [
      _registerData.currentStep >= 0, // Step 1 - Initial
      _registerData.currentStep >= 1, // Step 2 - Personal Info
      _registerData.currentStep >= 2, // Step 3 - Password
    ];
  }

  /// Debug method to print current state (sanitized for security)
  @override
  String toString() {
    final sanitizedData =
        'RegisterProvider(step: ${_registerData.currentStep}, '
        'hasName: ${_registerData.name.isNotEmpty}, '
        'hasEmail: ${_registerData.email.isNotEmpty}, '
        'hasError: ${_errorMessage != null})';
    return DataSanitizationService.sanitizeForLogging(sanitizedData);
  }
}
