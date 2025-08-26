import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/task.dart';

/// Utility class for task display-related operations
/// 
/// This class centralizes the logic for converting task enums to display strings,
/// eliminating code duplication across the UI layer. It ensures consistency in
/// how task types and priorities are presented to users throughout the app.
/// 
/// Benefits:
/// - Centralized display logic reduces duplication
/// - Consistent naming across all UI components  
/// - Easy to maintain and update display names
/// - Type-safe conversion from enums to localized strings
/// - Single source of truth for task display formatting
/// 
/// Usage:
/// ```dart
/// final displayName = TaskDisplayUtils.getTaskTypeName(TaskType.watering);
/// final priorityName = TaskDisplayUtils.getPriorityName(TaskPriority.high);
/// ```
class TaskDisplayUtils {
  // Private constructor to prevent instantiation
  TaskDisplayUtils._();

  /// Returns the localized display name for a task type
  /// 
  /// This method provides consistent naming for task types across the entire
  /// application. All display names are retrieved from the AppStrings class
  /// to ensure proper localization support.
  /// 
  /// Parameters:
  /// - [type]: The task type enum value to get a display name for
  /// 
  /// Returns:
  /// - Localized display name string for the task type
  /// 
  /// Example:
  /// ```dart
  /// final name = TaskDisplayUtils.getTaskTypeName(TaskType.watering);
  /// print(name); // "Rega"
  /// ```
  static String getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return AppStrings.taskTypeWatering;
      case TaskType.fertilizing:
        return AppStrings.taskTypeFertilizing;
      case TaskType.pruning:
        return AppStrings.taskTypePruning;
      case TaskType.pestInspection:
        return AppStrings.taskTypePestInspection;
      case TaskType.repotting:
        return AppStrings.taskTypeRepotting;
      case TaskType.cleaning:
        return AppStrings.taskTypeCleaning;
      case TaskType.spraying:
        return AppStrings.taskTypeSpraying;
      case TaskType.sunlight:
        return AppStrings.taskTypeSunlight;
      case TaskType.shade:
        return AppStrings.taskTypeShade;
      case TaskType.custom:
        return AppStrings.taskTypeCustom;
    }
  }

  /// Returns the localized display name for a task priority level
  /// 
  /// This method provides consistent naming for priority levels across the
  /// entire application. All display names are retrieved from the AppStrings
  /// class to ensure proper localization support.
  /// 
  /// Parameters:
  /// - [priority]: The task priority enum value to get a display name for
  /// 
  /// Returns:
  /// - Localized display name string for the priority level
  /// 
  /// Example:
  /// ```dart
  /// final name = TaskDisplayUtils.getPriorityName(TaskPriority.urgent);
  /// print(name); // "Urgente"
  /// ```
  static String getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppStrings.priorityUrgent;
      case TaskPriority.high:
        return AppStrings.priorityHigh;
      case TaskPriority.medium:
        return AppStrings.priorityMedium;
      case TaskPriority.low:
        return AppStrings.priorityLow;
    }
  }
}