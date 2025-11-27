import 'package:flutter/material.dart';

import 'premium_active_card.dart';
import 'premium_upgrade_card.dart';

/// Card showing premium status or upgrade option.
class AccountPremiumCard extends StatelessWidget {
  const AccountPremiumCard({
    super.key,
    required this.isPremium,
  });

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return isPremium
        ? const PremiumActiveCard()
        : const PremiumUpgradeCard();
  }
}
