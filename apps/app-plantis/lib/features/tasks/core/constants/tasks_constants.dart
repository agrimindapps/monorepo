/// Constants for the Tasks system
/// This file contains all magic numbers and constant values used in the tasks system
class TasksConstants {
  TasksConstants._();

  // ============================================================================
  // TIMING CONSTANTS
  // ============================================================================

  /// Minimum interval between sync operations to prevent throttling
  static const Duration syncMinimumInterval = Duration(seconds: 2);

  /// Notification time before task due date
  static const Duration notificationAdvanceTime = Duration(hours: 1);

  /// Snooze duration for postponed notifications
  static const Duration snoozeDuration = Duration(hours: 1);

  /// Upcoming tasks filter duration (next 15 days)
  static const Duration upcomingTasksDuration = Duration(days: 15);

  /// Search debounce delay to prevent excessive queries
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  /// Background task check interval
  static const Duration backgroundCheckInterval = Duration(days: 1);

  /// Maximum notification ID value to prevent overflow
  static const int maxNotificationId = 2147483647;

  // ============================================================================
  // UI CONSTANTS
  // ============================================================================

  /// Task creation dialog width percentage
  static const double taskDialogWidthPercentage = 0.9;

  /// Task description maximum length
  static const int taskDescriptionMaxLength = 200;

  /// Task description input max lines
  static const int taskDescriptionMaxLines = 3;

  /// Date picker future limit (1 year)
  static const int datePickerMaxDays = 365;

  /// Progress color thresholds
  static const int progressExcellentThreshold = 80;
  static const int progressGoodThreshold = 50;
  static const int progressFairThreshold = 25;

  // ============================================================================
  // UI SPACING CONSTANTS
  // ============================================================================

  /// Empty state illustration size
  static const double emptyStateIllustrationSize = 120.0;

  /// Empty state padding
  static const double emptyStatePadding = 32.0;

  /// Empty state spacing between elements
  static const double emptyStateSpacing = 24.0;
  static const double emptyStateSmallSpacing = 12.0;
  static const double emptyStateButtonSpacing = 32.0;

  /// Stat card padding
  static const double statCardPadding = 12.0;

  /// Stat card icon size
  static const double statCardIconSize = 20.0;

  /// Stat card spacing
  static const double statCardSpacing = 12.0;
  static const double statCardSmallSpacing = 4.0;

  /// Progress bar height
  static const double progressBarHeight = 8.0;
  static const double progressBarBorderRadius = 4.0;

  /// Task dialog icon size
  static const double taskDialogIconSize = 28.0;
  static const double taskDialogIconSpacing = 12.0;

  /// Task type dropdown icon size
  static const double taskTypeIconSize = 20.0;

  /// Priority icon size
  static const double priorityIconSize = 20.0;

  /// Dashboard container padding
  static const double dashboardPadding = 16.0;
  static const double dashboardShadowBlurRadius = 4.0;
  static const double dashboardShadowOffset = 2.0;

  /// Dashboard stat card spacing
  static const double statCardRowSpacing = 12.0;
  static const double dashboardVerticalSpacing = 16.0;
  static const double progressSectionSpacing = 8.0;

  // ============================================================================
  // NOTIFICATION CONSTANTS
  // ============================================================================

  /// Fixed notification ID for daily summary
  static const int dailySummaryNotificationId = 9999;

  /// Notification background operations channel ID
  static const String backgroundTaskCheckType = 'background_check';

  /// Notification action IDs
  static const String completeTaskActionId = 'complete_task';
  static const String snoozeTaskActionId = 'snooze_task';
  static const String rescheduleTaskActionId = 'reschedule_task';
  static const String viewDetailsActionId = 'view_details';

  /// Android notification icons
  static const String androidCheckIcon = 'ic_check';
  static const String androidSnoozeIcon = 'ic_snooze';
  static const String androidScheduleIcon = 'ic_schedule';
  static const String androidInfoIcon = 'ic_info';

  /// Notification color
  static const int notificationColor = 0xFF4CAF50;

  // ============================================================================
  // TASK FILTER CONSTANTS
  // ============================================================================

  /// Maximum priority index for sorting
  static const int maxPriorityIndex = 4;

  // ============================================================================
  // ALPHA/OPACITY CONSTANTS
  // ============================================================================

  /// Primary container alpha for illustrations
  static const double illustrationAlpha = 0.3;

  /// Surface alpha for secondary text
  static const double secondaryTextAlpha = 0.7;

  /// Surface alpha for muted text
  static const double mutedTextAlpha = 0.6;

  /// Surface alpha for disabled text
  static const double disabledTextAlpha = 0.4;

  /// Border alpha for containers
  static const double borderAlpha = 0.3;

  /// Shadow alpha
  static const double shadowAlpha = 0.1;
}
