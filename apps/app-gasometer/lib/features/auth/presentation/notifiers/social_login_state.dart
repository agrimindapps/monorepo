/// Enum para métodos de social login
enum SocialLoginMethod {
  google,
  apple,
  facebook,
}

/// Estado do social login
class SocialLoginState {
  /// Construtor principal com parâmetros nomeados
  const SocialLoginState({
    this.isLoading = false,
    this.currentMethod,
    this.errorMessage,
  });

  /// Construtor para estado inicial
  const SocialLoginState.initial()
      : isLoading = false,
        currentMethod = null,
        errorMessage = null;

  /// Construtor para estado de loading
  const SocialLoginState.loading(SocialLoginMethod method)
      : isLoading = true,
        currentMethod = method,
        errorMessage = null;

  /// Construtor para estado de sucesso
  const SocialLoginState.success(SocialLoginMethod method)
      : isLoading = false,
        currentMethod = method,
        errorMessage = null;

  /// Construtor para estado de erro
  const SocialLoginState.error(String message, [SocialLoginMethod? method])
      : isLoading = false,
        currentMethod = method,
        errorMessage = message;

  final bool isLoading;
  final SocialLoginMethod? currentMethod;
  final String? errorMessage;

  /// Indica se há erro
  bool get hasError => errorMessage != null;

  /// Indica se está em processo de login
  bool get isProcessing => isLoading;

  String? get currentMethodLabel {
    if (currentMethod == null) return null;
    switch (currentMethod!) {
      case SocialLoginMethod.google:
        return 'Google';
      case SocialLoginMethod.apple:
        return 'Apple';
      case SocialLoginMethod.facebook:
        return 'Facebook';
    }
  }

  /// CopyWith para criar nova instância com campos modificados
  SocialLoginState copyWith({
    bool? isLoading,
    SocialLoginMethod? Function()? currentMethod,
    String? Function()? errorMessage,
  }) {
    return SocialLoginState(
      isLoading: isLoading ?? this.isLoading,
      currentMethod:
          currentMethod != null ? currentMethod() : this.currentMethod,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  /// Limpa erro mantendo outros campos
  SocialLoginState clearError() {
    return copyWith(errorMessage: () => null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SocialLoginState &&
        other.isLoading == isLoading &&
        other.currentMethod == currentMethod &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^ currentMethod.hashCode ^ errorMessage.hashCode;

  @override
  String toString() {
    return 'SocialLoginState('
        'isLoading: $isLoading, '
        'currentMethod: $currentMethod, '
        'errorMessage: $errorMessage)';
  }
}
