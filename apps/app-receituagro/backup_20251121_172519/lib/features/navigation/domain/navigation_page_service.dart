import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../comentarios/comentarios_page.dart';
import '../../defensivos/home_defensivos_page.dart';
import '../../favoritos/favoritos_page.dart';
import '../../pragas/presentation/pages/home_pragas_page.dart';
import '../../settings/settings_page.dart';
import 'navigation_constants.dart';

/// Serviço para gerenciar páginas de navegação
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Centraliza mapeamento de índice → página
/// - Elimina switch case no widget (OCP violation)
/// - Facilita adição de novas páginas
@lazySingleton
class NavigationPageService {
  /// Mapa de índice para widget builder
  final Map<int, Widget Function()> _pageBuilders = {
    NavigationConstants.indexDefensivos: () => const HomeDefensivosPage(),
    NavigationConstants.indexPragas: () => const HomePragasPage(),
    NavigationConstants.indexFavoritos: () => const FavoritosPage(),
    NavigationConstants.indexComentarios: () => const ComentariosPage(),
    NavigationConstants.indexConfiguracoes: () => const SettingsPage(),
  };

  /// Retorna a página para o índice especificado
  Widget getPageByIndex(int index) {
    final builder = _pageBuilders[index];
    if (builder == null) {
      // Fallback para página padrão
      return const HomeDefensivosPage();
    }
    return builder();
  }

  /// Executa ação específica ao navegar para um índice
  /// (ex: reload de favoritos)
  void onNavigateToIndex(int index) {
    if (index == NavigationConstants.indexFavoritos) {
      FavoritosPage.reloadIfActive();
    }
  }

  /// Verifica se um índice é válido
  bool isValidIndex(int index) {
    return index >= 0 && index < NavigationConstants.totalItems;
  }

  /// Retorna índice padrão
  int getDefaultIndex() {
    return NavigationConstants.indexDefensivos;
  }
}
