import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../providers/register_notifier.dart';

/// Manager for handling auth submission actions
/// Centralizes login, register, and anonymous login logic
class AuthSubmissionManager {
  final Ref ref;

  AuthSubmissionManager({required this.ref});

  /// Submits login action
  /// Returns true if successful, false otherwise
  Future<bool> submitLogin({
    required String email,
    required String password,
    required void Function(String) onError,
    required void Function() onSuccess,
  }) async {
    try {
      await ref.read(authProvider.notifier).login(email, password);
      onSuccess();
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  /// Submits register action
  /// Returns true if successful, false otherwise
  Future<bool> submitRegister({
    required String email,
    required String password,
    required String name,
    required void Function(String) onError,
    required void Function() onSuccess,
  }) async {
    try {
      await ref.read(authProvider.notifier).register(email, password, name);
      onSuccess();
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  /// Submits anonymous login action
  /// Returns true if successful, false otherwise
  Future<bool> submitAnonymousLogin({
    required void Function(String) onError,
    required void Function() onSuccess,
  }) async {
    try {
      await ref.read(authProvider.notifier).signInAnonymously();
      onSuccess();
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  /// Validates and submits registration using RegisterNotifier
  /// Returns true if successful, false otherwise
  Future<bool> submitCompleteRegistration({
    required void Function(String) onError,
    required void Function() onSuccess,
  }) async {
    try {
      final registerState = ref.read(registerNotifierProvider);

      // Validate all fields
      if (registerState.registerData.name.trim().isEmpty) {
        onError('Nome é obrigatório');
        return false;
      }

      if (registerState.registerData.email.trim().isEmpty) {
        onError('Email é obrigatório');
        return false;
      }

      if (registerState.registerData.password.isEmpty) {
        onError('Senha é obrigatória');
        return false;
      }

      if (registerState.registerData.password !=
          registerState.registerData.confirmPassword) {
        onError('As senhas não coincidem');
        return false;
      }

      // Submit registration
      await ref
          .read(authProvider.notifier)
          .register(
            registerState.registerData.email,
            registerState.registerData.password,
            registerState.registerData.name,
          );

      onSuccess();
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  /// Resets password for given email
  /// Returns true if successful, false otherwise
  Future<bool> resetPassword({
    required String email,
    required void Function(String) onError,
    required void Function() onSuccess,
  }) async {
    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      onSuccess();
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }
}
