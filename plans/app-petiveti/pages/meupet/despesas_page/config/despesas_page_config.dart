/// Centralized configuration for the despesas_page module
/// 
/// Contains all constants, timeouts, limits and configuration that were 
/// previously hardcoded throughout the module.
class DespesasPageConfig {
  // Private constructor to prevent instantiation
  DespesasPageConfig._();

  // ========== UI CONSTANTS ==========
  
  /// Form and layout dimensions
  static const double maxFormWidth = 1020.0;
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  static const double cardMargin = 16.0;
  static const double cardPadding = 20.0;

  /// Spacing constants
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // ========== TIMING CONSTANTS ==========
  
  /// Search debounce delay in milliseconds
  static const int searchDebounceMs = 300;
  
  /// Data refresh intervals
  static const int refreshThresholdMinutes = 5;
  static const int autoRefreshMinutes = 30;
  
  /// Animation durations in milliseconds
  static const int animationDurationFast = 150;
  static const int animationDurationMedium = 300;
  static const int animationDurationSlow = 500;

  // ========== LIMITS AND THRESHOLDS ==========
  
  /// Default limits for queries and displays
  static const int defaultRecentLimit = 10;
  static const int maxItemsPerPage = 50;
  static const int recentDaysThreshold = 7;
  static const int defaultPeriodDays = 30;
  
  /// Export limits
  static const int maxExportItems = 1000;
  static const int csvMaxFileSize = 10 * 1024 * 1024; // 10MB

  // ========== DATE/TIME CONSTANTS ==========
  
  /// Date format patterns
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatShort = 'dd/MM';
  static const String dateFormatLong = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MM/yyyy';
  static const String yearFormat = 'yyyy';

  /// Month abbreviations (Portuguese)
  static const List<String> monthsAbbreviated = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

  /// Full month names (Portuguese)
  static const List<String> monthsFull = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  /// Weekday names (Portuguese)
  static const List<String> weekdaysFull = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo'
  ];

  static const List<String> weekdaysAbbreviated = [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
  ];

  // ========== STRING CONSTANTS ==========
  
  /// Common UI labels
  static const String labelCarregando = 'Carregando...';
  static const String labelAtualizando = 'Atualizando...';
  static const String labelNenhumaDespesa = 'Nenhuma despesa';
  static const String labelNaoInicializado = 'Não inicializado';
  static const String labelPronto = 'Pronto';
  
  /// Error messages
  static const String errorInicializar = 'Erro ao inicializar o controlador';
  static const String errorCarregarDespesas = 'Erro ao carregar despesas';
  static const String errorExportarCsv = 'Error exporting despesas to CSV';
  
  /// Success messages
  static const String successCarregado = 'Dados carregados com sucesso';
  static const String successAtualizado = 'Dados atualizados com sucesso';

  // ========== VALIDATION CONSTANTS ==========
  
  /// Search and filter limits
  static const int searchMinLength = 2;
  static const int searchMaxLength = 100;
  static const int maxFilterCriteria = 10;

  // ========== CURRENCY CONSTANTS ==========
  
  /// Currency formatting
  static const String currencySymbol = 'R\$';
  static const String decimalSeparator = ',';
  static const String thousandSeparator = '.';
  static const int decimalPlaces = 2;

  // ========== COMPUTED PROPERTIES ==========
  
  /// Get search debounce duration
  static Duration get searchDebounceDuration => 
      const Duration(milliseconds: searchDebounceMs);
  
  /// Get refresh threshold duration
  static Duration get refreshThresholdDuration => 
      const Duration(minutes: refreshThresholdMinutes);
  
  /// Get auto-refresh duration
  static Duration get autoRefreshDuration => 
      const Duration(minutes: autoRefreshMinutes);
  
  /// Get recent days threshold duration
  static Duration get recentDaysThresholdDuration => 
      const Duration(days: recentDaysThreshold);
  
  /// Get default period duration
  static Duration get defaultPeriodDuration => 
      const Duration(days: defaultPeriodDays);

  // ========== HELPER METHODS ==========
  
  /// Format currency value
  static String formatCurrency(double value) {
    return '$currencySymbol ${value.toStringAsFixed(decimalPlaces).replaceAll('.', decimalSeparator)}';
  }
  
  /// Get animation duration
  static Duration getAnimationDuration({bool fast = false, bool slow = false}) {
    if (fast) return const Duration(milliseconds: animationDurationFast);
    if (slow) return const Duration(milliseconds: animationDurationSlow);
    return const Duration(milliseconds: animationDurationMedium);
  }

  /// Get month name by index (1-12)
  static String getMonthName(int month, {bool abbreviated = false}) {
    if (month < 1 || month > 12) return '';
    final months = abbreviated ? monthsAbbreviated : monthsFull;
    return months[month - 1];
  }

  /// Get weekday name by index (1-7, Monday = 1)
  static String getWeekdayName(int weekday, {bool abbreviated = false}) {
    if (weekday < 1 || weekday > 7) return '';
    final weekdays = abbreviated ? weekdaysAbbreviated : weekdaysFull;
    return weekdays[weekday - 1];
  }

  // ========== CONFIGURATION VALIDATION ==========
  
  /// Validate configuration on startup
  static bool validateConfiguration() {
    try {
      assert(searchDebounceMs > 0, 'searchDebounceMs must be positive');
      assert(defaultRecentLimit > 0, 'defaultRecentLimit must be positive');
      assert(monthsAbbreviated.length == 12, 'monthsAbbreviated must have 12 items');
      assert(monthsFull.length == 12, 'monthsFull must have 12 items');
      assert(weekdaysFull.length == 7, 'weekdaysFull must have 7 items');
      assert(weekdaysAbbreviated.length == 7, 'weekdaysAbbreviated must have 7 items');
      return true;
    } catch (e) {
      return false;
    }
  }
}