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

  String? validateName() {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Por favor, insira seu nome completo';
    }
    if (trimmedName.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? validateEmail() {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return 'Por favor, insira seu email';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmedEmail)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword() {
    if (confirmPassword.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (confirmPassword != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  bool get isPersonalInfoValid {
    return validateName() == null && validateEmail() == null;
  }

  bool get isPasswordValid {
    return validatePassword() == null && validateConfirmPassword() == null;
  }

  bool get isValid {
    return isPersonalInfoValid && isPasswordValid;
  }

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
    return 'RegisterData(hasName: ${name.isNotEmpty}, hasEmail: ${email.isNotEmpty}, currentStep: $currentStep)';
  }
}
