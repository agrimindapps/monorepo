// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/models/card_grid_info.dart';

/// Utilitário para cálculos responsivos no jogo da memória
///
/// Esta classe fornece métodos para calcular dimensões apropriadas
/// com base no tamanho da tela e na dificuldade do jogo.
class ResponsiveGameUtils {
  /// Constantes de layout
  static const double _horizontalPadding = 32.0;
  static const double _cardMargin = 8.0;
  static const double _gridPadding = 16.0;
  static const double _minCardSize = 40.0;
  static const double _maxCardSize = 120.0;
  static const double _uiReservedHeight = 200.0; // Espaço para AppBar e botões

  /// Calcula informações da grade de cartas com validação responsiva
  ///
  /// [screenSize] - Tamanho da tela
  /// [gridSize] - Número de colunas/linhas da grade
  /// [orientation] - Orientação da tela
  static CardGridInfo calculateCardGridInfo({
    required Size screenSize,
    required int gridSize,
    Orientation orientation = Orientation.portrait,
  }) {
    // Calcula tamanho baseado na largura da tela
    double availableWidth = screenSize.width - _horizontalPadding;
    double calculatedCardSize = availableWidth / gridSize;

    // Aplica restrições de tamanho mínimo e máximo
    double cardSize = calculatedCardSize.clamp(_minCardSize, _maxCardSize);

    // Calcula tamanho real da carta (removendo margem)
    double actualCardSize = cardSize - _cardMargin;

    // Calcula dimensões da grade
    double gridWidth = cardSize * gridSize + _gridPadding;
    double gridHeight = cardSize * gridSize + _gridPadding;

    // Verifica se a grade cabe na altura disponível
    double availableHeight = screenSize.height - _uiReservedHeight;
    if (gridHeight > availableHeight) {
      // Recalcula baseado na altura disponível
      double heightBasedCardSize = (availableHeight - _gridPadding) / gridSize;
      cardSize = heightBasedCardSize.clamp(_minCardSize, _maxCardSize);
      actualCardSize = cardSize - _cardMargin;
      gridWidth = cardSize * gridSize + _gridPadding;
      gridHeight = cardSize * gridSize + _gridPadding;
    }

    // Ajustes especiais para orientação landscape em tablets
    if (orientation == Orientation.landscape && _isTablet(screenSize)) {
      cardSize = math.min(cardSize, _maxCardSize * 0.8);
      actualCardSize = cardSize - _cardMargin;
      gridWidth = cardSize * gridSize + _gridPadding;
      gridHeight = cardSize * gridSize + _gridPadding;
    }

    return CardGridInfo(
      cardSize: cardSize,
      actualCardSize: actualCardSize,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      gridSize: gridSize,
    );
  }

  /// Verifica se o dispositivo é considerado um tablet
  static bool _isTablet(Size screenSize) {
    double diagonal = math
        .sqrt(math.pow(screenSize.width, 2) + math.pow(screenSize.height, 2));
    return diagonal > 1100; // Aproximadamente 7 polegadas
  }

  /// Calcula espaçamento apropriado para o grid
  static double getGridSpacing(Size screenSize) {
    if (screenSize.width < 600) {
      return 2.0; // Telefones pequenos
    } else if (screenSize.width < 900) {
      return 4.0; // Telefones grandes
    } else {
      return 6.0; // Tablets
    }
  }

  /// Calcula padding apropriado para diferentes tamanhos de tela
  static EdgeInsets getScreenPadding(Size screenSize) {
    if (screenSize.width < 600) {
      return const EdgeInsets.all(8.0);
    } else if (screenSize.width < 900) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }
}
