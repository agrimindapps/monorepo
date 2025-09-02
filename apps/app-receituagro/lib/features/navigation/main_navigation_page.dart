import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigation_provider.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../comentarios/comentarios_page.dart';
import '../culturas/lista_culturas_page.dart';
import '../defensivos/defensivos_page.dart';
import '../defensivos/lista_defensivos_page.dart';
import '../favoritos/favoritos_page.dart';
import '../pragas/detalhe_praga_page.dart';
import '../pragas/lista_pragas_page.dart';
import '../pragas/pragas_page.dart';
import '../settings/settings_page.dart';
import '../subscription/subscription_page.dart';
import 'navigation_test_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late AppNavigationProvider _navigationProvider;

  @override
  void initState() {
    super.initState();
    _navigationProvider = AppNavigationProvider();
    if (widget.initialIndex != 0) {
      _navigationProvider.navigateToBottomNavTab(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _navigationProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _navigationProvider,
      child: Consumer<AppNavigationProvider>(
        builder: (context, navigationProvider, child) {
          return Scaffold(
            body: _buildCurrentPage(navigationProvider),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: navigationProvider.currentBottomNavIndex,
              onTap: (index) {
                navigationProvider.navigateToBottomNavTab(index);
                
                // Recarrega favoritos quando a tab for selecionada
                if (index == 2) { // Index 2 é a página de favoritos
                  FavoritosPage.reloadIfActive();
                }
              },
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shield),
                  activeIcon: Icon(Icons.shield, size: 28),
                  label: 'Defensivos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bug_report),
                  activeIcon: Icon(Icons.bug_report, size: 28),
                  label: 'Pragas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite, size: 28),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.comment_outlined),
                  activeIcon: Icon(Icons.comment, size: 28),
                  label: 'Comentários',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings, size: 28),
                  label: 'Config',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPage(AppNavigationProvider navigationProvider) {
    final currentPage = navigationProvider.currentPage;
    if (currentPage == null) {
      return const SizedBox(); // Fallback
    }

    return _buildPageForType(currentPage.type, currentPage.arguments);
  }

  Widget _buildPageForType(AppPageType pageType, Map<String, dynamic>? arguments) {
    switch (pageType) {
      // Páginas principais
      case AppPageType.defensivos:
        return const DefensivosPage().withResponsiveWrapper();
      case AppPageType.pragas:
        return const PragasPage().withResponsiveWrapper();
      case AppPageType.favoritos:
        return const FavoritosPage().withResponsiveWrapper();
      case AppPageType.comentarios:
        return const ComentariosPage().withResponsiveWrapper();
      case AppPageType.settings:
        return const SettingsPage().withResponsiveWrapper();
      
      // Páginas de detalhes
      case AppPageType.listaPragas:
        return ListaPragasPage(
          pragaType: arguments?['pragaType'] as String?,
        ).withResponsiveWrapper();
      case AppPageType.detalhePraga:
        return DetalhePragaPage(
          pragaName: arguments?['pragaName'] as String? ?? '',
          pragaScientificName: arguments?['pragaScientificName'] as String? ?? '',
        ).withResponsiveWrapper();
      case AppPageType.listaDefensivos:
        return const ListaDefensivosPage().withResponsiveWrapper();
      case AppPageType.detalheDefensivo:
        return DetalheDefensivoPage(
          defensivoName: arguments?['defensivoName'] as String? ?? '',
          fabricante: arguments?['fabricante'] as String? ?? '',
        ).withResponsiveWrapper();
      case AppPageType.listaCulturas:
        return const ListaCulturasPage().withResponsiveWrapper();
      case AppPageType.subscription:
        return const SubscriptionPage().withResponsiveWrapper();
      case AppPageType.navigationTest:
        return const NavigationTestPage().withResponsiveWrapper();
      default:
        return const Center(
          child: Text('Página não encontrada'),
        ).withResponsiveWrapper();
    }
  }
}