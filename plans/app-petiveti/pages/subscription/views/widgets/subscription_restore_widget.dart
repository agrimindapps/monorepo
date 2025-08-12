// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/subscription_controller.dart';
import '../../utils/subscription_constants.dart';

class SubscriptionRestoreWidget extends StatelessWidget {
  final SubscriptionController controller;

  const SubscriptionRestoreWidget({
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
                  SubscriptionConstants.restoreIcon,
                  color: SubscriptionConstants.primaryColor,
                  size: SubscriptionConstants.iconSize,
                ),
                SizedBox(width: SubscriptionConstants.smallSpacing),
                Text(
                  SubscriptionConstants.restoreTitle,
                  style: SubscriptionConstants.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: SubscriptionConstants.smallSpacing),
            const Text(
              'Se você já possui uma assinatura ativa, restaure suas compras para continuar aproveitando todos os recursos premium do PetiVeti.',
              style: SubscriptionConstants.bodyMedium,
            ),
            const SizedBox(height: SubscriptionConstants.spacing),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.shouldDisableUI 
                    ? null 
                    : controller.restorePurchases,
                icon: controller.isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            SubscriptionConstants.primaryColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 20),
                label: Text(
                  controller.isRestoring 
                      ? SubscriptionConstants.restoringMessage
                      : SubscriptionConstants.restoreButtonLabel,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SubscriptionConstants.primaryColor,
                  side: const BorderSide(
                    color: SubscriptionConstants.primaryColor,
                  ),
                  padding: SubscriptionConstants.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SubscriptionConstants.buttonRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
