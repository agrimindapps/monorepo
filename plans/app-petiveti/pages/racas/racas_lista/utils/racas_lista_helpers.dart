// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'racas_lista_constants.dart';

class RacasListaHelpers {
  static BoxDecoration getCardDecoration({bool isSelected = false}) {
    return BoxDecoration(
      borderRadius: RacasListaConstants.defaultBorderRadius,
      border: isSelected
          ? Border.all(
              color: RacasListaConstants.selectedBorderColor,
              width: 2,
            )
          : null,
      boxShadow: isSelected
          ? RacasListaConstants.selectedCardShadow
          : RacasListaConstants.cardShadow,
    );
  }

  static BoxDecoration getImageDecoration() {
    return const BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(RacasListaConstants.cardBorderRadius),
        bottomLeft: Radius.circular(RacasListaConstants.cardBorderRadius),
      ),
    );
  }

  static BoxDecoration getGridImageDecoration() {
    return const BoxDecoration(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RacasListaConstants.cardBorderRadius),
      ),
    );
  }

  static BoxDecoration getHeaderImageDecoration(ImageProvider imageProvider) {
    return BoxDecoration(
      image: DecorationImage(
        image: imageProvider,
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static BoxDecoration getBadgeDecoration() {
    return BoxDecoration(
      color: RacasListaConstants.badgeBackgroundColor.withValues(alpha: 0.1),
      borderRadius: RacasListaConstants.badgeBorderRadius,
      border: Border.all(
        color: RacasListaConstants.badgeBackgroundColor.withValues(alpha: 0.3),
      ),
    );
  }

  static Widget buildSelectionIndicator() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: RacasListaConstants.selectedBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  static Widget buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: getBadgeDecoration(),
      child: Text(
        text,
        style: RacasListaConstants.badgeTextStyle.copyWith(
          color: RacasListaConstants.badgeBackgroundColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  static Widget buildBadgesWrap(List<String> badges) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: badges.map((badge) => buildBadge(badge)).toList(),
    );
  }

  static Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    TextStyle? textStyle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$label: $value',
            style: textStyle ?? TextStyle(color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget buildInfoRowExpanded({
    required IconData icon,
    required String text,
    Color? iconColor,
    TextStyle? textStyle,
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? TextStyle(color: Colors.grey[700]),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static TextStyle getEspecieTitleStyle(Color? color) {
    return RacasListaConstants.especieTitleStyle.copyWith(color: color);
  }

  static TextStyle getEspecieSubtitleStyle(Color? color) {
    return RacasListaConstants.especieSubtitleStyle.copyWith(color: color);
  }

  static String formatTotalRacas(int total) {
    if (total == 0) return 'Nenhuma raça registrada';
    if (total == 1) return '1 raça registrada';
    return '$total raças registradas';
  }

  static String formatSelectionCount(int count) {
    if (count == 0) return 'Nenhuma raça selecionada';
    if (count == 1) return '1 raça selecionada';
    return '$count raças selecionadas';
  }

  static Color getFilterChipColor(bool isSelected) {
    return isSelected 
        ? RacasListaConstants.selectedBackgroundColor.withValues(alpha: 0.1)
        : Colors.grey[200]!;
  }

  static Color getFilterChipSelectedColor() {
    return RacasListaConstants.selectedBackgroundColor.withValues(alpha: 0.1);
  }

  static Color getFilterChipCheckmarkColor() {
    return RacasListaConstants.selectedBackgroundColor.withValues(alpha: 0.8);
  }

  static Widget buildEmptyStateIcon() {
    return Icon(
      Icons.search_off,
      size: 64,
      color: Colors.grey[400],
    );
  }

  static Widget buildHeroImage({
    required String imagePath,
    required String heroTag,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return Hero(
      tag: heroTag,
      child: Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? Container(
            color: Colors.grey[300],
            child: const Icon(Icons.pets, color: Colors.grey),
          );
        },
      ),
    );
  }

  static LinearGradient getHeaderImageGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.4),
      ],
    );
  }

  static Duration getAnimationDuration({bool fast = false}) {
    return fast
        ? RacasListaConstants.fastAnimationDuration
        : RacasListaConstants.animationDuration;
  }

  static EdgeInsets getCardPadding() {
    return RacasListaConstants.cardPadding;
  }

  static EdgeInsets getCardMargin() {
    return RacasListaConstants.cardMargin;
  }

  static BorderRadius getDefaultBorderRadius() {
    return RacasListaConstants.defaultBorderRadius;
  }

  static bool shouldShowMaxSelectionMessage(Set<String> selectedRacas) {
    return selectedRacas.length >= RacasListaConstants.maxSelecaoComparacao;
  }

  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: RacasListaConstants.emptyStateTitle.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
