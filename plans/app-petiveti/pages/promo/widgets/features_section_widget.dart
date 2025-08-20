// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/promo_content_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class FeaturesSectionWidget extends StatelessWidget {
  final PromoController controller;
  final FeaturesContent featuresContent;

  const FeaturesSectionWidget({
    super.key,
    required this.controller,
    required this.featuresContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelpers.getResponsiveSectionPadding(context),
      color: PromoConstants.backgroundColor,
      child: Column(
        children: [
          _buildSectionHeader(context),
          const SizedBox(height: PromoConstants.largeSpacing),
          _buildFeaturesGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        // Section title
        Text(
          featuresContent.title,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.sectionTitleFontSize,
            ),
            fontWeight: PromoConstants.sectionTitleWeight,
            color: PromoConstants.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Section subtitle
        if (featuresContent.subtitle.isNotEmpty) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          Text(
            featuresContent.subtitle,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.sectionSubtitleFontSize,
              ),
              color: PromoConstants.textColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        // Accent line
        Container(
          margin: const EdgeInsets.symmetric(vertical: PromoConstants.itemSpacing),
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: PromoConstants.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final columns = ResponsiveHelpers.getResponsiveGridColumns(
      context,
      mobile: PromoConstants.featuresGridMobile,
      tablet: PromoConstants.featuresGridTablet,
      desktop: PromoConstants.featuresGridDesktop,
      ultrawide: 4,
    );

    final spacing = ResponsiveHelpers.getResponsiveGridSpacing(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: PromoConstants.featuresGridSpacing,
      ultrawide: 40.0,
    );

    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        if (breakpoint == ResponsiveBreakpoint.mobile) {
          return _buildMobileLayout(context);
        } else {
          return _buildGridLayout(context, columns, spacing);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: featuresContent.features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: PromoConstants.itemSpacing),
          child: _buildFeatureCard(context, feature, isMobile: true),
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(BuildContext context, int columns, double spacing) {
    final features = featuresContent.features;
    final rows = (features.length / columns).ceil();
    
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final endIndex = (startIndex + columns).clamp(0, features.length);
        final rowFeatures = features.sublist(startIndex, endIndex);
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rows - 1 ? spacing : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columns, (colIndex) {
              if (colIndex < rowFeatures.length) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: colIndex < columns - 1 ? spacing : 0,
                    ),
                    child: _buildFeatureCard(context, rowFeatures[colIndex]),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureCard(BuildContext context, PromoFeature feature, {bool isMobile = false}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onFeatureHover(context, feature, true),
          onExit: (_) => _onFeatureHover(context, feature, false),
          child: GestureDetector(
            onTap: () => _onFeatureTap(context, feature),
            child: AnimatedContainer(
              duration: PromoConstants.defaultAnimation,
              curve: PromoConstants.defaultCurve,
              height: ResponsiveHelpers.getResponsiveCardHeight(
                context,
                PromoConstants.featureCardHeight,
                mobileScale: 0.9,
              ),
              padding: ResponsiveHelpers.getResponsivePadding(
                context,
                mobile: const EdgeInsets.all(PromoConstants.cardPadding),
                tablet: const EdgeInsets.all(PromoConstants.cardPadding + 4),
                desktop: const EdgeInsets.all(PromoConstants.cardPadding + 8),
              ),
              decoration: _buildFeatureCardDecoration(feature),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureIcon(context, feature),
                  const SizedBox(height: PromoConstants.itemSpacing),
                  _buildFeatureTitle(context, feature),
                  const SizedBox(height: PromoConstants.smallSpacing),
                  _buildFeatureDescription(context, feature),
                  const Spacer(),
                  if (feature.isHighlight) _buildHighlightBadge(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildFeatureCardDecoration(PromoFeature feature) {
    final isHovered = controller.hoveredFeature == feature.id;
    
    return BoxDecoration(
      color: PromoConstants.whiteColor,
      borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
      boxShadow: isHovered
          ? [
              BoxShadow(
                color: feature.color?.withValues(alpha: 0.3) ?? PromoConstants.primaryColor.withValues(alpha: 0.3),
                spreadRadius: 3,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : PromoConstants.defaultShadow,
      border: isHovered
          ? Border.all(
              color: feature.color ?? PromoConstants.primaryColor,
              width: 2,
            )
          : null,
    );
  }

  Widget _buildFeatureIcon(BuildContext context, PromoFeature feature) {
    final iconSize = ResponsiveHelpers.getResponsiveIconSize(
      context,
      PromoConstants.featureIconSize,
    );
    
    return Container(
      width: ResponsiveHelpers.getResponsiveIconSize(
        context,
        PromoConstants.featureIconContainerSize,
      ),
      height: ResponsiveHelpers.getResponsiveIconSize(
        context,
        PromoConstants.featureIconContainerSize,
      ),
      decoration: BoxDecoration(
        gradient: PromoHelpers.getFeatureGradient(feature.category),
        borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
        boxShadow: [
          BoxShadow(
            color: (feature.color ?? PromoConstants.primaryColor).withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        feature.icon,
        size: iconSize,
        color: PromoConstants.whiteColor,
      ),
    );
  }

  Widget _buildFeatureTitle(BuildContext context, PromoFeature feature) {
    return Text(
      feature.title,
      style: TextStyle(
        fontSize: ResponsiveHelpers.getResponsiveFontSize(
          context,
          PromoConstants.cardTitleFontSize,
        ),
        fontWeight: PromoConstants.cardTitleWeight,
        color: PromoConstants.textColor,
        height: 1.3,
      ),
    );
  }

  Widget _buildFeatureDescription(BuildContext context, PromoFeature feature) {
    return Expanded(
      child: Text(
        feature.description,
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(
            context,
            PromoConstants.cardDescriptionFontSize,
          ),
          color: PromoConstants.textColor.withValues(alpha: 0.7),
          height: 1.5,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHighlightBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PromoConstants.smallSpacing * 2,
        vertical: PromoConstants.smallSpacing / 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PromoConstants.accentColor,
            PromoConstants.accentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(PromoConstants.defaultBorderRadius),
      ),
      child: Text(
        'DESTAQUE',
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 10),
          fontWeight: FontWeight.bold,
          color: PromoConstants.whiteColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _onFeatureHover(BuildContext context, PromoFeature feature, bool isHovered) {
    if (ResponsiveHelpers.isDesktop(context)) {
      controller.setHoveredFeature(isHovered ? feature.id : null);
    }
  }

  void _onFeatureTap(BuildContext context, PromoFeature feature) {
    // Handle feature tap - could show more details, navigate, etc.
    PromoHelpers.debugPrint('Feature tapped: ${feature.title}');
    
    // Example: Show feature details in a dialog
    _showFeatureDetails(context, feature);
  }

  void _showFeatureDetails(BuildContext context, PromoFeature feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
        ),
        title: Row(
          children: [
            Icon(
              feature.icon,
              color: feature.color ?? PromoConstants.primaryColor,
              size: 24,
            ),
            const SizedBox(width: PromoConstants.smallSpacing),
            Text(feature.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature.description,
              style: const TextStyle(height: 1.5),
            ),
            if (feature.isHighlight) ...[
              const SizedBox(height: PromoConstants.itemSpacing),
              Container(
                padding: const EdgeInsets.all(PromoConstants.smallSpacing),
                decoration: BoxDecoration(
                  color: PromoConstants.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(PromoConstants.defaultBorderRadius),
                  border: Border.all(
                    color: PromoConstants.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: PromoConstants.accentColor,
                      size: 16,
                    ),
                    SizedBox(width: PromoConstants.smallSpacing),
                    Text(
                      'Recurso em destaque',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: PromoConstants.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.showPreRegisterDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: feature.color ?? PromoConstants.primaryColor,
              foregroundColor: PromoConstants.whiteColor,
            ),
            child: const Text('Seja Notificado'),
          ),
        ],
      ),
    );
  }
}

// Navigation service for accessing context
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
