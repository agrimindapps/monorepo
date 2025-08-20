// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../models/benefit_model.dart';
import '../models/purchase_state_model.dart';
import '../models/subscription_model.dart';
import 'subscription_constants.dart';

class SubscriptionHelpers {
  // UI Helpers
  static Widget buildLoadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SubscriptionConstants.primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: SubscriptionConstants.spacing),
            Text(
              message,
              style: SubscriptionConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildErrorWidget(String message, VoidCallback? onRetry) {
    return Center(
      child: Padding(
        padding: SubscriptionConstants.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              SubscriptionConstants.errorIcon,
              size: 64,
              color: SubscriptionConstants.errorColor,
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            const Text(
              'Ops! Algo deu errado',
              style: SubscriptionConstants.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SubscriptionConstants.smallSpacing),
            Text(
              message,
              style: SubscriptionConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: SubscriptionConstants.spacing),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(SubscriptionConstants.retryButtonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SubscriptionConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState({String? message}) {
    return Center(
      child: Padding(
        padding: SubscriptionConstants.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            Text(
              message ?? SubscriptionConstants.noOffersMessage,
              style: SubscriptionConstants.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SubscriptionConstants.smallSpacing),
            const Text(
              'Tente novamente mais tarde.',
              style: SubscriptionConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Formatting Helpers
  static String formatPrice(double price, String currencyCode) {
    if (currencyCode.toUpperCase() == 'BRL' || currencyCode.toUpperCase() == 'R\$') {
      return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return '$currencyCode ${price.toStringAsFixed(2)}';
  }

  static String formatPeriod(PackageType packageType) {
    return SubscriptionConstants.packageDescriptions[packageType.name] ?? 'período';
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} dias';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} horas';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutos';
    } else {
      return '${duration.inSeconds} segundos';
    }
  }

  static String formatDate(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  // Validation Helpers
  static bool isValidPrice(double price) {
    return price >= SubscriptionConstants.minPrice && 
           price <= SubscriptionConstants.maxPrice;
  }

  static bool isValidTitle(String title) {
    return title.length >= SubscriptionConstants.minTitleLength && 
           title.length <= SubscriptionConstants.maxTitleLength;
  }

  static bool isValidDescription(String description) {
    return description.length >= SubscriptionConstants.minDescriptionLength && 
           description.length <= SubscriptionConstants.maxDescriptionLength;
  }

  static bool isPackageValid(Package package) {
    return package.storeProduct.title.isNotEmpty &&
           package.storeProduct.price > 0 &&
           isValidPrice(package.storeProduct.price) &&
           isValidTitle(package.storeProduct.title);
  }

  // Discount Calculation
  static double calculateDiscountPercentage(double originalPrice, double discountedPrice) {
    if (originalPrice <= 0 || discountedPrice >= originalPrice) return 0.0;
    return ((originalPrice - discountedPrice) / originalPrice) * 100;
  }

  static double calculateSavings(Package annualPackage, Package monthlyPackage) {
    if (annualPackage.packageType != PackageType.annual || 
        monthlyPackage.packageType != PackageType.monthly) {
      return 0.0;
    }
    
    final annualMonthlyPrice = annualPackage.storeProduct.price / 12;
    final monthlyPrice = monthlyPackage.storeProduct.price;
    
    return calculateDiscountPercentage(monthlyPrice, annualMonthlyPrice);
  }

  // Color Helpers
  static Color getPackageColor(PackageType packageType, bool isRecommended) {
    if (isRecommended) {
      return SubscriptionConstants.primaryColor;
    }
    
    switch (packageType) {
      case PackageType.weekly:
        return Colors.orange;
      case PackageType.monthly:
        return SubscriptionConstants.primaryColor;
      case PackageType.threeMonth:
        return Colors.purple;
      case PackageType.sixMonth:
        return Colors.indigo;
      case PackageType.annual:
        return Colors.green;
      case PackageType.lifetime:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  static Color getBenefitCategoryColor(BenefitCategory category) {
    switch (category) {
      case BenefitCategory.feature:
        return SubscriptionConstants.primaryColor;
      case BenefitCategory.professional:
        return SubscriptionConstants.secondaryColor;
      case BenefitCategory.convenience:
        return SubscriptionConstants.successColor;
      case BenefitCategory.support:
        return SubscriptionConstants.warningColor;
    }
  }

  static Color getPurchaseStateColor(PurchaseState state) {
    switch (state) {
      case PurchaseState.success:
        return SubscriptionConstants.successColor;
      case PurchaseState.error:
        return SubscriptionConstants.errorColor;
      case PurchaseState.loading:
      case PurchaseState.purchasing:
      case PurchaseState.restoring:
        return SubscriptionConstants.primaryColor;
      case PurchaseState.cancelled:
        return SubscriptionConstants.warningColor;
      case PurchaseState.idle:
      default:
        return Colors.grey;
    }
  }

  // Icon Helpers
  static IconData getPackageIcon(PackageType packageType) {
    switch (packageType) {
      case PackageType.weekly:
        return Icons.schedule;
      case PackageType.monthly:
        return Icons.calendar_month;
      case PackageType.threeMonth:
        return Icons.calendar_view_month;
      case PackageType.sixMonth:
        return Icons.date_range;
      case PackageType.annual:
        return Icons.calendar_today;
      case PackageType.lifetime:
        return Icons.all_inclusive;
      default:
        return Icons.card_membership;
    }
  }

  static IconData getPurchaseStateIcon(PurchaseState state) {
    switch (state) {
      case PurchaseState.success:
        return Icons.check_circle;
      case PurchaseState.error:
        return Icons.error;
      case PurchaseState.loading:
      case PurchaseState.purchasing:
      case PurchaseState.restoring:
        return Icons.hourglass_empty;
      case PurchaseState.cancelled:
        return Icons.cancel;
      case PurchaseState.idle:
      default:
        return Icons.circle_outlined;
    }
  }

  // Responsiveness Helpers
  static double getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 800;
    } else if (screenWidth > 800) {
      return screenWidth * 0.8;
    } else {
      return screenWidth;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) {
      return const EdgeInsets.all(24);
    } else {
      return SubscriptionConstants.defaultPadding;
    }
  }

  static int getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 3;
    } else if (screenWidth > 800) {
      return 2;
    } else {
      return 1;
    }
  }

  // Analytics Helpers
  static Map<String, dynamic> getAnalyticsProperties(SubscriptionData data) {
    return {
      'has_offerings': data.hasOfferings,
      'package_count': data.packageCount,
      'has_active_subscription': data.hasActiveSubscription,
      'has_recommended_package': data.recommendedPackage != null,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> getPurchaseAnalyticsProperties(Package package, PurchaseState state) {
    return {
      'package_id': package.identifier,
      'package_type': package.packageType.name,
      'price': package.storeProduct.price,
      'currency': package.storeProduct.currencyCode,
      'state': state.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Utility Functions
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? SubscriptionConstants.errorColor 
            : SubscriptionConstants.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, 
    String title, 
    String content,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(SubscriptionConstants.cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // Debug Helpers
  static void logDebug(String message) {
    debugPrint('[SubscriptionHelpers] $message');
  }

  static void logError(String message, [Object? error]) {
    debugPrint('[SubscriptionHelpers] ERROR: $message');
    if (error != null) {
      debugPrint('[SubscriptionHelpers] Stack trace: $error');
    }
  }
}
