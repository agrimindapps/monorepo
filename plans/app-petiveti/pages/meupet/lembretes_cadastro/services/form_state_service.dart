/// Form state service for managing state transitions (standardized pattern)
/// 
/// Provides centralized logic for managing form state transitions
/// following the standardized pattern from animal_cadastro module.
library;

// Project imports:
import '../config/lembrete_form_config.dart';
import '../models/lembrete_form_state.dart';

class FormStateService {
  FormStateService._();

  /// Transition state to validating
  static LembreteFormState transitionToValidating(LembreteFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      isLoading: false,
      isSubmitting: false,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  /// Transition state to loading
  static LembreteFormState transitionToLoading(LembreteFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  /// Transition state to success
  static LembreteFormState transitionToSuccess(
    LembreteFormState currentState, 
    String message
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      isSubmitting: false,
      clearErrorMessage: true,
      successMessage: message,
      hasChanges: false,
      fieldErrors: {},
    );
  }

  /// Transition state to error
  static LembreteFormState transitionToError(
    LembreteFormState currentState, 
    String error
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      errorMessage: error,
      clearSuccessMessage: true,
    );
  }

  /// Transition state to idle
  static LembreteFormState transitionToIdle(LembreteFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      isLoading: false,
      isSubmitting: false,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  /// Reset state to initial state
  static LembreteFormState resetToInitial() {
    return const LembreteFormState();
  }

  /// Set field error while maintaining current submission state
  static LembreteFormState setFieldError(
    LembreteFormState currentState,
    String fieldName,
    String? error
  ) {
    return currentState.setFieldError(fieldName, error);
  }

  /// Clear all field errors while maintaining current submission state
  static LembreteFormState clearAllFieldErrors(LembreteFormState currentState) {
    return currentState.copyWith(
      fieldErrors: {},
    );
  }

  /// Set multiple field errors at once
  static LembreteFormState setMultipleFieldErrors(
    LembreteFormState currentState,
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
        return 'Salvando lembrete...';
      case FormSubmissionState.success:
        return LembreteFormConfig.msgSuccessSave;
      case FormSubmissionState.error:
        return LembreteFormConfig.msgErrorSave;
    }
  }

  /// Check if form can be submitted in current state
  static bool canSubmit(LembreteFormState state) {
    return state.submissionState == FormSubmissionState.idle &&
           state.isReady &&
           !state.hasFieldErrors &&
           state.hasChanges;
  }

  /// Check if form is busy (loading or validating)
  static bool isBusy(LembreteFormState state) {
    return [
      FormSubmissionState.validating,
      FormSubmissionState.loading
    ].contains(state.submissionState);
  }

  /// Check if form has completed successfully
  static bool isSuccess(LembreteFormState state) {
    return state.submissionState == FormSubmissionState.success;
  }

  /// Check if form has error
  static bool hasError(LembreteFormState state) {
    return state.submissionState == FormSubmissionState.error ||
           state.hasError ||
           state.hasFieldErrors;
  }

  /// Get appropriate button text based on state
  static String getSubmitButtonText(LembreteFormState state, {bool isEditing = false}) {
    switch (state.submissionState) {
      case FormSubmissionState.validating:
        return 'Validando...';
      case FormSubmissionState.loading:
        return isEditing ? 'Atualizando...' : 'Salvando...';
      default:
        return isEditing ? LembreteFormConfig.buttonTextUpdate : LembreteFormConfig.buttonTextSave;
    }
  }

  /// Create a state with validation errors
  static LembreteFormState createValidationErrorState(
    LembreteFormState currentState,
    Map<String, String> fieldErrors
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      fieldErrors: fieldErrors,
      errorMessage: LembreteFormConfig.msgErrorValidation,
    );
  }

  /// Create state for form initialization
  static LembreteFormState createInitializedState() {
    return const LembreteFormState(
      isInitialized: true,
      submissionState: FormSubmissionState.idle,
    );
  }

  /// Handle form changes (mark as dirty)
  static LembreteFormState handleFormChanges(LembreteFormState currentState) {
    if (!currentState.hasChanges && currentState.submissionState == FormSubmissionState.idle) {
      return currentState.copyWith(hasChanges: true);
    }
    return currentState;
  }

  /// Create notification scheduling state
  static LembreteFormState createNotificationSchedulingState(LembreteFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      errorMessage: 'Agendando notificação...',
    );
  }

  /// Handle notification scheduling success
  static LembreteFormState handleNotificationSchedulingSuccess(LembreteFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      successMessage: 'Lembrete e notificação salvos com sucesso!',
    );
  }

  /// Handle notification scheduling error
  static LembreteFormState handleNotificationSchedulingError(
    LembreteFormState currentState,
    String error
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      errorMessage: 'Erro ao agendar notificação: $error',
    );
  }

  /// Validate form fields and return updated state with errors
  static LembreteFormState validateFormFields(
    LembreteFormState currentState,
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
      clearErrorMessage: true,
    );
  }

  /// Create state for date/time validation
  static LembreteFormState validateDateTime(
    LembreteFormState currentState,
    DateTime? dateTime
  ) {
    final validationError = LembreteFormConfig.validateDataHora(dateTime);
    
    if (validationError != null) {
      return currentState.setFieldError('dataHora', validationError);
    }

    return currentState.clearFieldError('dataHora');
  }

  /// Create state for reminder type validation
  static LembreteFormState validateReminderType(
    LembreteFormState currentState,
    String? type
  ) {
    final validationError = LembreteFormConfig.validateTipo(type);
    
    if (validationError != null) {
      return currentState.setFieldError('tipo', validationError);
    }

    return currentState.clearFieldError('tipo');
  }

  /// Create state for animal validation
  static LembreteFormState validateAnimal(
    LembreteFormState currentState,
    String? animalId
  ) {
    final validationError = LembreteFormConfig.validateAnimalId(animalId);
    
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
}
