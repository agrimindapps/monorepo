// Flutter imports:
import 'package:flutter/material.dart';

enum BackgroundTheme {
  defaultGreen,
  lightBlue,
  softPurple,
  warmOrange,
  coolGray,
  rosePink,
  mintGreen,
  lavender,
  peach,
  skyBlue,
}

extension BackgroundThemeExtension on BackgroundTheme {
  String get name {
    switch (this) {
      case BackgroundTheme.defaultGreen:
        return 'Verde Padrão';
      case BackgroundTheme.lightBlue:
        return 'Azul Claro';
      case BackgroundTheme.softPurple:
        return 'Roxo Suave';
      case BackgroundTheme.warmOrange:
        return 'Laranja Quente';
      case BackgroundTheme.coolGray:
        return 'Cinza Frio';
      case BackgroundTheme.rosePink:
        return 'Rosa';
      case BackgroundTheme.mintGreen:
        return 'Verde Menta';
      case BackgroundTheme.lavender:
        return 'Lavanda';
      case BackgroundTheme.peach:
        return 'Pêssego';
      case BackgroundTheme.skyBlue:
        return 'Azul Céu';
    }
  }

  BoxDecoration get decoration {
    switch (this) {
      case BackgroundTheme.defaultGreen:
        return const BoxDecoration(
          color: Color(0xFFE8F5E8), // Verde muito suave
        );
      case BackgroundTheme.lightBlue:
        return const BoxDecoration(
          color: Color(0xFFE3F2FD), // Azul muito claro
        );
      case BackgroundTheme.softPurple:
        return const BoxDecoration(
          color: Color(0xFFF3E5F5), // Roxo muito claro
        );
      case BackgroundTheme.warmOrange:
        return const BoxDecoration(
          color: Color(0xFFFFF3E0), // Laranja muito claro
        );
      case BackgroundTheme.coolGray:
        return const BoxDecoration(
          color: Color(0xFFF5F5F5), // Cinza muito claro
        );
      case BackgroundTheme.rosePink:
        return const BoxDecoration(
          color: Color(0xFFFCE4EC), // Rosa muito claro
        );
      case BackgroundTheme.mintGreen:
        return const BoxDecoration(
          color: Color(0xFFE0F2F1), // Verde menta claro
        );
      case BackgroundTheme.lavender:
        return const BoxDecoration(
          color: Color(0xFFEDE7F6), // Lavanda claro
        );
      case BackgroundTheme.peach:
        return const BoxDecoration(
          color: Color(0xFFFFF8E1), // Pêssego claro
        );
      case BackgroundTheme.skyBlue:
        return const BoxDecoration(
          color: Color(0xFFE1F5FE), // Azul céu claro
        );
    }
  }

  Color get primaryColor {
    switch (this) {
      case BackgroundTheme.defaultGreen:
        return const Color(0xFF4CAF50);
      case BackgroundTheme.lightBlue:
        return const Color(0xFF2196F3);
      case BackgroundTheme.softPurple:
        return const Color(0xFF9C27B0);
      case BackgroundTheme.warmOrange:
        return const Color(0xFFFF9800);
      case BackgroundTheme.coolGray:
        return const Color(0xFF607D8B);
      case BackgroundTheme.rosePink:
        return const Color(0xFFE91E63);
      case BackgroundTheme.mintGreen:
        return const Color(0xFF009688);
      case BackgroundTheme.lavender:
        return const Color(0xFF673AB7);
      case BackgroundTheme.peach:
        return const Color(0xFFFF5722);
      case BackgroundTheme.skyBlue:
        return const Color(0xFF03A9F4);
    }
  }

  Color get previewColor {
    switch (this) {
      case BackgroundTheme.defaultGreen:
        return const Color(0xFFE8F5E8);
      case BackgroundTheme.lightBlue:
        return const Color(0xFFE3F2FD);
      case BackgroundTheme.softPurple:
        return const Color(0xFFF3E5F5);
      case BackgroundTheme.warmOrange:
        return const Color(0xFFFFF3E0);
      case BackgroundTheme.coolGray:
        return const Color(0xFFF5F5F5);
      case BackgroundTheme.rosePink:
        return const Color(0xFFFCE4EC);
      case BackgroundTheme.mintGreen:
        return const Color(0xFFE0F2F1);
      case BackgroundTheme.lavender:
        return const Color(0xFFEDE7F6);
      case BackgroundTheme.peach:
        return const Color(0xFFFFF8E1);
      case BackgroundTheme.skyBlue:
        return const Color(0xFFE1F5FE);
    }
  }
}
