import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'premium_strings.dart';

/// SliverAppBar with premium branding and gradient background.
class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key, required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: GasometerDesignTokens.colorHeaderBackground,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          PremiumStrings.pageTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        background: _buildBackground(),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildBackground() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GasometerDesignTokens.colorHeaderBackground,
            GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
            GasometerDesignTokens.colorPrimary,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/patterns/premium_pattern.png',
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(top: 40),
              child: Icon(
                isPremium ? Icons.verified : Icons.workspace_premium,
                size: 80,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
