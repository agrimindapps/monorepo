/// Form state service for managing state transitions (standardized pattern)
/// 
/// Provides centralized logic for managing form state transitions
/// following the standardized pattern from animal_cadastro module.
library;

// Project imports:
import '../config/peso_config.dart';
import '../models/peso_form_state.dart';

class FormStateService {
  FormStateService._();

  /// Transition state to validating
  static PesoFormState transitionToValidating(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to loading
  static PesoFormState transitionToLoading(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to success
  static PesoFormState transitionToSuccess(
    PesoFormState currentState, 
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
  static PesoFormState transitionToError(
    PesoFormState currentState, 
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
  static PesoFormState transitionToIdle(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Reset state to initial state
  static PesoFormState resetToInitial() {
    return PesoFormState.initial();
  }

  /// Set field error while maintaining current submission state
  static PesoFormState setFieldError(
    PesoFormState currentState,
    String fieldName,
    String? error
  ) {
    return currentState.setFieldError(fieldName, error);
  }

  /// Clear all field errors while maintaining current submission state
  static PesoFormState clearAllFieldErrors(PesoFormState currentState) {
    return currentState.copyWith(
      fieldErrors: {},
    );
  }

  /// Set multiple field errors at once
  static PesoFormState setMultipleFieldErrors(
    PesoFormState currentState,
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
        return 'Salvando peso...';
      case FormSubmissionState.success:
        return PesoConfig.msgSuccessSave;
      case FormSubmissionState.error:
        return PesoConfig.msgErrorSave;
    }
  }

  /// Check if form can be submitted in current state
  static bool canSubmit(PesoFormState state) {
    return state.submissionState == FormSubmissionState.idle &&
           state.isReady &&
           !state.hasFieldErrors &&
           state.hasChanges;
  }

  /// Check if form is busy (loading or validating)
  static bool isBusy(PesoFormState state) {
    return [
      FormSubmissionState.validating,
      FormSubmissionState.loading
    ].contains(state.submissionState);
  }

  /// Check if form has completed successfully
  static bool isSuccess(PesoFormState state) {
    return state.submissionState == FormSubmissionState.success;
  }

  /// Check if form has error
  static bool hasError(PesoFormState state) {
    return state.submissionState == FormSubmissionState.error ||
           state.hasError ||
           state.hasFieldErrors;
  }

  /// Get appropriate button text based on state
  static String getSubmitButtonText(PesoFormState state, {bool isEditing = false}) {
    switch (state.submissionState) {
      case FormSubmissionState.validating:
        return 'Validando...';
      case FormSubmissionState.loading:
        return isEditing ? 'Atualizando...' : 'Salvando...';
      default:
        return isEditing ? PesoConfig.buttonTextUpdate : PesoConfig.buttonTextSave;
    }
  }

  /// Create a state with validation errors
  static PesoFormState createValidationErrorState(
    PesoFormState currentState,
    Map<String, String> fieldErrors
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      fieldErrors: fieldErrors,
      errorMessage: PesoConfig.msgErrorValidation,
    );
  }

  /// Create state for form initialization
  static PesoFormState createInitializedState() {
    return const PesoFormState(
      isInitialized: true,
      submissionState: FormSubmissionState.idle,
    );
  }

  /// Handle form changes (mark as dirty)
  static PesoFormState handleFormChanges(PesoFormState currentState) {
    if (!currentState.hasChanges && currentState.submissionState == FormSubmissionState.idle) {
      return currentState.copyWith(hasChanges: true);
    }
    return currentState;
  }

  /// Validate form fields and return updated state with errors
  static PesoFormState validateFormFields(
    PesoFormState currentState,
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

  /// Create state for weight validation
  static PesoFormState validateWeight(
    PesoFormState currentState,
    double? weight,
    {String? animalType, bool isFilhote = false}
  ) {
    final validationError = animalType != null
        ? PesoConfig.validatePesoForAnimalType(weight ?? 0.0, animalType, isFilhote: isFilhote)
        : PesoConfig.validatePeso(weight);
    
    if (validationError != null) {
      return currentState.setFieldError('peso', validationError);
    }

    return currentState.clearFieldError('peso');
  }

  /// Create state for date validation
  static PesoFormState validateDate(
    PesoFormState currentState,
    DateTime? date
  ) {
    final validationError = PesoConfig.validateDataPesagem(date);
    
    if (validationError != null) {
      return currentState.setFieldError('dataPesagem', validationError);
    }

    return currentState.clearFieldError('dataPesagem');
  }

  /// Create state for animal validation
  static PesoFormState validateAnimal(
    PesoFormState currentState,
    String? animalId
  ) {
    final validationError = PesoConfig.validateAnimalId(animalId);
    
    if (validationError != null) {
      return currentState.setFieldError('animalId', validationError);
    }

    return currentState.clearFieldError('animalId');
  }

  /// Create state for observations validation
  static PesoFormState validateObservations(
    PesoFormState currentState,
    String? observations
  ) {
    final validationError = PesoConfig.validateObservacoes(observations);
    
    if (validationError != null) {
      return currentState.setFieldError('observacoes', validationError);
    }

    return currentState.clearFieldError('observacoes');
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

  /// Create state for weight analysis
  static PesoFormState createAnalysisState(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Analisando peso...',
    );
  }

  /// Handle weight analysis success with insights
  static PesoFormState handleAnalysisSuccess(
    PesoFormState currentState,
    Map<String, dynamic> analysis
  ) {
    final category = analysis['category'] ?? 'Normal';
    final progress = analysis['progress'] ?? {};
    
    String message = 'Peso registrado! Categoria: $category';
    if (progress['status'] == 'ganho') {
      message += ' - Ganho de ${progress['diferenca']?.toStringAsFixed(2)}kg';
    } else if (progress['status'] == 'perda') {
      message += ' - Perda de ${progress['diferenca']?.abs().toStringAsFixed(2)}kg';
    }

    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: message,
    );
  }

  /// Create state for CSV export operation
  static PesoFormState createExportState(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      successMessage: 'Preparando exportação de pesos...',
    );
  }

  /// Handle CSV export success
  static PesoFormState handleExportSuccess(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      successMessage: 'Dados de peso exportados com sucesso!',
    );
  }

  /// Handle CSV export error
  static PesoFormState handleExportError(
    PesoFormState currentState,
    String error
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      errorMessage: 'Erro ao exportar dados: $error',
    );
  }

  /// Create state for weight chart generation
  static PesoFormState createChartGenerationState(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Gerando gráfico de peso...',
    );
  }

  /// Handle weight chart generation success
  static PesoFormState handleChartGenerationSuccess(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: 'Gráfico gerado com sucesso!',
    );
  }

  /// Create state for weight goal setting
  static PesoFormState createGoalSettingState(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Definindo meta de peso...',
    );
  }

  /// Handle weight goal setting success
  static PesoFormState handleGoalSettingSuccess(
    PesoFormState currentState,
    double targetWeight
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: 'Meta de peso definida: ${PesoConfig.formatPeso(targetWeight)}',
    );
  }

  /// Create state for weight comparison
  static PesoFormState createComparisonState(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Comparando pesos...',
    );
  }

  /// Handle weight comparison success
  static PesoFormState handleComparisonSuccess(
    PesoFormState currentState,
    Map<String, dynamic> comparison
  ) {
    final trend = comparison['trend'] ?? 'estável';
    final period = comparison['period'] ?? 'período';
    
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: 'Tendência $trend no $period',
    );
  }

  /// Validate weight against ideal ranges for animal
  static PesoFormState validateWeightAgainstIdeal(
    PesoFormState currentState,
    double weight,
    double idealWeight
  ) {
    final category = PesoConfig.getWeightCategory(weight, idealWeight);
    
    if (category == 'Obesidade grau I' || category == 'Obesidade grau II') {
      return currentState.setFieldError('peso', 'Peso indica $category - consulte veterinário');
    } else if (category == 'Abaixo do peso') {
      return currentState.setFieldError('peso', 'Peso abaixo do ideal - consulte veterinário');
    }

    return currentState.clearFieldError('peso');
  }

  /// Create state for weight trend analysis
  static PesoFormState createTrendAnalysisState(PesoFormState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Analisando tendência de peso...',
    );
  }

  /// Handle weight trend analysis success
  static PesoFormState handleTrendAnalysisSuccess(
    PesoFormState currentState,
    String trendDescription
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: trendDescription,
    );
  }
}
