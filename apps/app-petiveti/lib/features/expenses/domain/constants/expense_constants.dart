/// Constants for expense feature
///
/// Centralizes configuration values and business rules
class ExpenseConstants {
  // Private constructor to prevent instantiation
  ExpenseConstants._();

  // ========================================================================
  // VALIDATION
  // ========================================================================

  /// Minimum expense amount (to avoid accidental zero entries)
  static const double minExpenseAmount = 0.01;

  /// Maximum expense amount (reasonable limit for pet expenses)
  static const double maxExpenseAmount = 999999.99;

  /// Minimum description length
  static const int minDescriptionLength = 3;

  /// Maximum description length
  static const int maxDescriptionLength = 200;

  /// Maximum notes length
  static const int maxNotesLength = 500;

  /// Maximum vendor name length
  static const int maxVendorNameLength = 100;

  // ========================================================================
  // CATEGORIES
  // ========================================================================

  static const String categoryFood = 'food';
  static const String categoryVeterinary = 'veterinary';
  static const String categoryMedication = 'medication';
  static const String categoryGrooming = 'grooming';
  static const String categoryToys = 'toys';
  static const String categoryAccessories = 'accessories';
  static const String categoryInsurance = 'insurance';
  static const String categoryBoarding = 'boarding';
  static const String categoryTraining = 'training';
  static const String categoryOther = 'other';

  // ========================================================================
  // PAYMENT METHODS
  // ========================================================================

  static const String paymentCash = 'cash';
  static const String paymentCredit = 'credit';
  static const String paymentDebit = 'debit';
  static const String paymentPix = 'pix';
  static const String paymentBankTransfer = 'bank_transfer';
  static const String paymentOther = 'other';

  // ========================================================================
  // FREQUENCY
  // ========================================================================

  static const String frequencyOneTime = 'one_time';
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyBiweekly = 'biweekly';
  static const String frequencyMonthly = 'monthly';
  static const String frequencyQuarterly = 'quarterly';
  static const String frequencyYearly = 'yearly';

  // ========================================================================
  // UI CONFIGURATION
  // ========================================================================

  /// Number of recent expenses to show in dashboard
  static const int recentExpensesLimit = 5;

  /// Number of top categories to show in charts
  static const int topCategoriesLimit = 5;

  /// Animation duration in milliseconds
  static const int animationDurationMs = 300;

  /// List fade animation delay per item (milliseconds)
  static const int itemAnimationDelayMs = 50;

  /// Maximum items to animate in list
  static const int maxAnimatedItems = 20;

  // ========================================================================
  // STATISTICS
  // ========================================================================

  /// Number of months to include in statistics
  static const int statisticsMonthsRange = 6;

  /// Minimum expenses for trend analysis
  static const int minExpensesForTrends = 3;

  /// Days to consider for "recent" expenses
  static const int recentExpensesDays = 30;

  // ========================================================================
  // BUDGET & ALERTS
  // ========================================================================

  /// Default monthly budget (if not set)
  static const double defaultMonthlyBudget = 1000.0;

  /// Percentage threshold for budget warning
  static const double budgetWarningThreshold = 0.8; // 80%

  /// Percentage threshold for budget critical alert
  static const double budgetCriticalThreshold = 0.95; // 95%

  /// Days to warn before recurring expense
  static const int recurringExpenseWarningDays = 3;

  // ========================================================================
  // FILTERS & SORTING
  // ========================================================================

  /// Default sort order
  static const String sortByDateDesc = 'date_desc';
  static const String sortByDateAsc = 'date_asc';
  static const String sortByAmountDesc = 'amount_desc';
  static const String sortByAmountAsc = 'amount_asc';
  static const String sortByCategory = 'category';

  /// Default filter period
  static const String filterCurrentMonth = 'current_month';
  static const String filterLastMonth = 'last_month';
  static const String filterLast3Months = 'last_3_months';
  static const String filterLast6Months = 'last_6_months';
  static const String filterCurrentYear = 'current_year';
  static const String filterAllTime = 'all_time';
  static const String filterCustom = 'custom';

  // ========================================================================
  // EXPORT
  // ========================================================================

  /// Export filename prefix
  static const String exportFilenamePrefix = 'petiveti_expenses';

  /// Export date format
  static const String exportDateFormat = 'yyyy-MM-dd';

  /// Maximum records per export
  static const int maxExportRecords = 10000;

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Get category display name
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case categoryFood:
        return 'Alimentação';
      case categoryVeterinary:
        return 'Veterinário';
      case categoryMedication:
        return 'Medicamentos';
      case categoryGrooming:
        return 'Banho e Tosa';
      case categoryToys:
        return 'Brinquedos';
      case categoryAccessories:
        return 'Acessórios';
      case categoryInsurance:
        return 'Seguro';
      case categoryBoarding:
        return 'Hospedagem';
      case categoryTraining:
        return 'Adestramento';
      case categoryOther:
        return 'Outros';
      default:
        return 'Desconhecido';
    }
  }

  /// Get payment method display name
  static String getPaymentMethodDisplayName(String method) {
    switch (method) {
      case paymentCash:
        return 'Dinheiro';
      case paymentCredit:
        return 'Cartão de Crédito';
      case paymentDebit:
        return 'Cartão de Débito';
      case paymentPix:
        return 'PIX';
      case paymentBankTransfer:
        return 'Transferência Bancária';
      case paymentOther:
        return 'Outro';
      default:
        return 'Desconhecido';
    }
  }

  /// Get frequency display name
  static String getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case frequencyOneTime:
        return 'Única';
      case frequencyDaily:
        return 'Diária';
      case frequencyWeekly:
        return 'Semanal';
      case frequencyBiweekly:
        return 'Quinzenal';
      case frequencyMonthly:
        return 'Mensal';
      case frequencyQuarterly:
        return 'Trimestral';
      case frequencyYearly:
        return 'Anual';
      default:
        return 'Desconhecida';
    }
  }

  /// Check if amount is within valid range
  static bool isValidAmount(double amount) {
    return amount >= minExpenseAmount && amount <= maxExpenseAmount;
  }

  /// Check if budget warning should be shown
  static bool shouldShowBudgetWarning(double spent, double budget) {
    if (budget <= 0) return false;
    return (spent / budget) >= budgetWarningThreshold;
  }

  /// Check if budget critical alert should be shown
  static bool shouldShowBudgetCriticalAlert(double spent, double budget) {
    if (budget <= 0) return false;
    return (spent / budget) >= budgetCriticalThreshold;
  }

  /// Calculate budget usage percentage
  static double calculateBudgetUsagePercentage(double spent, double budget) {
    if (budget <= 0) return 0;
    return (spent / budget) * 100;
  }
}
