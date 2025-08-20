
/// Centralized configuration for the medicamento_cadastro module
/// 
/// Contains all constants, configurations, and settings that were previously
/// scattered across FormConstants, MedicamentoValidators and other files.
/// Supports environment-based configuration and runtime customization.
/// 
/// ## Naming Conventions
/// 
/// This module follows these standardized naming conventions:
/// 
/// ### Classes and Enums
/// - **PascalCase**: `MedicamentoConfig`, `ErrorCategory`, `MedicamentoFormController`
/// - Domain names in Portuguese: `MedicamentoVet`, `AnimalSelector`
/// 
/// ### Methods and Variables 
/// - **camelCase**: `formatDuration()`, `isLoadingReactive`, `dataInicio`
/// - Boolean getters: `isValid`, `hasChanges`, `canRetry`
/// - Action methods: `updateDosagem()`, `validateDuracao()`, `resetForm()`
/// 
/// ### Constants
/// - **camelCase for properties**: `maxFormWidth`, `primaryColor`
/// - **SCREAMING_SNAKE_CASE for environment**: `MEDICAMENTO_ENV`, `MEDICAMENTO_AUTO_SAVE`
/// - Grouped by purpose: UI constants, validation, business logic
/// 
/// ### Files and Directories
/// - **snake_case**: `medicamento_config.dart`, `form_validation_service.dart`
/// - Domain prefix: `medicamento_form_*`, `medicamento_error_*`
/// 
/// ### UI Components
/// - Widget classes: `DosagemInput`, `DatePicker`, `ActionButtons`
/// - Style classes: `MedicamentoFormStyles`
/// - Mixin suffix: `FormStateMixin`, `ValidationMixin`
class MedicamentoConfig {
  // Private constructor to prevent instantiation
  MedicamentoConfig._();
  
  /// Configuration environment types
  static const String envDevelopment = 'development';
  static const String envProduction = 'production';
  static const String envTesting = 'testing';
  
  /// Current environment (can be set via environment variables)
  static String get currentEnvironment => 
      const String.fromEnvironment('MEDICAMENTO_ENV', defaultValue: envProduction);
  
  // ========== UI CONSTANTS ==========
  
  /// Form dimensions and sizing
  static const double maxFormWidth = 600.0;
  static const double maxFormHeight = 600.0;
  static const double minFormWidth = 300.0;
  static const double minFormHeight = 400.0;
  
  /// Card styling
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  static const double cardMargin = 16.0;
  static const double cardPadding = 20.0;
  
  /// Spacing and layout
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  /// Input field dimensions
  static const double inputFieldHeight = 56.0;
  static const double inputFieldBorderRadius = 8.0;
  static const double inputFieldBorderWidth = 1.0;
  static const double inputFieldFocusedBorderWidth = 2.0;
  
  /// Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 6.0;
  static const double buttonMinWidth = 120.0;
  
  /// Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // ========== VALIDATION CONSTANTS ==========
  
  /// Field length constraints
  static const int minFieldLength = 2;
  static const int maxNomeMedicamentoLength = 100;
  static const int maxDosagemLength = 50;
  static const int maxFrequenciaLength = 50;
  static const int maxDuracaoLength = 50;
  static const int maxObservacoesLength = 500;
  static const int minFrequenciaLength = 3;
  
  /// Date constraints
  static const int maxTreatmentDurationDays = 730; // 2 years
  static const int minTreatmentDurationHours = 1;
  static const int maxDateRangeInPast = 730; // 2 years
  static const int maxDateRangeInFuture = 730; // 2 years

  // ========== FORM SECTIONS (STANDARDIZED PATTERN) ==========
  
  /// Section titles mapping
  static const Map<String, String> titulosSecoes = {
    'medicamento_info': 'Informações do Medicamento',
    'dosagem_freq': 'Dosagem e Frequência',
    'periodo_trat': 'Período do Tratamento',
    'observacoes': 'Observações Adicionais',
  };

  /// Section icons mapping  
  static const Map<String, String> iconesSecoes = {
    'medicamento_info': 'medication',
    'dosagem_freq': 'schedule',
    'periodo_trat': 'date_range',
    'observacoes': 'notes',
  };

  // ========== FIELD LABELS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field labels mapping for consistency
  static const Map<String, String> rotulosCampos = {
    'animal': 'Animal *',
    'nome_medicamento': 'Nome do Medicamento *',
    'dosagem': 'Dosagem *',
    'frequencia': 'Frequência *',
    'duracao': 'Duração *',
    'data_inicio': 'Início do Tratamento *',
    'data_fim': 'Fim do Tratamento *',
    'observacoes': 'Observações',
  };

  // ========== FIELD HINTS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field hints mapping for user guidance
  static const Map<String, String> dicasCampos = {
    'animal': 'Selecione o animal',
    'nome_medicamento': 'Ex: Dipirona, Amoxicilina',
    'dosagem': 'Ex: 500mg, 1 comprimido',
    'frequencia': 'Ex: 8 em 8 horas, 2x ao dia',
    'duracao': 'Ex: 7 dias, 2 semanas',
    'data_inicio': 'dd/mm/aaaa',
    'data_fim': 'dd/mm/aaaa',
    'observacoes': 'Informações adicionais (opcional)',
  };

  // ========== VALIDATION ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Standard validation error messages
  static const String requiredFieldMessage = 'Campo obrigatório';
  static const String invalidDateMessage = 'Data inválida';
  static const String dateTooFutureMessage = 'Data muito distante no futuro';
  static const String dateTooOldMessage = 'Data muito antiga';
  static const String animalNotSelectedMessage = 'Selecione um animal';
  static const String nameTooShortMessage = 'Nome muito curto';
  static const String nameTooLongMessage = 'Nome muito longo';
  static const String dosagemTooLongMessage = 'Dosagem muito longa';
  static const String frequenciaTooShortMessage = 'Frequência muito curta';
  static const String frequenciaTooLongMessage = 'Frequência muito longa';
  static const String duracaoTooLongMessage = 'Duração muito longa';
  static const String observacoesTooLongMessage = 'Observações muito longas';
  static const String invalidCharactersMessage = 'Contém caracteres inválidos';
  static const String treatmentTooShortMessage = 'Duração do tratamento muito curta';
  static const String treatmentTooLongMessage = 'Tratamento não pode exceder 2 anos';
  static const String endDateBeforeStartMessage = 'Data de fim deve ser posterior à data de início';

  // ========== SUCCESS MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Success messages
  static const String msgSuccessSave = 'Medicamento salvo com sucesso!';
  static const String msgSuccessUpdate = 'Medicamento atualizado com sucesso!';
  static const String msgSuccessDelete = 'Medicamento excluído com sucesso!';

  // ========== GENERAL ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// General error messages
  static const String msgErrorSave = 'Erro ao salvar medicamento';
  static const String msgErrorUpdate = 'Erro ao atualizar medicamento';
  static const String msgErrorDelete = 'Erro ao excluir medicamento';
  static const String msgErrorLoad = 'Erro ao carregar dados';
  static const String msgErrorNetwork = 'Erro de conexão';
  static const String msgErrorValidation = 'Dados inválidos';

  // ========== BUTTON TEXTS (STANDARDIZED PATTERN) ==========
  
  /// Button text constants
  static const String buttonTextSave = 'Salvar';
  static const String buttonTextUpdate = 'Atualizar';
  static const String buttonTextCancel = 'Cancelar';
  static const String buttonTextDelete = 'Excluir';

  // ========== FORM TITLES (STANDARDIZED PATTERN) ==========
  
  /// Form titles
  static const String formTitleNew = 'Novo Medicamento';
  static const String formTitleEdit = 'Editar Medicamento';

  // ========== BUSINESS CONSTANTS ==========
  
  /// Common medication types for suggestions
  static const List<String> tiposComuns = [
    'Antibiótico',
    'Anti-inflamatório',
    'Analgésico',
    'Antipirético',
    'Antiparasitário',
    'Vitamina',
    'Suplemento',
    'Pomada',
    'Colírio',
    'Vacina',
    'Outros'
  ];

  /// Common dosage formats
  static const List<String> formatosDosagem = [
    'mg',
    'ml',
    'gotas',
    'comprimido(s)',
    'cápsula(s)',
    'sachê(s)',
    'aplicação(ões)',
  ];

  /// Common frequency patterns
  static const List<String> frequenciasComuns = [
    '1x ao dia',
    '2x ao dia',
    '3x ao dia',
    '8 em 8 horas',
    '12 em 12 horas',
    'A cada 6 horas',
    'Quando necessário',
    'Conforme prescrição',
  ];

  /// Common duration patterns
  static const List<String> duracoesComuns = [
    '3 dias',
    '5 dias',
    '7 dias',
    '10 dias',
    '14 dias',
    '21 dias',
    '1 mês',
    '2 meses',
    '3 meses',
    'Uso contínuo',
  ];

  // ========== TIMING CONSTANTS ==========
  
  /// Animation durations (in milliseconds)
  static const int animationDurationFast = 150;
  static const int animationDurationMedium = 300;
  static const int animationDurationSlow = 500;
  
  /// Network timeouts (in seconds)
  static const int networkTimeoutShort = 10;
  static const int networkTimeoutMedium = 30;
  static const int networkTimeoutLong = 60;
  
  /// Auto-save intervals (in seconds)
  static const int autoSaveInterval = 30;
  static const int autoSaveDebounce = 2;
  
  /// Retry configuration
  static const int maxRetryAttempts = 3;
  static const int retryBaseDelayMs = 1000;
  static const int retryMaxDelayMs = 10000;

  // ========== FORMAT PATTERNS ==========
  
  /// Date formats
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatStorage = 'yyyy-MM-dd';
  static const String dateTimeFormatFull = 'dd/MM/yyyy HH:mm';
  
  /// Regex patterns
  static const String regexMedicamentoName = r'^[a-zA-ZÀ-ÿ0-9\s\-\(\)\.]+$';
  static const String regexDate = r'^\d{2}\/\d{2}\/\d{4}$';

  // ========== CACHE CONFIGURATION ==========
  
  /// Cache keys
  static const String cacheKeyMedicamentos = 'medicamentos_list';
  static const String cacheKeyFormats = 'medicamento_formats';
  static const String cacheKeyValidations = 'medicamento_validations';
  
  /// Cache durations (in minutes)
  static const int cacheDurationShort = 5;
  static const int cacheDurationMedium = 30;
  static const int cacheDurationLong = 240; // 4 hours
  
  /// Cache sizes
  static const int maxCacheSize = 100;
  static const int maxCacheMemoryMB = 10;

  // ========== DEVELOPMENT/DEBUG CONSTANTS ==========
  
  /// Debug settings
  static bool get isDebugMode => currentEnvironment == envDevelopment;
  static bool get isTestMode => currentEnvironment == envTesting;
  static bool get isProductionMode => currentEnvironment == envProduction;
  
  /// Logging levels
  static const String logLevelDebug = 'DEBUG';
  static const String logLevelInfo = 'INFO';
  static const String logLevelWarning = 'WARNING';
  static const String logLevelError = 'ERROR';
  
  /// Feature flags
  static bool get enableAutoSave => 
      const bool.fromEnvironment('MEDICAMENTO_AUTO_SAVE', defaultValue: true);
  static bool get enableRetry => 
      const bool.fromEnvironment('MEDICAMENTO_RETRY', defaultValue: true);
  static bool get enableCache => 
      const bool.fromEnvironment('MEDICAMENTO_CACHE', defaultValue: true);
  static bool get enableAnalytics => 
      const bool.fromEnvironment('MEDICAMENTO_ANALYTICS', defaultValue: false);

  // ========== VALIDATION METHODS ==========

  /// Validates medication name
  static String? validateNomeMedicamento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredFieldMessage;
    }
    final trimmed = value.trim();
    if (trimmed.length < minFieldLength) {
      return nameTooShortMessage;
    }
    if (trimmed.length > maxNomeMedicamentoLength) {
      return nameTooLongMessage;
    }
    if (!RegExp(regexMedicamentoName).hasMatch(trimmed)) {
      return invalidCharactersMessage;
    }
    return null;
  }

  /// Validates dosage
  static String? validateDosagem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredFieldMessage;
    }
    final trimmed = value.trim();
    if (trimmed.length > maxDosagemLength) {
      return dosagemTooLongMessage;
    }
    return null;
  }

  /// Validates frequency
  static String? validateFrequencia(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredFieldMessage;
    }
    final trimmed = value.trim();
    if (trimmed.length < minFrequenciaLength) {
      return frequenciaTooShortMessage;
    }
    if (trimmed.length > maxFrequenciaLength) {
      return frequenciaTooLongMessage;
    }
    return null;
  }

  /// Validates duration
  static String? validateDuracao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredFieldMessage;
    }
    final trimmed = value.trim();
    if (trimmed.length > maxDuracaoLength) {
      return duracaoTooLongMessage;
    }
    return null;
  }

  /// Validates observations
  static String? validateObservacoes(String? value) {
    if (value != null && value.length > maxObservacoesLength) {
      return observacoesTooLongMessage;
    }
    return null;
  }

  /// Validates animal ID
  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return animalNotSelectedMessage;
    }
    return null;
  }

  /// Validates start date
  static String? validateDataInicio(DateTime? value) {
    if (value == null) {
      return requiredFieldMessage;
    }
    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: maxDateRangeInPast));
    final maxDate = now.add(const Duration(days: maxDateRangeInFuture));
    
    if (value.isBefore(minDate)) {
      return dateTooOldMessage;
    }
    if (value.isAfter(maxDate)) {
      return dateTooFutureMessage;
    }
    return null;
  }

  /// Validates end date
  static String? validateDataFim(DateTime? inicio, DateTime? fim) {
    if (fim == null) {
      return requiredFieldMessage;
    }
    if (inicio != null) {
      if (fim.isBefore(inicio)) {
        return endDateBeforeStartMessage;
      }
      final maxDuration = inicio.add(const Duration(days: maxTreatmentDurationDays));
      if (fim.isAfter(maxDuration)) {
        return treatmentTooLongMessage;
      }
      if (fim.difference(inicio).inHours < minTreatmentDurationHours) {
        return treatmentTooShortMessage;
      }
    }
    return null;
  }

  /// Validates all fields at once
  static Map<String, String?> validateAllFields({
    required String animalId,
    required String nomeMedicamento,
    required String dosagem,
    required String frequencia,
    required String duracao,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'nomeMedicamento': validateNomeMedicamento(nomeMedicamento),
      'dosagem': validateDosagem(dosagem),
      'frequencia': validateFrequencia(frequencia),
      'duracao': validateDuracao(duracao),
      'dataInicio': validateDataInicio(dataInicio),
      'dataFim': validateDataFim(dataInicio, dataFim),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  /// Checks if form is valid
  static bool isFormValid({
    required String animalId,
    required String nomeMedicamento,
    required String dosagem,
    required String frequencia,
    required String duracao,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? observacoes,
  }) {
    final validation = validateAllFields(
      animalId: animalId,
      nomeMedicamento: nomeMedicamento,
      dosagem: dosagem,
      frequencia: frequencia,
      duracao: duracao,
      dataInicio: dataInicio,
      dataFim: dataFim,
      observacoes: observacoes,
    );
    return validation.values.every((error) => error == null);
  }

  // ========== COMPUTED PROPERTIES ==========
  
  /// Get animation duration based on current environment
  static Duration getAnimationDuration({bool fast = false}) {
    if (isTestMode) return Duration.zero; // No animations in tests
    return Duration(milliseconds: fast ? animationDurationFast : animationDurationMedium);
  }
  
  /// Get network timeout based on operation type
  static Duration getNetworkTimeout({bool isLongRunning = false}) {
    final seconds = isLongRunning ? networkTimeoutLong : networkTimeoutMedium;
    return Duration(seconds: seconds);
  }
  
  /// Get retry configuration
  static Map<String, int> getRetryConfig() {
    return {
      'maxAttempts': maxRetryAttempts,
      'baseDelay': retryBaseDelayMs,
      'maxDelay': retryMaxDelayMs,
    };
  }

  // ========== CONFIGURATION VALIDATION ==========
  
  /// Validates that all required configuration is present
  static bool validateConfiguration() {
    try {
      // Check required constants
      assert(tiposComuns.isNotEmpty, 'tiposComuns cannot be empty');
      assert(maxNomeMedicamentoLength > minFieldLength, 'maxNomeMedicamentoLength must be greater than minFieldLength');
      assert(maxTreatmentDurationDays > 0, 'maxTreatmentDurationDays must be positive');
      assert(minTreatmentDurationHours > 0, 'minTreatmentDurationHours must be positive');
      
      // Check string constants
      assert(formTitleNew.isNotEmpty, 'formTitleNew cannot be empty');
      assert(buttonTextSave.isNotEmpty, 'buttonTextSave cannot be empty');
      
      return true;
    } catch (e) {
      if (isDebugMode) {
        throw Exception('MedicamentoConfig validation failed: $e');
      }
      return false;
    }
  }
  
  /// Gets configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': currentEnvironment,
      'debugMode': isDebugMode,
      'tiposCount': tiposComuns.length,
      'maxNameLength': maxNomeMedicamentoLength,
      'maxTreatmentDays': maxTreatmentDurationDays,
      'featureFlags': {
        'autoSave': enableAutoSave,
        'retry': enableRetry,
        'cache': enableCache,
        'analytics': enableAnalytics,
      },
    };
  }
}