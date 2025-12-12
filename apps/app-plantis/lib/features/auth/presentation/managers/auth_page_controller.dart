import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/enhanced_loading_states.dart';
import '../managers/auth_submission_manager.dart';
import '../managers/credentials_persistence_manager.dart';
import '../providers/auth_dialog_managers_providers.dart';

/// Controller that manages authentication page business logic
/// Separates concerns from UI to reduce AuthPage complexity
class AuthPageController {
  final WidgetRef ref;
  final BuildContext context;
  final LoadingStateMixin loadingMixin;
  final CredentialsPersistenceManager credentialsManager;

  late final AuthSubmissionManager _submissionManager;

  AuthPageController({
    required this.ref,
    required this.context,
    required this.loadingMixin,
    required this.credentialsManager,
  }) {
    _submissionManager = ref.read(authSubmissionManagerProvider);
  }

  /// Handles login submission with validation and navigation
  Future<void> handleLogin({
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (!formKey.currentState!.validate()) return;

    // Save credentials if remember me is checked
    await credentialsManager.saveRememberedCredentials(
      email: email,
      rememberMe: rememberMe,
    );

    loadingMixin.showLoading(message: 'Fazendo login...');

    final success = await _submissionManager.submitLogin(
      email: email,
      password: password,
      onError: (error) {
        loadingMixin.hideLoading();
        _showErrorSnackbar(error);
      },
      onSuccess: () {
        loadingMixin.hideLoading();
        _navigateToHome();
      },
    );

    if (!success) {
      loadingMixin.hideLoading();
    }
  }

  /// Handles registration submission with validation and navigation
  Future<void> handleRegister({
    required GlobalKey<FormState> formKey,
    required String name,
    required String email,
    required String password,
  }) async {
    if (!formKey.currentState!.validate()) return;

    loadingMixin.showLoading(message: 'Criando conta...');

    final success = await _submissionManager.submitRegister(
      email: email,
      password: password,
      name: name,
      onError: (error) {
        loadingMixin.hideLoading();
        _showErrorSnackbar(error);
      },
      onSuccess: () {
        loadingMixin.hideLoading();
        _navigateToHome();
      },
    );

    if (!success) {
      loadingMixin.hideLoading();
    }
  }

  /// Handles anonymous login
  Future<void> handleAnonymousLogin() async {
    loadingMixin.showLoading(message: 'Entrando anonimamente...');

    final success = await _submissionManager.submitAnonymousLogin(
      onError: (error) {
        loadingMixin.hideLoading();
        _showErrorSnackbar(error);
      },
      onSuccess: () {
        loadingMixin.hideLoading();
        _navigateToHome();
      },
    );

    if (!success) {
      loadingMixin.hideLoading();
    }
  }

  /// Loads saved credentials on initialization
  Future<({String? email, bool rememberMe})> loadRememberedCredentials() async {
    return await credentialsManager.loadRememberedCredentials();
  }

  /// Saves credentials when remember me checkbox changes
  Future<void> saveRememberedCredentials({
    required String email,
    required bool rememberMe,
  }) async {
    await credentialsManager.saveRememberedCredentials(
      email: email,
      rememberMe: rememberMe,
    );
  }

  /// Navigates to home page after successful authentication
  void _navigateToHome() {
    if (context.mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasValue && authState.value!.isAuthenticated) {
        GoRouter.of(context).go('/plants');
      }
    }
  }

  /// Shows error message to user
  void _showErrorSnackbar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
