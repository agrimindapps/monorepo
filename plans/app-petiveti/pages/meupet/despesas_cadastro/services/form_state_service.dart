/// Form state service for managing state transitions (standardized pattern)
/// 
/// Provides centralized logic for managing form state transitions
/// following the standardized pattern from animal_cadastro module.
library;

// Project imports:
import '../config/despesa_config.dart';
import '../models/despesa_form_state.dart';

class FormStateService {
  FormStateService._();

  /// Transition state to validating
  static DespesaFormState transitionToValidating(DespesaFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to loading
  static DespesaFormState transitionToLoading(DespesaFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to success
  static DespesaFormState transitionToSuccess(
    DespesaFormState currentState, 
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
  static DespesaFormState transitionToError(
    DespesaFormState currentState, 
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
  static DespesaFormState transitionToIdle(DespesaFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Reset state to initial state
  static DespesaFormState resetToInitial() {
    return DespesaFormState.initial();
  }

  /// Set field error while maintaining current submission state
  static DespesaFormState setFieldError(
    DespesaFormState currentState,
    String fieldName,
    String? error
  ) {
    return currentState.setFieldError(fieldName, error);
  }

  /// Clear all field errors while maintaining current submission state
  static DespesaFormState clearAllFieldErrors(DespesaFormState currentState) {
    return currentState.copyWith(
      fieldErrors: {},
    );
  }

  /// Set multiple field errors at once
  static DespesaFormState setMultipleFieldErrors(
    DespesaFormState currentState,
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
        return 'Salvando despesa...';
      case FormSubmissionState.success:
        return DespesaConfig.msgSuccessSave;
      case FormSubmissionState.error:
        return DespesaConfig.msgErrorSave;
    }
  }

  /// Check if form can be submitted in current state
  static bool canSubmit(DespesaFormState state) {
    return state.submissionState == FormSubmissionState.idle &&
           state.isReady &&
           !state.hasFieldErrors &&
           state.hasChanges;
  }

  /// Check if form is busy (loading or validating)
  static bool isBusy(DespesaFormState state) {
    return [
      FormSubmissionState.validating,
      FormSubmissionState.loading
    ].contains(state.submissionState);
  }

  /// Check if form has completed successfully
  static bool isSuccess(DespesaFormState state) {
    return state.submissionState == FormSubmissionState.success;
  }

  /// Check if form has error
  static bool hasError(DespesaFormState state) {
    return state.submissionState == FormSubmissionState.error ||
           state.hasError ||
           state.hasFieldErrors;
  }

  /// Get appropriate button text based on state
  static String getSubmitButtonText(DespesaFormState state, {bool isEditing = false}) {
    switch (state.submissionState) {
      case FormSubmissionState.validating:
        return 'Validando...';
      case FormSubmissionState.loading:
        return isEditing ? 'Atualizando...' : 'Salvando...';
      default:
        return isEditing ? DespesaConfig.buttonTextUpdate : DespesaConfig.buttonTextSave;
    }
  }

  /// Create a state with validation errors
  static DespesaFormState createValidationErrorState(
    DespesaFormState currentState,
    Map<String, String> fieldErrors
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      fieldErrors: fieldErrors,
      errorMessage: DespesaConfig.msgErrorValidation,
    );
  }

  /// Create state for form initialization
  static DespesaFormState createInitializedState() {
    return const DespesaFormState(
      isInitialized: true,
      submissionState: FormSubmissionState.idle,
    );
  }

  /// Handle form changes (mark as dirty)
  static DespesaFormState handleFormChanges(DespesaFormState currentState) {
    if (!currentState.hasChanges && currentState.submissionState == FormSubmissionState.idle) {
      return currentState.copyWith(hasChanges: true);
    }
    return currentState;
  }
}
