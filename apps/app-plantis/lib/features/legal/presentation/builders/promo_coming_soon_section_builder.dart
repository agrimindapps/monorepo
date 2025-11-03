import 'package:flutter/material.dart';

/// Builder for the Coming Soon section in promotional page
/// Displays banner when app is not yet launched
/// Countdown is shown in the navigation bar instead
class PromoComingSoonSectionBuilder {
  /// Build the coming soon section with banner (countdown moved to nav bar)
  static Widget build({
    required bool comingSoon,
    required DateTime? launchDate,
  }) {
    // Coming soon banner removed - countdown now only in hero section
    return const SizedBox.shrink();
  }
}
