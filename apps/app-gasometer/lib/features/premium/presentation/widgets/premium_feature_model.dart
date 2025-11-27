import 'package:flutter/material.dart';

/// Simple immutable model used to render a feature card in the Premium page.
@immutable
class PremiumFeature {
  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.isEnabled,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isEnabled;
}
