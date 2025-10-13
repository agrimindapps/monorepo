import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/theme/plantis_colors.dart';

/// Constants for loading state styling
class _LoadingConstants {
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color darkCardColor = Color(0xFF2C2C2E);
}

/// Main loading state widget for plant details screen
///
/// This widget creates a comprehensive loading interface that includes:
/// - Loading shimmer effects for plant image, name, and description
/// - Placeholder tabs and content cards
/// - Semantic labels for accessibility
/// - Smooth animations and proper spacing
///
/// The loading state provides visual feedback while plant data is being fetched,
/// improving the user experience by showing content structure.
class PlantDetailsLoadingState extends StatelessWidget {
  final BuildContext context;
  final VoidCallback onBack;

  const PlantDetailsLoadingState({
    super.key,
    required this.context,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: PlantisColors.getPageBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: AppSpacing.appBarHeight,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            leading: IconButton(
              onPressed: onBack,
              icon: Container(
                padding: const EdgeInsets.all(AppSpacing.iconPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: LoadingImageSection(context: context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingShimmer(
                    height: AppSpacing.sectionSpacing,
                    width: 200,
                  ),
                  const SizedBox(height: AppSpacing.iconPadding),
                  const LoadingShimmer(height: AppSpacing.lg, width: 150),
                  const SizedBox(height: AppSpacing.sectionSpacing),
                  LoadingTabsSection(context: context),
                  const SizedBox(height: AppSpacing.lg),
                  ...[
                    for (int i = 0; i < 3; i++) ...[
                      LoadingCardWidget(context: context),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state for the plant image section
///
/// Displays a gradient background with a centered loading spinner
/// and a loading message. Includes semantic labels for accessibility.
class LoadingImageSection extends StatelessWidget {
  final BuildContext context;

  const LoadingImageSection({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppSpacing.loadingImageHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary.withValues(alpha: 0.1),
            PlantisColors.primaryLight.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.iconSize,
              height: AppSpacing.iconSize,
              decoration: BoxDecoration(
                color: PlantisColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusCircular,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: AppSpacing.strokeWidth,
                  color: PlantisColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              label: AppStrings.loadingPlantAriaLabel,
              liveRegion: true,
              child: Text(
                AppStrings.loadingPlant,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state for the tabs section
///
/// Displays a container with four placeholder tabs that match
/// the styling of the actual tab bar.
class LoadingTabsSection extends StatelessWidget {
  final BuildContext context;

  const LoadingTabsSection({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppSpacing.tabHeight,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? _LoadingConstants.darkCardColor
                : _LoadingConstants.lightBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusSmall,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading card widget for content placeholders
///
/// Displays a skeleton card with shimmer effects to indicate
/// loading content. Used for plant information sections.
class LoadingCardWidget extends StatelessWidget {
  final BuildContext context;

  const LoadingCardWidget({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? _LoadingConstants.darkCardColor
                : _LoadingConstants.lightBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(height: AppSpacing.xl, width: 150),
          SizedBox(height: AppSpacing.iconPadding),
          LoadingShimmer(height: AppSpacing.lg, width: double.infinity),
          SizedBox(height: AppSpacing.xs),
          LoadingShimmer(height: AppSpacing.lg, width: 250),
        ],
      ),
    );
  }
}

/// Optimized loading shimmer widget that doesn't rebuild unnecessarily
///
/// Creates a shimmer effect placeholder with the specified dimensions
/// and colors that adapt to the current theme (light/dark mode).
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key, required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
      ),
    );
  }
}
