/// Form submission state enum (standardized pattern)
enum FormSubmissionState {
  idle,
  validating, 
  loading,
  success,
  error
}

enum MedicamentoCadastroState {
  initial,
  loading,
  success,
  error,
}

class MedicamentoCadastroStateModel {
  final MedicamentoCadastroState state;
  final String? errorMessage;
  final bool isFormValid;
  final bool isDirty;

  const MedicamentoCadastroStateModel({
    this.state = MedicamentoCadastroState.initial,
    this.errorMessage,
    this.isFormValid = false,
    this.isDirty = false,
  });

  MedicamentoCadastroStateModel copyWith({
    MedicamentoCadastroState? state,
    String? errorMessage,
    bool? isFormValid,
    bool? isDirty,
  }) {
    return MedicamentoCadastroStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  bool get isLoading => state == MedicamentoCadastroState.loading;
  bool get hasError => state == MedicamentoCadastroState.error;
  bool get isSuccess => state == MedicamentoCadastroState.success;
  bool get isInitial => state == MedicamentoCadastroState.initial;
  bool get canSubmit => isFormValid && !isLoading;
  bool get shouldShowError => hasError && errorMessage != null;
}