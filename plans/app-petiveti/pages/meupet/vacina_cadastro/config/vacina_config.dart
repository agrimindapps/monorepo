
/// Centralized configuration for the vacina_cadastro module
/// 
/// Contains all constants, configurations, and settings that were previously
/// scattered across VaccinationConstants and other files.
/// Supports environment-based configuration and runtime customization.
/// 
/// ## Naming Conventions
/// 
/// This module follows these standardized naming conventions:
/// 
/// ### Classes and Enums
/// - **PascalCase**: `VacinaConfig`, `ErrorCategory`, `VacinaFormController`
/// - Domain names in Portuguese: `VacinaVet`, `AnimalSelector`
/// 
/// ### Methods and Variables 
/// - **camelCase**: `formatDate()`, `isLoadingReactive`, `dataAplicacao`
/// - Boolean getters: `isValid`, `hasChanges`, `canRetry`
/// - Action methods: `updateVacina()`, `validateData()`, `resetForm()`
/// 
/// ### Constants
/// - **camelCase for properties**: `maxFormWidth`, `primaryColor`
/// - **SCREAMING_SNAKE_CASE for environment**: `VACINA_ENV`, `VACINA_AUTO_SAVE`
/// - Grouped by purpose: UI constants, validation, business logic
/// 
/// ### Files and Directories
/// - **snake_case**: `vacina_config.dart`, `form_validation_service.dart`
/// - Domain prefix: `vacina_form_*`, `vacina_error_*`
/// 
/// ### UI Components
/// - Widget classes: `VacinaInput`, `DatePicker`, `ActionButtons`
/// - Style classes: `VacinaFormStyles`
/// - Mixin suffix: `FormStateMixin`, `ValidationMixin`
class VacinaConfig {
  // Private constructor to prevent instantiation
  VacinaConfig._();
  
  /// Configuration environment types
  static const String envDevelopment = 'development';
  static const String envProduction = 'production';
  static const String envTesting = 'testing';
  
  /// Current environment (can be set via environment variables)
  static String get currentEnvironment => 
      const String.fromEnvironment('VACINA_ENV', defaultValue: envProduction);
  
  // ========== UI CONSTANTS ==========
  
  /// Form dimensions and sizing
  static const double maxFormWidth = 500.0;
  static const double maxFormHeight = 700.0;
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
  
  /// Vaccine name constraints
  static const int minVaccineNameLength = 2;
  static const int maxVaccineNameLength = 100;
  
  /// Field length constraints  
  static const int maxObservacoesLength = 500;
  
  /// Date constraints
  static const int maxDaysInFuture = 0; // No future dates for application
  static const int maxYearsInPast = 10;
  static const int minDoseIntervalDays = 1;
  static const int maxFutureYearsNextDose = 2;

  // ========== FORM SECTIONS (STANDARDIZED PATTERN) ==========
  
  /// Section titles mapping
  static const Map<String, String> titulosSecoes = {
    'vacina_info': 'Informações da Vacina',
    'datas': 'Datas de Aplicação e Próxima Dose',
    'observacoes': 'Observações',
  };

  /// Section icons mapping  
  static const Map<String, String> iconesSecoes = {
    'vacina_info': 'vaccines',
    'datas': 'calendar_today',
    'observacoes': 'notes',
  };

  // ========== FIELD LABELS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field labels mapping for consistency
  static const Map<String, String> rotulosCampos = {
    'animal': 'Animal *',
    'nomeVacina': 'Nome da Vacina *',
    'dataAplicacao': 'Data de Aplicação *',
    'proximaDose': 'Próxima Dose *',
    'observacoes': 'Observações',
  };

  // ========== FIELD HINTS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field hints mapping for user guidance
  static const Map<String, String> dicasCampos = {
    'animal': 'Selecione o animal',
    'nomeVacina': 'Ex: V8, V10, Raiva, Múltipla',
    'dataAplicacao': 'Data em que a vacina foi aplicada',
    'proximaDose': 'Data prevista para a próxima dose',
    'observacoes': 'Informações adicionais (opcional)',
  };

  // ========== VALIDATION ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Standard validation error messages
  static const String requiredFieldMessage = 'Campo obrigatório';
  static const String invalidVaccineNameMessage = 'Nome da vacina inválido';
  static const String vaccineNameTooShortMessage = 'Nome deve ter pelo menos $minVaccineNameLength caracteres';
  static const String vaccineNameTooLongMessage = 'Nome não pode ter mais de $maxVaccineNameLength caracteres';
  static const String invalidDateMessage = 'Data inválida';
  static const String futureDateMessage = 'Data de aplicação não pode ser no futuro';
  static const String dateTooOldMessage = 'Data não pode ser anterior a $maxYearsInPast anos';
  static const String animalNotSelectedMessage = 'Selecione um animal';
  static const String observationsTooLongMessage = 'Observações muito longas (máx: $maxObservacoesLength caracteres)';
  static const String invalidDateRangeMessage = 'Data da próxima dose deve ser após a aplicação';
  static const String nextDoseTooFarMessage = 'Próxima dose muito distante (máx: $maxFutureYearsNextDose anos)';
  static const String invalidCharactersMessage = 'Contém caracteres inválidos';
  static const String dangerousContentMessage = 'Contém conteúdo potencialmente perigoso';

  // ========== SUCCESS MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Success messages
  static const String msgSuccessSave = 'Vacina cadastrada com sucesso!';
  static const String msgSuccessUpdate = 'Vacina atualizada com sucesso!';
  static const String msgSuccessDelete = 'Vacina removida com sucesso!';

  // ========== GENERAL ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// General error messages
  static const String msgErrorSave = 'Erro ao salvar vacina';
  static const String msgErrorUpdate = 'Erro ao atualizar vacina';
  static const String msgErrorDelete = 'Erro ao excluir vacina';
  static const String msgErrorLoad = 'Erro ao carregar dados';
  static const String msgErrorNetwork = 'Erro de conexão';
  static const String msgErrorValidation = 'Dados inválidos';
  static const String msgErrorDuplicate = 'Esta vacina já foi registrada para este animal';

  // ========== BUTTON TEXTS (STANDARDIZED PATTERN) ==========
  
  /// Button text constants
  static const String buttonTextSave = 'Salvar';
  static const String buttonTextUpdate = 'Atualizar';
  static const String buttonTextCancel = 'Cancelar';
  static const String buttonTextDelete = 'Excluir';

  // ========== FORM TITLES (STANDARDIZED PATTERN) ==========
  
  /// Form titles
  static const String formTitleNew = 'Nova Vacina';
  static const String formTitleEdit = 'Editar Vacina';

  // ========== BUSINESS CONSTANTS ==========
  
  /// Default vaccine intervals (in days)
  static const Map<String, int> intervalosVacinas = {
    'V8': 365,
    'V10': 365,
    'V12': 365,
    'Raiva': 365,
    'Múltipla': 365,
    'Gripe Canina': 180,
    'Giardia': 365,
    'Leishmaniose': 365,
    'Tríplice Felina': 365,
    'Quíntupla Felina': 365,
    'FeLV': 365,
    'FIV': 365,
    'Filhote 1ª dose': 21,
    'Filhote 2ª dose': 21,
    'Filhote 3ª dose': 21,
    'Reforço': 180,
  };

  /// Common vaccine names for suggestions
  static const List<String> vacinasComuns = [
    'V8',
    'V10',
    'V12',
    'Raiva',
    'Múltipla',
    'Gripe Canina',
    'Giardia',
    'Leishmaniose',
    'Tríplice Felina',
    'Quíntupla Felina',
    'FeLV',
    'FIV',
    'Filhote 1ª dose',
    'Filhote 2ª dose',
    'Filhote 3ª dose',
    'Reforço',
  ];

  /// Vaccine categories for classification
  static const Map<String, List<String>> categorias = {
    'Cachorro': ['V8', 'V10', 'V12', 'Raiva', 'Gripe Canina', 'Giardia', 'Leishmaniose'],
    'Gato': ['Tríplice Felina', 'Quíntupla Felina', 'FeLV', 'FIV', 'Raiva'],
    'Filhote': ['Filhote 1ª dose', 'Filhote 2ª dose', 'Filhote 3ª dose'],
    'Reforço': ['Reforço', 'V8', 'V10', 'Raiva'],
  };

  /// Priority levels for vaccines
  static const Map<String, String> prioridades = {
    'Raiva': 'critical',
    'V8': 'high',
    'V10': 'high',
    'V12': 'high',
    'Múltipla': 'high',
    'Tríplice Felina': 'high',
    'Quíntupla Felina': 'high',
    'FeLV': 'medium',
    'FIV': 'medium',
    'Gripe Canina': 'medium',
    'Giardia': 'low',
    'Leishmaniose': 'medium',
  };

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
  static const String regexVaccineName = r'^[a-zA-ZÀ-ÿ0-9\s\-\.ªº°]{2,100}$';
  static const String regexObservations = r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\!\?\(\)]{0,500}$';
  static const String regexDate = r'^\d{2}\/\d{2}\/\d{4}$';

  // ========== CACHE CONFIGURATION ==========
  
  /// Cache keys
  static const String cacheKeyVacinas = 'vacinas_list';
  static const String cacheKeyFormats = 'vacina_formats';
  static const String cacheKeyValidations = 'vacina_validations';
  
  /// Cache durations (in minutes)
  static const int cacheDurationShort = 5;
  static const int cacheDurationMedium = 30;
  static const int cacheDurationLong = 240; // 4 hours
  
  /// Cache sizes
  static const int maxCacheSize = 1000; // Vaccine records can be numerous
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
      const bool.fromEnvironment('VACINA_AUTO_SAVE', defaultValue: true);
  static bool get enableRetry => 
      const bool.fromEnvironment('VACINA_RETRY', defaultValue: true);
  static bool get enableCache => 
      const bool.fromEnvironment('VACINA_CACHE', defaultValue: true);
  static bool get enableAnalytics => 
      const bool.fromEnvironment('VACINA_ANALYTICS', defaultValue: false);

  // ========== SECURITY CONSTANTS ==========
  
  /// Invalid characters for vaccine names and observations
  static const Set<String> invalidCharacters = {
    '<', '>', '"', "'", '/', '&', '`', '\\', ';', '|'
  };
  
  /// Dangerous patterns to detect in input
  static const List<String> dangerousPatterns = [
    '<script',
    'javascript:',
    'data:',
    'vbscript:',
    'onload=',
    'onerror=',
    'onclick=',
    'onmouseover=',
    '<%',
    '%>',
    '<?',
    '?>',
  ];

  // ========== VALIDATION METHODS ==========

  /// Validates vaccine name
  static String? validateNomeVacina(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredFieldMessage;
    }
    
    final trimmed = value.trim();
    if (trimmed.length < minVaccineNameLength) {
      return vaccineNameTooShortMessage;
    }
    if (trimmed.length > maxVaccineNameLength) {
      return vaccineNameTooLongMessage;
    }
    
    // Check for invalid characters
    for (final char in invalidCharacters) {
      if (trimmed.contains(char)) {
        return invalidCharactersMessage;
      }
    }
    
    // Check for dangerous patterns
    final lowerCase = trimmed.toLowerCase();
    for (final pattern in dangerousPatterns) {
      if (lowerCase.contains(pattern.toLowerCase())) {
        return dangerousContentMessage;
      }
    }
    
    // Check regex pattern
    if (!RegExp(regexVaccineName).hasMatch(trimmed)) {
      return invalidVaccineNameMessage;
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

  /// Validates observations
  static String? validateObservacoes(String? value) {
    if (value != null && value.length > maxObservacoesLength) {
      return observationsTooLongMessage;
    }
    
    if (value != null && value.isNotEmpty) {
      // Check for invalid characters
      for (final char in invalidCharacters) {
        if (value.contains(char)) {
          return invalidCharactersMessage;
        }
      }
      
      // Check for dangerous patterns
      final lowerCase = value.toLowerCase();
      for (final pattern in dangerousPatterns) {
        if (lowerCase.contains(pattern.toLowerCase())) {
          return dangerousContentMessage;
        }
      }
      
      // Check regex pattern
      if (!RegExp(regexObservations).hasMatch(value)) {
        return 'Observações contêm caracteres inválidos';
      }
    }
    
    return null;
  }

  /// Validates application date
  static String? validateDataAplicacao(DateTime? value) {
    if (value == null) {
      return requiredFieldMessage;
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return futureDateMessage;
    }
    
    final maxPastDate = now.subtract(const Duration(days: maxYearsInPast * 365));
    if (value.isBefore(maxPastDate)) {
      return dateTooOldMessage;
    }
    
    return null;
  }

  /// Validates next dose date
  static String? validateProximaDose(DateTime? value, DateTime? dataAplicacao) {
    if (value == null) {
      return requiredFieldMessage;
    }
    
    if (dataAplicacao != null && value.isBefore(dataAplicacao)) {
      return invalidDateRangeMessage;
    }
    
    final maxFutureDate = DateTime.now().add(const Duration(days: maxFutureYearsNextDose * 365));
    if (value.isAfter(maxFutureDate)) {
      return nextDoseTooFarMessage;
    }
    
    return null;
  }

  /// Validates all fields at once
  static Map<String, String?> validateAllFields({
    required String animalId,
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'nomeVacina': validateNomeVacina(nomeVacina),
      'dataAplicacao': validateDataAplicacao(dataAplicacao),
      'proximaDose': validateProximaDose(proximaDose, dataAplicacao),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  /// Checks if form is valid
  static bool isFormValid({
    required String animalId,
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
    String? observacoes,
  }) {
    final validation = validateAllFields(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );
    return validation.values.every((error) => error == null);
  }

  // ========== COMPUTED PROPERTIES ==========
  
  /// Format date for display
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Get suggested next dose interval for vaccine
  static int getSuggestedInterval(String vaccineName) {
    final normalizedName = vaccineName.trim();
    
    // Check exact matches first
    if (intervalosVacinas.containsKey(normalizedName)) {
      return intervalosVacinas[normalizedName]!;
    }
    
    // Check partial matches
    for (final entry in intervalosVacinas.entries) {
      if (normalizedName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(normalizedName.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Default interval
    return 365; // 1 year
  }

  /// Get vaccine priority
  static String getVaccinePriority(String vaccineName) {
    final normalizedName = vaccineName.trim();
    
    // Check exact matches first
    if (prioridades.containsKey(normalizedName)) {
      return prioridades[normalizedName]!;
    }
    
    // Check partial matches
    for (final entry in prioridades.entries) {
      if (normalizedName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(normalizedName.toLowerCase())) {
        return entry.value;
      }
    }
    
    return 'medium'; // Default priority
  }

  /// Get vaccine category based on animal type and vaccine name
  static String? getVaccineCategory(String? animalType, String vaccineName) {
    if (animalType == null) return null;
    
    final normalizedName = vaccineName.trim();
    
    for (final entry in categorias.entries) {
      if (entry.value.any((vaccine) => 
          normalizedName.toLowerCase().contains(vaccine.toLowerCase()) ||
          vaccine.toLowerCase().contains(normalizedName.toLowerCase()))) {
        return entry.key;
      }
    }
    
    return null;
  }

  /// Calculate days until next dose
  static int daysUntilNextDose(DateTime nextDoseDate) {
    final now = DateTime.now();
    return nextDoseDate.difference(now).inDays;
  }

  /// Check if vaccine is overdue
  static bool isOverdue(DateTime nextDoseDate) {
    return DateTime.now().isAfter(nextDoseDate);
  }

  /// Get vaccine status based on next dose date
  static String getVaccineStatus(DateTime nextDoseDate) {
    final daysUntil = daysUntilNextDose(nextDoseDate);
    
    if (daysUntil < 0) return 'overdue';
    if (daysUntil <= 7) return 'urgent';
    if (daysUntil <= 30) return 'approaching';
    return 'scheduled';
  }

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
      assert(intervalosVacinas.isNotEmpty, 'intervalosVacinas cannot be empty');
      assert(vacinasComuns.isNotEmpty, 'vacinasComuns cannot be empty');
      assert(maxVaccineNameLength > minVaccineNameLength, 'maxVaccineNameLength must be greater than minVaccineNameLength');
      assert(maxObservacoesLength > 0, 'maxObservacoesLength must be positive');
      
      // Check string constants
      assert(formTitleNew.isNotEmpty, 'formTitleNew cannot be empty');
      assert(buttonTextSave.isNotEmpty, 'buttonTextSave cannot be empty');
      
      return true;
    } catch (e) {
      if (isDebugMode) {
        throw Exception('VacinaConfig validation failed: $e');
      }
      return false;
    }
  }
  
  /// Gets configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': currentEnvironment,
      'debugMode': isDebugMode,
      'vaccineTypesCount': intervalosVacinas.length,
      'commonVaccinesCount': vacinasComuns.length,
      'maxNameLength': maxVaccineNameLength,
      'maxObservationsLength': maxObservacoesLength,
      'featureFlags': {
        'autoSave': enableAutoSave,
        'retry': enableRetry,
        'cache': enableCache,
        'analytics': enableAnalytics,
      },
    };
  }
}