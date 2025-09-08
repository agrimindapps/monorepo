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
  
  // Novas páginas para migração
  detalheCultura,
  buscarAvancada,
  resultadosBusca,
}

/// Configuração de navegação para controlar exibição de BottomNav
class NavigationConfig {
  final bool showBottomNavigation;
  final bool showBackButton;
  final bool canGoBack;
  final String? customAppBarTitle;
  
  const NavigationConfig({
    this.showBottomNavigation = true,
    this.showBackButton = true,
    this.canGoBack = true,
    this.customAppBarTitle,
  });
}

/// Dados de uma página específica
class AppPageData {
  final AppPageType type;
  final Map<String, dynamic>? arguments;
  final String? title;
  final NavigationConfig config;

  const AppPageData({
    required this.type,
    this.arguments,
    this.title,
    this.config = const NavigationConfig(),
  });
}

/// Provider para gerenciar navegação interna do app
/// 
/// Sistema completo de navegação que:
/// - Mantém uma pilha de páginas sem usar Navigator.push
/// - Controla quando BottomNavigation deve aparecer
/// - Gerencia estados para páginas principais vs detalhes
/// - Preserva contexto de navegação entre transições
class AppNavigationProvider extends ChangeNotifier {
  final List<AppPageData> _pageStack = [];
  int _currentBottomNavIndex = 0;
  
  // Navigation history para melhor UX
  final List<AppPageData> _navigationHistory = [];
  static const int _maxHistoryLength = 10;
  
  // Estado para controle de loading durante navegação
  bool _isNavigating = false;

  List<AppPageData> get pageStack => List.unmodifiable(_pageStack);
  List<AppPageData> get navigationHistory => List.unmodifiable(_navigationHistory);
  int get currentBottomNavIndex => _currentBottomNavIndex;
  bool get isNavigating => _isNavigating;
  
  /// Página atual sendo exibida
  AppPageData? get currentPage => _pageStack.isNotEmpty ? _pageStack.last : null;
  
  /// Se está em uma página de detalhe (não é página principal)
  bool get isInDetailPage => _pageStack.length > 1;
  
  /// Se deve mostrar BottomNavigation na página atual
  bool get shouldShowBottomNavigation => currentPage?.config.showBottomNavigation ?? true;
  
  /// Se deve mostrar botão de voltar
  bool get shouldShowBackButton => isInDetailPage && (currentPage?.config.showBackButton ?? true);
  
  /// Se pode voltar (tem páginas na pilha)
  bool get canGoBack => _pageStack.length > 1 && (currentPage?.config.canGoBack ?? true);
  
  /// Título da página atual
  String? get currentPageTitle => currentPage?.config.customAppBarTitle ?? currentPage?.title;
  
  /// Profundidade da navegação (quantas páginas na pilha)
  int get navigationDepth => _pageStack.length;
  
  /// Página principal da tab atual
  AppPageData? get mainPageOfCurrentTab => _pageStack.isNotEmpty ? _pageStack.first : null;

  /// Inicializa com a página principal baseada no índice do bottom navigation
  void _initMainPage() {
    _pageStack.clear();
    
    // Adiciona à história se não for a mesma página
    final newMainPage = _getMainPageForIndex(_currentBottomNavIndex);
    if (newMainPage != null) {
      _pageStack.add(newMainPage);
      _addToHistory(newMainPage);
    }
  }
  
  /// Retorna a página principal para o índice dado
  AppPageData? _getMainPageForIndex(int index) {
    switch (index) {
      case 0:
        return const AppPageData(
          type: AppPageType.defensivos,
          title: 'Defensivos',
          config: NavigationConfig(showBottomNavigation: true, showBackButton: false),
        );
      case 1:
        return const AppPageData(
          type: AppPageType.pragas,
          title: 'Pragas',
          config: NavigationConfig(showBottomNavigation: true, showBackButton: false),
        );
      case 2:
        return const AppPageData(
          type: AppPageType.favoritos,
          title: 'Favoritos',
          config: NavigationConfig(showBottomNavigation: true, showBackButton: false),
        );
      case 3:
        return const AppPageData(
          type: AppPageType.comentarios,
          title: 'Comentários',
          config: NavigationConfig(showBottomNavigation: true, showBackButton: false),
        );
      case 4:
        return const AppPageData(
          type: AppPageType.settings,
          title: 'Configurações',
          config: NavigationConfig(showBottomNavigation: true, showBackButton: false),
        );
      default:
        return null;
    }
  }

  /// Navega para uma nova tab do bottom navigation
  void navigateToBottomNavTab(int index) {
    if (_currentBottomNavIndex != index) {
      _setNavigating(true);
      _currentBottomNavIndex = index;
      _initMainPage();
      _setNavigating(false);
      notifyListeners();
    }
  }

  /// Navega para uma página de detalhe
  void navigateToPage(AppPageType pageType, {
    Map<String, dynamic>? arguments,
    String? title,
    NavigationConfig? config,
  }) {
    _setNavigating(true);
    
    final pageData = AppPageData(
      type: pageType,
      arguments: arguments,
      title: title,
      config: config ?? _getDefaultConfigForPageType(pageType),
    );
    
    _pageStack.add(pageData);
    _addToHistory(pageData);
    
    _setNavigating(false);
    notifyListeners();
  }
  
  /// Retorna configuração padrão para um tipo de página
  NavigationConfig _getDefaultConfigForPageType(AppPageType pageType) {
    switch (pageType) {
      // Páginas de detalhes - SEM BottomNav
      case AppPageType.detalheDefensivo:
      case AppPageType.detalhePraga:
      case AppPageType.detalheDetalhes:
      case AppPageType.detalheCultura:
        return const NavigationConfig(
          showBottomNavigation: false,
          showBackButton: true,
          canGoBack: true,
        );
      
      // Páginas de listas - COM BottomNav
      case AppPageType.listaDefensivos:
      case AppPageType.listaPragas:
      case AppPageType.listaCulturas:
        return const NavigationConfig(
          showBottomNavigation: true,
          showBackButton: true,
          canGoBack: true,
        );
      
      // Páginas especiais
      case AppPageType.subscription:
        return const NavigationConfig(
          showBottomNavigation: false,
          showBackButton: true,
          canGoBack: true,
        );
      
      // Páginas de busca e resultados
      case AppPageType.buscarAvancada:
      case AppPageType.resultadosBusca:
        return const NavigationConfig(
          showBottomNavigation: true,
          showBackButton: true,
          canGoBack: true,
        );
      
      default:
        return const NavigationConfig();
    }
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
    if (_pageStack.length > 1 && canGoBack) {
      _setNavigating(true);
      _pageStack.removeLast();
      _setNavigating(false);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Volta para a página principal da tab atual
  void goBackToMain() {
    if (_pageStack.length > 1) {
      _setNavigating(true);
      final mainPage = _pageStack.first;
      _pageStack.clear();
      _pageStack.add(mainPage);
      _setNavigating(false);
      notifyListeners();
    }
  }
  
  /// Remove todas as páginas até encontrar uma do tipo especificado
  void popUntil(AppPageType pageType) {
    _setNavigating(true);
    while (_pageStack.length > 1 && _pageStack.last.type != pageType) {
      _pageStack.removeLast();
    }
    _setNavigating(false);
    notifyListeners();
  }
  
  /// Replace da página atual (útil para redirecionamentos)
  void replacePage(AppPageType pageType, {
    Map<String, dynamic>? arguments,
    String? title,
    NavigationConfig? config,
  }) {
    if (_pageStack.isNotEmpty) {
      _setNavigating(true);
      _pageStack.removeLast();
      
      final pageData = AppPageData(
        type: pageType,
        arguments: arguments,
        title: title,
        config: config ?? _getDefaultConfigForPageType(pageType),
      );
      
      _pageStack.add(pageData);
      _addToHistory(pageData);
      
      _setNavigating(false);
      notifyListeners();
    }
  }
  
  /// Navega e limpa toda a pilha (útil para reset completo)
  void navigateAndClearStack(AppPageType pageType, {
    Map<String, dynamic>? arguments,
    String? title,
    NavigationConfig? config,
  }) {
    _setNavigating(true);
    _pageStack.clear();
    
    final pageData = AppPageData(
      type: pageType,
      arguments: arguments,
      title: title,
      config: config ?? _getDefaultConfigForPageType(pageType),
    );
    
    _pageStack.add(pageData);
    _addToHistory(pageData);
    
    _setNavigating(false);
    notifyListeners();
  }
  
  /// Adiciona página ao histórico de navegação
  void _addToHistory(AppPageData page) {
    _navigationHistory.add(page);
    
    // Mantém apenas as últimas páginas no histórico
    if (_navigationHistory.length > _maxHistoryLength) {
      _navigationHistory.removeAt(0);
    }
  }
  
  /// Define estado de navegação
  void _setNavigating(bool value) {
    if (_isNavigating != value) {
      _isNavigating = value;
      // Pode notificar listeners se quiser mostrar loading durante navegação
    }
  }
  
  /// Limpa histórico de navegação
  void clearHistory() {
    _navigationHistory.clear();
  }
  
  /// Verifica se uma página específica está na pilha
  bool hasPageInStack(AppPageType pageType) {
    return _pageStack.any((page) => page.type == pageType);
  }
  
  /// Retorna quantas vezes uma página aparece na pilha
  int getPageCountInStack(AppPageType pageType) {
    return _pageStack.where((page) => page.type == pageType).length;
  }
  
  /// Retorna informações de debug da navegação
  Map<String, dynamic> getNavigationDebugInfo() {
    return {
      'currentBottomNavIndex': _currentBottomNavIndex,
      'navigationDepth': navigationDepth,
      'isInDetailPage': isInDetailPage,
      'shouldShowBottomNavigation': shouldShowBottomNavigation,
      'shouldShowBackButton': shouldShowBackButton,
      'canGoBack': canGoBack,
      'currentPageType': currentPage?.type.toString(),
      'currentPageTitle': currentPageTitle,
      'stackPages': _pageStack.map((p) => p.type.toString()).toList(),
      'historyCount': _navigationHistory.length,
      'isNavigating': _isNavigating,
    };
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
  
  @override
  void dispose() {
    _pageStack.clear();
    _navigationHistory.clear();
    super.dispose();
  }
}