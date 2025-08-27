import 'package:flutter/material.dart';

/// Provider para gerenciar estado das tabs
/// Responsabilidade única: controle de navegação entre tabs
class TabControllerProvider extends ChangeNotifier {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  TabController get tabController => _tabController;
  int get selectedTabIndex => _selectedTabIndex;

  /// Inicializa o TabController
  void initializeTabController(TickerProvider vsync) {
    _tabController = TabController(length: 4, vsync: vsync);
    _tabController.addListener(_onTabChanged);
  }

  /// Handler para mudança de tab
  void _onTabChanged() {
    if (_tabController.index != _selectedTabIndex) {
      _selectedTabIndex = _tabController.index;
      notifyListeners();
    }
  }

  /// Navega para uma tab específica
  void goToTab(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(index);
    }
  }

  /// Dados das tabs com ícones e textos
  List<Map<String, dynamic>> get tabData => [
    {'icon': Icons.info_outlined, 'text': 'Informações'},
    {'icon': Icons.search_outlined, 'text': 'Diagnóstico'},
    {'icon': Icons.settings_outlined, 'text': 'Tecnologia'},
    {'icon': Icons.comment_outlined, 'text': 'Comentários'},
  ];

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Reset do provider
  void reset() {
    _selectedTabIndex = 0;
    notifyListeners();
  }
}