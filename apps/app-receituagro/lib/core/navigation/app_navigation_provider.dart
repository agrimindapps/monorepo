import 'package:flutter/material.dart';

/// Tipo de página que pode ser exibida no app
enum AppPageType {
  // Páginas principais (bottom navigation)
  defensivos,
  pragas,
  favoritos,
  comentarios,
  settings,
  
  // Páginas de detalhes
  listaPragas,
  detalhePraga,
  listaDefensivos,
  detalheDefensivo,
  listaCulturas,
  detalheDetalhes,
  subscription,
  navigationTest,
}

/// Dados de uma página específica
class AppPageData {
  final AppPageType type;
  final Map<String, dynamic>? arguments;
  final String? title;

  const AppPageData({
    required this.type,
    this.arguments,
    this.title,
  });
}

/// Provider para gerenciar navegação interna do app
/// 
/// Mantém uma pilha de páginas e permite navegação sem usar Navigator.push,
/// preservando o bottomNavigationBar
class AppNavigationProvider extends ChangeNotifier {
  final List<AppPageData> _pageStack = [];
  int _currentBottomNavIndex = 0;

  List<AppPageData> get pageStack => List.unmodifiable(_pageStack);
  int get currentBottomNavIndex => _currentBottomNavIndex;
  
  /// Página atual sendo exibida
  AppPageData? get currentPage => _pageStack.isNotEmpty ? _pageStack.last : null;
  
  /// Se está em uma página de detalhe (não é página principal)
  bool get isInDetailPage => _pageStack.isNotEmpty;
  
  /// Título da página atual
  String? get currentPageTitle => currentPage?.title;

  /// Inicializa com a página principal baseada no índice do bottom navigation
  void _initMainPage() {
    _pageStack.clear();
    switch (_currentBottomNavIndex) {
      case 0:
        _pageStack.add(const AppPageData(type: AppPageType.defensivos));
        break;
      case 1:
        _pageStack.add(const AppPageData(type: AppPageType.pragas));
        break;
      case 2:
        _pageStack.add(const AppPageData(type: AppPageType.favoritos));
        break;
      case 3:
        _pageStack.add(const AppPageData(type: AppPageType.comentarios));
        break;
      case 4:
        _pageStack.add(const AppPageData(type: AppPageType.settings));
        break;
    }
  }

  /// Navega para uma nova tab do bottom navigation
  void navigateToBottomNavTab(int index) {
    if (_currentBottomNavIndex != index) {
      _currentBottomNavIndex = index;
      _initMainPage();
      notifyListeners();
    }
  }

  /// Navega para uma página de detalhe
  void navigateToPage(AppPageType pageType, {
    Map<String, dynamic>? arguments,
    String? title,
  }) {
    _pageStack.add(AppPageData(
      type: pageType,
      arguments: arguments,
      title: title,
    ));
    notifyListeners();
  }

  /// Navega para lista de pragas
  void navigateToListaPragas({String? pragaType}) {
    navigateToPage(
      AppPageType.listaPragas,
      arguments: {'pragaType': pragaType},
      title: _getPragaTypeTitle(pragaType),
    );
  }

  /// Navega para detalhe de praga
  void navigateToDetalhePraga({
    required String pragaName,
    String? pragaScientificName,
    Map<String, dynamic>? extraData,
  }) {
    navigateToPage(
      AppPageType.detalhePraga,
      arguments: {
        'pragaName': pragaName,
        'pragaScientificName': pragaScientificName ?? '',
        ...?extraData,
      },
      title: pragaName,
    );
  }

  /// Navega para lista de defensivos
  void navigateToListaDefensivos() {
    navigateToPage(
      AppPageType.listaDefensivos,
      title: 'Defensivos',
    );
  }

  /// Navega para detalhe de defensivo
  void navigateToDetalheDefensivo({
    required String defensivoName,
    String? fabricante,
  }) {
    navigateToPage(
      AppPageType.detalheDefensivo,
      arguments: {
        'defensivoName': defensivoName,
        'fabricante': fabricante,
      },
      title: defensivoName,
    );
  }

  /// Navega para lista de culturas
  void navigateToListaCulturas() {
    navigateToPage(
      AppPageType.listaCulturas,
      title: 'Culturas',
    );
  }

  /// Navega para página de teste de navegação
  void navigateToNavigationTest() {
    navigateToPage(
      AppPageType.navigationTest,
      title: 'Teste de Navegação',
    );
  }

  /// Volta para a página anterior
  bool goBack() {
    if (_pageStack.length > 1) {
      _pageStack.removeLast();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Volta para a página principal da tab atual
  void goBackToMain() {
    if (_pageStack.length > 1) {
      final mainPage = _pageStack.first;
      _pageStack.clear();
      _pageStack.add(mainPage);
      notifyListeners();
    }
  }

  String _getPragaTypeTitle(String? pragaType) {
    switch (pragaType) {
      case '1':
        return 'Insetos';
      case '2':
        return 'Doenças';
      case '3':
        return 'Plantas Daninhas';
      default:
        return 'Pragas';
    }
  }
}