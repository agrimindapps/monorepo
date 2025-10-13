import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/theme/plantis_colors.dart';
import 'plant_details_controller.dart';

/// Error state widget for plant details screen
///
/// This widget displays a user-friendly error interface with recovery options
/// including retry functionality, troubleshooting tips, and help dialog.
///
/// Features:
/// - Clear error messaging with illustration
/// - Retry functionality to recover from temporary failures
/// - Expandable error details for debugging
/// - Troubleshooting tips for common issues
/// - Help dialog for additional support
/// - Navigation options to return to previous screen
class PlantDetailsErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final PlantDetailsController? controller;
  final String plantId;

  const PlantDetailsErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onBack,
    this.controller,
    required this.plantId,
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
          AppStrings.error,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
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
                child: Icon(
                  Icons.eco,
                  size: 60,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),

              Semantics(
                label: AppStrings.plantLoadError,
                liveRegion: true,
                child: Text(
                  AppStrings.oopsError,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.buttonSpacing),

              Text(
                AppStrings.plantLoadError,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.iconPadding),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                ErrorDetailsSection(errorMessage: errorMessage!),

              const SizedBox(height: 32),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppStrings.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlantisColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.buttonSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text(AppStrings.goBack),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonSpacing,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.buttonSpacing),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => ErrorHelpDialog.show(context),
                          icon: const Icon(Icons.help_outline),
                          label: const Text(AppStrings.help),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonSpacing,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sectionSpacing),
              const TroubleshootingTipsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable section showing detailed error information
///
/// This widget displays technical error details in an expandable format,
/// helping developers and support teams diagnose issues while keeping
/// the interface clean for regular users.
class ErrorDetailsSection extends StatelessWidget {
  final String errorMessage;

  const ErrorDetailsSection({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        AppStrings.errorDetails,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      iconColor: theme.colorScheme.onSurfaceVariant,
      collapsedIconColor: theme.colorScheme.onSurfaceVariant,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.iconPadding,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            errorMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

/// Card showing troubleshooting tips for common error scenarios
///
/// This widget provides users with actionable steps to resolve common
/// issues, improving user experience during error states.
class TroubleshootingTipsSection extends StatelessWidget {
  const TroubleshootingTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.troubleshootingTips,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const TipItem(tip: AppStrings.checkConnection),
          const TipItem(tip: AppStrings.restartApp),
          const TipItem(tip: AppStrings.checkUpdates),
        ],
      ),
    );
  }
}

/// Individual tip item with bullet point styling
///
/// Displays a single troubleshooting tip with consistent formatting
/// and bullet point indicator.
class TipItem extends StatelessWidget {
  final String tip;

  const TipItem({
    super.key,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.iconPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.tipBulletSize,
            height: AppSpacing.tipBulletSize,
            margin: const EdgeInsets.only(
              top: AppSpacing.iconPadding,
              right: AppSpacing.buttonSpacing,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSpacing.tipBulletSize / 2),
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog showing help information for error recovery
///
/// Provides additional support information when users need help
/// understanding or resolving errors.
class ErrorHelpDialog {
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.needHelp),
            content: const Text(AppStrings.helpMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.understood),
              ),
            ],
          ),
    );
  }
}
