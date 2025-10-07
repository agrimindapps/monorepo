/// A centralized collection of constants for the Medications feature.
///
/// This includes UI strings, accessibility labels, layout values, and routes
/// to ensure consistency and ease of maintenance.
class MedicationsConstants {
  MedicationsConstants._();

  // --- Feature-level Constants ---
  static const int tabCount = 4;

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String allMedicationsTitle = 'Medications';
    static const String petMedicationsTitle = 'Pet Medications';
    static const String searchHintText = 'Search medications...';
    static const String allTabTitle = 'All';
    static const String activeTabTitle = 'Active';
    static const String expiringTabTitle = 'Expiring';
    static const String statisticsTabTitle = 'Statistics';
    static const String noActiveMedications = 'No active medications at the moment';
    static const String noExpiringMedications = 'No medications nearing expiration';
    static const String noMedicationsFound = 'No medications found';
    static const String retryButtonText = 'Try Again';
    static const String cancelButtonText = 'Cancel';
    static const String deleteButtonText = 'Delete';
    static const String discontinueButtonText = 'Discontinue';
    static const String deleteMedicationTitle = 'Delete Medication';
    static const String discontinueMedicationTitle = 'Discontinue Medication';
    static const String medicationDeletedMessage = 'Medication deleted successfully';
    static const String medicationDiscontinuedMessage = 'Medication discontinued';
    static const String discontinuationReasonLabel = 'Reason for discontinuation';
  }

  /// Constants for accessibility labels and hints.
  /// These should also be localized.
  abstract class Accessibility {
    Accessibility._();
    static const String addMedicationTooltip = 'Add Medication';
    static const String refreshTooltip = 'Refresh';
  }

  /// Constants for navigation routes related to the Medications feature.
  abstract class Routes {
    Routes._();
    static const String addMedication = '/medications/add';
    static const String details = '/medications/details';
    static const String edit = '/medications/edit';
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const double tabIconSize = 16.0;
    static const double errorIconSize = 64.0;
    static const double pageContentPadding = 16.0;
    static const double searchFiltersSpacing = 8.0;
    static const double errorContentSpacing = 16.0;
    static const double dialogContentSpacing = 16.0;
    static const double medicationCardHeight = 120.0;
    static const double cardBottomSpacing = 8.0;
    static const double errorTextSize = 16.0;
    static const int reasonTextFieldMaxLines = 3;
  }

  /// Duration and timing constants.
  abstract class Timings {
    Timings._();
    static const Duration loadingTimeout = Duration(seconds: 10);
  }
}