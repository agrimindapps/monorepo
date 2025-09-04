import 'package:flutter/material.dart';
import 'premium_upgrade_widget.dart';

class ComentariosPremiumRestrictionWidget extends StatelessWidget {
  final VoidCallback? onUpgradePressed;

  const ComentariosPremiumRestrictionWidget({
    super.key,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumUpgradeWidget.noPermission(
      onUpgrade: onUpgradePressed,
    );
  }
}