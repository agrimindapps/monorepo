// Flutter imports:
import 'package:flutter/material.dart';

enum ResponsiveBreakpoint {
  mobile('mobile', 0, 600),
  tablet('tablet', 600, 900),
  desktop('desktop', 900, 1200),
  ultrawide('ultrawide', 1200, double.infinity);

  const ResponsiveBreakpoint(this.name, this.minWidth, this.maxWidth);
  final String name;
  final double minWidth;
  final double maxWidth;
}

enum DeviceOrientation {
  portrait,
  landscape,
}

class ResponsiveService extends ChangeNotifier {
  static final ResponsiveService _instance = ResponsiveService._internal();
  factory ResponsiveService() => _instance;
  ResponsiveService._internal();

  // State
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  ResponsiveBreakpoint _currentBreakpoint = ResponsiveBreakpoint.mobile;
  DeviceOrientation _orientation = DeviceOrientation.portrait;
  double _pixelRatio = 1.0;
  bool _isInitialized = false;

  // Getters
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  ResponsiveBreakpoint get currentBreakpoint => _currentBreakpoint;
  DeviceOrientation get orientation => _orientation;
  double get pixelRatio => _pixelRatio;
  bool get isInitialized => _isInitialized;

  // Breakpoint checks
  bool get isMobile => _currentBreakpoint == ResponsiveBreakpoint.mobile;
  bool get isTablet => _currentBreakpoint == ResponsiveBreakpoint.tablet;
  bool get isDesktop => _currentBreakpoint == ResponsiveBreakpoint.desktop;
  bool get isUltrawide => _currentBreakpoint == ResponsiveBreakpoint.ultrawide;

  // Orientation checks
  bool get isPortrait => _orientation == DeviceOrientation.portrait;
  bool get isLandscape => _orientation == DeviceOrientation.landscape;

  // Combined checks
  bool get isMobilePortrait => isMobile && isPortrait;
  bool get isMobileLandscape => isMobile && isLandscape;
  bool get isTabletPortrait => isTablet && isPortrait;
  bool get isTabletLandscape => isTablet && isLandscape;
  bool get isDesktopOrLarger => isDesktop || isUltrawide;
  bool get isTabletOrLarger => isTablet || isDesktop || isUltrawide;
  bool get isMobileOrTablet => isMobile || isTablet;

  // Initialize from MediaQuery
  void initializeFromMediaQuery(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final orientation = mediaQuery.orientation;
    final pixelRatio = mediaQuery.devicePixelRatio;

    _screenWidth = size.width;
    _screenHeight = size.height;
    _pixelRatio = pixelRatio;
    _orientation = orientation == Orientation.portrait 
        ? DeviceOrientation.portrait 
        : DeviceOrientation.landscape;
    
    _updateBreakpoint();
    _isInitialized = true;
    notifyListeners();
  }

  // Update screen size manually
  void updateScreenSize(double width, double height) {
    if (_screenWidth != width || _screenHeight != height) {
      _screenWidth = width;
      _screenHeight = height;
      _orientation = width > height 
          ? DeviceOrientation.landscape 
          : DeviceOrientation.portrait;
      
      _updateBreakpoint();
      notifyListeners();
    }
  }

  void _updateBreakpoint() {
    final newBreakpoint = _getBreakpointForWidth(_screenWidth);
    if (_currentBreakpoint != newBreakpoint) {
      _currentBreakpoint = newBreakpoint;
    }
  }

  ResponsiveBreakpoint _getBreakpointForWidth(double width) {
    for (final breakpoint in ResponsiveBreakpoint.values) {
      if (width >= breakpoint.minWidth && width < breakpoint.maxWidth) {
        return breakpoint;
      }
    }
    return ResponsiveBreakpoint.mobile;
  }

  // Layout calculations
  int getGridColumnsForBreakpoint({
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    int? ultrawideColumns,
  }) {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return mobileColumns ?? 1;
      case ResponsiveBreakpoint.tablet:
        return tabletColumns ?? 2;
      case ResponsiveBreakpoint.desktop:
        return desktopColumns ?? 3;
      case ResponsiveBreakpoint.ultrawide:
        return ultrawideColumns ?? 4;
    }
  }

  double getPaddingForBreakpoint({
    double? mobilePadding,
    double? tabletPadding,
    double? desktopPadding,
    double? ultrawidePadding,
  }) {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return mobilePadding ?? 16.0;
      case ResponsiveBreakpoint.tablet:
        return tabletPadding ?? 24.0;
      case ResponsiveBreakpoint.desktop:
        return desktopPadding ?? 32.0;
      case ResponsiveBreakpoint.ultrawide:
        return ultrawidePadding ?? 40.0;
    }
  }

  double getFontSizeForBreakpoint({
    double? mobileFontSize,
    double? tabletFontSize,
    double? desktopFontSize,
    double? ultrawideFontSize,
  }) {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return mobileFontSize ?? 14.0;
      case ResponsiveBreakpoint.tablet:
        return tabletFontSize ?? 16.0;
      case ResponsiveBreakpoint.desktop:
        return desktopFontSize ?? 18.0;
      case ResponsiveBreakpoint.ultrawide:
        return ultrawideFontSize ?? 20.0;
    }
  }

  double getIconSizeForBreakpoint({
    double? mobileIconSize,
    double? tabletIconSize,
    double? desktopIconSize,
    double? ultrawideIconSize,
  }) {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return mobileIconSize ?? 20.0;
      case ResponsiveBreakpoint.tablet:
        return tabletIconSize ?? 24.0;
      case ResponsiveBreakpoint.desktop:
        return desktopIconSize ?? 28.0;
      case ResponsiveBreakpoint.ultrawide:
        return ultrawideIconSize ?? 32.0;
    }
  }

  // Widget sizing
  double getMaxContentWidth() {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return _screenWidth;
      case ResponsiveBreakpoint.tablet:
        return 800.0;
      case ResponsiveBreakpoint.desktop:
        return 1200.0;
      case ResponsiveBreakpoint.ultrawide:
        return 1600.0;
    }
  }

  double getHeroSectionHeight() {
    if (isMobile) {
      return isPortrait ? _screenHeight * 0.7 : _screenHeight * 0.9;
    } else if (isTablet) {
      return _screenHeight * 0.6;
    } else {
      return 600.0;
    }
  }

  double getNavBarHeight() {
    return isDesktopOrLarger ? 80.0 : 60.0;
  }

  double getSectionVerticalPadding() {
    if (isMobile) return 40.0;
    if (isTablet) return 60.0;
    return 80.0;
  }

  double getSectionHorizontalPadding() {
    if (isMobile) return 20.0;
    if (isTablet) return 40.0;
    return 80.0;
  }

  // Responsive text scaling
  double scaleText(double baseSize) {
    final scaleFactor = _getTextScaleFactor();
    return baseSize * scaleFactor;
  }

  double _getTextScaleFactor() {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return 0.9;
      case ResponsiveBreakpoint.tablet:
        return 1.0;
      case ResponsiveBreakpoint.desktop:
        return 1.1;
      case ResponsiveBreakpoint.ultrawide:
        return 1.2;
    }
  }

  // Widget adaptation
  T adaptValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? ultrawide,
  }) {
    switch (_currentBreakpoint) {
      case ResponsiveBreakpoint.mobile:
        return mobile;
      case ResponsiveBreakpoint.tablet:
        return tablet ?? mobile;
      case ResponsiveBreakpoint.desktop:
        return desktop ?? tablet ?? mobile;
      case ResponsiveBreakpoint.ultrawide:
        return ultrawide ?? desktop ?? tablet ?? mobile;
    }
  }

  // Layout helpers
  bool shouldShowSidebar() {
    return isDesktopOrLarger;
  }

  bool shouldUseDrawer() {
    return isMobileOrTablet;
  }

  bool shouldShowFloatingActionButton() {
    return isMobile;
  }

  bool shouldUseBottomNavigation() {
    return isMobile;
  }

  bool shouldUseTabNavigation() {
    return isTabletOrLarger;
  }

  // Image sizing
  double getImageWidth() {
    return adaptValue(
      mobile: _screenWidth * 0.8,
      tablet: 400.0,
      desktop: 500.0,
      ultrawide: 600.0,
    );
  }

  double getImageHeight() {
    return adaptValue(
      mobile: _screenWidth * 0.6,
      tablet: 300.0,
      desktop: 400.0,
      ultrawide: 500.0,
    );
  }

  // Grid calculations
  double calculateGridItemWidth({
    required int columns,
    required double totalWidth,
    required double spacing,
    required double padding,
  }) {
    final availableWidth = totalWidth - (padding * 2);
    final totalSpacing = spacing * (columns - 1);
    return (availableWidth - totalSpacing) / columns;
  }

  double calculateGridHeight({
    required int rows,
    required double itemHeight,
    required double spacing,
    required double padding,
  }) {
    return (rows * itemHeight) + ((rows - 1) * spacing) + (padding * 2);
  }

  // Breakpoint transitions
  bool isTransitioningBreakpoint(ResponsiveBreakpoint from, ResponsiveBreakpoint to) {
    // Add logic for detecting breakpoint transitions if needed
    return false;
  }

  // Performance optimizations
  bool shouldLazyLoad() {
    // Load content lazily on mobile to improve performance
    return isMobile;
  }

  bool shouldUseReducedMotion() {
    // Reduce animations on mobile for better performance
    return isMobile;
  }

  int getImageQuality() {
    // Return different image quality based on device
    if (isMobile) return 70;
    if (isTablet) return 80;
    return 90;
  }

  // Debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'screenWidth': _screenWidth,
      'screenHeight': _screenHeight,
      'breakpoint': _currentBreakpoint.name,
      'orientation': _orientation.name,
      'pixelRatio': _pixelRatio,
      'aspectRatio': _screenHeight != 0 ? _screenWidth / _screenHeight : 0,
      'isInitialized': _isInitialized,
    };
  }

  // Static helper methods
  static ResponsiveBreakpoint getBreakpointFromWidth(double width) {
    for (final breakpoint in ResponsiveBreakpoint.values) {
      if (width >= breakpoint.minWidth && width < breakpoint.maxWidth) {
        return breakpoint;
      }
    }
    return ResponsiveBreakpoint.mobile;
  }

  static bool isMobileWidth(double width) {
    return width < ResponsiveBreakpoint.tablet.minWidth;
  }

  static bool isTabletWidth(double width) {
    return width >= ResponsiveBreakpoint.tablet.minWidth && 
           width < ResponsiveBreakpoint.desktop.minWidth;
  }

  static bool isDesktopWidth(double width) {
    return width >= ResponsiveBreakpoint.desktop.minWidth;
  }

  // Widget builder helpers
  Widget buildResponsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? ultrawide,
  }) {
    return adaptValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  // Validation
  bool isValidScreenSize() {
    return _screenWidth > 0 && _screenHeight > 0;
  }

  // Reset and cleanup
  void reset() {
    _screenWidth = 0.0;
    _screenHeight = 0.0;
    _currentBreakpoint = ResponsiveBreakpoint.mobile;
    _orientation = DeviceOrientation.portrait;
    _pixelRatio = 1.0;
    _isInitialized = false;
    notifyListeners();
  }
}
