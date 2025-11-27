import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'premium_strings.dart';

/// Card displaying a pricing plan option.
class PremiumPricingCard extends StatelessWidget {
  const PremiumPricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    this.originalPrice,
    this.discount,
    required this.features,
    required this.isPopular,
  });

  final String title;
  final String price;
  final String period;
  final String? originalPrice;
  final String? discount;
  final List<String> features;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) _buildPopularBadge(),
          if (isPopular) const SizedBox(height: 12),
          _buildTitle(context),
          const SizedBox(height: 8),
          _buildPriceRow(context),
          if (originalPrice != null) ...[
            const SizedBox(height: 4),
            _buildOriginalPrice(context),
          ],
          const SizedBox(height: 16),
          ...features.map((f) => _buildFeatureItem(context, f)),
          const SizedBox(height: 16),
          _buildSubscribeButton(context),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: isPopular
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.1),
                GasometerDesignTokens.colorPrimary.withValues(alpha: 0.05),
              ],
            )
          : null,
      color: isPopular ? null : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isPopular
            ? GasometerDesignTokens.colorPremiumAccent
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: isPopular ? 2 : 1,
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorPremiumAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        PremiumStrings.mostPopular,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isPopular
                ? GasometerDesignTokens.colorPremiumAccent
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          period,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (discount != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              discount!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOriginalPrice(BuildContext context) {
    return Text(
      'De $originalPrice',
      style: TextStyle(
        fontSize: 14,
        decoration: TextDecoration.lineThrough,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: isPopular
                ? GasometerDesignTokens.colorPremiumAccent
                : Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(PremiumStrings.purchaseInProgress),
              backgroundColor: Colors.orange,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPopular
              ? GasometerDesignTokens.colorPremiumAccent
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isPopular ? 6 : 2,
        ),
        child: const Text(
          PremiumStrings.subscribeNow,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
