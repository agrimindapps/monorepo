/// Pure entity representing registration data
///
/// This entity only holds data without business logic.
/// Validation is handled by AuthValidators utility class.
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
