/// Responsive design constants for adaptive layouts
/// Defines breakpoints, constraints and responsive behaviors
/// for mobile, tablet and desktop experiences
library;

import 'package:flutter/material.dart';

/// Screen size breakpoints for responsive design
class ResponsiveBreakpoints {
  static const double mobile = 0;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
  static const double maxContentWidth = 1120;
  static const double sidebarWidth = 280;
  static const double collapsedSidebarWidth = 72;
  static const double navigationRailWidth = 80;

  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth >= largeDesktop) return 32.0;
    if (screenWidth >= desktop) return 24.0;
    if (screenWidth >= tablet) return 20.0;
    return 16.0;
  }

  static int getGridColumns(double screenWidth) {
    if (screenWidth >= largeDesktop) return 4;
    if (screenWidth >= desktop) return 3;
    if (screenWidth >= tablet) return 2;
    return 1;
  }

  static EdgeInsets getContentPadding(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.sidebar:
        return const EdgeInsets.all(24.0);
      case NavigationType.rail:
        return const EdgeInsets.all(20.0);
      case NavigationType.bottom:
        return const EdgeInsets.all(16.0);
    }
  }
}

/// Navigation layout types based on screen size
enum NavigationType {
  bottom, // Mobile: Bottom navigation bar
  rail, // Tablet: Navigation rail
  sidebar, // Desktop: Collapsible sidebar
}

/// Responsive layout utilities and helpers
class ResponsiveLayout {
  /// Get appropriate navigation type based on screen width
  static NavigationType getNavigationType(double screenWidth) {
    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return NavigationType.sidebar;
    }
    if (screenWidth >= ResponsiveBreakpoints.tablet) return NavigationType.rail;
    return NavigationType.bottom;
  }

  /// Check if current context is mobile sized
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;
  }

  /// Check if current context is tablet sized
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet &&
        width < ResponsiveBreakpoints.desktop;
  }

  /// Check if current context is desktop sized
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;
  }

  /// Get current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return ScreenSize.largeDesktop;
    }
    if (width >= ResponsiveBreakpoints.desktop) return ScreenSize.desktop;
    if (width >= ResponsiveBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

/// Screen size categories for fine-grained responsive behavior
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Adaptive spacing system based on screen size
class AdaptiveSpacing {
  static const Map<ScreenSize, Map<String, double>> _spacingMap = {
    ScreenSize.mobile: {
      'xs': 4.0,
      'sm': 8.0,
      'md': 16.0,
      'lg': 24.0,
      'xl': 32.0,
    },
    ScreenSize.tablet: {
      'xs': 6.0,
      'sm': 12.0,
      'md': 20.0,
      'lg': 28.0,
      'xl': 36.0,
    },
    ScreenSize.desktop: {
      'xs': 8.0,
      'sm': 16.0,
      'md': 24.0,
      'lg': 32.0,
      'xl': 40.0,
    },
    ScreenSize.largeDesktop: {
      'xs': 8.0,
      'sm': 16.0,
      'md': 24.0,
      'lg': 32.0,
      'xl': 48.0,
    },
  };

  static double getSpacing(BuildContext context, String size) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    return _spacingMap[screenSize]?[size] ?? 16.0;
  }

  static double xs(BuildContext context) => getSpacing(context, 'xs');
  static double sm(BuildContext context) => getSpacing(context, 'sm');
  static double md(BuildContext context) => getSpacing(context, 'md');
  static double lg(BuildContext context) => getSpacing(context, 'lg');
  static double xl(BuildContext context) => getSpacing(context, 'xl');
}
