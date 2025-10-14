import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/data_sanitization_service.dart';
import '../../domain/entities/register_data.dart';

part 'register_provider.freezed.dart';
part 'register_provider.g.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(RegisterData()) RegisterData registerData,
    String? errorMessage,
    @Default(false) bool isLoading,
  }) = _RegisterState;

  const RegisterState._();

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

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  RegisterState build() {
    return const RegisterState();
  }

  void updateName(String name) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(name: name),
      errorMessage: null,
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(email: email),
      errorMessage: null,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(password: password),
      errorMessage: null,
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      registerData: state.registerData.copyWith(confirmPassword: confirmPassword),
      errorMessage: null,
    );
  }

  void nextStep() {
    if (_canProceedToNextStep()) {
      state = state.copyWith(
        registerData: state.registerData.copyWith(
          currentStep: state.registerData.currentStep + 1,
        ),
        errorMessage: null,
      );
    }
  }

  void previousStep() {
    if (state.registerData.currentStep > 0) {
      state = state.copyWith(
        registerData: state.registerData.copyWith(
          currentStep: state.registerData.currentStep - 1,
        ),
        errorMessage: null,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(
        registerData: state.registerData.copyWith(currentStep: step),
        errorMessage: null,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (state.registerData.currentStep) {
      case 0: // Initial step
        return true;
      case 1: // Personal info step
        return state.registerData.isPersonalInfoValid;
      case 2: // Password step
        return state.registerData.isPasswordValid;
      default:
        return false;
    }
  }

  bool validatePersonalInfo() {
    state = state.copyWith(errorMessage: null);

    final nameError = state.registerData.validateName();
    final emailError = state.registerData.validateEmail();

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

  bool validatePassword() {
    state = state.copyWith(errorMessage: null);

    final passwordError = state.registerData.validatePassword();
    final confirmPasswordError = state.registerData.validateConfirmPassword();

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

  Future<bool> checkEmailExists(String email) async {
    try {
      state = state.copyWith(isLoading: true);

      await Future<void>.delayed(const Duration(milliseconds: 500));
      final exists = email.toLowerCase() == 'test@test.com';

      state = state.copyWith(isLoading: false);

      return exists;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _setError('Erro ao verificar email. Tente novamente.');
      if (kDebugMode) {
        debugPrint(
          'Erro verificação email: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
        );
      }
      return false;
    }
  }

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

  bool validateAndProceedPassword() {
    if (!validatePassword()) {
      return false;
    }

    nextStep();
    return true;
  }

  void reset() {
    state = const RegisterState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void _setError(String error) {
    state = state.copyWith(errorMessage: error);
  }
}
