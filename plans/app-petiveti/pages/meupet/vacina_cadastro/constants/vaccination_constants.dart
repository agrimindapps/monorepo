/// Type-safe constants for vaccination module to replace magic strings and numbers
class VaccinationConstants {
  // Field names - type-safe field identifiers
  static const String fieldAnimalId = 'animalId';
  static const String fieldNomeVacina = 'nomeVacina';
  static const String fieldDataAplicacao = 'dataAplicacao';
  static const String fieldProximaDose = 'proximaDose';
  static const String fieldObservacoes = 'observacoes';
  
  // Validation limits
  static const int minVaccineNameLength = 2;
  static const int maxVaccineNameLength = 100;
  static const int maxObservationsLength = 500;
  static const int minDoseIntervalDays = 1;
  static const int maxFutureDateYears = 10;
  static const int minValidYear = 1900;
  
  // Default intervals (in days)
  static const int defaultNextDoseInterval = 365;
  static const int puppyVaccineInterval = 21;
  static const int boosterInterval = 180;
  static const int annualVaccineInterval = 365;
  static const int monthlyInterval = 30;
  static const int weeklyInterval = 7;
  static const int biWeeklyInterval = 14;
  static const int triWeeklyInterval = 21;
  
  // Timeout and debounce values (in milliseconds)
  static const int validationDebounceMs = 300;
  static const int formSubmissionTimeoutMs = 30000;
  static const int saveTimeoutMs = 10000;
  static const int networkTimeoutMs = 15000;
  
  // Business rule constants
  static const int toleranceDays = 7;
  static const int maxFutureYears = 2;
  static const int maxHistoryYears = 100;
  static const int maxDeletionAgeHours = 1;
  static const int maxBackupRetentionDays = 30;
  
  // Dialog dimensions
  static const double dialogMaxWidth = 500.0;
  static const double dialogMaxHeight = 500.0;
  static const double dialogMinWidth = 300.0;
  static const double dialogMinHeight = 200.0;
  
  // Form field constraints
  static const int maxFormFieldLength = 1000;
  static const int maxSearchQueryLength = 100;
  static const int maxBatchOperationSize = 50;
  
  // Security constants
  static const Set<String> invalidCharacters = {
    '<', '>', '"', "'", '/', '&', '`', '\\', ';', '|'
  };
  
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
  
  // Error message constants
  static const String errorSaveFailure = 'Falha ao salvar vacina. Tente novamente.';
  static const String errorNetworkTimeout = 'Operação demorou muito. Verifique sua conexão e tente novamente.';
  static const String errorNoInternet = 'Sem conexão com a internet. Verifique sua conexão.';
  static const String errorServerError = 'Erro no servidor. Tente novamente em alguns minutos.';
  static const String errorValidationFailed = 'Dados inválidos. Verifique os campos destacados.';
  static const String errorNotFound = 'Vacina não encontrada.';
  static const String errorPermissionDenied = 'Permissão negada para esta operação.';
  static const String errorDuplicateEntry = 'Esta vacina já foi registrada para este animal.';
  static const String errorDateInFuture = 'Data não pode ser no futuro.';
  static const String errorDateTooOld = 'Data muito antiga.';
  static const String errorInvalidDateRange = 'Data de próxima dose deve ser após a aplicação.';
  
  // Success message constants
  static const String successVaccineSaved = 'Vacina cadastrada com sucesso!';
  static const String successVaccineUpdated = 'Vacina atualizada com sucesso!';
  static const String successVaccineDeleted = 'Vacina removida com sucesso!';
  static const String successBackupCreated = 'Backup criado com sucesso!';
  static const String successDataSynced = 'Dados sincronizados com sucesso!';
  
  // Field validation error messages
  static const String errorVaccineNameRequired = 'Nome da vacina é obrigatório';
  static const String errorVaccineNameTooShort = 'Nome da vacina deve ter pelo menos';
  static const String errorVaccineNameTooLong = 'Nome da vacina não pode ter mais de';
  static const String errorObservationsTooLong = 'Observações não podem ter mais de';
  static const String errorAnimalIdRequired = 'ID do animal é obrigatório';
  static const String errorApplicationDateRequired = 'Data de aplicação é obrigatória';
  static const String errorNextDoseDateRequired = 'Data da próxima dose é obrigatória';
  static const String errorInvalidCharacters = 'contém caracteres inválidos';
  static const String errorDangerousContent = 'contém conteúdo potencialmente perigoso';
  
  // Form labels and hints
  static const String labelVaccineName = 'Nome da Vacina *';
  static const String labelApplicationDate = 'Data de Aplicação *';
  static const String labelNextDoseDate = 'Próxima Dose *';
  static const String labelObservations = 'Observações';
  
  static const String hintVaccineName = 'Ex: V8, V10, Raiva, Múltipla';
  static const String hintApplicationDate = 'Data em que a vacina foi aplicada';
  static const String hintNextDoseDate = 'Data prevista para a próxima dose';
  static const String hintObservations = 'Informações adicionais (opcional)';
  
  // Form titles and button texts
  static const String titleNewVaccine = 'Nova Vacina';
  static const String titleEditVaccine = 'Editar Vacina';
  static const String buttonSave = 'Salvar';
  static const String buttonUpdate = 'Atualizar';
  static const String buttonCancel = 'Cancelar';
  static const String buttonDelete = 'Excluir';
  static const String buttonConfirm = 'Confirmar';
  
  // Loading messages
  static const String loadingSaving = 'Salvando vacina...';
  static const String loadingUpdating = 'Atualizando vacina...';
  static const String loadingDeleting = 'Removendo vacina...';
  static const String loadingValidating = 'Validando dados...';
  static const String loadingSyncing = 'Sincronizando dados...';
  
  // Status messages
  static const String statusDraft = 'Rascunho';
  static const String statusPending = 'Pendente';
  static const String statusCompleted = 'Concluído';
  static const String statusCancelled = 'Cancelado';
  static const String statusError = 'Erro';
  
  // Date format patterns
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String timeFormatDisplay = 'HH:mm';
  static const String dateFormatCompact = 'dd/MM';
  
  // Vaccine categories
  static const String categoryPuppy = 'puppy';
  static const String categoryAnnual = 'annual';
  static const String categoryBooster = 'booster';
  static const String categoryOptional = 'optional';
  static const String categoryEmergency = 'emergency';
  
  // Common vaccine names (for suggestions)
  static const List<String> commonVaccineNames = [
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
  ];
  
  // Animal size categories (affects vaccine dosage)
  static const String sizeSmall = 'small';
  static const String sizeMedium = 'medium';
  static const String sizeLarge = 'large';
  
  // Priority levels
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityCritical = 'critical';
  
  // Data export formats
  static const String formatJson = 'json';
  static const String formatCsv = 'csv';
  static const String formatPdf = 'pdf';
  static const String formatExcel = 'xlsx';
  
  // Cache keys
  static const String cacheVaccineList = 'vaccine_list';
  static const String cacheAnimalData = 'animal_data';
  static const String cacheFormData = 'form_data';
  static const String cacheUserPreferences = 'user_preferences';
  
  // SharedPreferences keys
  static const String prefAutoSave = 'auto_save_enabled';
  static const String prefDefaultInterval = 'default_interval_days';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  
  // Regular expression patterns
  static const String regexVaccineName = r'^[a-zA-ZÀ-ÿ0-9\s\-\.]{2,100}$';
  static const String regexObservations = r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\!\?\(\)]{0,500}$';
  static const String regexAnimalId = r'^[a-zA-Z0-9\-\_]{1,50}$';
  
  // API endpoints (if applicable)
  static const String apiVaccines = '/api/vaccines';
  static const String apiAnimals = '/api/animals';
  static const String apiSync = '/api/sync';
  static const String apiBackup = '/api/backup';
  
  // File operations
  static const String fileExtensionBackup = '.bak';
  static const String fileExtensionExport = '.json';
  static const String fileExtensionLog = '.log';
  
  // Logging levels
  static const String logLevelDebug = 'DEBUG';
  static const String logLevelInfo = 'INFO';
  static const String logLevelWarning = 'WARNING';
  static const String logLevelError = 'ERROR';
  static const String logLevelFatal = 'FATAL';
}

/// Enum-like class for vaccine status
class VaccineStatus {
  static const String scheduled = 'scheduled';
  static const String applied = 'applied';
  static const String overdue = 'overdue';
  static const String cancelled = 'cancelled';
  static const String deferred = 'deferred';
  
  static const List<String> allStatuses = [
    scheduled,
    applied,
    overdue,
    cancelled,
    deferred,
  ];
}

/// Enum-like class for form validation states
class ValidationState {
  static const String valid = 'valid';
  static const String invalid = 'invalid';
  static const String pending = 'pending';
  static const String error = 'error';
  
  static const List<String> allStates = [
    valid,
    invalid,
    pending,
    error,
  ];
}

/// Enum-like class for form actions
class FormAction {
  static const String create = 'create';
  static const String read = 'read';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String duplicate = 'duplicate';
  
  static const List<String> allActions = [
    create,
    read,
    update,
    delete,
    duplicate,
  ];
}