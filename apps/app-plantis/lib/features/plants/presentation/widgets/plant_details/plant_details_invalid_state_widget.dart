import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/theme/plantis_colors.dart';
import '../../../domain/entities/plant.dart';

/// Widget that displays the invalid data state for plant details
///
/// This widget is displayed when a plant has incomplete or invalid data
/// that prevents it from being properly shown in the details view.
///
/// Features:
/// - Warning icon with clear messaging about data issues
/// - Edit button to fix the plant data (if plant ID exists)
/// - Back button to return to plant list
/// - Full accessibility support with semantic labels
///
/// The widget provides a clear path for users to resolve data issues
/// by editing the plant or returning to the list.
///
/// Example usage:
/// ```dart
/// PlantDetailsInvalidDataState(
///   context: context,
///   plant: plant,
///   onEdit: () => _controller.editPlant(plant),
/// )
/// ```
class PlantDetailsInvalidDataState extends StatelessWidget {
  final BuildContext context;
  final Plant plant;
  final VoidCallback onEdit;

  const PlantDetailsInvalidDataState({
    super.key,
    required this.context,
    required this.plant,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: PlantisColors.getPageBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          AppStrings.incompleteData,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Semantics(
          label: AppStrings.backToPlantList,
          button: true,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),

              Semantics(
                label: AppStrings.incompleteDataAriaLabel,
                child: Text(
                  AppStrings.incompleteData,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.buttonSpacing),

              Text(
                AppStrings.incompleteDataMessage,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),
              Column(
                children: [
                  if (plant.id.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        label: AppStrings.editPlantData,
                        button: true,
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit),
                          label: const Text(AppStrings.editPlant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlantisColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (plant.id.isNotEmpty) const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(AppStrings.goBack),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
