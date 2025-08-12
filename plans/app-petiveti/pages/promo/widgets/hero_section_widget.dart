// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/navigation_model.dart';
import '../models/promo_content_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class HeroSectionWidget extends StatelessWidget {
  final PromoController controller;
  final HeroContent heroContent;

  const HeroSectionWidget({
    super.key,
    required this.controller,
    required this.heroContent,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        return Container(
          height: ResponsiveHelpers.getResponsiveHeroHeight(context),
          decoration: BoxDecoration(
            gradient: PromoHelpers.createHeroGradient(),
          ),
          child: Stack(
            children: [
              _buildBackgroundElements(context, breakpoint),
              _buildContent(context, breakpoint),
              _buildFloatingElements(context, breakpoint),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundElements(BuildContext context, ResponsiveBreakpoint breakpoint) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ResponsiveBreakpoint breakpoint) {
    return SafeArea(
      child: Padding(
        padding: ResponsiveHelpers.getResponsiveSectionPadding(context),
        child: ResponsiveHelpers.buildResponsive(
          context,
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
          desktop: _buildDesktopLayout(context),
          ultrawide: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        _buildHeroImage(context, ResponsiveBreakpoint.mobile),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildTextContent(context, ResponsiveBreakpoint.mobile),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildActionButtons(context, ResponsiveBreakpoint.mobile),
        const Spacer(),
        _buildScrollIndicator(context),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextContent(context, ResponsiveBreakpoint.tablet),
              const SizedBox(height: PromoConstants.largeSpacing),
              _buildActionButtons(context, ResponsiveBreakpoint.tablet),
            ],
          ),
        ),
        const SizedBox(width: PromoConstants.largeSpacing),
        Expanded(
          flex: 2,
          child: _buildHeroImage(context, ResponsiveBreakpoint.tablet),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextContent(context, ResponsiveBreakpoint.desktop),
              const SizedBox(height: PromoConstants.largeSpacing),
              _buildActionButtons(context, ResponsiveBreakpoint.desktop),
              const SizedBox(height: PromoConstants.largeSpacing),
              _buildFeatureHighlights(context),
            ],
          ),
        ),
        const SizedBox(width: PromoConstants.largeSpacing * 2),
        Expanded(
          flex: 2,
          child: _buildHeroImage(context, ResponsiveBreakpoint.desktop),
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context, ResponsiveBreakpoint breakpoint) {
    final imageSize = ResponsiveHelpers.getResponsiveImageSize(
      context,
      const Size(400, 500),
      mobileScale: 0.8,
      tabletScale: 1.0,
      desktopScale: 1.2,
      ultrawideScale: 1.4,
    );

    return Hero(
      tag: 'hero_image',
      child: Container(
        width: imageSize.width,
        height: imageSize.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveHelpers.getResponsiveBorderRadius(
              context,
              PromoConstants.imageBorderRadius,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            ResponsiveHelpers.getResponsiveBorderRadius(
              context,
              PromoConstants.imageBorderRadius,
            ),
          ),
          child: heroContent.imageUrl.isNotEmpty
              ? Image.network(
                  heroContent.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return PromoHelpers.createLoadingPlaceholder(
                      width: imageSize.width,
                      height: imageSize.height,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: imageSize.width,
                      height: imageSize.height,
                      color: PromoConstants.backgroundColor,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: PromoConstants.textColor,
                      ),
                    );
                  },
                )
              : Container(
                  width: imageSize.width,
                  height: imageSize.height,
                  color: PromoConstants.backgroundColor,
                  child: Icon(
                    Icons.pets,
                    size: ResponsiveHelpers.getResponsiveIconSize(context, 100),
                    color: PromoConstants.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, ResponsiveBreakpoint breakpoint) {
    final isMobile = breakpoint == ResponsiveBreakpoint.mobile;
    
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          heroContent.title,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.heroTitleFontSize,
            ),
            fontWeight: PromoConstants.heroTitleWeight,
            color: PromoConstants.whiteColor,
            height: 1.2,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        
        // Accent line
        Container(
          margin: const EdgeInsets.symmetric(vertical: PromoConstants.itemSpacing),
          width: ResponsiveHelpers.getResponsiveValue(
            context,
            mobile: 60.0,
            tablet: PromoConstants.heroAccentLineWidth,
            desktop: PromoConstants.heroAccentLineWidth,
            ultrawide: PromoConstants.heroAccentLineWidth,
          ),
          height: PromoConstants.heroAccentLineHeight,
          decoration: BoxDecoration(
            color: PromoConstants.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // Subtitle
        Text(
          heroContent.subtitle,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.heroSubtitleFontSize,
            ),
            fontWeight: PromoConstants.heroSubtitleWeight,
            color: PromoConstants.whiteColor.withValues(alpha: 0.9),
            height: 1.4,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        
        // Description
        if (heroContent.description.isNotEmpty) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          Text(
            heroContent.description,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.bodyFontSize,
              ),
              color: PromoConstants.whiteColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ResponsiveBreakpoint breakpoint) {
    final isMobile = breakpoint == ResponsiveBreakpoint.mobile;
    
    return Wrap(
      spacing: PromoConstants.itemSpacing,
      runSpacing: PromoConstants.smallSpacing,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        // Pre-register button
        ElevatedButton.icon(
          onPressed: () => controller.showPreRegisterDialog(),
          icon: Icon(
            Icons.notifications_active,
            size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
          ),
          label: Text(
            'Seja Notificado',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
              fontWeight: PromoConstants.buttonWeight,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: PromoConstants.primaryColor,
            backgroundColor: PromoConstants.whiteColor,
            padding: ResponsiveHelpers.getResponsivePadding(
              context,
              mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              tablet: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              desktop: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
            ),
            elevation: PromoConstants.buttonElevation,
          ),
        ),
        
        // Learn more button
        OutlinedButton.icon(
          onPressed: () => controller.scrollToSection(NavigationSection.features),
          icon: Icon(
            Icons.expand_more,
            size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
          ),
          label: Text(
            'Saiba Mais',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
              fontWeight: PromoConstants.buttonWeight,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: PromoConstants.whiteColor,
            side: const BorderSide(color: PromoConstants.whiteColor, width: 2),
            padding: ResponsiveHelpers.getResponsivePadding(
              context,
              mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              tablet: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              desktop: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    return Wrap(
      spacing: PromoConstants.itemSpacing,
      runSpacing: PromoConstants.smallSpacing,
      children: heroContent.highlights.map((highlight) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PromoConstants.smallSpacing * 2,
            vertical: PromoConstants.smallSpacing,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(PromoConstants.defaultBorderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
                color: PromoConstants.whiteColor,
              ),
              const SizedBox(width: PromoConstants.smallSpacing),
              Text(
                highlight,
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                  color: PromoConstants.whiteColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingElements(BuildContext context, ResponsiveBreakpoint breakpoint) {
    if (breakpoint == ResponsiveBreakpoint.mobile) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Floating stats or badges could go here
        Positioned(
          top: ResponsiveHelpers.getResponsiveValue(context, mobile: 100.0, tablet: 120.0, desktop: 140.0),
          right: ResponsiveHelpers.getResponsiveValue(context, mobile: 20.0, tablet: 40.0, desktop: 60.0),
          child: _buildFloatingBadge(context, 'Lançamento em breve'),
        ),
      ],
    );
  }

  Widget _buildFloatingBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PromoConstants.defaultPadding,
        vertical: PromoConstants.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: PromoConstants.accentColor,
        borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
          color: PromoConstants.whiteColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScrollIndicator(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => controller.scrollToSection(NavigationSection.features),
          child: Column(
            children: [
              Text(
                'Role para baixo',
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                  color: PromoConstants.whiteColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: PromoConstants.smallSpacing),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (value * 10) - 5),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: PromoConstants.whiteColor.withValues(alpha: 0.7),
                      size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
