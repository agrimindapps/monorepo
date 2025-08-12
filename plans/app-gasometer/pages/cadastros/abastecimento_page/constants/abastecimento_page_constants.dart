// Flutter imports:
import 'package:flutter/material.dart';

class AbastecimentoPageConstants {
  // Carousel configuration
  static const double carouselViewportFraction = 1.0;
  static const bool carouselEnableInfiniteScroll = false;
  static const bool carouselAutoPlay = false;

  // Month navigation styling
  static const double monthPadding = 16.0;
  static const double monthVerticalPadding = 8.0;
  static const double monthHorizontalMargin = 4.0;
  static const double monthBorderRadius = 20.0;
  static const double monthHeaderSpacing = 8.0;
  static const double navigationBarPadding = 8.0;

  // Text styles
  static const TextStyle monthTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
  );

  // Carousel configuration
  static const Duration carouselAnimationDuration = Duration(milliseconds: 300);
  static const Curve carouselAnimationCurve = Curves.easeInOut;
}
