// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../const/bottom_navigator_const.dart';

/// Controlador global para gerenciar o estado do BottomNavigator
/// Mantém o índice ativo mesmo quando navegando entre páginas
class BottomNavigatorController extends GetxController {
  static BottomNavigatorController get instance => Get.find();

  // Índice do item atualmente selecionado
  final RxInt _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  @override
  void onInit() {
    super.onInit();
    // Inicializa com o primeiro item (Defensivos)
    _selectedIndex.value = 0;
  }

  /// Define o índice ativo baseado na rota atual
  void setActiveIndexByRoute(String route) {
    final index = _getIndexByRoute(route);
    if (index != -1) {
      _selectedIndex.value = index;
    }
  }

  /// Define o índice ativo diretamente
  void setActiveIndex(int index) {
    if (index >= 0 && index < itensMenuBottom.length) {
      _selectedIndex.value = index;
    }
  }

  /// Obtém o índice baseado na rota
  int _getIndexByRoute(String route) {
    for (int i = 0; i < itensMenuBottom.length; i++) {
      if (itensMenuBottom[i]['page'] == route) {
        return i;
      }
    }

    // Se não encontrou rota exata, tenta encontrar por categoria
    return _getIndexByCategory(route);
  }

  /// Determina o índice baseado na categoria da página atual
  int _getIndexByCategory(String route) {
    // Páginas relacionadas a defensivos
    if (route.contains('defensivos') || route.contains('lista_defensivos')) {
      return 0; // Defensivos
    }

    // Páginas relacionadas a pragas
    if (route.contains('pragas') ||
        route.contains('lista_pragas') ||
        route.contains('culturas')) {
      return 1; // Pragas
    }

    // Páginas relacionadas a favoritos
    if (route.contains('favoritos')) {
      return 2; // Favoritos
    }

    // Páginas relacionadas a comentários
    if (route.contains('comentarios')) {
      return 3; // Comentários
    }

    // Páginas relacionadas a configurações
    if (route.contains('config') || route.contains('configuracao')) {
      return 4; // Outros
    }

    // Retorna -1 se não conseguir determinar
    return -1;
  }

  /// Navega para o item selecionado
  void navigateToIndex(int index) {
    if (index >= 0 && index < itensMenuBottom.length) {
      _selectedIndex.value = index;
      final route = itensMenuBottom[index]['page'];
      Get.offAllNamed(route);
    }
  }

  /// Verifica se uma página específica deve mostrar o BottomNavigator ativo
  bool shouldShowActiveState(String currentRoute) {
    return _getIndexByRoute(currentRoute) == selectedIndex;
  }

  /// Atualiza o estado baseado na rota atual do GetX
  void updateFromCurrentRoute() {
    final currentRoute = Get.currentRoute;
    setActiveIndexByRoute(currentRoute);
  }
  
  @override
  void onClose() {
    // Limpar recursos para evitar memory leaks
    super.onClose();
  }
}
