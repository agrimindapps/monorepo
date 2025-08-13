// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/favoritos_design_tokens.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String title;
  final Color? accentColor;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.title,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? FavoritosDesignTokens.defensivosColor;

    return Center(
      child: Container(
        margin: FavoritosDesignTokens.sectionPadding,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: FavoritosDesignTokens.getCardColor(context),
          borderRadius:
              BorderRadius.circular(FavoritosDesignTokens.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: FavoritosDesignTokens.createIconGradient(color),
                shape: BoxShape.circle,
                boxShadow: FavoritosDesignTokens.iconShadow(color),
              ),
              child: const Icon(
                Icons.favorite,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: FavoritosDesignTokens.extraLargeSpacing),
            Text(
              title,
              style: FavoritosDesignTokens.cardTitleStyle.copyWith(
                fontSize: FavoritosDesignTokens.headingFontSize,
                fontWeight: FontWeight.bold,
                color: FavoritosDesignTokens.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FavoritosDesignTokens.defaultSpacing),
            Text(
              message,
              style: FavoritosDesignTokens.cardSubtitleStyle.copyWith(
                color: FavoritosDesignTokens.getSubtitleColor(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
