// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/subscription_controller.dart';
import '../../utils/subscription_constants.dart';

class SubscriptionTermsWidget extends StatelessWidget {
  final SubscriptionController controller;

  const SubscriptionTermsWidget({
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
            const Row(
              children: [
                Icon(
                  SubscriptionConstants.termsIcon,
                  color: SubscriptionConstants.primaryColor,
                  size: SubscriptionConstants.iconSize,
                ),
                SizedBox(width: SubscriptionConstants.smallSpacing),
                Text(
                  SubscriptionConstants.termsTitle,
                  style: SubscriptionConstants.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.openTermsOfUse,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text(SubscriptionConstants.termsButtonLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SubscriptionConstants.primaryColor,
                      side: const BorderSide(
                        color: SubscriptionConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.openPrivacyPolicy,
                    icon: const Icon(Icons.privacy_tip, size: 18),
                    label: const Text(SubscriptionConstants.privacyButtonLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SubscriptionConstants.primaryColor,
                      side: const BorderSide(
                        color: SubscriptionConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            Text(
              SubscriptionConstants.defaultTermsText,
              style: SubscriptionConstants.bodyMedium.copyWith(
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
