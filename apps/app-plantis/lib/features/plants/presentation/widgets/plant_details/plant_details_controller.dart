import 'package:flutter/material.dart';

import '../../../../../core/localization/app_strings.dart';
import '../../../domain/entities/plant.dart';
import '../../providers/plant_details_provider.dart';

/// Controller responsible for business logic of the plant details screen
///
/// This controller follows the separation of concerns principle by not using
/// BuildContext directly. Instead, it uses callback functions to trigger UI actions.
/// This approach makes the controller more testable and decouples it from the UI.
///
/// The controller handles:
/// - Plant data loading and refreshing
/// - Navigation actions (back, edit, images, schedule)
/// - Plant operations (delete, share, duplicate)
/// - Error handling and success/failure messaging
///
/// Example usage:
/// ```dart
/// final controller = PlantDetailsController(
///   provider: plantDetailsProvider,
///   onBack: () => Navigator.of(context).pop(),
///   onShowSnackBar: (message, type) => showSnackBar(message),
/// );
/// controller.loadPlant('plant-id-123');
/// ```
class PlantDetailsController {
  final PlantDetailsProvider provider;
  final VoidCallback? onBack;
  final void Function(String)? onNavigateToEdit;
  final void Function(String)? onNavigateToImages;
  final void Function(String)? onNavigateToSchedule;
  final void Function(String, String)? onShowSnackBar;
  final void Function(String, String, {Color? backgroundColor})?
  onShowSnackBarWithColor;
  final void Function(Widget)? onShowDialog;
  final void Function(Widget)? onShowBottomSheet;
  final void Function(String)? onPlantDeleted;

  PlantDetailsController({
    required this.provider,
    this.onBack,
    this.onNavigateToEdit,
    this.onNavigateToImages,
    this.onNavigateToSchedule,
    this.onShowSnackBar,
    this.onShowSnackBarWithColor,
    this.onShowDialog,
    this.onShowBottomSheet,
    this.onPlantDeleted,
  });

  /// Loads a plant by its unique identifier
  ///
  /// This method triggers the provider to fetch plant data from the repository.
  /// The UI will automatically update when the data loading state changes.
  ///
  /// Parameters:
  /// - [plantId]: The unique identifier of the plant to load
  ///
  /// Example:
  /// ```dart
  /// controller.loadPlant('plant-123');
  /// ```
  void loadPlant(String plantId) {
    provider.loadPlant(plantId);
  }

  /// Refreshes the current plant data
  ///
  /// This method forces a reload of the plant data, useful for recovering
  /// from error states or ensuring the latest data is displayed.
  ///
  /// Parameters:
  /// - [plantId]: The unique identifier of the plant to refresh
  ///
  /// Example:
  /// ```dart
  /// controller.refresh('plant-123');
  /// ```
  void refresh(String plantId) {
    provider.loadPlant(plantId);
  }

  /// Navigates back to the previous screen
  ///
  /// This method triggers the back navigation callback, typically closing
  /// the plant details screen and returning to the plants list.
  ///
  /// Example:
  /// ```dart
  /// controller.goBack();
  /// ```
  void goBack() {
    onBack?.call();
  }

  /// Shows the plant editing dialog
  ///
  /// This method displays a modal dialog with the plant form in edit mode,
  /// allowing users to modify the plant's information. Using a dialog ensures
  /// consistent UX with the plant creation flow and prevents navigation issues.
  ///
  /// Parameters:
  /// - [plant]: The plant entity containing the current plant data
  ///
  /// Example:
  /// ```dart
  /// controller.editPlant(selectedPlant);
  /// ```
  void editPlant(Plant plant) {
    onNavigateToEdit?.call(plant.id);
  }

  /// Navigates to the plant image management screen
  ///
  /// This method opens the photo gallery where users can view, add,
  /// edit, and delete plant images.
  ///
  /// Parameters:
  /// - [plant]: The plant entity for which to manage images
  ///
  /// Example:
  /// ```dart
  /// controller.managePhotos(selectedPlant);
  /// ```
  void managePhotos(Plant plant) {
    onNavigateToImages?.call(plant.id);
  }

  /// Navigates to the plant care schedule editing screen
  ///
  /// This method opens the schedule management interface where users
  /// can configure watering, fertilizing, and other care reminders.
  ///
  /// Parameters:
  /// - [plant]: The plant entity for which to edit the schedule
  ///
  /// Example:
  /// ```dart
  /// controller.editSchedule(selectedPlant);
  /// ```
  void editSchedule(Plant plant) {
    onNavigateToSchedule?.call(plant.id);
  }

  /// Displays plant editing options in a bottom sheet
  ///
  /// This method shows a modal bottom sheet with various plant editing
  /// options like edit details, manage photos, etc.
  ///
  /// Parameters:
  /// - [plant]: The plant entity for which to show edit options
  /// - [bottomSheetBuilder]: A function that builds the bottom sheet widget
  ///
  /// Example:
  /// ```dart
  /// controller.showEditOptions(plant, (p) => EditOptionsSheet(plant: p));
  /// ```
  void showEditOptions(Plant plant, Widget Function(Plant) bottomSheetBuilder) {
    onShowBottomSheet?.call(bottomSheetBuilder(plant));
  }

  /// Displays additional plant options in a bottom sheet
  ///
  /// This method shows a modal bottom sheet with extended plant actions
  /// like share, duplicate, delete, etc.
  ///
  /// Parameters:
  /// - [plant]: The plant entity for which to show more options
  /// - [bottomSheetBuilder]: A function that builds the bottom sheet widget
  ///
  /// Example:
  /// ```dart
  /// controller.showMoreOptions(plant, (p) => MoreOptionsSheet(plant: p));
  /// ```
  void showMoreOptions(Plant plant, Widget Function(Plant) bottomSheetBuilder) {
    onShowBottomSheet?.call(bottomSheetBuilder(plant));
  }

  /// Shows a confirmation dialog before deleting a plant
  ///
  /// This method displays a confirmation dialog to ensure the user
  /// really wants to delete the plant, as this action is irreversible.
  ///
  /// Parameters:
  /// - [plant]: The plant entity to be potentially deleted
  /// - [dialogBuilder]: A function that builds the confirmation dialog
  ///
  /// Example:
  /// ```dart
  /// controller.confirmDelete(plant, (p) => DeleteConfirmDialog(plant: p));
  /// ```
  void confirmDelete(Plant plant, Widget Function(Plant) dialogBuilder) {
    onShowDialog?.call(dialogBuilder(plant));
  }

  /// Deletes a plant permanently from the system
  ///
  /// This method performs the actual plant deletion operation.
  /// It loads the plant data, attempts to delete it through the provider,
  /// and provides feedback through callbacks.
  ///
  /// The deletion process:
  /// 1. Loads the plant data to ensure it exists
  /// 2. Calls the provider's delete method
  /// 3. Shows success message and navigates back on success
  /// 4. Shows error message on failure
  ///
  /// Parameters:
  /// - [plantId]: The unique identifier of the plant to delete
  ///
  /// Returns:
  /// - A [Future] that completes when the deletion operation finishes
  ///
  /// Example:
  /// ```dart
  /// await controller.deletePlant('plant-123');
  /// ```
  Future<void> deletePlant(String plantId) async {
    try {
      final success =
          await provider.deletePlant(); // Deleta a planta atual no provider

      if (success) {
        onPlantDeleted?.call(plantId);

        onShowSnackBarWithColor?.call(
          AppStrings.plantDeletedSuccessfully,
          '',
          backgroundColor: Colors.green,
        );
        onBack?.call();
      } else {
        onShowSnackBar?.call(
          provider.errorMessage ?? AppStrings.errorDeletingPlant,
          'error',
        );
      }
    } catch (e) {
      onShowSnackBar?.call('${AppStrings.errorDeletingPlant}: $e', 'error');
    }
  }

  /// Shares plant information with other applications
  ///
  /// This method allows users to share plant details through various
  /// channels like social media, messaging apps, or email.
  ///
  /// Currently shows a development message as the feature is being implemented.
  ///
  /// Parameters:
  /// - [plant]: The plant entity whose information should be shared
  ///
  /// Example:
  /// ```dart
  /// controller.sharePlant(selectedPlant);
  /// ```
  void sharePlant(Plant plant) {
    onShowSnackBar?.call(AppStrings.sharingFeatureInDevelopment, 'info');
  }

  /// Creates a duplicate copy of an existing plant
  ///
  /// This method creates a new plant entry with the same characteristics
  /// as the original plant, useful for users who want to track multiple
  /// plants of the same species or similar care requirements.
  ///
  /// Currently shows a development message as the feature is being implemented.
  ///
  /// Parameters:
  /// - [plant]: The plant entity to be duplicated
  ///
  /// Example:
  /// ```dart
  /// controller.duplicatePlant(selectedPlant);
  /// ```
  void duplicatePlant(Plant plant) {
    onShowSnackBar?.call(AppStrings.duplicateFeatureInDevelopment, 'info');
  }

  /// Displays an error message to the user
  ///
  /// This method shows error messages through the snackbar callback.
  /// Used for displaying validation errors, network issues, or other failures.
  ///
  /// Parameters:
  /// - [message]: The error message to display to the user
  ///
  /// Example:
  /// ```dart
  /// controller.showError('Failed to load plant data');
  /// ```
  void showError(String message) {
    onShowSnackBar?.call(message, 'error');
  }

  /// Displays a success message to the user
  ///
  /// This method shows success messages through the snackbar callback
  /// with a green background to indicate successful operations.
  ///
  /// Parameters:
  /// - [message]: The success message to display to the user
  ///
  /// Example:
  /// ```dart
  /// controller.showSuccess('Plant updated successfully!');
  /// ```
  void showSuccess(String message) {
    onShowSnackBarWithColor?.call(message, '', backgroundColor: Colors.green);
  }
}
