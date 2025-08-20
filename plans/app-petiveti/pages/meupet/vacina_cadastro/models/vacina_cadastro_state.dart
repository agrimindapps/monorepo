// Project imports:
import '../../../../models/16_vacina_model.dart';

/// Form submission state enum (standardized pattern)
enum FormSubmissionState {
  idle,
  validating, 
  loading,
  success,
  error
}

/// Unified state management model for VacinaCadastro
/// 
/// This model combines form state, validation state, and business state
/// into a single source of truth, eliminating the need for multiple
/// state management systems.
class VacinaCadastroState {
  final String animalId;
  final String nomeVacina;
  final int dataAplicacao;
  final int proximaDose;
  final String? observacoes;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final bool isEditing;
  final String? vacinaIdBeingEdited;
  
  // Form validation state
  final Map<String, String?> fieldErrors;
  final Map<String, bool> fieldTouched;
  final bool isSubmitting;
  final bool hasChanges;
  final FormSubmissionState submissionState;

  const VacinaCadastroState({
    this.animalId = '',
    this.nomeVacina = '',
    required this.dataAplicacao,
    required this.proximaDose,
    this.observacoes,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.isEditing = false,
    this.vacinaIdBeingEdited,
    this.fieldErrors = const {},
    this.fieldTouched = const {},
    this.isSubmitting = false,
    this.hasChanges = false,
    this.submissionState = FormSubmissionState.idle,
  });

  /// Creates a state from existing vaccine (for editing)
  VacinaCadastroState.fromVacina(VacinaVet vacina)
      : animalId = vacina.animalId,
        nomeVacina = vacina.nomeVacina,
        dataAplicacao = vacina.dataAplicacao,
        proximaDose = vacina.proximaDose,
        observacoes = vacina.observacoes,
        isLoading = false,
        isInitialized = true,
        errorMessage = null,
        successMessage = null,
        isEditing = true,
        vacinaIdBeingEdited = vacina.id,
        fieldErrors = const {},
        fieldTouched = const {},
        isSubmitting = false,
        hasChanges = false,
        submissionState = FormSubmissionState.idle;

  /// Creates an empty state for new vaccine
  VacinaCadastroState.empty(String selectedAnimalId)
      : animalId = selectedAnimalId,
        nomeVacina = '',
        dataAplicacao = DateTime.now().millisecondsSinceEpoch,
        proximaDose = DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
        observacoes = '',
        isLoading = false,
        isInitialized = true,
        errorMessage = null,
        successMessage = null,
        isEditing = false,
        vacinaIdBeingEdited = null,
        fieldErrors = const {},
        fieldTouched = const {},
        isSubmitting = false,
        hasChanges = false,
        submissionState = FormSubmissionState.idle;

  VacinaCadastroState copyWith({
    String? animalId,
    String? nomeVacina,
    int? dataAplicacao,
    int? proximaDose,
    String? observacoes,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    bool? isEditing,
    String? vacinaIdBeingEdited,
    Map<String, String?>? fieldErrors,
    Map<String, bool>? fieldTouched,
    bool? isSubmitting,
    bool? hasChanges,
    FormSubmissionState? submissionState,
  }) {
    return VacinaCadastroState(
      animalId: animalId ?? this.animalId,
      nomeVacina: nomeVacina ?? this.nomeVacina,
      dataAplicacao: dataAplicacao ?? this.dataAplicacao,
      proximaDose: proximaDose ?? this.proximaDose,
      observacoes: observacoes ?? this.observacoes,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isEditing: isEditing ?? this.isEditing,
      vacinaIdBeingEdited: vacinaIdBeingEdited ?? this.vacinaIdBeingEdited,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      fieldTouched: fieldTouched ?? this.fieldTouched,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasChanges: hasChanges ?? this.hasChanges,
      submissionState: submissionState ?? this.submissionState,
    );
  }

  // Computed properties
  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasFieldErrors => fieldErrors.isNotEmpty && fieldErrors.values.any((error) => error != null);
  bool get isReady => isInitialized && !isLoading;
  bool get canSubmit => isReady && !isSubmitting && !hasFieldErrors;
  DateTime get dataAplicacaoDate => DateTime.fromMillisecondsSinceEpoch(dataAplicacao);
  DateTime get proximaDoseDate => DateTime.fromMillisecondsSinceEpoch(proximaDose);
  
  bool get isValid => 
      animalId.isNotEmpty &&
      nomeVacina.trim().isNotEmpty &&
      nomeVacina.trim().length >= 2 &&
      proximaDose >= dataAplicacao;

  /// Checks if next dose date is valid (not before application date)
  bool get isValidNextDoseDate => proximaDose >= dataAplicacao;

  /// Calculate days until next dose
  int get daysUntilNextDose {
    final now = DateTime.now();
    final nextDose = DateTime.fromMillisecondsSinceEpoch(proximaDose);
    return nextDose.difference(now).inDays;
  }

  /// Check if vaccine would be overdue
  bool get wouldBeOverdue {
    final now = DateTime.now();
    final nextDose = DateTime.fromMillisecondsSinceEpoch(proximaDose);
    return nextDose.isBefore(now);
  }

  /// Gets the form title based on editing state
  String get formTitle => isEditing ? 'Editar Vacina' : 'Nova Vacina';

  /// Gets the submit button text based on editing state
  String get submitButtonText => isEditing ? 'Atualizar' : 'Salvar';

  // Form validation computed properties - updated for standardized pattern
  bool get isFormValid => fieldErrors.isEmpty && hasRequiredFields;
  bool get hasFormErrors => fieldErrors.isNotEmpty;
  bool get hasRequiredFields => animalId.isNotEmpty && nomeVacina.trim().isNotEmpty;
  
  /// Checks if a field has been touched
  bool isFieldTouched(String fieldName) => fieldTouched[fieldName] ?? false;
  
  /// Gets field error if exists
  String? getFieldError(String fieldName) => fieldErrors[fieldName];
  
  /// Checks if field should show error
  bool shouldShowFieldError(String fieldName) => 
      isFieldTouched(fieldName) && fieldErrors.containsKey(fieldName);

  // Form state manipulation methods
  
  /// Sets error for a specific field
  VacinaCadastroState setFieldError(String fieldName, String? error) {
    final newErrors = Map<String, String?>.from(fieldErrors);
    if (error != null) {
      newErrors[fieldName] = error;
    } else {
      newErrors.remove(fieldName);
    }
    
    return copyWith(fieldErrors: newErrors);
  }

  /// Sets multiple field errors
  VacinaCadastroState setFieldErrors(Map<String, String?> errors) {
    final newErrors = Map<String, String?>.from(fieldErrors);
    
    for (final entry in errors.entries) {
      if (entry.value != null) {
        newErrors[entry.key] = entry.value;
      } else {
        newErrors.remove(entry.key);
      }
    }
    
    return copyWith(fieldErrors: newErrors);
  }

  /// Marks a field as touched
  VacinaCadastroState touchField(String fieldName) {
    final newTouched = Map<String, bool>.from(fieldTouched);
    newTouched[fieldName] = true;
    
    return copyWith(fieldTouched: newTouched);
  }

  /// Clears all validation errors
  VacinaCadastroState clearValidationErrors() {
    return copyWith(fieldErrors: {});
  }

  /// Clears all form state (errors and touched)
  VacinaCadastroState clearFormState() {
    return copyWith(
      fieldErrors: {},
      fieldTouched: {},
    );
  }

  /// Clear field error
  VacinaCadastroState clearFieldError(String fieldName) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    updatedErrors.remove(fieldName);
    return copyWith(fieldErrors: updatedErrors);
  }

  /// Clear all errors
  VacinaCadastroState clearAllErrors() {
    return copyWith(
      errorMessage: null,
      fieldErrors: {},
    );
  }

  /// Clear messages
  VacinaCadastroState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Set loading state
  VacinaCadastroState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set submitting state
  VacinaCadastroState setSubmitting(bool submitting) {
    return copyWith(isSubmitting: submitting);
  }

  /// Set error
  VacinaCadastroState setError(String error) {
    return copyWith(
      errorMessage: error,
      isLoading: false,
      isSubmitting: false,
    );
  }

  /// Set success
  VacinaCadastroState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      isLoading: false,
      isSubmitting: false,
      hasChanges: false,
    );
  }

  /// Set initialized
  VacinaCadastroState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  /// Set has changes
  VacinaCadastroState setHasChanges(bool changes) {
    return copyWith(hasChanges: changes);
  }

  /// Resets to initial state for new vaccine
  VacinaCadastroState resetForNewVaccine(String animalId) {
    final now = DateTime.now();
    return VacinaCadastroState(
      animalId: animalId,
      nomeVacina: '',
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      observacoes: null,
      isLoading: false,
      isInitialized: true,
      errorMessage: null,
      successMessage: null,
      isEditing: false,
      vacinaIdBeingEdited: null,
      fieldErrors: const {},
      fieldTouched: const {},
      isSubmitting: false,
      hasChanges: false,
      submissionState: FormSubmissionState.idle,
    );
  }

  /// Serialization methods for standardized pattern
  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'nomeVacina': nomeVacina,
      'dataAplicacao': dataAplicacao,
      'proximaDose': proximaDose,
      'observacoes': observacoes,
      'isLoading': isLoading,
      'isInitialized': isInitialized,
      'errorMessage': errorMessage,
      'successMessage': successMessage,
      'isEditing': isEditing,
      'vacinaIdBeingEdited': vacinaIdBeingEdited,
      'fieldErrors': fieldErrors,
      'fieldTouched': fieldTouched,
      'isSubmitting': isSubmitting,
      'hasChanges': hasChanges,
      'submissionState': submissionState.name,
    };
  }

  factory VacinaCadastroState.fromJson(Map<String, dynamic> json) {
    return VacinaCadastroState(
      animalId: json['animalId'] ?? '',
      nomeVacina: json['nomeVacina'] ?? '',
      dataAplicacao: json['dataAplicacao'] ?? DateTime.now().millisecondsSinceEpoch,
      proximaDose: json['proximaDose'] ?? DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
      observacoes: json['observacoes'],
      isLoading: json['isLoading'] ?? false,
      isInitialized: json['isInitialized'] ?? false,
      errorMessage: json['errorMessage'],
      successMessage: json['successMessage'],
      isEditing: json['isEditing'] ?? false,
      vacinaIdBeingEdited: json['vacinaIdBeingEdited'],
      fieldErrors: Map<String, String?>.from(json['fieldErrors'] ?? {}),
      fieldTouched: Map<String, bool>.from(json['fieldTouched'] ?? {}),
      isSubmitting: json['isSubmitting'] ?? false,
      hasChanges: json['hasChanges'] ?? false,
      submissionState: FormSubmissionState.values.firstWhere(
        (state) => state.name == json['submissionState'],
        orElse: () => FormSubmissionState.idle,
      ),
    );
  }

  // Factory constructors for common states
  factory VacinaCadastroState.initial() {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
    );
  }

  factory VacinaCadastroState.loading() {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      isLoading: true,
    );
  }

  factory VacinaCadastroState.ready() {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      isInitialized: true,
    );
  }

  factory VacinaCadastroState.error(String error) {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      isInitialized: true,
      errorMessage: error,
    );
  }

  factory VacinaCadastroState.success(String message) {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      isInitialized: true,
      successMessage: message,
    );
  }

  factory VacinaCadastroState.submitting() {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      isInitialized: true,
      isSubmitting: true,
    );
  }
}
