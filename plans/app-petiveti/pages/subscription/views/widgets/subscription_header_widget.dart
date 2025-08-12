// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/subscription_controller.dart';
import '../../utils/subscription_constants.dart';

class SubscriptionHeaderWidget extends StatelessWidget {
  final SubscriptionController controller;

  const SubscriptionHeaderWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SubscriptionConstants.cardPadding,
      decoration: BoxDecoration(
        gradient: SubscriptionConstants.primaryGradient,
        borderRadius: BorderRadius.circular(SubscriptionConstants.cardRadius),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              SubscriptionConstants.premiumIcon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: SubscriptionConstants.spacing),
          Text(
            SubscriptionConstants.appTitle,
            style: SubscriptionConstants.titleLarge.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SubscriptionConstants.smallSpacing),
          const Text(
            'Cuidados veterinários profissionais para seu pet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.hasActiveSubscription) ...[
            const SizedBox(height: SubscriptionConstants.spacing),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SubscriptionConstants.successColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Premium Ativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
