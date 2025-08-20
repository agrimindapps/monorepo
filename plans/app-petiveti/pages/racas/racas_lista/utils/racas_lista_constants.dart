// Flutter imports:
import 'package:flutter/material.dart';

class RacasListaConstants {
  // Filtros rápidos disponíveis
  static const List<String> quickFilterOptions = [
    'Guarda',
    'Familiar',
    'Pequeno',
    'Grande',
    'Pelo curto',
    'Pelo longo',
    'Alta energia',
    'Tranquilo',
  ];

  // Filtros de tamanho
  static const List<String> tamanhoOptions = [
    'Pequeno',
    'Médio',
    'Grande',
    'Gigante',
  ];

  // Filtros de temperamento
  static const List<String> temperamentoOptions = [
    'Amigável',
    'Protetor',
    'Inteligente',
    'Calmo',
    'Ativo',
    'Independente',
    'Leal',
    'Brincalhão',
  ];

  // Filtros de cuidados
  static const List<String> cuidadosOptions = [
    'Pouca manutenção',
    'Manutenção regular',
    'Alta manutenção',
    'Hipoalergênico',
    'Resistente ao frio',
    'Resistente ao calor',
  ];

  // Configurações de layout
  static const double headerImageHeight = 150.0;
  static const double searchBarPadding = 16.0;
  static const double quickFiltersHeight = 40.0;
  static const double cardBorderRadius = 12.0;
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;
  static const double gridSpacing = 12.0;
  static const double listItemHeight = 120.0;
  static const double listItemImageWidth = 120.0;

  // Configurações de comparação
  static const int maxSelecaoComparacao = 3;

  // Durações de animação
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  // Cores
  static const Color selectedBorderColor = Colors.blue;
  static const Color selectedBackgroundColor = Colors.blue;
  static const Color badgeBackgroundColor = Colors.blue;

  // Configurações do modal de filtro
  static const double modalInitialSize = 0.6;
  static const double modalMaxSize = 0.9;
  static const double modalMinSize = 0.5;

  // Estilos de texto
  static const TextStyle headerTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Colors.black,
      ),
    ],
  );

  static const TextStyle especieTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle especieSubtitleStyle = TextStyle(
    fontSize: 12,
  );

  static const TextStyle racaNomeGridStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle racaNomeListStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle racaOrigemStyle = TextStyle(
    fontSize: 12,
  );

  static const TextStyle racaTemperamentoStyle = TextStyle(
    fontSize: 11,
  );

  static const TextStyle badgeTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle emptyStateSubtitle = TextStyle(
    fontSize: 14,
  );

  static const TextStyle modalTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle modalSectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Configurações de sombra
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> selectedCardShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  // Configurações do header da espécie
  static BoxShadow get especieHeaderShadow => const BoxShadow(
    color: Colors.black12,
    blurRadius: 2,
    spreadRadius: 0,
    offset: Offset(0, 1),
  );

  static Color get especieHeaderBackground => Colors.blue[50]!;

  // Configurações de padding e margin
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets gridPadding = EdgeInsets.all(16);
  static const EdgeInsets listPadding = EdgeInsets.all(16);
  static const EdgeInsets searchPadding = EdgeInsets.fromLTRB(16, 8, 16, 8);
  static const EdgeInsets filterChipMargin = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets modalPadding = EdgeInsets.all(24);

  // Configurações de bordas
  static BorderRadius get defaultBorderRadius => 
      BorderRadius.circular(cardBorderRadius);

  static BorderRadius get searchBorderRadius => 
      BorderRadius.circular(12);

  static BorderRadius get badgeBorderRadius => 
      BorderRadius.circular(12);

  static BorderRadius get modalBorderRadius => 
      const BorderRadius.vertical(top: Radius.circular(20));
}
