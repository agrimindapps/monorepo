// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../controllers/subscription_controller.dart';
import '../../models/subscription_model.dart';
import '../../utils/subscription_constants.dart';
import '../../utils/subscription_helpers.dart';

class SubscriptionPricingWidget extends StatelessWidget {
  final SubscriptionController controller;

  const SubscriptionPricingWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: SubscriptionConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SubscriptionConstants.cardRadius),
      ),
      child: Padding(
        padding: SubscriptionConstants.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              SubscriptionConstants.packagesTitle,
              style: SubscriptionConstants.titleLarge,
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            if (controller.hasOfferings && controller.packages.isNotEmpty) ...{
              ...controller.packages.map((package) => _buildPackageCard(package)),
            } else ...{
              SubscriptionHelpers.buildEmptyState(
                message: SubscriptionConstants.noOffersMessage,
              ),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(SubscriptionPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: package.isRecommended 
              ? SubscriptionConstants.primaryColor 
              : Colors.grey[300]!,
          width: package.isRecommended ? 2 : 1,
        ),
        color: package.isRecommended
            ? SubscriptionConstants.primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Stack(
        children: [
          if (package.isRecommended || package.badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: package.isRecommended 
                      ? SubscriptionConstants.primaryColor
                      : SubscriptionConstants.warningColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  package.badge ?? SubscriptionConstants.recommendedBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.displayTitle,
                            style: SubscriptionConstants.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package.displayDescription,
                            style: SubscriptionConstants.bodyMedium,
                          ),
                          if (package.showDiscount) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: SubscriptionConstants.successColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                package.discountText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          package.priceString,
                          style: SubscriptionConstants.priceStyle,
                        ),
                        Text(
                          SubscriptionHelpers.formatPeriod(package.packageType),
                          style: SubscriptionConstants.bodyMedium.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.shouldDisableUI 
                        ? null 
                        : () => _handlePurchase(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SubscriptionConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: SubscriptionConstants.buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SubscriptionConstants.buttonRadius,
                        ),
                      ),
                      elevation: package.isRecommended ? 4 : 2,
                    ),
                    child: controller.isPurchasing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _getPurchaseButtonText(package),
                            style: SubscriptionConstants.buttonTextStyle,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPurchaseButtonText(SubscriptionPackage package) {
    if (controller.isPurchasing) {
      return 'Processando...';
    }
    
    switch (package.packageType) {
      case PackageType.weekly:
        return 'Assinar Semanal';
      case PackageType.monthly:
        return 'Assinar Mensal';
      case PackageType.threeMonth:
        return 'Assinar Trimestral';
      case PackageType.sixMonth:
        return 'Assinar Semestral';
      case PackageType.annual:
        return 'Assinar Anual';
      case PackageType.lifetime:
        return 'Comprar Vitalício';
      default:
        return SubscriptionConstants.purchaseButtonLabel;
    }
  }

  void _handlePurchase(SubscriptionPackage package) {
    controller.purchasePackage(package.package);
  }
}
