import 'package:flutter/material.dart';

/// Manages form keys, text controllers, and focus nodes for auth forms
/// Extracts form management complexity from AuthPage
class AuthFormManager {
  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Register controllers
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();

  // Focus nodes for login
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode loginButtonFocusNode = FocusNode();

  // Focus nodes for register
  FocusNode registerNameFocusNode = FocusNode();
  FocusNode registerEmailFocusNode = FocusNode();
  FocusNode registerPasswordFocusNode = FocusNode();
  FocusNode registerConfirmPasswordFocusNode = FocusNode();
  FocusNode registerButtonFocusNode = FocusNode();

  // Visibility flags
  bool obscureLoginPassword = true;
  bool obscureRegisterPassword = true;
  bool obscureRegisterConfirmPassword = true;

  // Remember me flag
  bool rememberMe = false;

  /// Validates login form
  bool validateLoginForm() {
    return loginFormKey.currentState?.validate() ?? false;
  }

  /// Validates register form
  bool validateRegisterForm() {
    return registerFormKey.currentState?.validate() ?? false;
  }

  /// Clears all form data
  void clearAllForms() {
    loginEmailController.clear();
    loginPasswordController.clear();
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }

  /// Clears login form only
  void clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  /// Clears register form only
  void clearRegisterForm() {
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }

  /// Sets login credentials (for remembered credentials)
  void setLoginCredentials(String email, String password) {
    loginEmailController.text = email;
    loginPasswordController.text = password;
  }

  /// Gets login email
  String get loginEmail => loginEmailController.text.trim();

  /// Gets login password
  String get loginPassword => loginPasswordController.text;

  /// Gets register data
  Map<String, String> get registerData => {
    'name': registerNameController.text.trim(),
    'email': registerEmailController.text.trim(),
    'password': registerPasswordController.text,
    'confirmPassword': registerConfirmPasswordController.text,
  };

  /// Toggles login password visibility
  void toggleLoginPasswordVisibility() {
    obscureLoginPassword = !obscureLoginPassword;
  }

  /// Toggles register password visibility
  void toggleRegisterPasswordVisibility() {
    obscureRegisterPassword = !obscureRegisterPassword;
  }

  /// Toggles register confirm password visibility
  void toggleRegisterConfirmPasswordVisibility() {
    obscureRegisterConfirmPassword = !obscureRegisterConfirmPassword;
  }

  /// Toggles remember me
  void toggleRememberMe() {
    rememberMe = !rememberMe;
  }

  /// Disposes all controllers and focus nodes
  void dispose() {
    // Dispose text controllers
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();

    // Dispose focus nodes
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    loginButtonFocusNode.dispose();
    registerNameFocusNode.dispose();
    registerEmailFocusNode.dispose();
    registerPasswordFocusNode.dispose();
    registerConfirmPasswordFocusNode.dispose();
    registerButtonFocusNode.dispose();
  }
}
