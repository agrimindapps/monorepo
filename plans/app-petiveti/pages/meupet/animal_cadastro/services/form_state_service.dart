// Project imports:
import '../models/animal_form_state.dart';

class FormStateService {
  // Private constructor to prevent instantiation
  FormStateService._();

  // State transition methods
  static AnimalFormState transitionToValidating(AnimalFormState currentState) {
    return currentState.setValidating(true);
  }

  static AnimalFormState transitionToLoading(AnimalFormState currentState) {
    return currentState.setLoading(true);
  }

  static AnimalFormState transitionToSuccess(
      AnimalFormState currentState, String message) {
    return currentState.setSuccess(message);
  }

  static AnimalFormState transitionToError(
      AnimalFormState currentState, String error) {
    return currentState.setError(error);
  }

  static AnimalFormState transitionToIdle(AnimalFormState currentState) {
    return currentState.setSubmissionState(FormSubmissionState.idle);
  }

  // State validation
  static bool canSubmit(AnimalFormState state) {
    return state.canSubmit;
  }

  static bool isProcessing(AnimalFormState state) {
    return state.isLoading || state.isValidating || state.isSubmitting;
  }

  static bool hasErrors(AnimalFormState state) {
    return state.hasError || state.hasFieldErrors;
  }

  // Form flow management
  static AnimalFormState handleFormSubmission(AnimalFormState currentState) {
    if (!canSubmit(currentState)) {
      return currentState
          .setError('Formulário não pode ser enviado no estado atual');
    }

    return transitionToLoading(currentState);
  }

  static AnimalFormState handleValidationResult(
      AnimalFormState currentState, Map<String, String?> validationErrors) {
    if (validationErrors.isEmpty) {
      return currentState.clearAllErrors();
    } else {
      return currentState.setFieldErrors(validationErrors);
    }
  }

  static AnimalFormState handleSubmissionSuccess(
      AnimalFormState currentState, String successMessage) {
    return transitionToSuccess(currentState, successMessage);
  }

  static AnimalFormState handleSubmissionError(
      AnimalFormState currentState, String errorMessage) {
    return transitionToError(currentState, errorMessage);
  }

  // Reset methods
  static AnimalFormState resetForm(AnimalFormState currentState) {
    return currentState.reset();
  }

  static AnimalFormState clearErrors(AnimalFormState currentState) {
    return currentState.clearAllErrors();
  }

  static AnimalFormState clearMessages(AnimalFormState currentState) {
    return currentState.clearMessages();
  }

  // Edit mode management
  static AnimalFormState enterEditMode(AnimalFormState currentState) {
    return currentState.setEditMode(true);
  }

  static AnimalFormState exitEditMode(AnimalFormState currentState) {
    return currentState.setEditMode(false);
  }

  // Change tracking
  static AnimalFormState markAsChanged(AnimalFormState currentState) {
    return currentState.setHasChanges(true);
  }

  static AnimalFormState markAsSaved(AnimalFormState currentState) {
    return currentState.setHasChanges(false);
  }

  // Validation workflow
  static AnimalFormState startValidation(AnimalFormState currentState) {
    return currentState.clearAllErrors().setValidating(true);
  }

  static AnimalFormState completeValidation(
      AnimalFormState currentState, Map<String, String?> errors) {
    return currentState.setValidating(false).setFieldErrors(errors);
  }

  // Submission workflow
  static AnimalFormState startSubmission(AnimalFormState currentState) {
    return currentState.clearMessages().setLoading(true);
  }

  static AnimalFormState completeSubmission(AnimalFormState currentState,
      {String? successMessage, String? errorMessage}) {
    if (successMessage != null) {
      return currentState.setSuccess(successMessage);
    } else if (errorMessage != null) {
      return currentState.setError(errorMessage);
    } else {
      return currentState.setLoading(false);
    }
  }

  // State queries
  static bool shouldShowValidationErrors(AnimalFormState state) {
    return state.hasFieldErrors && !state.isValidating;
  }

  static bool shouldShowLoadingIndicator(AnimalFormState state) {
    return state.isLoading || state.isSubmitting;
  }

  static bool shouldShowSuccessMessage(AnimalFormState state) {
    return state.hasSuccess && !state.isLoading;
  }

  static bool shouldShowErrorMessage(AnimalFormState state) {
    return state.hasError && !state.isLoading;
  }

  static bool shouldDisableForm(AnimalFormState state) {
    return isProcessing(state);
  }

  static bool shouldEnableSubmitButton(AnimalFormState state) {
    return canSubmit(state) && !isProcessing(state);
  }

  // Debug helpers
  static String getStateDescription(AnimalFormState state) {
    if (state.isLoading) return 'Carregando...';
    if (state.isValidating) return 'Validando...';
    if (state.isSubmitting) return 'Enviando...';
    if (state.isSuccess) return 'Sucesso!';
    if (state.isError) return 'Erro!';
    if (state.hasFieldErrors) return 'Erros de validação';
    return 'Pronto';
  }

  static Map<String, dynamic> getStateInfo(AnimalFormState state) {
    return {
      'submission_state': state.submissionState.toString(),
      'is_loading': state.isLoading,
      'is_initialized': state.isInitialized,
      'has_changes': state.hasChanges,
      'is_edit_mode': state.isEditMode,
      'error_count': state.fieldErrors.length,
      'can_submit': canSubmit(state),
      'is_processing': isProcessing(state),
      'description': getStateDescription(state),
    };
  }
}
