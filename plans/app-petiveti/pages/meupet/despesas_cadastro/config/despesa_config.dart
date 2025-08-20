/// Centralized configuration for the despesas_cadastro module
/// 
/// Contains all constants, configurations, and settings that were previously
/// hardcoded throughout the module. Supports environment-based configuration
/// and runtime customization.
/// 
/// ## Naming Conventions
/// 
/// This module follows these standardized naming conventions:
/// 
/// ### Classes and Enums
/// - **PascalCase**: `DespesaConfig`, `ErrorCategory`, `DespesaFormController`
/// - Domain names in Portuguese: `DespesaVet`, `AnimalSelector`
/// 
/// ### Methods and Variables 
/// - **camelCase**: `formatCurrency()`, `isLoadingReactive`, `dataDespesa`
/// - Boolean getters: `isValid`, `hasChanges`, `canRetry`
/// - Action methods: `updateValor()`, `validateDescricao()`, `resetForm()`
/// 
/// ### Constants
/// - **camelCase for properties**: `maxFormWidth`, `primaryColor`
/// - **SCREAMING_SNAKE_CASE for environment**: `DESPESA_ENV`, `DESPESA_AUTO_SAVE`
/// - Grouped by purpose: UI constants, validation, business logic
/// 
/// ### Files and Directories
/// - **snake_case**: `despesa_config.dart`, `error_handler.dart`
/// - Domain prefix: `despesa_form_*`, `despesa_error_*`
/// 
/// ### UI Components
/// - Widget classes: `ValorInput`, `DataPicker`, `ActionButtons`
/// - Style classes: `DespesaFormStyles`
/// - Mixin suffix: `FormStateMixin`, `ValidationMixin`
class DespesaConfig {
  // Private constructor to prevent instantiation
  DespesaConfig._();
  
  /// Configuration environment types
  static const String envDevelopment = 'development';
  static const String envProduction = 'production';
  static const String envTesting = 'testing';
  
  /// Current environment (can be set via environment variables)
  static String get currentEnvironment => 
      const String.fromEnvironment('DESPESA_ENV', defaultValue: envProduction);
  
  // ========== UI CONSTANTS ==========
  
  /// Form dimensions and sizing
  static const double maxFormWidth = 400.0;
  static const double maxFormHeight = 445.0;
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
  static const double buttonBorderRadius = 8.0;
  static const double buttonMinWidth = 120.0;
  
  /// Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // ========== VALIDATION CONSTANTS ==========
  
  /// Description field constraints
  static const int descricaoMinLength = 3;
  static const int descricaoMaxLength = 255;
  
  /// Value constraints
  static const double valorMinimo = 0.01;
  static const double valorMaximo = 999999.99;
  static const int valorDecimalPlaces = 2;
  
  /// Date constraints (in days)
  static const int maxDateRangeInPast = 365; // 1 year
  static const int maxDateRangeInFuture = 365; // 1 year
  
  /// Input length limits
  static const int animalIdMaxLength = 50;
  static const int tipoMaxLength = 50;
  static const int veterinarioMaxLength = 100;
  
  // ========== BUSINESS CONSTANTS ==========
  
  /// Available expense types
  static const List<String> tiposDespesa = [
    'Consulta',
    'Medicamento',
    'Vacina',
    'Exame',
    'Cirurgia',
    'Emergência',
    'Banho e Tosa',
    'Alimentação',
    'Petiscos',
    'Brinquedos',
    'Acessórios',
    'Hospedagem',
    'Transporte',
    'Seguro',
    'Outros'
  ];
  
  /// Default values
  static String get defaultTipo => tiposDespesa.isNotEmpty ? tiposDespesa.first : 'Outros';
  static double get defaultValor => valorMinimo;
  
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
  
  // ========== STRING CONSTANTS ==========
  
  /// Form titles and labels
  static const String formTitleNew = 'Nova Despesa';
  static const String formTitleEdit = 'Editar Despesa';
  static const String buttonTextSave = 'Salvar';
  static const String buttonTextUpdate = 'Atualizar';
  static const String buttonTextCancel = 'Cancelar';
  static const String buttonTextDelete = 'Excluir';
  
  /// Field labels
  static const String labelAnimal = 'Animal';
  static const String labelTipo = 'Tipo';
  static const String labelDescricao = 'Descrição';
  static const String labelValor = 'Valor';
  static const String labelData = 'Data';
  static const String labelObservacoes = 'Observações';
  
  /// Placeholder texts
  static const String placeholderTipo = 'Selecione o tipo';
  static const String placeholderDescricao = 'Descreva a despesa...';
  static const String placeholderValor = 'R\$ 0,00';
  static const String placeholderData = 'dd/mm/aaaa';

  // ========== FORM SECTIONS (STANDARDIZED PATTERN) ==========
  
  /// Section titles mapping
  static const Map<String, String> titulosSecoes = {
    'despesa_info': 'Informações da Despesa',
    'valores': 'Valores e Data',
    'detalhes': 'Detalhes Adicionais',
  };

  /// Section icons mapping  
  static const Map<String, String> iconesSecoes = {
    'despesa_info': 'receipt',
    'valores': 'attach_money',
    'detalhes': 'notes',
  };

  // ========== FIELD LABELS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field labels mapping for consistency
  static const Map<String, String> rotulosCampos = {
    'animal': 'Animal *',
    'tipo': 'Tipo de Despesa *', 
    'descricao': 'Descrição',
    'valor': 'Valor (R\$) *',
    'data_despesa': 'Data da Despesa *',
    'observacoes': 'Observações',
  };

  // ========== FIELD HINTS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field hints mapping for user guidance
  static const Map<String, String> dicasCampos = {
    'animal': 'Selecione o animal',
    'tipo': 'Escolha o tipo de despesa',
    'descricao': 'Descreva a despesa (opcional)',
    'valor': 'Ex: 50,00',
    'data_despesa': 'dd/mm/aaaa',
    'observacoes': 'Informações adicionais (opcional)',
  };
  
  /// Success messages
  static const String msgSuccessSave = 'Despesa salva com sucesso!';
  static const String msgSuccessUpdate = 'Despesa atualizada com sucesso!';
  static const String msgSuccessDelete = 'Despesa excluída com sucesso!';
  
  /// Error messages
  static const String msgErrorSave = 'Erro ao salvar despesa';
  static const String msgErrorUpdate = 'Erro ao atualizar despesa';
  static const String msgErrorDelete = 'Erro ao excluir despesa';
  static const String msgErrorLoad = 'Erro ao carregar dados';
  static const String msgErrorNetwork = 'Erro de conexão';
  static const String msgErrorValidation = 'Dados inválidos';

  // ========== VALIDATION ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Standard validation error messages
  static const String requiredFieldMessage = 'Campo obrigatório';
  static const String invalidNumberMessage = 'Digite um número válido';
  static const String valueTooHighMessage = 'Valor muito alto';
  static const String valueTooLowMessage = 'Valor deve ser maior que zero';
  static const String invalidDateMessage = 'Data inválida';
  static const String descriptionTooLongMessage = 'Descrição muito longa';
  static const String dateTooOldMessage = 'Data muito antiga';
  static const String dateTooFutureMessage = 'Data não pode ser futura';
  static const String animalNotSelectedMessage = 'Selecione um animal';
  static const String tipoNotSelectedMessage = 'Selecione o tipo de despesa';
  
  /// Confirmation messages
  static const String confirmDelete = 'Tem certeza que deseja excluir esta despesa?';
  static const String confirmCancel = 'Descartar alterações?';
  
  // ========== FORMAT PATTERNS ==========
  
  /// Date formats
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatStorage = 'yyyy-MM-dd';
  static const String dateTimeFormatFull = 'dd/MM/yyyy HH:mm';
  
  /// Number formats
  static const String currencySymbol = 'R\$';
  static const String decimalSeparator = ',';
  static const String thousandSeparator = '.';
  
  /// Regex patterns
  static const String regexCurrency = r'^\d+\,?\d{0,2}';
  static const String regexDate = r'^\d{2}\/\d{2}\/\d{4}$';
  static const String regexText = r'^[a-zA-ZÀ-ÿ\s\.\-]+$';
  
  // ========== CACHE CONFIGURATION ==========
  
  /// Cache keys
  static const String cacheKeyTipos = 'despesa_tipos';
  static const String cacheKeyFormats = 'despesa_formats';
  static const String cacheKeyValidations = 'despesa_validations';
  
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
      const bool.fromEnvironment('DESPESA_AUTO_SAVE', defaultValue: true);
  static bool get enableRetry => 
      const bool.fromEnvironment('DESPESA_RETRY', defaultValue: true);
  static bool get enableCache => 
      const bool.fromEnvironment('DESPESA_CACHE', defaultValue: true);
  static bool get enableAnalytics => 
      const bool.fromEnvironment('DESPESA_ANALYTICS', defaultValue: false);
  
  // ========== COMPUTED PROPERTIES ==========
  
  /// Get currency format with symbol
  static String formatCurrency(double value) {
    return '$currencySymbol ${value.toStringAsFixed(valorDecimalPlaces).replaceAll('.', decimalSeparator)}';
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
  
  /// Get form constraints as a map
  static Map<String, dynamic> getFormConstraints() {
    return {
      'descricao': {
        'minLength': descricaoMinLength,
        'maxLength': descricaoMaxLength,
      },
      'valor': {
        'min': valorMinimo,
        'max': valorMaximo,
        'decimalPlaces': valorDecimalPlaces,
      },
      'date': {
        'maxPastDays': maxDateRangeInPast,
        'maxFutureDays': maxDateRangeInFuture,
      },
    };
  }
  
  /// Get all available tipos with metadata
  static List<Map<String, dynamic>> getTiposWithMetadata() {
    return tiposDespesa.map((tipo) => {
      'value': tipo,
      'label': tipo,
      'icon': _getTipoIcon(tipo),
      'color': _getTipoColor(tipo),
    }).toList();
  }
  
  /// Get icon for tipo (private helper)
  static String _getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta': return '🏥';
      case 'medicamento': return '💊';
      case 'vacina': return '💉';
      case 'exame': return '🔬';
      case 'cirurgia': return '⚕️';
      case 'emergência': return '🚨';
      case 'banho e tosa': return '🛁';
      case 'alimentação': return '🍽️';
      case 'petiscos': return '🦴';
      case 'brinquedos': return '🎾';
      case 'acessórios': return '🎀';
      case 'hospedagem': return '🏠';
      case 'transporte': return '🚗';
      case 'seguro': return '🛡️';
      default: return '📝';
    }
  }
  
  /// Get color for tipo (private helper)
  static String _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta': return '#4CAF50';
      case 'medicamento': return '#FF9800';
      case 'vacina': return '#2196F3';
      case 'exame': return '#9C27B0';
      case 'cirurgia': return '#E53935';
      case 'emergência': return '#E91E63';
      case 'banho e tosa': return '#00BCD4';
      case 'alimentação': return '#8BC34A';
      case 'petiscos': return '#FFC107';
      case 'brinquedos': return '#FF5722';
      case 'acessórios': return '#673AB7';
      case 'hospedagem': return '#795548';
      case 'transporte': return '#607D8B';
      case 'seguro': return '#3F51B5';
      default: return '#9E9E9E';
    }
  }
  
  // ========== CONFIGURATION VALIDATION ==========
  
  /// Validates that all required configuration is present
  static bool validateConfiguration() {
    try {
      // Check required constants
      assert(tiposDespesa.isNotEmpty, 'tiposDespesa cannot be empty');
      assert(valorMinimo > 0, 'valorMinimo must be positive');
      assert(valorMaximo > valorMinimo, 'valorMaximo must be greater than valorMinimo');
      assert(descricaoMaxLength > descricaoMinLength, 'descricaoMaxLength must be greater than descricaoMinLength');
      
      // Check string constants
      assert(formTitleNew.isNotEmpty, 'formTitleNew cannot be empty');
      assert(currencySymbol.isNotEmpty, 'currencySymbol cannot be empty');
      
      return true;
    } catch (e) {
      if (isDebugMode) {
        throw Exception('DespesaConfig validation failed: $e');
      }
      return false;
    }
  }
  
  /// Gets configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': currentEnvironment,
      'debugMode': isDebugMode,
      'tiposCount': tiposDespesa.length,
      'valorRange': '$valorMinimo - $valorMaximo',
      'descricaoRange': '$descricaoMinLength - $descricaoMaxLength',
      'featureFlags': {
        'autoSave': enableAutoSave,
        'retry': enableRetry,
        'cache': enableCache,
        'analytics': enableAnalytics,
      },
    };
  }
}