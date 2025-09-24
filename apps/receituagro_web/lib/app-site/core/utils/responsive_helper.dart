import 'package:flutter/material.dart';

/// Helper para lógica responsiva centralizada
class ResponsiveHelper {
  /// Breakpoints para diferentes tamanhos de tela
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Obtém o tipo de dispositivo baseado na largura da tela
  static DeviceType getDeviceType(double width) {
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Calcula crossAxisCount para grid baseado na largura da tela
  static int getCrossAxisCount(double screenWidth,
      {GridType type = GridType.card}) {
    final deviceType = getDeviceType(screenWidth);

    switch (type) {
      case GridType.card:
        return _getCardGridCount(deviceType);
      case GridType.list:
        return _getListGridCount(deviceType);
      case GridType.detail:
        return _getDetailGridCount(deviceType);
      case GridType.thumbnail:
        return _getThumbnailGridCount(deviceType);
    }
  }

  /// Grid count para cards
  static int _getCardGridCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }

  /// Grid count para listas
  static int _getListGridCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 1;
      case DeviceType.desktop:
        return 2;
      case DeviceType.largeDesktop:
        return 2;
    }
  }

  /// Grid count para detalhes
  static int _getDetailGridCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }

  /// Grid count para thumbnails
  static int _getThumbnailGridCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 4;
      case DeviceType.desktop:
        return 6;
      case DeviceType.largeDesktop:
        return 8;
    }
  }

  /// Obtém padding responsivo
  static EdgeInsets getResponsivePadding(double screenWidth,
      {PaddingType type = PaddingType.normal}) {
    final deviceType = getDeviceType(screenWidth);

    switch (type) {
      case PaddingType.small:
        return _getSmallPadding(deviceType);
      case PaddingType.normal:
        return _getNormalPadding(deviceType);
      case PaddingType.large:
        return _getLargePadding(deviceType);
      case PaddingType.container:
        return _getContainerPadding(deviceType);
    }
  }

  /// Padding pequeno
  static EdgeInsets _getSmallPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(8);
      case DeviceType.tablet:
        return const EdgeInsets.all(12);
      case DeviceType.desktop:
        return const EdgeInsets.all(16);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Padding normal
  static EdgeInsets _getNormalPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Padding grande
  static EdgeInsets _getLargePadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(24);
      case DeviceType.tablet:
        return const EdgeInsets.all(32);
      case DeviceType.desktop:
        return const EdgeInsets.all(40);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(48);
    }
  }

  /// Padding para containers
  static EdgeInsets _getContainerPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case DeviceType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
  }

  /// Obtém spacing responsivo
  static double getResponsiveSpacing(double screenWidth,
      {SpacingType type = SpacingType.normal}) {
    final deviceType = getDeviceType(screenWidth);

    switch (type) {
      case SpacingType.small:
        return _getSmallSpacing(deviceType);
      case SpacingType.normal:
        return _getNormalSpacing(deviceType);
      case SpacingType.large:
        return _getLargeSpacing(deviceType);
      case SpacingType.section:
        return _getSectionSpacing(deviceType);
    }
  }

  /// Spacing pequeno
  static double _getSmallSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 8;
      case DeviceType.tablet:
        return 12;
      case DeviceType.desktop:
        return 16;
      case DeviceType.largeDesktop:
        return 20;
    }
  }

  /// Spacing normal
  static double _getNormalSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
      case DeviceType.largeDesktop:
        return 32;
    }
  }

  /// Spacing grande
  static double _getLargeSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 24;
      case DeviceType.tablet:
        return 32;
      case DeviceType.desktop:
        return 40;
      case DeviceType.largeDesktop:
        return 48;
    }
  }

  /// Spacing para seções
  static double _getSectionSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 32;
      case DeviceType.tablet:
        return 40;
      case DeviceType.desktop:
        return 48;
      case DeviceType.largeDesktop:
        return 64;
    }
  }

  /// Obtém largura máxima para containers
  static double getMaxContainerWidth(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 600;
      case DeviceType.desktop:
        return 1120;
      case DeviceType.largeDesktop:
        return 1400;
    }
  }

  /// Verifica se deve usar layout em coluna
  static bool shouldUseColumnLayout(double screenWidth) {
    return screenWidth < mobileBreakpoint;
  }

  /// Verifica se deve usar layout em linha
  static bool shouldUseRowLayout(double screenWidth) {
    return screenWidth >= mobileBreakpoint;
  }

  /// Obtém tamanho de fonte responsivo
  static double getResponsiveFontSize(double screenWidth,
      {FontSizeType type = FontSizeType.body}) {
    final deviceType = getDeviceType(screenWidth);

    switch (type) {
      case FontSizeType.small:
        return _getSmallFontSize(deviceType);
      case FontSizeType.body:
        return _getBodyFontSize(deviceType);
      case FontSizeType.title:
        return _getTitleFontSize(deviceType);
      case FontSizeType.heading:
        return _getHeadingFontSize(deviceType);
    }
  }

  /// Fonte pequena
  static double _getSmallFontSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 13;
      case DeviceType.desktop:
        return 14;
      case DeviceType.largeDesktop:
        return 15;
    }
  }

  /// Fonte do corpo
  static double _getBodyFontSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 15;
      case DeviceType.desktop:
        return 16;
      case DeviceType.largeDesktop:
        return 17;
    }
  }

  /// Fonte do título
  static double _getTitleFontSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 18;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 22;
      case DeviceType.largeDesktop:
        return 24;
    }
  }

  /// Fonte do cabeçalho
  static double _getHeadingFontSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 24;
      case DeviceType.tablet:
        return 28;
      case DeviceType.desktop:
        return 32;
      case DeviceType.largeDesktop:
        return 36;
    }
  }

  /// Verifica se está em modo landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Obtém orientação específica para diferentes dispositivos
  static ResponsiveOrientation getResponsiveOrientation(BuildContext context) {
    final isLandscapeMode = isLandscape(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(screenWidth);

    if (deviceType == DeviceType.mobile) {
      return isLandscapeMode
          ? ResponsiveOrientation.mobileLandscape
          : ResponsiveOrientation.mobilePortrait;
    } else if (deviceType == DeviceType.tablet) {
      return isLandscapeMode
          ? ResponsiveOrientation.tabletLandscape
          : ResponsiveOrientation.tabletPortrait;
    } else {
      return ResponsiveOrientation.desktop;
    }
  }
}

/// Tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Tipos de grid
enum GridType {
  card,
  list,
  detail,
  thumbnail,
}

/// Tipos de padding
enum PaddingType {
  small,
  normal,
  large,
  container,
}

/// Tipos de spacing
enum SpacingType {
  small,
  normal,
  large,
  section,
}

/// Tipos de fonte
enum FontSizeType {
  small,
  body,
  title,
  heading,
}

/// Orientações responsivas
enum ResponsiveOrientation {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
  desktop,
}

/// Extension para facilitar uso do ResponsiveHelper
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(screenWidth);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop =>
      deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  bool get shouldUseColumnLayout =>
      ResponsiveHelper.shouldUseColumnLayout(screenWidth);
  bool get shouldUseRowLayout =>
      ResponsiveHelper.shouldUseRowLayout(screenWidth);

  int crossAxisCount({GridType type = GridType.card}) =>
      ResponsiveHelper.getCrossAxisCount(screenWidth, type: type);

  EdgeInsets responsivePadding({PaddingType type = PaddingType.normal}) =>
      ResponsiveHelper.getResponsivePadding(screenWidth, type: type);

  double responsiveSpacing({SpacingType type = SpacingType.normal}) =>
      ResponsiveHelper.getResponsiveSpacing(screenWidth, type: type);

  double responsiveFontSize({FontSizeType type = FontSizeType.body}) =>
      ResponsiveHelper.getResponsiveFontSize(screenWidth, type: type);
}
