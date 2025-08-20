// Flutter imports:
import 'package:flutter/material.dart';

/// Utilitário para layouts responsivos
class ResponsiveLayout {
  // Breakpoints para diferentes tamanhos de tela
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Verifica se é dispositivo móvel
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Verifica se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Obtém tipo de dispositivo
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Obtém orientação da tela
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Obtém padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Obtém margin responsivo
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Obtém espaçamento entre campos
  static double getFieldSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// Obtém espaçamento entre seções
  static double getSectionSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 20.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  /// Obtém largura máxima para formulários
  static double getMaxFormWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600.0;
    } else {
      return 800.0;
    }
  }

  /// Obtém número de colunas para layout em grid
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Obtém tamanho de fonte responsivo
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final textScaler = MediaQuery.of(context).textScaler;

    double scaledSize = baseFontSize;

    // Ajusta baseado no tipo de dispositivo
    if (isMobile(context)) {
      scaledSize = baseFontSize * 0.9;
    } else if (isTablet(context)) {
      scaledSize = baseFontSize;
    } else {
      scaledSize = baseFontSize * 1.1;
    }

    // Ajusta baseado na densidade de pixels
    if (devicePixelRatio > 3.0) {
      scaledSize *= 0.95;
    } else if (devicePixelRatio < 2.0) {
      scaledSize *= 1.05;
    }

    // Limita o impacto do textScaler
    final textScaleFactor = textScaler.scale(1.0);
    final adjustedTextScale = textScaleFactor.clamp(0.8, 1.3);

    return scaledSize * adjustedTextScale;
  }

  /// Obtém altura de campo responsiva
  static double getFieldHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  /// Obtém largura de botão responsiva
  static double? getButtonWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity; // Botão ocupa toda a largura
    } else {
      return null; // Largura baseada no conteúdo
    }
  }

  /// Obtém altura de botão responsiva
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 44.0;
    } else {
      return 40.0;
    }
  }

  /// Calcula largura baseada em proporção da tela
  static double getProportionalWidth(BuildContext context, double proportion) {
    return MediaQuery.of(context).size.width * proportion;
  }

  /// Calcula altura baseada em proporção da tela
  static double getProportionalHeight(BuildContext context, double proportion) {
    return MediaQuery.of(context).size.height * proportion;
  }

  /// Verifica se é fold screen
  static bool isFoldScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;

    // Fold screens geralmente têm aspect ratio muito específico
    return aspectRatio > 2.0 || aspectRatio < 0.5;
  }

  /// Obtém layout de campos baseado no contexto
  static FieldLayout getFieldLayout(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    if (deviceType == DeviceType.mobile) {
      return isLandscapeMode ? FieldLayout.horizontal : FieldLayout.vertical;
    } else if (deviceType == DeviceType.tablet) {
      return FieldLayout.horizontal;
    } else {
      return FieldLayout.grid;
    }
  }

  /// Obtém configuração de dialog responsivo
  static DialogConfig getDialogConfig(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenSize = MediaQuery.of(context).size;

    switch (deviceType) {
      case DeviceType.mobile:
        return DialogConfig(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          borderRadius: 12.0,
        );
      case DeviceType.tablet:
        return const DialogConfig(
          width: 0.7,
          height: 0.6,
          padding: EdgeInsets.all(24.0),
          borderRadius: 16.0,
        );
      case DeviceType.desktop:
        return const DialogConfig(
          width: 600.0,
          height: 500.0,
          padding: EdgeInsets.all(32.0),
          borderRadius: 20.0,
        );
    }
  }

  /// Widget responsivo que adapta baseado no tamanho da tela
  static Widget responsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Enum para tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Enum para layouts de campo
enum FieldLayout {
  vertical,
  horizontal,
  grid,
}

/// Configuração de dialog responsivo
class DialogConfig {
  final double width;
  final double height;
  final EdgeInsets padding;
  final double borderRadius;

  const DialogConfig({
    required this.width,
    required this.height,
    required this.padding,
    required this.borderRadius,
  });
}

/// Widget helper para layouts responsivos
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Container responsivo que adapta padding e margin
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? ResponsiveLayout.getMaxFormWidth(context),
      height: height,
      padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
      margin: margin ?? ResponsiveLayout.getResponsiveMargin(context),
      child: child,
    );
  }
}

/// Spacer responsivo
class ResponsiveSpacer extends StatelessWidget {
  final bool isVertical;
  final double? customSize;

  const ResponsiveSpacer({
    super.key,
    this.isVertical = true,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = customSize ?? ResponsiveLayout.getFieldSpacing(context);

    return SizedBox(
      width: isVertical ? null : spacing,
      height: isVertical ? spacing : null,
    );
  }
}
