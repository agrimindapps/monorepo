// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../services/responsive_service.dart';
import 'promo_constants.dart';

class ResponsiveHelpers {
  ResponsiveHelpers._();

  // Get responsive value based on screen width
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? ultrawide,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= PromoConstants.ultrawideBreakpoint) {
      return ultrawide ?? desktop ?? tablet ?? mobile;
    } else if (screenWidth >= PromoConstants.desktopBreakpoint) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= PromoConstants.tabletBreakpoint) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? ultrawide,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile ?? const EdgeInsets.all(PromoConstants.defaultPadding),
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? ultrawide,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile ?? EdgeInsets.zero,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseSize, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 0.9,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.1,
      ultrawide: ultrawideScale ?? 1.2,
    );
    
    return baseSize * scale;
  }

  // Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context,
    double baseSize, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 0.8,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.2,
      ultrawide: ultrawideScale ?? 1.4,
    );
    
    return baseSize * scale;
  }

  // Get responsive grid columns
  static int getResponsiveGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int ultrawide = 4,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Get responsive grid spacing
  static double getResponsiveGridSpacing(
    BuildContext context, {
    double mobile = 16.0,
    double tablet = 20.0,
    double desktop = 24.0,
    double ultrawide = 30.0,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(
    BuildContext context, {
    BoxConstraints? mobile,
    BoxConstraints? tablet,
    BoxConstraints? desktop,
    BoxConstraints? ultrawide,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile ?? const BoxConstraints(),
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Get responsive max width
  static double getResponsiveMaxWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: MediaQuery.of(context).size.width,
      tablet: PromoConstants.maxContentWidthTablet,
      desktop: PromoConstants.maxContentWidthDesktop,
      ultrawide: PromoConstants.maxContentWidth,
    );
  }

  // Get responsive section padding
  static EdgeInsets getResponsiveSectionPadding(BuildContext context) {
    final horizontal = getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 40.0,
      desktop: 60.0,
      ultrawide: 80.0,
    );
    
    final vertical = getResponsiveValue(
      context,
      mobile: PromoConstants.sectionPaddingMobile,
      tablet: 60.0,
      desktop: PromoConstants.sectionPadding,
      ultrawide: PromoConstants.sectionPadding,
    );
    
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  // Get responsive hero section height
  static double getResponsiveHeroHeight(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    if (isPortrait && screenSize.width < PromoConstants.tabletBreakpoint) {
      return screenSize.height * 0.7;
    } else if (screenSize.width < PromoConstants.tabletBreakpoint) {
      return screenSize.height * 0.9;
    } else if (screenSize.width < PromoConstants.desktopBreakpoint) {
      return screenSize.height * 0.6;
    } else {
      return 600.0;
    }
  }

  // Get responsive navigation bar height
  static double getResponsiveNavBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: PromoConstants.navBarHeightMobile,
      tablet: PromoConstants.navBarHeight,
      desktop: PromoConstants.navBarHeight,
      ultrawide: PromoConstants.navBarHeight,
    );
  }

  // Get responsive card height
  static double getResponsiveCardHeight(
    BuildContext context,
    double baseHeight, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 0.9,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.0,
      ultrawide: ultrawideScale ?? 1.1,
    );
    
    return baseHeight * scale;
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 0.8,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.0,
      ultrawide: ultrawideScale ?? 1.2,
    );
    
    return baseRadius * scale;
  }

  // Get responsive elevation
  static double getResponsiveElevation(
    BuildContext context,
    double baseElevation, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 0.5,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.0,
      ultrawide: ultrawideScale ?? 1.2,
    );
    
    return baseElevation * scale;
  }

  // Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < PromoConstants.tabletBreakpoint;
  }

  // Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= PromoConstants.tabletBreakpoint && width < PromoConstants.desktopBreakpoint;
  }

  // Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= PromoConstants.desktopBreakpoint;
  }

  // Check if device is ultrawide
  static bool isUltrawide(BuildContext context) {
    return MediaQuery.of(context).size.width >= PromoConstants.ultrawideBreakpoint;
  }

  // Check if device is portrait
  static bool isPortrait(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height > size.width;
  }

  // Check if device is landscape
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  // Get responsive breakpoint
  static ResponsiveBreakpoint getBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= PromoConstants.ultrawideBreakpoint) {
      return ResponsiveBreakpoint.ultrawide;
    } else if (width >= PromoConstants.desktopBreakpoint) {
      return ResponsiveBreakpoint.desktop;
    } else if (width >= PromoConstants.tabletBreakpoint) {
      return ResponsiveBreakpoint.tablet;
    } else {
      return ResponsiveBreakpoint.mobile;
    }
  }

  // Get responsive widget
  static Widget buildResponsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? ultrawide,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Create responsive layout builder
  static Widget buildResponsiveLayout(
    BuildContext context, {
    required Widget Function(BuildContext, BoxConstraints, ResponsiveBreakpoint) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = getBreakpoint(context);
        return builder(context, constraints, breakpoint);
      },
    );
  }

  // Get responsive safe area padding
  static EdgeInsets getResponsiveSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safePadding = mediaQuery.padding;
    
    return EdgeInsets.only(
      top: safePadding.top,
      bottom: isMobile(context) ? safePadding.bottom : 0,
      left: safePadding.left,
      right: safePadding.right,
    );
  }

  // Get responsive text theme
  static TextTheme getResponsiveTextTheme(BuildContext context) {
    final baseTheme = Theme.of(context).textTheme;
    final scaleFactor = getResponsiveValue(
      context,
      mobile: 0.9,
      tablet: 1.0,
      desktop: 1.1,
      ultrawide: 1.2,
    );

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: (baseTheme.displayLarge?.fontSize ?? 32) * scaleFactor,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: (baseTheme.displayMedium?.fontSize ?? 28) * scaleFactor,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: (baseTheme.displaySmall?.fontSize ?? 24) * scaleFactor,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: (baseTheme.headlineLarge?.fontSize ?? 22) * scaleFactor,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: (baseTheme.headlineMedium?.fontSize ?? 20) * scaleFactor,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: (baseTheme.headlineSmall?.fontSize ?? 18) * scaleFactor,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: (baseTheme.titleLarge?.fontSize ?? 16) * scaleFactor,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: (baseTheme.titleMedium?.fontSize ?? 14) * scaleFactor,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: (baseTheme.titleSmall?.fontSize ?? 12) * scaleFactor,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
    );
  }

  // Get responsive image size
  static Size getResponsiveImageSize(
    BuildContext context,
    Size baseSize, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 0.8,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.2,
      ultrawide: ultrawideScale ?? 1.4,
    );
    
    return Size(baseSize.width * scale, baseSize.height * scale);
  }

  // Get responsive flex values for layouts
  static List<int> getResponsiveFlexValues(
    BuildContext context, {
    required List<int> mobile,
    List<int>? tablet,
    List<int>? desktop,
    List<int>? ultrawide,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Get responsive animation duration
  static Duration getResponsiveAnimationDuration(
    BuildContext context,
    Duration baseDuration, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 1.2, // Slower on mobile
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 0.8, // Faster on desktop
      ultrawide: ultrawideScale ?? 0.6, // Fastest on ultrawide
    );
    
    return Duration(milliseconds: (baseDuration.inMilliseconds * scale).round());
  }

  // Check if should show sidebar
  static bool shouldShowSidebar(BuildContext context) {
    return !isMobile(context);
  }

  // Check if should use drawer
  static bool shouldUseDrawer(BuildContext context) {
    return isMobile(context);
  }

  // Check if should use bottom navigation
  static bool shouldUseBottomNavigation(BuildContext context) {
    return isMobile(context);
  }

  // Check if should use app bar
  static bool shouldUseAppBar(BuildContext context) {
    return true; // Always use app bar, but style can vary
  }

  // Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 10,
      desktop: kToolbarHeight + 20,
      ultrawide: kToolbarHeight + 30,
    );
  }

  // Get responsive scroll physics
  static ScrollPhysics getResponsiveScrollPhysics(BuildContext context) {
    if (isMobile(context)) {
      return const BouncingScrollPhysics();
    } else {
      return const ClampingScrollPhysics();
    }
  }

  // Get responsive list tile content padding
  static EdgeInsets getResponsiveListTilePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ultrawide: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    );
  }

  // Get responsive dialog constraints
  static BoxConstraints getResponsiveDialogConstraints(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return getResponsiveValue(
      context,
      mobile: BoxConstraints(
        maxWidth: screenSize.width * 0.9,
        maxHeight: screenSize.height * 0.8,
      ),
      tablet: BoxConstraints(
        maxWidth: screenSize.width * 0.7,
        maxHeight: screenSize.height * 0.7,
      ),
      desktop: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 500,
      ),
      ultrawide: const BoxConstraints(
        maxWidth: 700,
        maxHeight: 600,
      ),
    );
  }

  // Get responsive button size
  static Size getResponsiveButtonSize(
    BuildContext context,
    Size baseSize, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
    double? ultrawideScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: mobileScale ?? 1.1, // Larger buttons on mobile for better touch
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 0.9,
      ultrawide: ultrawideScale ?? 0.8,
    );
    
    return Size(baseSize.width * scale, baseSize.height * scale);
  }
}
