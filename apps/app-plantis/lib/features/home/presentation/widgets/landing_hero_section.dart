import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/landing_content.dart';
import 'landing_coming_soon_banner.dart';
import 'landing_countdown_timer.dart';

/// Hero section widget for landing page
/// Displays the main headline, subtitle, and CTA button
/// When comingSoon is true, shows a countdown timer and "Coming Soon" banner
class LandingHeroSection extends StatelessWidget {
  final HeroContent content;
  final VoidCallback onCtaPressed;
  final bool comingSoon;
  final DateTime? launchDate;

  const LandingHeroSection({
    required this.content,
    required this.onCtaPressed,
    this.comingSoon = false,
    this.launchDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        children: [
          // "Coming Soon" banner
          if (comingSoon && content.comingSoonLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: LandingComingSoonBanner(
                label: content.comingSoonLabel ?? 'Em Breve',
                message: 'Este aplicativo será lançado em breve',
              ),
            ),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          // Countdown timer
          if (comingSoon && launchDate != null) ...[
            const SizedBox(height: 40),
            LandingCountdownTimer(launchDate: launchDate!),
          ],
          const SizedBox(height: 40),
          // CTA Button (disabled when coming soon)
          ElevatedButton(
            onPressed: comingSoon ? null : onCtaPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: comingSoon ? Colors.grey[400] : Colors.white,
              foregroundColor: comingSoon ? Colors.grey : PlantisColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: comingSoon ? 0 : 8,
            ),
            child: Text(
              comingSoon ? 'Aguarde o lançamento' : content.ctaText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
