// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/promo_content_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class ScreenshotsSectionWidget extends StatelessWidget {
  final PromoController controller;
  final ScreenshotsContent screenshotsContent;

  const ScreenshotsSectionWidget({
    super.key,
    required this.controller,
    required this.screenshotsContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveHelpers.getResponsiveValue(
        context,
        mobile: 500.0,
        tablet: 550.0,
        desktop: PromoConstants.screenshotsHeight,
        ultrawide: 650.0,
      ),
      decoration: BoxDecoration(
        gradient: PromoHelpers.createScreenshotsGradient(),
      ),
      child: Stack(
        children: [
          _buildBackgroundElements(context),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Geometric shapes
          Positioned(
            top: 50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Grid pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSectionHeader(context),
          const Spacer(),
          _buildScreenshotsCarousel(context),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: ResponsiveHelpers.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(PromoConstants.defaultPadding),
        tablet: const EdgeInsets.all(PromoConstants.cardPadding),
        desktop: const EdgeInsets.all(PromoConstants.largeSpacing),
      ),
      child: Column(
        children: [
          Text(
            screenshotsContent.title,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.sectionTitleFontSize,
              ),
              fontWeight: PromoConstants.sectionTitleWeight,
              color: PromoConstants.whiteColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (screenshotsContent.subtitle.isNotEmpty) ...[
            const SizedBox(height: PromoConstants.itemSpacing),
            Text(
              screenshotsContent.subtitle,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(
                  context,
                  PromoConstants.sectionSubtitleFontSize,
                ),
                color: PromoConstants.whiteColor.withValues(alpha: 0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenshotsCarousel(BuildContext context) {
    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        switch (breakpoint) {
          case ResponsiveBreakpoint.mobile:
            return _buildMobileCarousel(context);
          case ResponsiveBreakpoint.tablet:
            return _buildTabletCarousel(context);
          case ResponsiveBreakpoint.desktop:
          case ResponsiveBreakpoint.ultrawide:
            return _buildDesktopCarousel(context);
        }
      },
    );
  }

  Widget _buildMobileCarousel(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        itemCount: screenshotsContent.screenshots.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: PromoConstants.smallSpacing),
            child: _buildScreenshotCard(
              context,
              screenshotsContent.screenshots[index],
              index,
              isFocused: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletCarousel(BuildContext context) {
    return SizedBox(
      height: 450,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PromoConstants.defaultPadding),
        itemCount: screenshotsContent.screenshots.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: PromoConstants.itemSpacing),
            child: _buildScreenshotCard(
              context,
              screenshotsContent.screenshots[index],
              index,
              isFocused: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopCarousel(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          height: 500,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background screenshots
              ..._buildBackgroundScreenshots(context),
              // Main screenshot
              _buildMainScreenshot(context),
              // Navigation arrows
              _buildNavigationArrows(context),
              // Indicators
              _buildIndicators(context),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBackgroundScreenshots(BuildContext context) {
    final currentIndex = controller.currentScreenshotIndex;
    final screenshots = screenshotsContent.screenshots;
    
    return List.generate(screenshots.length, (index) {
      if (index == currentIndex) return const SizedBox.shrink();
      
      final distance = (index - currentIndex).abs();
      final isLeft = index < currentIndex;
      final offset = distance * 200.0;
      
      return Positioned(
        left: isLeft ? null : MediaQuery.of(context).size.width / 2 + offset,
        right: isLeft ? MediaQuery.of(context).size.width / 2 + offset : null,
        child: Transform.scale(
          scale: 1.0 - (distance * 0.2),
          child: Opacity(
            opacity: 1.0 - (distance * 0.3),
            child: _buildScreenshotCard(
              context,
              screenshots[index],
              index,
              isFocused: false,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMainScreenshot(BuildContext context) {
    final currentIndex = controller.currentScreenshotIndex;
    final screenshots = screenshotsContent.screenshots;
    
    if (currentIndex >= screenshots.length) return const SizedBox.shrink();
    
    return _buildScreenshotCard(
      context,
      screenshots[currentIndex],
      currentIndex,
      isFocused: true,
      isMain: true,
    );
  }

  Widget _buildScreenshotCard(
    BuildContext context,
    PromoScreenshot screenshot,
    int index, {
    bool isFocused = false,
    bool isMain = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final cardWidth = ResponsiveHelpers.getResponsiveValue(
      context,
      mobile: screenWidth * 0.7,
      tablet: PromoConstants.screenshotWidth,
      desktop: isMain ? PromoConstants.screenshotWidth + 50 : PromoConstants.screenshotWidth,
      ultrawide: isMain ? PromoConstants.screenshotWidth + 100 : PromoConstants.screenshotWidth,
    );
    
    final cardHeight = ResponsiveHelpers.getResponsiveValue(
      context,
      mobile: 400.0,
      tablet: PromoConstants.screenshotHeight * 0.8,
      desktop: isMain ? PromoConstants.screenshotHeight : PromoConstants.screenshotHeight * 0.9,
      ultrawide: isMain ? PromoConstants.screenshotHeight + 50 : PromoConstants.screenshotHeight,
    );

    return GestureDetector(
      onTap: () => _onScreenshotTap(context, index),
      child: Hero(
        tag: 'screenshot_${screenshot.id}',
        child: Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: PromoConstants.screenshotMargin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PromoConstants.screenshotBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isMain ? 0.3 : 0.2),
                spreadRadius: isMain ? 3 : 1,
                blurRadius: isMain ? 25 : 15,
                offset: Offset(0, isMain ? 12 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PromoConstants.screenshotBorderRadius),
            child: Stack(
              children: [
                // Screenshot image
                Positioned.fill(
                  child: screenshot.url.isNotEmpty
                      ? Image.network(
                          screenshot.url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return PromoHelpers.createLoadingPlaceholder(
                              width: cardWidth,
                              height: cardHeight,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
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
                          color: PromoConstants.backgroundColor,
                          child: Icon(
                            Icons.phone_android,
                            size: ResponsiveHelpers.getResponsiveIconSize(context, 80),
                            color: PromoConstants.primaryColor,
                          ),
                        ),
                ),
                
                // Overlay with title and description
                if (isFocused) _buildScreenshotOverlay(context, screenshot),
                
                // Platform indicator
                _buildPlatformIndicator(context, screenshot),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotOverlay(BuildContext context, PromoScreenshot screenshot) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(PromoConstants.defaultPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              screenshot.title,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: PromoConstants.whiteColor,
              ),
            ),
            if (screenshot.description != null && screenshot.description!.isNotEmpty) ...[
              const SizedBox(height: PromoConstants.smallSpacing),
              Text(
                screenshot.description!,
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                  color: PromoConstants.whiteColor.withValues(alpha: 0.9),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformIndicator(BuildContext context, PromoScreenshot screenshot) {
    return Positioned(
      top: PromoConstants.defaultPadding,
      right: PromoConstants.defaultPadding,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PromoConstants.smallSpacing,
          vertical: PromoConstants.smallSpacing / 2,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(PromoConstants.defaultBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smartphone,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 12),
              color: PromoConstants.whiteColor,
            ),
            const SizedBox(width: PromoConstants.smallSpacing / 2),
            Text(
              'App',
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 10),
                color: PromoConstants.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrows(BuildContext context) {
    if (!ResponsiveHelpers.isDesktop(context)) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous arrow
        Padding(
          padding: const EdgeInsets.only(left: PromoConstants.largeSpacing),
          child: _buildNavigationArrow(
            context,
            Icons.arrow_back_ios,
            () => controller.previousScreenshot(),
            controller.currentScreenshotIndex > 0,
          ),
        ),
        
        // Next arrow
        Padding(
          padding: const EdgeInsets.only(right: PromoConstants.largeSpacing),
          child: _buildNavigationArrow(
            context,
            Icons.arrow_forward_ios,
            () => controller.nextScreenshot(),
            controller.currentScreenshotIndex < screenshotsContent.screenshots.length - 1,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationArrow(BuildContext context, IconData icon, VoidCallback onTap, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isEnabled ? PromoConstants.whiteColor : PromoConstants.whiteColor.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          boxShadow: isEnabled ? PromoConstants.defaultShadow : [],
        ),
        child: Icon(
          icon,
          color: isEnabled ? PromoConstants.primaryColor : PromoConstants.textColor.withValues(alpha: 0.3),
          size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
        ),
      ),
    );
  }

  Widget _buildIndicators(BuildContext context) {
    if (!ResponsiveHelpers.isDesktop(context)) return const SizedBox.shrink();
    
    return Positioned(
      bottom: PromoConstants.defaultPadding,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(screenshotsContent.screenshots.length, (index) {
          return GestureDetector(
            onTap: () => controller.setCurrentScreenshot(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: controller.currentScreenshotIndex == index ? 30 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: controller.currentScreenshotIndex == index
                    ? PromoConstants.whiteColor
                    : PromoConstants.whiteColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onScreenshotTap(BuildContext context, int index) {
    if (ResponsiveHelpers.isDesktop(context)) {
      controller.setCurrentScreenshot(index);
    } else {
      // On mobile/tablet, show fullscreen view
      _showFullscreenScreenshot(context, index);
    }
  }

  void _showFullscreenScreenshot(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: index),
              itemCount: screenshotsContent.screenshots.length,
              itemBuilder: (context, pageIndex) {
                final screenshot = screenshotsContent.screenshots[pageIndex];
                return Hero(
                  tag: 'screenshot_${screenshot.id}',
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(PromoConstants.defaultBorderRadius),
                      child: Image.network(
                        screenshot.url,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
