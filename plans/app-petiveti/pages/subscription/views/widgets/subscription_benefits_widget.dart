// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/subscription_controller.dart';
import '../../models/benefit_model.dart';
import '../../utils/subscription_constants.dart';
import '../../utils/subscription_helpers.dart';

class SubscriptionBenefitsWidget extends StatelessWidget {
  final SubscriptionController controller;

  const SubscriptionBenefitsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final benefits = controller.getSortedBenefits();

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
              SubscriptionConstants.benefitsTitle,
              style: SubscriptionConstants.titleLarge,
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            if (benefits.isNotEmpty) ...{
              ...benefits.map((benefit) => _buildBenefitItem(benefit)),
            } else ...{
              SubscriptionHelpers.buildEmptyState(
                message: 'Nenhum benefício disponível',
              ),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(Benefit benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SubscriptionConstants.spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: benefit.categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              benefit.icon,
              color: benefit.categoryColor,
              size: SubscriptionConstants.iconSize,
            ),
          ),
          const SizedBox(width: SubscriptionConstants.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        benefit.title,
                        style: SubscriptionConstants.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (benefit.isHighlight) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SubscriptionConstants.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Destaque',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  benefit.description,
                  style: SubscriptionConstants.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: benefit.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getCategoryDisplayName(benefit.category),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: benefit.categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            SubscriptionConstants.checkIcon,
            color: SubscriptionConstants.successColor,
            size: SubscriptionConstants.iconSize,
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(BenefitCategory category) {
    switch (category) {
      case BenefitCategory.feature:
        return 'Funcionalidade';
      case BenefitCategory.professional:
        return 'Profissional';
      case BenefitCategory.convenience:
        return 'Conveniência';
      case BenefitCategory.support:
        return 'Suporte';
    }
  }
}
