// Flutter imports:
import 'package:flutter/material.dart';

class RacasDetalhesConstants {
  // Cores temáticas para seções
  static const Map<String, Color> sectionColors = {
    'temperamento': Colors.blue,
    'saude': Colors.red,
    'cuidados': Colors.green,
    'treinamento': Colors.amber,
    'caracteristicas': Colors.purple,
    'info': Colors.blue,
  };

  // Ícones para seções
  static const Map<String, IconData> sectionIcons = {
    'temperamento': Icons.mood,
    'saude': Icons.favorite,
    'cuidados': Icons.pets,
    'treinamento': Icons.school,
    'caracteristicas': Icons.star,
    'info': Icons.info_outline,
    'origem': Icons.public,
    'altura': Icons.height,
    'peso': Icons.fitness_center,
    'expectativa': Icons.timer,
    'grupo': Icons.category,
    'galeria': Icons.photo_library,
    'relacionadas': Icons.pets,
    'vacinacao': Icons.vaccines,
    'cuidados_especificos': Icons.medical_services,
    'sinais_alerta': Icons.warning_amber,
  };

  // Configurações de layout
  static const double expandedHeight = 250.0;
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double cardMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 8.0;
  static const double galleryHeight = 120.0;
  static const double galleryItemWidth = 160.0;
  static const double relatedBreedWidth = 120.0;

  // Configurações de sombra
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 10,
    spreadRadius: 0,
    offset: const Offset(0, 2),
  );

  // Cores de fundo das seções
  static Color getSectionBackgroundColor(String section) {
    final baseColor = sectionColors[section] ?? Colors.grey;
    return baseColor.withValues(alpha: 0.1);
  }

  static Color getSectionIconColor(String section) {
    final baseColor = sectionColors[section] ?? Colors.grey;
    return baseColor.withValues(alpha: 0.8);
  }

  // Configurações da barra de características
  static const int maxCharacteristicValue = 5;
  static const double characteristicBarHeight = 8.0;
  static const double characteristicBarSpacing = 2.0;

  // Configurações do modal
  static const double modalInitialSize = 0.7;
  static const double modalMaxSize = 0.9;
  static const double modalMinSize = 0.5;
  static const double modalHandleWidth = 40.0;
  static const double modalHandleHeight = 4.0;

  // Durações de animação
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  // Gradientes
  static LinearGradient get imageGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black.withValues(alpha: 0.7),
    ],
  );

  // Estilos de texto
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle infoLabelStyle = TextStyle(
    fontWeight: FontWeight.w500,
  );

  static TextStyle infoValueStyle = TextStyle(
    color: Colors.grey[800],
  );

  static const TextStyle characteristicLabelStyle = TextStyle(
    fontWeight: FontWeight.w500,
  );

  static const TextStyle galleryTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle relatedBreedNameStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle modalTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle modalSectionTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static const TextStyle modalContentStyle = TextStyle(
    height: 1.5,
  );
}
