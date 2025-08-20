/// Form state service for managing state transitions (standardized pattern)
/// 
/// Provides centralized logic for managing form state transitions
/// following the standardized pattern from animal_cadastro module.
library;

// Project imports:
import '../config/vacina_config.dart';
import '../models/vacina_cadastro_state.dart';

class FormStateService {
  FormStateService._();

  /// Transition state to validating
  static VacinaCadastroState transitionToValidating(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to loading
  static VacinaCadastroState transitionToLoading(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Transition state to success
  static VacinaCadastroState transitionToSuccess(
    VacinaCadastroState currentState, 
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
  static VacinaCadastroState transitionToError(
    VacinaCadastroState currentState, 
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
  static VacinaCadastroState transitionToIdle(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.idle,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Reset state to initial state
  static VacinaCadastroState resetToInitial() {
    return VacinaCadastroState.initial();
  }

  /// Set field error while maintaining current submission state
  static VacinaCadastroState setFieldError(
    VacinaCadastroState currentState,
    String fieldName,
    String? error
  ) {
    return currentState.setFieldError(fieldName, error);
  }

  /// Clear all field errors while maintaining current submission state
  static VacinaCadastroState clearAllFieldErrors(VacinaCadastroState currentState) {
    return currentState.copyWith(
      fieldErrors: {},
    );
  }

  /// Set multiple field errors at once
  static VacinaCadastroState setMultipleFieldErrors(
    VacinaCadastroState currentState,
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
        return 'Salvando vacina...';
      case FormSubmissionState.success:
        return VacinaConfig.msgSuccessSave;
      case FormSubmissionState.error:
        return VacinaConfig.msgErrorSave;
    }
  }

  /// Check if form can be submitted in current state
  static bool canSubmit(VacinaCadastroState state) {
    return state.submissionState == FormSubmissionState.idle &&
           state.isReady &&
           !state.hasFieldErrors &&
           state.hasChanges;
  }

  /// Check if form is busy (loading or validating)
  static bool isBusy(VacinaCadastroState state) {
    return [
      FormSubmissionState.validating,
      FormSubmissionState.loading
    ].contains(state.submissionState);
  }

  /// Check if form has completed successfully
  static bool isSuccess(VacinaCadastroState state) {
    return state.submissionState == FormSubmissionState.success;
  }

  /// Check if form has error
  static bool hasError(VacinaCadastroState state) {
    return state.submissionState == FormSubmissionState.error ||
           state.hasError ||
           state.hasFieldErrors;
  }

  /// Get appropriate button text based on state
  static String getSubmitButtonText(VacinaCadastroState state, {bool isEditing = false}) {
    switch (state.submissionState) {
      case FormSubmissionState.validating:
        return 'Validando...';
      case FormSubmissionState.loading:
        return isEditing ? 'Atualizando...' : 'Salvando...';
      default:
        return isEditing ? VacinaConfig.buttonTextUpdate : VacinaConfig.buttonTextSave;
    }
  }

  /// Create a state with validation errors
  static VacinaCadastroState createValidationErrorState(
    VacinaCadastroState currentState,
    Map<String, String> fieldErrors
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      isSubmitting: false,
      fieldErrors: fieldErrors,
      errorMessage: VacinaConfig.msgErrorValidation,
    );
  }

  /// Create state for form initialization
  static VacinaCadastroState createInitializedState() {
    final now = DateTime.now();
    return VacinaCadastroState(
      dataAplicacao: now.millisecondsSinceEpoch,
      proximaDose: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
      isInitialized: true,
      submissionState: FormSubmissionState.idle,
    );
  }

  /// Handle form changes (mark as dirty)
  static VacinaCadastroState handleFormChanges(VacinaCadastroState currentState) {
    if (!currentState.hasChanges && currentState.submissionState == FormSubmissionState.idle) {
      return currentState.copyWith(hasChanges: true);
    }
    return currentState;
  }

  /// Validate form fields and return updated state with errors
  static VacinaCadastroState validateFormFields(
    VacinaCadastroState currentState,
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

  /// Create state for vaccine name validation
  static VacinaCadastroState validateVaccineName(
    VacinaCadastroState currentState,
    String? vaccineName
  ) {
    final validationError = VacinaConfig.validateNomeVacina(vaccineName);
    
    if (validationError != null) {
      return currentState.setFieldError('nomeVacina', validationError);
    }

    return currentState.clearFieldError('nomeVacina');
  }

  /// Create state for application date validation
  static VacinaCadastroState validateApplicationDate(
    VacinaCadastroState currentState,
    DateTime? date
  ) {
    final validationError = VacinaConfig.validateDataAplicacao(date);
    
    if (validationError != null) {
      return currentState.setFieldError('dataAplicacao', validationError);
    }

    return currentState.clearFieldError('dataAplicacao');
  }

  /// Create state for next dose date validation
  static VacinaCadastroState validateNextDoseDate(
    VacinaCadastroState currentState,
    DateTime? nextDoseDate,
    DateTime? applicationDate
  ) {
    final validationError = VacinaConfig.validateProximaDose(nextDoseDate, applicationDate);
    
    if (validationError != null) {
      return currentState.setFieldError('proximaDose', validationError);
    }

    return currentState.clearFieldError('proximaDose');
  }

  /// Create state for animal validation
  static VacinaCadastroState validateAnimal(
    VacinaCadastroState currentState,
    String? animalId
  ) {
    final validationError = VacinaConfig.validateAnimalId(animalId);
    
    if (validationError != null) {
      return currentState.setFieldError('animalId', validationError);
    }

    return currentState.clearFieldError('animalId');
  }

  /// Create state for observations validation
  static VacinaCadastroState validateObservations(
    VacinaCadastroState currentState,
    String? observations
  ) {
    final validationError = VacinaConfig.validateObservacoes(observations);
    
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

  /// Create state for vaccine suggestion operation
  static VacinaCadastroState createSuggestionState(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Buscando sugestões de vacinas...',
    );
  }

  /// Handle vaccine suggestion success
  static VacinaCadastroState handleSuggestionSuccess(
    VacinaCadastroState currentState,
    List<String> suggestions
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: 'Encontradas ${suggestions.length} sugestões de vacinas',
    );
  }

  /// Create state for next dose calculation
  static VacinaCadastroState createNextDoseCalculationState(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Calculando próxima dose...',
    );
  }

  /// Handle next dose calculation success
  static VacinaCadastroState handleNextDoseCalculationSuccess(
    VacinaCadastroState currentState,
    DateTime suggestedDate
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      proximaDose: suggestedDate.millisecondsSinceEpoch,
      successMessage: 'Próxima dose sugerida: ${VacinaConfig.formatDate(suggestedDate)}',
    );
  }

  /// Create state for vaccine conflict check
  static VacinaCadastroState createConflictCheckState(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Verificando conflitos...',
    );
  }

  /// Handle vaccine conflict check success
  static VacinaCadastroState handleConflictCheckSuccess(
    VacinaCadastroState currentState,
    bool hasConflicts,
    List<String> conflicts
  ) {
    if (hasConflicts) {
      return currentState.copyWith(
        submissionState: FormSubmissionState.error,
        errorMessage: 'Conflitos encontrados: ${conflicts.join(', ')}',
      );
    }

    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: 'Nenhum conflito encontrado',
    );
  }

  /// Create state for vaccine schedule generation
  static VacinaCadastroState createScheduleGenerationState(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      successMessage: 'Gerando cronograma de vacinação...',
    );
  }

  /// Handle vaccine schedule generation success
  static VacinaCadastroState handleScheduleGenerationSuccess(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      successMessage: 'Cronograma de vacinação gerado com sucesso!',
    );
  }

  /// Create state for CSV export operation
  static VacinaCadastroState createExportState(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
      successMessage: 'Preparando exportação de vacinas...',
    );
  }

  /// Handle CSV export success
  static VacinaCadastroState handleExportSuccess(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      isLoading: false,
      successMessage: 'Dados de vacinação exportados com sucesso!',
    );
  }

  /// Handle CSV export error
  static VacinaCadastroState handleExportError(
    VacinaCadastroState currentState,
    String error
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.error,
      isLoading: false,
      errorMessage: 'Erro ao exportar dados: $error',
    );
  }

  /// Validate vaccine against existing vaccinations for conflicts
  static VacinaCadastroState validateVaccineConflicts(
    VacinaCadastroState currentState,
    String vaccineName,
    DateTime applicationDate,
    List<String> existingVaccines
  ) {
    // Check for same vaccine within minimum interval
    final conflictingVaccines = existingVaccines.where((existing) {
      return existing.toLowerCase() == vaccineName.toLowerCase();
    }).toList();

    if (conflictingVaccines.isNotEmpty) {
      return currentState.setFieldError('nomeVacina', 'Esta vacina já foi aplicada recentemente');
    }

    return currentState.clearFieldError('nomeVacina');
  }

  /// Create state for vaccine reminder setup
  static VacinaCadastroState createReminderSetupState(VacinaCadastroState currentState) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.validating,
      successMessage: 'Configurando lembrete...',
    );
  }

  /// Handle vaccine reminder setup success
  static VacinaCadastroState handleReminderSetupSuccess(
    VacinaCadastroState currentState,
    DateTime reminderDate
  ) {
    return currentState.copyWith(
      submissionState: FormSubmissionState.success,
      successMessage: 'Lembrete configurado para ${VacinaConfig.formatDate(reminderDate)}',
    );
  }

  /// Get vaccine priority indicator
  static String getVaccinePriorityIndicator(VacinaCadastroState state) {
    if (state.nomeVacina.isEmpty) return '';
    
    final priority = VacinaConfig.getVaccinePriority(state.nomeVacina);
    switch (priority) {
      case 'critical':
        return '🚨 Crítica';
      case 'high':
        return '🔴 Alta';
      case 'medium':
        return '🟡 Média';
      case 'low':
        return '🟢 Baixa';
      default:
        return '';
    }
  }

  /// Get vaccine status indicator based on next dose date
  static String getVaccineStatusIndicator(VacinaCadastroState state) {
    final nextDoseDate = DateTime.fromMillisecondsSinceEpoch(state.proximaDose);
    final status = VacinaConfig.getVaccineStatus(nextDoseDate);
    
    switch (status) {
      case 'overdue':
        return '⚠️ Atrasada';
      case 'urgent':
        return '🟠 Urgente (7 dias)';
      case 'approaching':
        return '🟡 Próxima (30 dias)';
      case 'scheduled':
        return '✅ Agendada';
      default:
        return '';
    }
  }
}
