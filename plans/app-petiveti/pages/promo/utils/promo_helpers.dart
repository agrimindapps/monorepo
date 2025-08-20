// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/launch_countdown_model.dart';
import '../models/pre_register_model.dart';
import '../models/promo_content_model.dart';
import 'promo_constants.dart';

class PromoHelpers {
  PromoHelpers._();

  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim());
  }

  // Name validation
  static bool isValidName(String name) {
    return name.trim().length >= PromoConstants.minNameLength &&
           name.trim().length <= PromoConstants.maxNameLength;
  }

  // Get email validation error message
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email é obrigatório';
    if (email.length < PromoConstants.minEmailLength) return 'Email muito curto';
    if (email.length > PromoConstants.maxEmailLength) return 'Email muito longo';
    if (!isValidEmail(email)) return 'Email inválido';
    return null;
  }

  // Get name validation error message
  static String? getNameError(String name) {
    if (name.trim().isEmpty) return 'Nome é obrigatório';
    if (name.trim().length < PromoConstants.minNameLength) return 'Nome muito curto';
    if (name.trim().length > PromoConstants.maxNameLength) return 'Nome muito longo';
    return null;
  }

  // Format launch date
  static String formatLaunchDate(DateTime date) {
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  // Format countdown time unit
  static String formatTimeUnit(int value, String unit) {
    final formattedValue = value.toString().padLeft(2, '0');
    return '$formattedValue\n$unit';
  }

  // Calculate countdown time remaining
  static Map<String, int> calculateTimeRemaining(DateTime launchDate) {
    final now = DateTime.now();
    final difference = launchDate.difference(now);

    if (difference.isNegative) {
      return {'days': 0, 'hours': 0, 'minutes': 0, 'seconds': 0};
    }

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  // Get launch status message
  static String getLaunchStatusMessage(LaunchStatus status) {
    switch (status) {
      case LaunchStatus.preAnnouncement:
        return 'Em breve';
      case LaunchStatus.countdown:
        return 'Contagem regressiva';
      case LaunchStatus.launched:
        return 'Disponível';
      case LaunchStatus.postLaunch:
        return 'Disponível';
    }
  }

  // Get platform icon
  static IconData getPlatformIcon(AppPlatform platform) {
    switch (platform) {
      case AppPlatform.android:
        return Icons.android;
      case AppPlatform.ios:
        return Icons.apple;
    }
  }

  // Get platform color
  static Color getPlatformColor(AppPlatform platform) {
    switch (platform) {
      case AppPlatform.android:
        return const Color(0xFF3DDC84);
      case AppPlatform.ios:
        return const Color(0xFF007AFF);
    }
  }

  // Generate gradient for feature category
  static LinearGradient getFeatureGradient(PromoFeatureCategory category) {
    switch (category) {
      case PromoFeatureCategory.petProfiles:
        return LinearGradient(
          colors: [PromoConstants.petProfilesColor, PromoConstants.petProfilesColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PromoFeatureCategory.health:
        return LinearGradient(
          colors: [PromoConstants.vaccinesColor, PromoConstants.vaccinesColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PromoFeatureCategory.medication:
        return LinearGradient(
          colors: [PromoConstants.medicationsColor, PromoConstants.medicationsColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PromoFeatureCategory.tracking:
        return LinearGradient(
          colors: [PromoConstants.weightControlColor, PromoConstants.weightControlColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PromoFeatureCategory.appointments:
        return LinearGradient(
          colors: [PromoConstants.appointmentsColor, PromoConstants.appointmentsColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PromoFeatureCategory.reminders:
        return LinearGradient(
          colors: [PromoConstants.remindersColor, PromoConstants.remindersColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // Create feature decoration
  static BoxDecoration createFeatureDecoration(PromoFeatureCategory category) {
    return BoxDecoration(
      gradient: getFeatureGradient(category),
      borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
      boxShadow: PromoConstants.defaultShadow,
    );
  }

  // Create button decoration
  static BoxDecoration createButtonDecoration({
    Color? color,
    bool isPressed = false,
    bool isHovered = false,
  }) {
    final baseColor = color ?? PromoConstants.primaryColor;
    final buttonColor = isPressed 
        ? baseColor.withValues(alpha: PromoConstants.pressedOpacity)
        : isHovered 
            ? baseColor.withValues(alpha: PromoConstants.hoverOpacity)
            : baseColor;

    return BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
      boxShadow: isPressed ? [] : PromoConstants.defaultShadow,
    );
  }

  // Create card decoration
  static BoxDecoration createCardDecoration({
    Color? color,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? PromoConstants.whiteColor,
      borderRadius: BorderRadius.circular(borderRadius ?? PromoConstants.cardBorderRadius),
      boxShadow: boxShadow ?? PromoConstants.defaultShadow,
    );
  }

  // Format error message for UI
  static String formatErrorMessage(String error) {
    if (error.isEmpty) return PromoConstants.defaultErrorMessage;
    return error.substring(0, 1).toUpperCase() + error.substring(1);
  }

  // Generate success message for pre-registration
  static String getPreRegistrationSuccessMessage(String name, AppPlatform? platform) {
    final platformName = platform?.displayName ?? 'sua plataforma';
    return 'Obrigado, $name! Você será notificado quando o PetiVeti estiver disponível para $platformName.';
  }

  // Check if device supports feature
  static bool deviceSupportsFeature(String feature) {
    // Add device capability checks here
    switch (feature) {
      case 'notifications':
        return PromoConstants.enableNotifications;
      case 'camera':
        return true; // Most devices support camera
      case 'location':
        return true; // Most devices support location
      default:
        return true;
    }
  }

  // Get optimized image URL based on device
  static String getOptimizedImageUrl(String baseUrl, {
    required double width,
    required double height,
    int? quality,
  }) {
    // In a real app, you might use a service like Cloudinary or similar
    // For now, return the base URL
    final params = <String>[];
    
    if (quality != null) {
      params.add('q_$quality');
    }
    
    params.add('w_${width.toInt()}');
    params.add('h_${height.toInt()}');
    
    if (params.isNotEmpty) {
      final separator = baseUrl.contains('?') ? '&' : '?';
      return '$baseUrl$separator${params.join('&')}';
    }
    
    return baseUrl;
  }

  // Calculate responsive font size
  static double getResponsiveFontSize(double baseSize, double screenWidth) {
    if (screenWidth < PromoConstants.mobileBreakpoint) {
      return baseSize * 0.9;
    } else if (screenWidth < PromoConstants.tabletBreakpoint) {
      return baseSize;
    } else if (screenWidth < PromoConstants.desktopBreakpoint) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  // Calculate responsive padding
  static double getResponsivePadding(double basePadding, double screenWidth) {
    if (screenWidth < PromoConstants.mobileBreakpoint) {
      return basePadding * 0.5;
    } else if (screenWidth < PromoConstants.tabletBreakpoint) {
      return basePadding * 0.75;
    } else if (screenWidth < PromoConstants.desktopBreakpoint) {
      return basePadding;
    } else {
      return basePadding * 1.25;
    }
  }

  // Generate hero gradient
  static LinearGradient createHeroGradient() {
    return const LinearGradient(
      colors: PromoConstants.heroGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Generate screenshots section gradient
  static LinearGradient createScreenshotsGradient() {
    return const LinearGradient(
      colors: PromoConstants.screenshotsGradient,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // Create smooth scroll curve
  static Curve getScrollCurve(double distance) {
    if (distance < 500) {
      return PromoConstants.fastCurve;
    } else if (distance < 1500) {
      return PromoConstants.defaultCurve;
    } else {
      return PromoConstants.scrollCurve;
    }
  }

  // Get scroll duration based on distance
  static Duration getScrollDuration(double distance) {
    final baseDuration = PromoConstants.scrollAnimation.inMilliseconds;
    final factor = (distance / 1000).clamp(0.5, 2.0);
    return Duration(milliseconds: (baseDuration * factor).round());
  }

  // Format testimonial rating
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  // Generate star rating widgets
  static List<Widget> buildStarRating(double rating, {double size = 16.0}) {
    final stars = <Widget>[];
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: PromoConstants.warningColor, size: size));
    }
    
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: PromoConstants.warningColor, size: size));
    }
    
    final remainingStars = 5 - stars.length;
    for (int i = 0; i < remainingStars; i++) {
      stars.add(Icon(Icons.star_border, color: PromoConstants.warningColor, size: size));
    }
    
    return stars;
  }

  // Check if string contains only letters and spaces
  static bool isValidPersonName(String name) {
    return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(name.trim());
  }

  // Sanitize input text
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Generate loading placeholder widget
  static Widget createLoadingPlaceholder({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(PromoConstants.defaultBorderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PromoConstants.primaryColor),
        ),
      ),
    );
  }

  // Create shimmer effect for loading states
  static Widget createShimmerPlaceholder({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(PromoConstants.defaultBorderRadius),
      ),
    );
  }

  // Calculate grid dimensions
  static (int columns, double itemWidth) calculateGridDimensions({
    required double screenWidth,
    required double itemAspectRatio,
    required double spacing,
    required double padding,
    int maxColumns = 4,
  }) {
    int columns = 1;
    
    if (screenWidth >= PromoConstants.ultrawideBreakpoint) {
      columns = maxColumns;
    } else if (screenWidth >= PromoConstants.desktopBreakpoint) {
      columns = (maxColumns * 0.75).round();
    } else if (screenWidth >= PromoConstants.tabletBreakpoint) {
      columns = (maxColumns * 0.5).round();
    } else {
      columns = 1;
    }
    
    final availableWidth = screenWidth - (padding * 2);
    final totalSpacing = spacing * (columns - 1);
    final itemWidth = (availableWidth - totalSpacing) / columns;
    
    return (columns, itemWidth);
  }

  // Debug helpers
  static void debugPrint(String message) {
    if (PromoConstants.enableDebugMode) {
      debugPrint('${PromoConstants.debugTag}: $message');
    }
  }

  // Performance helpers
  static bool shouldEnableAnimations() {
    return PromoConstants.enableAnimations;
  }

  static bool shouldUseLazyLoading() {
    return PromoConstants.enableLazyLoading;
  }

  static bool shouldCacheImages() {
    return PromoConstants.enableImageCaching;
  }

  // URL helpers
  static String buildStoreUrl(AppPlatform platform) {
    switch (platform) {
      case AppPlatform.android:
        return PromoConstants.playStoreUrl;
      case AppPlatform.ios:
        return PromoConstants.appStoreUrl;
    }
  }

  // Social sharing helpers
  static Map<String, String> buildSocialShareUrls(String message) {
    final encodedMessage = Uri.encodeComponent(message);
    final encodedUrl = Uri.encodeComponent(PromoConstants.websiteUrl);
    
    return {
      'facebook': 'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl',
      'twitter': 'https://twitter.com/intent/tweet?text=$encodedMessage&url=$encodedUrl',
      'whatsapp': 'https://wa.me/?text=$encodedMessage%20$encodedUrl',
      'telegram': 'https://t.me/share/url?url=$encodedUrl&text=$encodedMessage',
    };
  }

  // Analytics helpers
  static Map<String, dynamic> buildAnalyticsEvent(String eventName, {
    Map<String, dynamic>? properties,
  }) {
    return {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': properties ?? {},
      'source': 'promo_page',
    };
  }
}
