// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_model.dart';
import '../../../services/domain/plants/plant_limit_service.dart';
import '../interfaces/plantas_controller_interface.dart';
import '../services/plantas_navigation_service.dart';
import '../services/plantas_state_service.dart';
import '../services/plantas_ui_service.dart';

/// Controller específico para MinhasPlantasPage usando composição
/// ao invés de herança problemática do PlantasController
/// Implementa IPlantasController para compatibilidade com widgets existentes
class MinhasPlantasController extends GetxController
    implements IPlantasController {
  // ========== SERVICES (COMPOSIÇÃO) ==========

  /// Serviço de estado centralizado
  PlantasStateService get _stateService => PlantasStateService.instance;

  /// Serviço de navegação especializado
  final _navigationService = PlantasNavigationService();

  /// Serviço de UI e feedback
  final _uiService = PlantasUIService();

  // ========== CONTROLLER STATE ==========

  /// Controlador de busca
  final searchController = TextEditingController();

  /// Modo de visualização: 'list' ou 'grid'
  final viewMode = 'list'.obs;

  // ========== GETTERS REATIVOS ==========

  /// Lista completa de plantas (delegado para o serviço)
  @override
  Rx<List<PlantaModel>> get plantas => _stateService.plantas;

  /// Lista filtrada de plantas (delegado para o serviço)
  @override
  Rx<List<PlantaModel>> get plantasComTarefas =>
      _stateService.plantasWithFilter;

  /// Lista de espaços (delegado para o serviço)
  @override
  Rx<List<EspacoModel>> get espacos => _stateService.espacos;

  /// Estado de loading (delegado para o serviço)
  @override
  RxBool get isLoading => _stateService.isLoading;

  /// Texto de busca atual (delegado para o serviço)
  @override
  RxString get searchText => _stateService.searchFilter;

  // ========== LIFECYCLE ==========

  @override
  void onInit() {
    super.onInit();
    _ensureStateServiceInitialized();
    _setupSearchListener();
    _loadInitialData();
    debugPrint('🔄 MinhasPlantasController: Inicializado com composição');
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('🔄 MinhasPlantasController: onReady - controller pronto');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ========== INITIALIZATION METHODS ==========

  /// Garante que o serviço de estado está inicializado
  void _ensureStateServiceInitialized() {
    if (!Get.isRegistered<PlantasStateService>()) {
      Get.put(PlantasStateService(), permanent: true);
    }
  }

  /// Configura listener para busca em tempo real
  void _setupSearchListener() {
    searchController.addListener(() {
      _stateService.setSearchFilter(searchController.text);
    });
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    try {
      await _stateService.loadData();
    } catch (e) {
      _uiService.showError('Erro ao carregar dados: $e');
    }
  }

  // ========== VIEW MODE METHODS ==========

  /// Alterna entre modo lista e grade
  void toggleViewMode() {
    viewMode.value = viewMode.value == 'list' ? 'grid' : 'list';
    debugPrint(
        '🔄 MinhasPlantasController: View mode alterado para ${viewMode.value}');
  }

  // ========== DATA MANAGEMENT METHODS ==========

  /// Força recarregamento completo dos dados
  @override
  Future<void> forcarRecarregamento() async {
    try {
      debugPrint(
          '🔄 MinhasPlantasController: Forçando recarregamento completo');
      await _stateService.forceReload();
    } catch (e) {
      _uiService.showError('Erro ao recarregar dados: $e');
    }
  }

  /// Filtra plantas baseado no texto de busca
  @override
  void filtrarPlantas() {
    // Filtro agora é gerenciado automaticamente pelo serviço
    // quando searchText muda via listener
    debugPrint(
        '🔍 MinhasPlantasController: Filtro delegado para PlantasStateService');
  }

  /// Limpa o filtro de busca
  @override
  void limparBusca() {
    searchController.clear();
    _stateService.clearSearchFilter();
    debugPrint('🔍 MinhasPlantasController: Busca limpa');
  }

  // ========== NAVIGATION METHODS ==========

  /// Navega para adicionar nova planta
  Future<void> adicionarPlanta() async {
    // Verificar limite de plantas para usuários não premium
    final canAdd = await PlantLimitService.instance.canAddNewPlant();

    if (!canAdd) {
      // Mostrar dialog informando sobre o limite
      await _showPlantLimitDialog();
      return;
    }

    final result = await _navigationService.navigateToAddPlant();
    if (result == true) {
      await forcarRecarregamento();
      // Mensagem de sucesso já é exibida pelo PlantaFormController
    }
  }

  /// Navega para visualizar detalhes da planta
  void visualizarPlanta(PlantaModel planta) {
    _navigationService.navigateToPlantDetails(planta);
  }

  /// Navega para editar planta
  Future<void> editarPlanta(PlantaModel planta) async {
    final result = await _navigationService.navigateToEditPlant(planta);
    if (result == true) {
      await forcarRecarregamento();
      // Mensagem de sucesso já é exibida pelo PlantaFormController
    }
  }

  /// Confirma e executa remoção da planta
  Future<void> confirmarRemocaoPlanta(PlantaModel planta) async {
    final confirmed =
        await _uiService.showRemoveConfirmation(planta.nome ?? 'Planta');

    if (confirmed) {
      try {
        await _stateService.removePlanta(planta.id);
        _uiService.showSuccess('${planta.nome} foi removida com sucesso');
        debugPrint(
            '✅ MinhasPlantasController: Planta removida: ${planta.nome}');
      } catch (e) {
        _uiService.showError('Erro ao remover planta: $e');
        debugPrint('❌ MinhasPlantasController: Erro ao remover planta: $e');
      }
    }
  }

  // ========== UTILITY METHODS ==========

  /// Mostra dialog informando sobre o limite de plantas atingido
  Future<void> _showPlantLimitDialog() async {
    final limitInfo = await PlantLimitService.instance.getLimitInfo();

    await Get.dialog(
      AlertDialog(
        title: const Text('Limite de Plantas Atingido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Você já possui ${limitInfo.currentCount} plantas cadastradas.'),
            const SizedBox(height: 8.0),
            const Text('Usuários gratuitos podem ter até 3 plantas.'),
            const SizedBox(height: 16.0),
            const Text(
              'Para cadastrar plantas ilimitadas, assine o plano Premium!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendi'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Navegar para página de assinatura
              _uiService
                  .showInfo('Funcionalidade de assinatura em desenvolvimento');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20B2AA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Assinar Premium'),
          ),
        ],
      ),
    );
  }

  /// Obtém nome do espaço por ID
  @override
  String getNomeEspaco(String? espacoId) {
    if (espacoId == null || espacoId.isEmpty) return 'Sem espaço';
    final espaco = _stateService.getEspaco(espacoId);
    return espaco?.nome ?? 'Espaço não encontrado';
  }

  /// Obtém planta por ID
  @override
  PlantaModel? getPlanta(String plantaId) {
    return _stateService.getPlanta(plantaId);
  }

  /// Obtém tarefas pendentes para uma planta específica
  @override
  Future<List<Map<String, dynamic>>> getTarefasPendentes(
      String plantaId) async {
    return await _stateService.getTarefasPendentes(plantaId);
  }

  /// Obtém snapshot do estado atual para debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'viewMode': viewMode.value,
      'searchText': searchText.value,
      'stateInfo': _stateService.getStateSnapshot(),
    };
  }
}
