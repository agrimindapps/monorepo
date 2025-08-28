class RegisterData {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final int currentStep;

  const RegisterData({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.currentStep = 0,
  });

  RegisterData copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    int? currentStep,
  }) {
    return RegisterData(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Validates name field
  String? validateName() {
    if (name.trim().isEmpty) {
      return 'Por favor, insira seu nome completo';
    }
    if (name.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  /// Validates email field
  String? validateEmail() {
    if (email.isEmpty) {
      return 'Por favor, insira seu email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  /// Validates password field
  String? validatePassword() {
    if (password.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) {
      return 'A senha deve conter letras e números';
    }
    return null;
  }

  /// Validates confirm password field
  String? validateConfirmPassword() {
    if (confirmPassword.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (confirmPassword != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  /// Validates personal info step (name and email)
  bool get isPersonalInfoValid {
    return validateName() == null && validateEmail() == null;
  }

  /// Validates password step
  bool get isPasswordValid {
    return validatePassword() == null && validateConfirmPassword() == null;
  }

  /// Checks if all data is valid for registration
  bool get isValid {
    return isPersonalInfoValid && isPasswordValid;
  }

  /// Clears all data
  RegisterData clear() {
    return const RegisterData();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RegisterData &&
      other.name == name &&
      other.email == email &&
      other.password == password &&
      other.confirmPassword == confirmPassword &&
      other.currentStep == currentStep;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      confirmPassword.hashCode ^
      currentStep.hashCode;
  }

  @override
  String toString() {
    return 'RegisterData(name: $name, email: $email, currentStep: $currentStep)';
  }
}