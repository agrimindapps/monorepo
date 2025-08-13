// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/planta_model.dart';
import '../../../navigation/plantas_navigator.dart';

/// Serviço especializado para navegação entre páginas do módulo de plantas
/// Encapsula toda a lógica de navegação para melhor testabilidade e organização
class PlantasNavigationService extends GetxService {
  static PlantasNavigationService get instance =>
      Get.find<PlantasNavigationService>();

  /// Navega para a página de adicionar nova planta
  ///
  /// Returns: `true` se uma planta foi adicionada, `false` ou `null` caso contrário
  Future<bool?> navigateToAddPlant() async {
    try {
      return await PlantasNavigator.toNovaPlanta();
    } catch (e) {
      Get.log(
          '❌ PlantasNavigationService: Erro ao navegar para nova planta: $e');
      return null;
    }
  }

  /// Navega para a página de detalhes da planta
  ///
  /// [planta] - A planta cujos detalhes serão exibidos
  Future<void> navigateToPlantDetails(PlantaModel planta) async {
    try {
      PlantasNavigator.toPlantaDetalhes(planta);
      Get.log(
          '📱 PlantasNavigationService: Navegando para detalhes de ${planta.nome}');
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao navegar para detalhes: $e');
    }
  }

  /// Navega para a página de edição da planta
  ///
  /// [planta] - A planta a ser editada
  /// Returns: `true` se a planta foi editada, `false` ou `null` caso contrário
  Future<bool?> navigateToEditPlant(PlantaModel planta) async {
    try {
      final result = await PlantasNavigator.toEditarPlanta(planta);
      Get.log(
          '📱 PlantasNavigationService: Editando ${planta.nome}, resultado: $result');
      return result;
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao navegar para edição: $e');
      return null;
    }
  }

  /// Navega para a página de espaços
  Future<void> navigateToSpaces() async {
    try {
      await PlantasNavigator.toEspacos();
      Get.log('📱 PlantasNavigationService: Navegando para espaços');
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao navegar para espaços: $e');
    }
  }

  /// Navega para a página de tarefas gerais
  Future<void> navigateToTasks() async {
    try {
      await PlantasNavigator.toTarefas();
      Get.log('📱 PlantasNavigationService: Navegando para tarefas');
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao navegar para tarefas: $e');
    }
  }

  /// Volta para a página anterior
  void goBack() {
    try {
      Get.back();
      Get.log('📱 PlantasNavigationService: Voltando para página anterior');
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao voltar: $e');
    }
  }

  /// Fecha todos os dialogs abertos
  void closeAllDialogs() {
    try {
      Get.until((route) => !Get.isDialogOpen!);
      Get.log('📱 PlantasNavigationService: Fechando todos os dialogs');
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao fechar dialogs: $e');
    }
  }

  /// Navega para a página inicial do módulo de plantas
  void navigateToHome() {
    try {
      Get.offAllNamed('/plantas');
      Get.log('📱 PlantasNavigationService: Navegando para home');
    } catch (e) {
      Get.log('❌ PlantasNavigationService: Erro ao navegar para home: $e');
    }
  }

  /// Verifica se pode navegar para trás
  bool canGoBack() {
    return Get.routing.previous.isNotEmpty;
  }

  /// Obtém informações da rota atual para debug
  String getCurrentRouteInfo() {
    return 'Current: ${Get.currentRoute}, Previous: ${Get.routing.previous}';
  }
}
