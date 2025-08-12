// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/especie_seletor_model.dart';
import 'racas_seletor_constants.dart';

class RacasSeletorHelpers {
  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(RacasSeletorConstants.cardBorderRadius),
      boxShadow: RacasSeletorConstants.cardShadow,
    );
  }

  static BorderRadius getCardBorderRadius() {
    return BorderRadius.circular(RacasSeletorConstants.cardBorderRadius);
  }

  static BorderRadius getImageBorderRadius() {
    return const BorderRadius.vertical(
      top: Radius.circular(RacasSeletorConstants.imageBorderRadius),
    );
  }

  static BorderRadius getBadgeBorderRadius() {
    return BorderRadius.circular(RacasSeletorConstants.badgeBorderRadius);
  }

  static TextStyle getCardTitleStyle(BuildContext context) {
    return RacasSeletorConstants.cardTitleStyle.copyWith(
      color: Theme.of(context).textTheme.titleLarge?.color,
    );
  }

  static TextStyle getCardDescriptionStyle(BuildContext context) {
    return RacasSeletorConstants.cardDescriptionStyle.copyWith(
      color: Colors.grey[600],
    );
  }

  static TextStyle getFallbackTextStyle(BuildContext context) {
    return RacasSeletorConstants.fallbackTextStyle.copyWith(
      color: Colors.grey[600],
    );
  }

  static Color getFallbackIconColor(BuildContext context) {
    return Colors.grey[600] ?? Colors.grey;
  }

  static String formatRacasCount(int count) {
    if (count == 0) return '0 raças';
    if (count == 1) return '1 raça';
    return '$count raças';
  }

  static Widget buildBadge(String text) {
    return Container(
      padding: RacasSeletorConstants.badgePadding,
      decoration: BoxDecoration(
        color: RacasSeletorConstants.badgeBackgroundColor,
        borderRadius: getBadgeBorderRadius(),
      ),
      child: Text(
        text,
        style: RacasSeletorConstants.badgeTextStyle,
      ),
    );
  }

  static Widget buildFallbackContent(String title, IconData icon, BuildContext context) {
    return Container(
      width: double.infinity,
      color: RacasSeletorConstants.fallbackBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: RacasSeletorConstants.fallbackIconSize,
              color: getFallbackIconColor(context),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: getFallbackTextStyle(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: RacasSeletorConstants.loadingPadding,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: RacasSeletorConstants.errorPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: RacasSeletorConstants.errorIconSize,
              color: RacasSeletorConstants.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar',
              style: RacasSeletorConstants.errorTitleStyle.copyWith(
                color: RacasSeletorConstants.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: RacasSeletorConstants.errorMessageStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  static int getResponsiveGridCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return RacasSeletorConstants.getGridCrossAxisCount(screenWidth);
  }

  static double getResponsiveAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return RacasSeletorConstants.getCardAspectRatio(screenWidth);
  }

  static SliverGridDelegate getResponsiveGridDelegate(BuildContext context) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: getResponsiveGridCount(context),
      childAspectRatio: getResponsiveAspectRatio(context),
      crossAxisSpacing: RacasSeletorConstants.gridCrossAxisSpacing,
      mainAxisSpacing: RacasSeletorConstants.gridMainAxisSpacing,
    );
  }

  static Color getSpeciesColor(String especieNome) {
    switch (especieNome.toLowerCase()) {
      case 'cachorros':
        return Colors.brown;
      case 'gatos':
        return Colors.orange;
      case 'coelhos':
        return Colors.pink;
      case 'cobras':
        return Colors.green;
      case 'aranhas':
        return Colors.purple;
      case 'peixes':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static bool shouldShowSpecies(EspecieSeletor especie) {
    // Pode incluir lógica para filtrar espécies baseado em preferências do usuário
    return true;
  }

  static String getAccessibilityLabel(EspecieSeletor especie) {
    return '${especie.nome}, ${especie.racasText}, ${especie.descricao}';
  }

  static Duration getAnimationDuration() {
    return RacasSeletorConstants.cardAnimationDuration;
  }

  static EdgeInsets getGridPadding() {
    return RacasSeletorConstants.gridPadding;
  }

  static EdgeInsets getCardPadding() {
    return RacasSeletorConstants.cardPadding;
  }
}
