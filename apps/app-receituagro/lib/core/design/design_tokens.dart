/// Design Tokens para ReceitaAgro
/// 
/// Sistema de design padronizado para garantir consistência visual
/// across todas as páginas da aplicação.

import 'package:flutter/material.dart';

/// Tokens de espaçamento padronizados
class ReceitaAgroSpacing {
  // Base spacing scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // Semantic spacing tokens
  static const double sectionSpacing = xxl;     // 24px entre seções principais
  static const double cardPadding = lg;         // 16px padding interno de cards
  static const double horizontalPadding = sm;   // 8px padding horizontal padrão
  static const double bottomSafeArea = 80.0;    // 80px espaço para bottom navigation
  static const double headerSpacing = xl;       // 20px após header
  static const double itemSpacing = sm;         // 8px entre items de lista
  static const double sectionHeaderSpacing = md; // 12px após títulos de seção
}

/// Tokens de elevação padronizados
class ReceitaAgroElevation {
  static const double card = 2.0;
  static const double section = 1.0;
  static const double button = 3.0;
  static const double header = 4.0;
}

/// Tokens de border radius padronizados
class ReceitaAgroBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double button = 15.0;
  static const double card = 12.0;
}

/// Tokens de tipografia padronizados
class ReceitaAgroTypography {
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle itemTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle itemSubtitle = TextStyle(
    fontSize: 14,
  );
  
  static const TextStyle itemCategory = TextStyle(
    fontSize: 12,
  );
}

/// Tokens de dimensões padronizados
class ReceitaAgroDimensions {
  static const double buttonHeight = 90.0;
  static const double itemImageSize = 48.0;
  static const double carouselHeight = 280.0;
  static const double touchTargetSize = 44.0;
}

/// Tokens de responsividade
class ReceitaAgroBreakpoints {
  static const double smallDevice = 360.0;
  static const double mediumDevice = 600.0;
  static const double verticalLayoutThreshold = 320.0;
}