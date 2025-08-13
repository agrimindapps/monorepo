import 'package:flutter/material.dart';

/// Interface for app rating functionality
abstract class IAppRatingRepository {
  /// Shows the native app store rating dialog
  /// Returns true if the rating dialog was shown successfully
  Future<bool> showRatingDialog({BuildContext? context});
  
  /// Opens the app store page for manual review
  /// Returns true if the app store was opened successfully
  Future<bool> openAppStore();
  
  /// Checks if rating dialog can be shown (based on usage conditions)
  /// Returns true if conditions are met to show rating prompt
  Future<bool> canShowRatingDialog();
  
  /// Increments the app usage count for rating conditions
  Future<void> incrementUsageCount();
  
  /// Marks that user has already rated the app
  Future<void> markAsRated();
  
  /// Checks if user has already rated the app
  Future<bool> hasUserRated();
  
  /// Sets minimum usage count before showing rating dialog
  /// [count] - minimum number of app launches/usage before showing dialog
  Future<void> setMinimumUsageCount(int count);
  
  /// Resets all rating preferences (useful for testing)
  Future<void> resetRatingPreferences();
}