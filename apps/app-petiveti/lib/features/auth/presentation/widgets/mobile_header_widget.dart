import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';

/// Mobile header widget following SRP
/// 
/// Single responsibility: Display app branding for mobile layout
class MobileHeaderWidget extends StatelessWidget {
  const MobileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SplashColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pets,
                color: SplashColors.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              SplashConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SplashColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Portal do Gestor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: SplashColors.primaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}