// Flutter imports:
import 'package:flutter/material.dart';

class RacasSeletorConstants {
  // Configurações do layout do grid
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.85;
  static const double gridCrossAxisSpacing = 16.0;
  static const double gridMainAxisSpacing = 16.0;
  static const EdgeInsets gridPadding = EdgeInsets.fromLTRB(8, 8, 8, 0);

  // Configurações do card
  static const double cardElevation = 4.0;
  static const double cardBorderRadius = 12.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(8);

  // Configurações da imagem
  static const double imageBorderRadius = 12.0;
  static const int imageFlexValue = 3;
  static const int infoFlexValue = 2;

  // Configurações do badge de raças
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const double badgeBorderRadius = 10.0;
  static const Color badgeBackgroundColor = Colors.black54;
  static const TextStyle badgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  // Configurações do fallback
  static const double fallbackIconSize = 40.0;
  static const Color fallbackBackgroundColor = Color(0xFFEEEEEE);
  static const TextStyle fallbackTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  // Estilos de texto do card
  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardDescriptionStyle = TextStyle(
    fontSize: 11,
  );

  // Configurações do layout principal
  static const double maxWidth = 1120.0;
  static const EdgeInsets mainPadding = EdgeInsets.zero;

  // Configurações de animação
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);
  static const Duration loadingAnimationDuration = Duration(milliseconds: 500);

  // Configurações do loading
  static const double loadingIndicatorSize = 24.0;
  static const EdgeInsets loadingPadding = EdgeInsets.all(32);

  // Configurações do erro
  static const double errorIconSize = 64.0;
  static const EdgeInsets errorPadding = EdgeInsets.all(32);
  static const TextStyle errorTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle errorMessageStyle = TextStyle(
    fontSize: 14,
  );

  // Configurações do modal de informações
  static const double modalIconSize = 24.0;
  static const EdgeInsets modalContentPadding = EdgeInsets.all(16);
  static const double modalSpacing = 8.0;

  // Cores
  static const Color primaryColor = Colors.blue;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;

  // Configurações de sombra
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // Configurações do Hero
  static String getHeroTag(String especieNome) => 'especie_$especieNome';

  // Configurações responsivas
  static int getGridCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }

  static double getCardAspectRatio(double screenWidth) {
    if (screenWidth > 600) return gridChildAspectRatio;
    return 1.2; // Mais alto em telas pequenas
  }

  // Configurações de acessibilidade
  static const String cardSemanticLabel = 'Card de espécie animal';
  static const String badgeSemanticLabel = 'Número de raças disponíveis';
  static const String fallbackSemanticLabel = 'Imagem não disponível';
}
