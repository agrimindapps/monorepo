import 'package:flutter/material.dart';

/// A centralized collection of constants for the Reminders feature.
///
/// This includes UI strings, accessibility labels, layout values, icons, and
/// timings to ensure consistency and ease of maintenance.
class RemindersConstants {
  RemindersConstants._();

  // --- Feature-level Constants ---
  static const int tabCount = 3;

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String pageTitle = 'Reminders';
    static const String todayTab = 'Today';
    static const String overdueTab = 'Overdue';
    static const String allTab = 'All';
    static const String emptyToday = 'No reminders for today';
    static const String emptyOverdue = 'No overdue reminders';
    static const String emptyAll = 'No reminders have been added yet';
    static const String completeMenu = 'Mark as Complete';
    static const String snoozeMenu = 'Snooze';
    static const String editMenu = 'Edit';
    static const String deleteMenu = 'Delete';
    static const String snoozeDialogTitle = 'Snooze Reminder';
    static const String snoozeDialogContent = 'How long would you like to snooze this reminder?';
    static const String snooze1Hour = '1 hour';
    static const String snooze4Hours = '4 hours';
    static const String snooze1Day = '1 day';
    static const String deleteDialogTitle = 'Confirm Deletion';
    static const String cancelButton = 'Cancel';
    static const String deleteButton = 'Delete';
    static const String retryButton = 'Try Again';
    static const String todayAt = 'Today at';
    static const String tomorrowAt = 'Tomorrow at';
    static const String yesterdayAt = 'Yesterday at';
    static const String repeatsEvery = 'Repeats every';
    static const String days = 'days';
    static const String addFeatureInDev = 'Add reminder feature is in development';
    static const String editFeatureInDev = 'Edit reminder feature is in development';
  }

  /// Constants for accessibility labels and hints.
  /// These should also be localized.
  abstract class Accessibility {
    Accessibility._();
    static const String refresh = 'Refresh reminders';
    static const String addReminder = 'Add new reminder';
    static const String loading = 'Loading reminders';
    static const String todayList = 'Today\'s reminders';
    static const String overdueList = 'Overdue reminders';
    static const String allList = 'All reminders';
    static const String reminderOptions = 'Reminder options';
    static const String reminderOptionsHint = 'Tap to see available actions';
    static const String cardHint = 'Tap to see reminder options';

    static String reminderCardLabel(String title, String status, String date) =>
        '$title, $status, $date';
    static String reminderTypeLabel(String typeName) => 'Reminder type: $typeName';
    static String tabLabel(String tabName, int count) => '$tabName tab, $count items';
    static String deleteConfirmation(String title) =>
        'Are you sure you want to delete the reminder "$title"?';
  }

  /// Icon constants for the Reminders feature.
  abstract class Icons {
    Icons._();
    static const IconData refresh = Icons.refresh;
    static const IconData add = Icons.add;
    static const IconData today = Icons.today;
    static const IconData warning = Icons.warning;
    static const IconData list = Icons.list;
    static const IconData emptySchedule = Icons.schedule;
    static const IconData vaccine = Icons.vaccines;
    static const IconData medication = Icons.medication;
    static const IconData appointment = Icons.event;
    static const IconData weight = Icons.scale;
    static const IconData general = Icons.notifications;
    static const IconData schedule = Icons.schedule;
    static const IconData repeat = Icons.repeat;
    static const IconData check = Icons.check;
    static const IconData snooze = Icons.snooze;
    static const IconData edit = Icons.edit;
    static const IconData delete = Icons.delete;
  }

  /// Color constants specific to the Reminders feature.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Colors {
    Colors._();
    static const Color vaccine = Colors.green;
    static const Color medication = Colors.blue;
    static const Color appointment = Colors.purple;
    static const Color weight = Colors.teal;
    static const Color general = Colors.grey;
    static const Color completedIcon = Colors.white;
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12);
    static const EdgeInsets listPadding = EdgeInsets.all(16);
    static const double emptyIconSize = 64.0;
    static const double itemExtent = 120.0;
    static const double scheduleIconSize = 14.0;
    static const double repeatIconSize = 14.0;
    static const double iconSpacing = 4.0;
    static const double subtitleSpacing = 4.0;
  }

  /// Duration and timing constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Timings {
    Timings._();
    static const double listCacheExtent = 1000.0;
    static const Duration snooze1Hour = Duration(hours: 1);
    static const Duration snooze4Hours = Duration(hours: 4);
    static const Duration snooze1Day = Duration(days: 1);
  }
}