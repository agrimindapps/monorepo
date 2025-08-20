/// Form state service for managing state transitions (standardized pattern)
/// 
/// Provides centralized logic for managing form state transitions
/// following the standardized pattern from animal_cadastro module.
library;

// Project imports:
import '../config/medicamento_config.dart';
import '../models/medicamento_form_state.dart';

class FormStateService {
  FormStateService._();

  /// Transition state to validating
  static MedicamentoFormState transitionToValidating(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to loading
  static MedicamentoFormState transitionToLoading(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to success
  static MedicamentoFormState transitionToSuccess(
    MedicamentoFormState currentState, 
    String message
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: message,
      hasChanges: false,
      fieldErrors: {},
    );
  }

  /// Transition state to error
  static MedicamentoFormState transitionToError(
    MedicamentoFormState currentState, 
    String error
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      errorMessage: error,
      successMessage: null,
    );
  }

  /// Transition state to idle
  static MedicamentoFormState transitionToIdle(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Reset state to initial state
  static MedicamentoFormState resetToInitial() {
    return MedicamentoFormState.initial();
  }

  /// Set field error while maintaining current submission state
  static MedicamentoFormState setFieldError(
    MedicamentoFormState currentState,
    String fieldName,
    String? error
  ) {
    return currentState.setFieldError(fieldName, error);
  }

  /// Clear all field errors while maintaining current submission state
  static MedicamentoFormState clearAllFieldErrors(MedicamentoFormState currentState) {
    return currentState.copyWith(
      fieldErrors: {},
    );
  }

  /// Set multiple field errors at once
  static MedicamentoFormState setMultipleFieldErrors(
    MedicamentoFormState currentState,
    Map<String, String> errors
  ) {
    final updatedErrors = Map<String, String?>.from(currentState.fieldErrors);
    errors.forEach((field, error) {
      updatedErrors[field] = error;
    });
    
    return currentState.copyWith(
      fieldErrors: updatedErrors,
    );
  }

  /// Check if state transition is valid
  static bool isValidTransition(
    FormSubmissionState from, 
    FormSubmissionState to
  ) {
    switch (from) {
      case FormSubmissionState.idle:
        return [
          FormSubmissionState.validating,
          FormSubmissionState.loading
        ].contains(to);
        
      case FormSubmissionState.validating:
        return [
          FormSubmissionState.loading,
          FormSubmissionState.error,
          FormSubmissionState.idle
        ].contains(to);
        
      case FormSubmissionState.loading:
        return [
          FormSubmissionState.success,
          FormSubmissionState.error,
          FormSubmissionState.idle
        ].contains(to);
        
      case FormSubmissionState.success:
        return [
          FormSubmissionState.idle,
          FormSubmissionState.validating
        ].contains(to);
        
      case FormSubmissionState.error:
        return [
          FormSubmissionState.idle,
          FormSubmissionState.validating,
          FormSubmissionState.loading
        ].contains(to);
    }
  }

  /// Get user-friendly message for submission state
  static String getStateMessage(FormSubmissionState state) {
    switch (state) {
      case FormSubmissionState.idle:
        return '';
      case FormSubmissionState.validating:
        return 'Validando dados...';
      case FormSubmissionState.loading:
        return 'Salvando medicamento...';
      case FormSubmissionState.success:
        return MedicamentoConfig.msgSuccessSave;
      case FormSubmissionState.error:
        return MedicamentoConfig.msgErrorSave;
    }
  }

  /// Check if form can be submitted in current state
  static bool canSubmit(MedicamentoFormState state) {
    return state.submissionState == FormSubmissionState.idle &&
           state.isReady &&
           !state.hasFieldErrors &&
           state.hasChanges;
  }

  /// Check if form is busy (loading or validating)
  static bool isBusy(MedicamentoFormState state) {
    return [
      FormSubmissionState.validating,
      FormSubmissionState.loading
    ].contains(state.submissionState);
  }

  /// Check if form has completed successfully
  static bool isSuccess(MedicamentoFormState state) {
    return state.submissionState == FormSubmissionState.success;
  }

  /// Check if form has error
  static bool hasError(MedicamentoFormState state) {
    return state.submissionState == FormSubmissionState.error ||
           state.hasError ||
           state.hasFieldErrors;
  }

  /// Get appropriate button text based on state
  static String getSubmitButtonText(MedicamentoFormState state, {bool isEditing = false}) {
    switch (state.submissionState) {
      case FormSubmissionState.validating:
        return 'Validando...';
      case FormSubmissionState.loading:
        return isEditing ? 'Atualizando...' : 'Salvando...';
      default:
        return isEditing ? MedicamentoConfig.buttonTextUpdate : MedicamentoConfig.buttonTextSave;
    }
  }

  /// Create a state with validation errors
  static MedicamentoFormState createValidationErrorState(
    MedicamentoFormState currentState,
    Map<String, String> fieldErrors
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      fieldErrors: fieldErrors,
      errorMessage: MedicamentoConfig.msgErrorValidation,
    );
  }

  /// Create state for form initialization
  static MedicamentoFormState createInitializedState() {
    return const MedicamentoFormState(
      isInitialized: true,
      submissionState: FormSubmissionState.idle,
    );
  }

  /// Handle form changes (mark as dirty)
  static MedicamentoFormState handleFormChanges(MedicamentoFormState currentState) {
    if (!currentState.hasChanges && currentState.submissionState == FormSubmissionState.idle) {
      return currentState.copyWith(hasChanges: true);
    }
    return currentState;
  }

  /// Validate form fields and return updated state with errors
  static MedicamentoFormState validateFormFields(
    MedicamentoFormState currentState,
    Map<String, String?> validationResults
  ) {
    final errors = <String, String>{};
    
    validationResults.forEach((field, error) {
      if (error != null) {
        errors[field] = error;
      }
    });

    if (errors.isNotEmpty) {
      return createValidationErrorState(currentState, errors);
    }

    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      fieldErrors: {},
      errorMessage: null,
    );
  }

  /// Create state for medication name validation
  static MedicamentoFormState validateMedicationName(
    MedicamentoFormState currentState,
    String? name
  ) {
    final validationError = MedicamentoConfig.validateNomeMedicamento(name);
    
    if (validationError != null) {
      return currentState.setFieldError('nomeMedicamento', validationError);
    }

    return currentState.clearFieldError('nomeMedicamento');
  }

  /// Create state for dosage validation
  static MedicamentoFormState validateDosage(
    MedicamentoFormState currentState,
    String? dosage
  ) {
    final validationError = MedicamentoConfig.validateDosagem(dosage);
    
    if (validationError != null) {
      return currentState.setFieldError('dosagem', validationError);
    }

    return currentState.clearFieldError('dosagem');
  }

  /// Create state for frequency validation
  static MedicamentoFormState validateFrequency(
    MedicamentoFormState currentState,
    String? frequency
  ) {
    final validationError = MedicamentoConfig.validateFrequencia(frequency);
    
    if (validationError != null) {
      return currentState.setFieldError('frequencia', validationError);
    }

    return currentState.clearFieldError('frequencia');
  }

  /// Create state for duration validation
  static MedicamentoFormState validateDuration(
    MedicamentoFormState currentState,
    String? duration
  ) {
    final validationError = MedicamentoConfig.validateDuracao(duration);
    
    if (validationError != null) {
      return currentState.setFieldError('duracao', validationError);
    }

    return currentState.clearFieldError('duracao');
  }

  /// Create state for date range validation
  static MedicamentoFormState validateDateRange(
    MedicamentoFormState currentState,
    DateTime? startDate,
    DateTime? endDate
  ) {
    var newState = currentState;

    // Validate start date
    final startDateError = MedicamentoConfig.validateDataInicio(startDate);
    if (startDateError != null) {
      newState = newState.setFieldError('dataInicio', startDateError);
    } else {
      newState = newState.clearFieldError('dataInicio');
    }

    // Validate end date
    final endDateError = MedicamentoConfig.validateDataFim(startDate, endDate);
    if (endDateError != null) {
      newState = newState.setFieldError('dataFim', endDateError);
    } else {
      newState = newState.clearFieldError('dataFim');
    }

    return newState;
  }

  /// Create state for animal validation
  static MedicamentoFormState validateAnimal(
    MedicamentoFormState currentState,
    String? animalId
  ) {
    final validationError = MedicamentoConfig.validateAnimalId(animalId);
    
    if (validationError != null) {
      return currentState.setFieldError('animalId', validationError);
    }

    return currentState.clearFieldError('animalId');
  }

  /// Get progress percentage based on submission state
  static double getProgressPercentage(FormSubmissionState state) {
    switch (state) {
      case FormSubmissionState.idle:
        return 0.0;
      case FormSubmissionState.validating:
        return 0.25;
      case FormSubmissionState.loading:
        return 0.75;
      case FormSubmissionState.success:
        return 1.0;
      case FormSubmissionState.error:
        return 0.0;
    }
  }

  /// Check if state allows form editing
  static bool allowsEditing(FormSubmissionState state) {
    return [
      FormSubmissionState.idle,
      FormSubmissionState.error
    ].contains(state);
  }

  /// Check if state should show loading indicator
  static bool shouldShowLoading(FormSubmissionState state) {
    return [
      FormSubmissionState.validating,
      FormSubmissionState.loading
    ].contains(state);
  }

  /// Handle date validation with treatment logic
  static MedicamentoFormState validateTreatmentPeriod(
    MedicamentoFormState currentState,
    DateTime? startDate,
    DateTime? endDate
  ) {
    if (startDate == null || endDate == null) {
      return validateDateRange(currentState, startDate, endDate);
    }

    // Additional treatment-specific validations
    final duration = endDate.difference(startDate);
    
    if (duration.inDays > MedicamentoConfig.maxTreatmentDurationDays) {
      return currentState.setFieldError('dataFim', MedicamentoConfig.treatmentTooLongMessage);
    }

    if (duration.inHours < MedicamentoConfig.minTreatmentDurationHours) {
      return currentState.setFieldError('dataFim', MedicamentoConfig.treatmentTooShortMessage);
    }

    return validateDateRange(currentState, startDate, endDate);
  }

  /// Create state for CSV export operation
  static MedicamentoFormState createExportState(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      successMessage: 'Preparando exportação...',
    );
  }

  /// Handle CSV export success
  static MedicamentoFormState handleExportSuccess(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      successMessage: 'Dados exportados com sucesso!',
    );
  }

  /// Handle CSV export error
  static MedicamentoFormState handleExportError(
    MedicamentoFormState currentState,
    String error
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      errorMessage: 'Erro ao exportar dados: $error',
    );
  }

  /// Create state for auto-suggestion loading
  static MedicamentoFormState createSuggestionLoadingState(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Carregando sugestões...',
    );
  }

  /// Handle auto-suggestion success
  static MedicamentoFormState handleSuggestionSuccess(MedicamentoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      successMessage: null,
    );
  }
}
