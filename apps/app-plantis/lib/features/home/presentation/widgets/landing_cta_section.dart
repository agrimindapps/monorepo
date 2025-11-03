import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/landing_content.dart';

/// CTA (Call to Action) section widget for landing page
/// When comingSoon is true, the button is disabled
class LandingCtaSection extends StatelessWidget {
  final CTAContent content;
  final VoidCallback onPressed;
  final bool comingSoon;

  const LandingCtaSection({
    required this.content,
    required this.onPressed,
    this.comingSoon = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PlantisColors.primary,
            PlantisColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: comingSoon ? null : onPressed,
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
              comingSoon ? 'Aguarde o lançamento' : content.buttonText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
