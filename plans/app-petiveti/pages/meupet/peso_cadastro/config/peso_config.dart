
/// Centralized configuration for the peso_cadastro module
/// 
/// Contains all constants, configurations, and settings that were previously
/// scattered across FormConstants, PesoValidators and other files.
/// Supports environment-based configuration and runtime customization.
/// 
/// ## Naming Conventions
/// 
/// This module follows these standardized naming conventions:
/// 
/// ### Classes and Enums
/// - **PascalCase**: `PesoConfig`, `ErrorCategory`, `PesoFormController`
/// - Domain names in Portuguese: `PesoAnimal`, `AnimalSelector`
/// 
/// ### Methods and Variables 
/// - **camelCase**: `formatPeso()`, `isLoadingReactive`, `dataPesagem`
/// - Boolean getters: `isValid`, `hasChanges`, `canRetry`
/// - Action methods: `updatePeso()`, `validateData()`, `resetForm()`
/// 
/// ### Constants
/// - **camelCase for properties**: `maxFormWidth`, `primaryColor`
/// - **SCREAMING_SNAKE_CASE for environment**: `PESO_ENV`, `PESO_AUTO_SAVE`
/// - Grouped by purpose: UI constants, validation, business logic
/// 
/// ### Files and Directories
/// - **snake_case**: `peso_config.dart`, `form_validation_service.dart`
/// - Domain prefix: `peso_form_*`, `peso_error_*`
/// 
/// ### UI Components
/// - Widget classes: `PesoInput`, `DatePicker`, `ActionButtons`
/// - Style classes: `PesoFormStyles`
/// - Mixin suffix: `FormStateMixin`, `ValidationMixin`
class PesoConfig {
  // Private constructor to prevent instantiation
  PesoConfig._();
  
  /// Configuration environment types
  static const String envDevelopment = 'development';
  static const String envProduction = 'production';
  static const String envTesting = 'testing';
  
  /// Current environment (can be set via environment variables)
  static String get currentEnvironment => 
      const String.fromEnvironment('PESO_ENV', defaultValue: envProduction);
  
  // ========== UI CONSTANTS ==========
  
  /// Form dimensions and sizing
  static const double maxFormWidth = 400.0;
  static const double maxFormHeight = 600.0;
  static const double minFormWidth = 300.0;
  static const double minFormHeight = 300.0;
  
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
  
  /// Weight constraints
  static const double minPeso = 0.01;
  static const double maxPeso = 500.0;
  static const int pesoDecimalPlaces = 2;
  
  /// Field length constraints  
  static const int maxObservacoesLength = 500;
  
  /// Date constraints
  static const int maxDaysInPast = 365; // 1 year
  static const int maxDaysInFuture = 0; // No future dates allowed

  // ========== FORM SECTIONS (STANDARDIZED PATTERN) ==========
  
  /// Section titles mapping
  static const Map<String, String> titulosSecoes = {
    'peso_info': 'Informações do Peso',
    'data_pesagem': 'Data da Pesagem',
    'observacoes': 'Observações',
  };

  /// Section icons mapping  
  static const Map<String, String> iconesSecoes = {
    'peso_info': 'monitor_weight',
    'data_pesagem': 'calendar_today',
    'observacoes': 'notes',
  };

  // ========== FIELD LABELS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field labels mapping for consistency
  static const Map<String, String> rotulosCampos = {
    'animal': 'Animal *',
    'peso': 'Peso (kg) *',
    'data_pesagem': 'Data da Pesagem *',
    'observacoes': 'Observações',
  };

  // ========== FIELD HINTS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field hints mapping for user guidance
  static const Map<String, String> dicasCampos = {
    'animal': 'Selecione o animal',
    'peso': 'Ex: 5.2, 12.5, 25.0',
    'data_pesagem': 'dd/mm/aaaa',
    'observacoes': 'Informações adicionais (opcional)',
  };

  // ========== VALIDATION ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Standard validation error messages
  static const String requiredFieldMessage = 'Campo obrigatório';
  static const String invalidWeightMessage = 'Peso inválido';
  static const String weightTooLowMessage = 'Peso deve ser maior que $minPeso kg';
  static const String weightTooHighMessage = 'Peso deve ser menor que $maxPeso kg';
  static const String invalidDateMessage = 'Data inválida';
  static const String futureDateMessage = 'Data não pode ser no futuro';
  static const String dateTooOldMessage = 'Data não pode ser anterior a 1 ano';
  static const String animalNotSelectedMessage = 'Selecione um animal';
  static const String observationsTooLongMessage = 'Observações muito longas';

  // ========== SUCCESS MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Success messages
  static const String msgSuccessSave = 'Peso salvo com sucesso!';
  static const String msgSuccessUpdate = 'Peso atualizado com sucesso!';
  static const String msgSuccessDelete = 'Peso excluído com sucesso!';

  // ========== GENERAL ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// General error messages
  static const String msgErrorSave = 'Erro ao salvar peso';
  static const String msgErrorUpdate = 'Erro ao atualizar peso';
  static const String msgErrorDelete = 'Erro ao excluir peso';
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
  static const String formTitleNew = 'Novo Registro de Peso';
  static const String formTitleEdit = 'Editar Peso';

  // ========== BUSINESS CONSTANTS ==========
  
  /// Weight ranges by animal type (in kg)
  static const Map<String, Map<String, double>> pesosPorEspecie = {
    'Cão': {
      'min': 0.5,
      'max': 100.0,
      'filhote_min': 0.1,
      'filhote_max': 10.0,
    },
    'Gato': {
      'min': 0.5,
      'max': 15.0,
      'filhote_min': 0.1,
      'filhote_max': 2.0,
    },
    'Pássaro': {
      'min': 0.01,
      'max': 5.0,
      'filhote_min': 0.005,
      'filhote_max': 1.0,
    },
    'Peixe': {
      'min': 0.001,
      'max': 50.0,
      'filhote_min': 0.001,
      'filhote_max': 5.0,
    },
    'Coelho': {
      'min': 0.3,
      'max': 8.0,
      'filhote_min': 0.05,
      'filhote_max': 2.0,
    },
    'Hamster': {
      'min': 0.02,
      'max': 0.2,
      'filhote_min': 0.005,
      'filhote_max': 0.05,
    },
    'Tartaruga': {
      'min': 0.01,
      'max': 200.0,
      'filhote_min': 0.005,
      'filhote_max': 5.0,
    },
  };

  /// Weight categories for analysis
  static const List<String> categoriasPeso = [
    'Abaixo do peso',
    'Peso ideal',
    'Sobrepeso',
    'Obesidade grau I',
    'Obesidade grau II',
  ];

  /// Common weight units
  static const List<String> unidadesPeso = [
    'kg',
    'g',
    'lb',
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
  
  /// Weight formats
  static const String weightUnit = 'kg';
  static const String decimalSeparator = ',';
  static const String thousandSeparator = '.';
  
  /// Regex patterns
  static const String regexWeight = r'^\d+[\,\.]?\d{0,2}$';
  static const String regexDate = r'^\d{2}\/\d{2}\/\d{4}$';

  // ========== CACHE CONFIGURATION ==========
  
  /// Cache keys
  static const String cacheKeyPesos = 'pesos_list';
  static const String cacheKeyFormats = 'peso_formats';
  static const String cacheKeyValidations = 'peso_validations';
  
  /// Cache durations (in minutes)
  static const int cacheDurationShort = 5;
  static const int cacheDurationMedium = 30;
  static const int cacheDurationLong = 240; // 4 hours
  
  /// Cache sizes
  static const int maxCacheSize = 500; // Weight records can be numerous
  static const int maxCacheMemoryMB = 5;

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
      const bool.fromEnvironment('PESO_AUTO_SAVE', defaultValue: true);
  static bool get enableRetry => 
      const bool.fromEnvironment('PESO_RETRY', defaultValue: true);
  static bool get enableCache => 
      const bool.fromEnvironment('PESO_CACHE', defaultValue: true);
  static bool get enableAnalytics => 
      const bool.fromEnvironment('PESO_ANALYTICS', defaultValue: false);

  // ========== VALIDATION METHODS ==========

  /// Validates weight value
  static String? validatePeso(double? value) {
    if (value == null) {
      return requiredFieldMessage;
    }
    if (value <= 0) {
      return 'O peso deve ser maior que zero';
    }
    if (value < minPeso) {
      return weightTooLowMessage;
    }
    if (value > maxPeso) {
      return weightTooHighMessage;
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
    return null;
  }

  /// Validates weighing date
  static String? validateDataPesagem(DateTime? value) {
    if (value == null) {
      return requiredFieldMessage;
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return futureDateMessage;
    }
    final maxPastDate = now.subtract(const Duration(days: maxDaysInPast));
    if (value.isBefore(maxPastDate)) {
      return dateTooOldMessage;
    }
    return null;
  }

  /// Validates weight for specific animal type
  static String? validatePesoForAnimalType(double peso, String animalType, {bool isFilhote = false}) {
    final ranges = pesosPorEspecie[animalType];
    if (ranges == null) {
      return validatePeso(peso); // Fallback to general validation
    }

    final minKey = isFilhote ? 'filhote_min' : 'min';
    final maxKey = isFilhote ? 'filhote_max' : 'max';
    final minWeight = ranges[minKey] ?? minPeso;
    final maxWeight = ranges[maxKey] ?? maxPeso;

    if (peso < minWeight) {
      return 'Peso muito baixo para $animalType (mín: ${minWeight}kg)';
    }
    if (peso > maxWeight) {
      return 'Peso muito alto para $animalType (máx: ${maxWeight}kg)';
    }

    return null;
  }

  /// Validates all fields at once
  static Map<String, String?> validateAllFields({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
    String? animalType,
    bool isFilhote = false,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'peso': animalType != null 
          ? validatePesoForAnimalType(peso, animalType, isFilhote: isFilhote)
          : validatePeso(peso),
      'dataPesagem': validateDataPesagem(dataPesagem),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  /// Checks if form is valid
  static bool isFormValid({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
    String? animalType,
    bool isFilhote = false,
  }) {
    final validation = validateAllFields(
      animalId: animalId,
      peso: peso,
      dataPesagem: dataPesagem,
      observacoes: observacoes,
      animalType: animalType,
      isFilhote: isFilhote,
    );
    return validation.values.every((error) => error == null);
  }

  // ========== COMPUTED PROPERTIES ==========
  
  /// Format weight with unit
  static String formatPeso(double peso) {
    return '${peso.toStringAsFixed(pesoDecimalPlaces).replaceAll('.', decimalSeparator)} $weightUnit';
  }

  /// Parse weight from string
  static double? parsePeso(String pesoString) {
    try {
      final cleanValue = pesoString
          .replaceAll(weightUnit, '')
          .replaceAll(' ', '')
          .replaceAll(decimalSeparator, '.');
      return double.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  /// Get weight category based on ideal weight ranges
  static String getWeightCategory(double peso, double pesoIdeal) {
    final ratio = peso / pesoIdeal;
    
    if (ratio < 0.85) return categoriasPeso[0]; // Abaixo do peso
    if (ratio <= 1.15) return categoriasPeso[1]; // Peso ideal
    if (ratio <= 1.30) return categoriasPeso[2]; // Sobrepeso
    if (ratio <= 1.50) return categoriasPeso[3]; // Obesidade grau I
    return categoriasPeso[4]; // Obesidade grau II
  }

  /// Get weight progress between two weights
  static Map<String, dynamic> getWeightProgress(double pesoAnterior, double pesoAtual) {
    final diferenca = pesoAtual - pesoAnterior;
    final percentual = (diferenca / pesoAnterior) * 100;
    
    return {
      'diferenca': diferenca,
      'percentual': percentual,
      'status': diferenca > 0 ? 'ganho' : diferenca < 0 ? 'perda' : 'estável',
      'significativo': percentual.abs() > 5.0, // Change > 5% is significant
    };
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
      assert(pesosPorEspecie.isNotEmpty, 'pesosPorEspecie cannot be empty');
      assert(maxPeso > minPeso, 'maxPeso must be greater than minPeso');
      assert(maxObservacoesLength > 0, 'maxObservacoesLength must be positive');
      assert(pesoDecimalPlaces >= 0, 'pesoDecimalPlaces must be non-negative');
      
      // Check string constants
      assert(formTitleNew.isNotEmpty, 'formTitleNew cannot be empty');
      assert(weightUnit.isNotEmpty, 'weightUnit cannot be empty');
      
      return true;
    } catch (e) {
      if (isDebugMode) {
        throw Exception('PesoConfig validation failed: $e');
      }
      return false;
    }
  }
  
  /// Gets configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': currentEnvironment,
      'debugMode': isDebugMode,
      'speciesCount': pesosPorEspecie.length,
      'weightRange': '$minPeso - $maxPeso $weightUnit',
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