// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

class GameTheme {
  // Cores primárias
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryRed = Color(0xFFF44336);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // Esquemas de cores
  static const xPlayerColors = [
    Color(0xFF1976D2), // Azul principal
    Color(0xFF1565C0), // Azul escuro
    Color(0xFFBBDEFB), // Azul claro
  ];
  
  static const oPlayerColors = [
    Color(0xFFD32F2F), // Vermelho principal
    Color(0xFFC62828), // Vermelho escuro
    Color(0xFFFFCDD2), // Vermelho claro
  ];
  
  // Gradientes
  static const winnerGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Sombras
  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  // Tamanhos responsivos
  static double getGameBoardSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final minDimension = math.min(screenWidth, screenHeight);
    
    if (minDimension < 400) {
      return minDimension * 0.8;
    } else if (minDimension < 600) {
      return minDimension * 0.7;
    } else {
      return math.min(400.0, minDimension * 0.6);
    }
  }
  
  static double getCellPadding(BuildContext context) {
    final boardSize = getGameBoardSize(context);
    return boardSize * 0.02;
  }
  
  static double getFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return baseFontSize * 0.8;
    } else if (screenWidth > 600) {
      return baseFontSize * 1.2;
    }
    return baseFontSize;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
      ? backgroundDark
      : backgroundLight;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
      ? cardDark
      : cardLight;
  }
}
