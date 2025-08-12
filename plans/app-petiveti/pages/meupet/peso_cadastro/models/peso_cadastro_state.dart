enum PesoCadastroState {
  initial,
  loading,
  success,
  error,
}

class PesoCadastroStateModel {
  final PesoCadastroState state;
  final String? errorMessage;
  final bool isFormValid;

  const PesoCadastroStateModel({
    this.state = PesoCadastroState.initial,
    this.errorMessage,
    this.isFormValid = false,
  });

  PesoCadastroStateModel copyWith({
    PesoCadastroState? state,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return PesoCadastroStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  bool get isLoading => state == PesoCadastroState.loading;
  bool get hasError => state == PesoCadastroState.error;
  bool get isSuccess => state == PesoCadastroState.success;
  bool get isInitial => state == PesoCadastroState.initial;
}