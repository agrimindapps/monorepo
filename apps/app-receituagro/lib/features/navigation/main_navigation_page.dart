import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigation_provider.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../comentarios/comentarios_page.dart';
import '../culturas/lista_culturas_page.dart';
import '../defensivos/home_defensivos_page.dart';
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
            bottomNavigationBar: _buildBottomNavigationBar(navigationProvider),
          );
        },
      ),
    );
  }


  /// Constrói BottomNavigationBar com controle de visibilidade
  Widget? _buildBottomNavigationBar(AppNavigationProvider navigationProvider) {
    // Só mostra BottomNav quando configurado para mostrar
    if (!navigationProvider.shouldShowBottomNavigation) {
      return null;
    }

    return BottomNavigationBar(
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
    );
  }

  Widget _buildCurrentPage(AppNavigationProvider navigationProvider) {
    final currentPage = navigationProvider.currentPage;
    if (currentPage == null) {
      return const Center(
        child: Text('Carregando...'),
      );
    }

    // Adiciona loading indicator se estiver navegando
    return Stack(
      children: [
        _buildPageForType(currentPage.type, currentPage.arguments),
        if (navigationProvider.isNavigating)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildPageForType(AppPageType pageType, Map<String, dynamic>? arguments) {
    Widget page;
    
    switch (pageType) {
      // Páginas principais
      case AppPageType.defensivos:
        page = const HomeDefensivosPage();
        break;
      case AppPageType.pragas:
        page = const PragasPage();
        break;
      case AppPageType.favoritos:
        page = const FavoritosPage();
        break;
      case AppPageType.comentarios:
        page = const ComentariosPage();
        break;
      case AppPageType.settings:
        page = const SettingsPage();
        break;
      
      // Páginas de detalhes e listas
      case AppPageType.listaPragas:
        page = ListaPragasPage(
          pragaType: arguments?['pragaType'] as String?,
        );
        break;
      case AppPageType.detalhePraga:
        page = DetalhePragaPage(
          pragaName: arguments?['pragaName'] as String? ?? '',
          pragaScientificName: arguments?['pragaScientificName'] as String? ?? '',
        );
        break;
      case AppPageType.listaDefensivos:
        page = const ListaDefensivosPage();
        break;
      case AppPageType.detalheDefensivo:
        page = DetalheDefensivoPage(
          defensivoName: arguments?['defensivoName'] as String? ?? '',
          fabricante: arguments?['fabricante'] as String? ?? '',
        );
        break;
      case AppPageType.listaCulturas:
        page = const ListaCulturasPage();
        break;
      case AppPageType.subscription:
        page = const SubscriptionPage();
        break;
      case AppPageType.navigationTest:
        page = const NavigationTestPage();
        break;
      
      // Novas páginas para migração futura
      case AppPageType.detalheCultura:
        page = _buildPlaceholderPage('Detalhe da Cultura', arguments);
        break;
      case AppPageType.buscarAvancada:
        page = _buildPlaceholderPage('Busca Avançada', arguments);
        break;
      case AppPageType.resultadosBusca:
        page = _buildPlaceholderPage('Resultados da Busca', arguments);
        break;
      
      default:
        page = const Center(
          child: Text('Página não encontrada'),
        );
        break;
    }
    
    return page.withResponsiveWrapper();
  }
  
  /// Constrói uma página placeholder para desenvolvimento
  Widget _buildPlaceholderPage(String title, Map<String, dynamic>? arguments) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (arguments != null && arguments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Arguments: $arguments'),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final navigationProvider = Provider.of<AppNavigationProvider>(context, listen: false);
                navigationProvider.goBack();
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

}