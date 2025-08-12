// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get_utils/src/platform/platform.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';

class OdometroPageConstants {
  // Page configuration
  static const double maxWidth = 1020.0;
  static const double headerHeight = 72.0;
  static const double carouselHeight = 220.0;

  // Platform-specific heights
  static double getNoDataHeight(double screenHeight) {
    return screenHeight - (GetPlatform.isWeb ? 285 : 420);
  }

  // Page titles and labels
  static const Map<String, String> pageTitles = {
    'title': 'Odômetro',
    'subtitle': 'Registros do odômetro',
    'noDataTitle': 'Nenhum registro de odômetro encontrado neste período.',
  };

  // Icons
  static const Map<String, IconData> icons = {
    'speed': Icons.speed,
    'speedOutlined': Icons.speed_outlined,
    'analytics': Icons.analytics,
    'analyticsOutlined': Icons.analytics_outlined,
    'add': Icons.add,
  };

  // Styling constants
  static const Map<String, double> dimensions = {
    'padding': 8.0,
    'smallPadding': 4.0,
    'contentSpacing': 16.0,
    'iconSize': 20.0,
    'noDataIconSize': 64.0,
    'noDataContainerWidth': 300.0,
    'borderRadius': 8.0,
    'monthPadding': 16.0,
    'monthVerticalPadding': 8.0,
    'monthHorizontalMargin': 4.0,
    'monthBorderRadius': 20.0,
    'monthHeaderSpacing': 8.0,
    'carouselSpacing': 4.0,
    'itemSpacing': 4.0,
  };

  // Font sizes
  static const Map<String, double> fontSizes = {
    'noDataText': 16.0,
    'monthText': 14.0,
  };

  // Colors keys for theme resolution
  static const Map<String, String> colorKeys = {
    'background': 'background',
    'surface': 'surface',
    'border': 'border',
    'text': 'text',
    'mutedText': 'mutedText',
    'selectedMonth': 'selectedMonth',
    'unselectedMonth': 'unselectedMonth',
    'fabEnabled': 'fabEnabled',
    'fabDisabled': 'fabDisabled',
  };

  // Carousel configuration
  static const double carouselViewportFraction = 1.0;
  static const bool carouselEnableInfiniteScroll = false;
  static const bool carouselAutoPlay = false;

  // Layout breakpoints
  static const double tabletBreakpoint = 1024.0;

  static bool isTablet(double width) => width >= tabletBreakpoint;

  // Date formatting
  static const String monthYearFormat = 'MMM yy';
  static const String locale = 'pt_BR';

  // Messages
  static const Map<String, String> messages = {
    'loadError': 'Erro ao carregar dados do odômetro',
    'refreshing': 'Atualizando dados...',
  };

  // Refresh indicator configuration
  static const Duration refreshThrottleDuration = Duration(milliseconds: 500);

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // Widget keys for testing
  static const String fabKey = 'odometro_fab';
  static const String carouselKey = 'odometro_carousel';
  static const String headerKey = 'odometro_header';
  static const String monthsBarKey = 'odometro_months_bar';

  // Accessibility
  static const Map<String, String> semanticLabels = {
    'fab': 'Adicionar novo registro de odômetro',
    'monthSelector': 'Seletor de mês',
    'toggleStats': 'Alternar estatísticas',
    'refresh': 'Atualizar dados',
  };

  // Helper methods for responsive design
  static EdgeInsets getContentPadding() {
    return EdgeInsets.all(dimensions['padding']!);
  }

  static EdgeInsets getSmallPadding() {
    return EdgeInsets.all(dimensions['smallPadding']!);
  }

  static EdgeInsets getHorizontalPadding() {
    return EdgeInsets.symmetric(horizontal: dimensions['padding']!);
  }

  static EdgeInsets getVerticalPadding() {
    return EdgeInsets.symmetric(vertical: dimensions['padding']!);
  }

  // Month container styling
  static BoxDecoration getMonthContainerDecoration(
      Color backgroundColor, Color borderColor) {
    // Mantém o fundo original e aplica uma borda responsiva ao tema
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(dimensions['borderRadius']!),
      border: Border.all(color: borderColor),
    );
  }

  static BoxDecoration getSelectedMonthDecoration(Color selectedColor) {
    return BoxDecoration(
      color: selectedColor,
      borderRadius: BorderRadius.circular(dimensions['monthBorderRadius']!),
    );
  }

  static BoxDecoration getUnselectedMonthDecoration(Color unselectedColor) {
    return BoxDecoration(
      color: unselectedColor,
      borderRadius: BorderRadius.circular(dimensions['monthBorderRadius']!),
    );
  }

  // Text styles
  static const TextStyle monthTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static TextStyle get noDataTextStyle => TextStyle(
        fontSize: 16.0,
        color: ShadcnStyle.mutedTextColor,
        fontWeight: FontWeight.w500,
      );
}
