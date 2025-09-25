import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/receituagro_navigation_service.dart';
import '../../core/navigation/agricultural_page_types.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../comentarios/comentarios_page.dart';
import '../culturas/lista_culturas_page.dart';
import '../defensivos/home_defensivos_page.dart';
import '../defensivos/presentation/pages/defensivos_unificado_page.dart';
import '../defensivos/presentation/providers/defensivos_unificado_provider.dart';
import '../favoritos/favoritos_page.dart';
import '../pragas/detalhe_praga_page.dart';
import '../pragas/lista_pragas_page.dart';
import '../pragas/pragas_page.dart';
import '../settings/settings_page.dart';
import '../subscription/subscription_page.dart';

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
  late ReceitaAgroNavigationService _navigationService;
  int _currentBottomNavIndex = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    _currentBottomNavIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentPage(),
          if (_isNavigating)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Constrói BottomNavigationBar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentBottomNavIndex,
      onTap: _onBottomNavTap,
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

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Recarrega favoritos quando a tab for selecionada
    if (index == 2) { // Index 2 é a página de favoritos
      FavoritosPage.reloadIfActive();
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentBottomNavIndex) {
      case 0:
        return const HomeDefensivosPage();
      case 1:
        return const PragasPage();
      case 2:
        return const FavoritosPage();
      case 3:
        return const ComentariosPage();
      case 4:
        return const SettingsPage();
      default:
        return const HomeDefensivosPage();
    }
  }

  // Legacy method support for existing navigation calls
  Widget _buildPageForAgriculturalType(AgriculturalPageType pageType, Map<String, dynamic>? arguments) {
    Widget page;

    switch (pageType) {
      // Páginas principais
      case AgriculturalPageType.favoritos:
        page = const FavoritosPage();
        break;
      case AgriculturalPageType.settings:
        page = const SettingsPage();
        break;

      // Páginas de lista
      case AgriculturalPageType.listaDefensivos:
        page = const DefensivosUnificadoPage();
        break;
      case AgriculturalPageType.listaPragas:
        page = const ListaPragasPage();
        break;
      case AgriculturalPageType.listaCulturas:
        page = const ListaCulturasPage();
        break;

      // Páginas de detalhes
      case AgriculturalPageType.detalheDefensivo:
        final defensivoName = arguments?['defensivoName'] as String?;
        final fabricante = arguments?['fabricante'] as String? ?? 'Fabricante não informado';
        if (defensivoName != null) {
          page = DetalheDefensivoPage(
            defensivoName: defensivoName,
            fabricante: fabricante,
          );
        } else {
          page = const HomeDefensivosPage(); // Fallback
        }
        break;

      case AgriculturalPageType.detalhePraga:
        final pragaName = arguments?['pragaName'] as String?;
        final pragaScientificName = arguments?['pragaScientificName'] as String?;
        if (pragaName != null && pragaScientificName != null) {
          page = DetalhePragaPage(
            pragaName: pragaName,
            pragaScientificName: pragaScientificName,
          );
        } else {
          page = const PragasPage(); // Fallback
        }
        break;

      // Páginas especiais
      case AgriculturalPageType.premium:
        page = const SubscriptionPage();
        break;

      default:
        page = const HomeDefensivosPage();
        break;
    }

    return ResponsiveContentWrapper(child: page);
  }
}