// Flutter imports:
import 'package:flutter/material.dart';

/// Breakpoints responsivos para diferentes tipos de dispositivo
class ResponsiveBreakpoints {
  // Breakpoints baseados em Material Design guidelines
  static const double mobileSmall = 320; // Telefones pequenos
  static const double mobile = 480; // Telefones padrão
  static const double mobileLarge = 600; // Telefones grandes
  static const double tablet = 768; // Tablets pequenos
  static const double tabletLarge = 1024; // Tablets grandes
  static const double desktop = 1200; // Desktop pequeno
  static const double desktopLarge = 1600; // Desktop grande
  static const double desktopXL = 1920; // Desktop extra grande

  /// Determina o tipo de dispositivo baseado na largura da tela
  static DeviceType getDeviceType(double width) {
    if (width < mobile) return DeviceType.mobileSmall;
    if (width < mobileLarge) return DeviceType.mobile;
    if (width < tablet) return DeviceType.mobileLarge;
    if (width < tabletLarge) return DeviceType.tablet;
    if (width < desktop) return DeviceType.tabletLarge;
    if (width < desktopLarge) return DeviceType.desktop;
    if (width < desktopXL) return DeviceType.desktopLarge;
    return DeviceType.desktopXL;
  }

  /// Obtém o número de colunas para um grid baseado na largura
  static int getGridColumns(double width) {
    final deviceType = getDeviceType(width);
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 1;
      case DeviceType.mobile:
        return 1;
      case DeviceType.mobileLarge:
        return 2;
      case DeviceType.tablet:
        return 2;
      case DeviceType.tabletLarge:
        return 3;
      case DeviceType.desktop:
        return 4;
      case DeviceType.desktopLarge:
        return 5;
      case DeviceType.desktopXL:
        return 6;
    }
  }

  /// Obtém o padding horizontal baseado na largura da tela
  static double getHorizontalPadding(double width) {
    final deviceType = getDeviceType(width);
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 8.0;
      case DeviceType.mobile:
        return 12.0;
      case DeviceType.mobileLarge:
        return 16.0;
      case DeviceType.tablet:
        return 24.0;
      case DeviceType.tabletLarge:
        return 32.0;
      case DeviceType.desktop:
        return 48.0;
      case DeviceType.desktopLarge:
        return 64.0;
      case DeviceType.desktopXL:
        return 80.0;
    }
  }

  /// Obtém a largura máxima do conteúdo
  static double getMaxContentWidth(double screenWidth) {
    final deviceType = getDeviceType(screenWidth);
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
      case DeviceType.mobileLarge:
        return screenWidth;
      case DeviceType.tablet:
        return tablet - 32;
      case DeviceType.tabletLarge:
        return tabletLarge - 64;
      case DeviceType.desktop:
        return desktop - 96;
      case DeviceType.desktopLarge:
        return desktopLarge - 128;
      case DeviceType.desktopXL:
        return desktopXL - 160;
    }
  }

  /// Verifica se está em modo landscape
  static bool isLandscape(Size size) {
    return size.width > size.height;
  }

  /// Verifica se é um dispositivo móvel
  static bool isMobile(double width) {
    return width < tablet;
  }

  /// Verifica se é um tablet
  static bool isTablet(double width) {
    return width >= tablet && width < desktop;
  }

  /// Verifica se é desktop
  static bool isDesktop(double width) {
    return width >= desktop;
  }
}

/// Tipos de dispositivo
enum DeviceType {
  mobileSmall,
  mobile,
  mobileLarge,
  tablet,
  tabletLarge,
  desktop,
  desktopLarge,
  desktopXL,
}

/// Extensões para facilitar o uso
extension DeviceTypeExtension on DeviceType {
  bool get isMobile => index <= DeviceType.mobileLarge.index;
  bool get isTablet =>
      this == DeviceType.tablet || this == DeviceType.tabletLarge;
  bool get isDesktop => index >= DeviceType.desktop.index;

  String get name {
    switch (this) {
      case DeviceType.mobileSmall:
        return 'Mobile Small';
      case DeviceType.mobile:
        return 'Mobile';
      case DeviceType.mobileLarge:
        return 'Mobile Large';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.tabletLarge:
        return 'Tablet Large';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.desktopLarge:
        return 'Desktop Large';
      case DeviceType.desktopXL:
        return 'Desktop XL';
    }
  }
}

/// Widget builder responsivo que fornece informações sobre o dispositivo
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final width = constraints.maxWidth;
        final deviceType = ResponsiveBreakpoints.getDeviceType(width);

        final info = ResponsiveInfo(
          screenSize: size,
          constrainedWidth: width,
          constrainedHeight: constraints.maxHeight,
          deviceType: deviceType,
          isLandscape: ResponsiveBreakpoints.isLandscape(size),
          gridColumns: ResponsiveBreakpoints.getGridColumns(width),
          horizontalPadding: ResponsiveBreakpoints.getHorizontalPadding(width),
          maxContentWidth: ResponsiveBreakpoints.getMaxContentWidth(width),
        );

        return builder(context, info);
      },
    );
  }
}

/// Informações responsivas fornecidas pelo ResponsiveBuilder
class ResponsiveInfo {
  final Size screenSize;
  final double constrainedWidth;
  final double constrainedHeight;
  final DeviceType deviceType;
  final bool isLandscape;
  final int gridColumns;
  final double horizontalPadding;
  final double maxContentWidth;

  const ResponsiveInfo({
    required this.screenSize,
    required this.constrainedWidth,
    required this.constrainedHeight,
    required this.deviceType,
    required this.isLandscape,
    required this.gridColumns,
    required this.horizontalPadding,
    required this.maxContentWidth,
  });

  bool get isMobile => deviceType.isMobile;
  bool get isTablet => deviceType.isTablet;
  bool get isDesktop => deviceType.isDesktop;
  bool get isPortrait => !isLandscape;

  /// Obtém espaçamento baseado no tipo de dispositivo
  double getSpacing(
      {double mobile = 8, double tablet = 12, double desktop = 16}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Obtém tamanho de fonte responsivo
  double getFontSize(
      {double mobile = 14, double tablet = 16, double desktop = 18}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Obtém altura de item responsiva
  double getItemHeight(
      {double mobile = 80, double tablet = 96, double desktop = 120}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  @override
  String toString() {
    return 'ResponsiveInfo(deviceType: ${deviceType.name}, size: ${screenSize.width}x${screenSize.height}, isLandscape: $isLandscape)';
  }
}
