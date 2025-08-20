// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/bovino_class.dart';
import '../services/state_management/agrihurbi_service_locator.dart';
import '../services/state_management/agrihurbi_state_manager.dart';
import '../services/state_management/unified_data_service.dart';

/// Controller aprimorado que usa o novo sistema de gerenciamento de estado centralizado
/// 
/// Este controller demonstra como usar os novos services para eliminar duplicação
/// de estado e garantir consistência entre controllers.
class EnhancedBovinosController extends GetxController {
  
  // ========== DEPENDENCIES ==========
  
  late final AgrihurbiServiceLocator _serviceLocator;
  late final UnifiedDataService _dataService;
  late final AgrihurbiStateManager _stateManager;

  // ========== ESTADO LOCAL (APENAS UI) ==========
  
  /// Estado de carregamento específico desta tela
  final RxBool isPageLoading = false.obs;
  
  /// Bovino selecionado para edição/visualização
  final Rx<BovinoClass?> selectedBovino = Rx<BovinoClass?>(null);
  
  /// Modo de exibição (lista, edição, etc.)
  final RxString viewMode = 'list'.obs;
  
  /// Filtros de busca locais
  final RxString searchFilter = ''.obs;
  final RxString categoryFilter = ''.obs;

  // ========== COMPUTED PROPERTIES ==========
  
  /// Lista de bovinos do service centralizado
  List<BovinoClass> get bovinos => _dataService.bovinos;
  
  /// Lista filtrada de bovinos
  List<BovinoClass> get filteredBovinos {
    var filtered = bovinos;
    
    // Aplicar filtro de busca
    if (searchFilter.value.isNotEmpty) {
      filtered = filtered.where((bovino) =>
        bovino.nomeComum.toLowerCase().contains(searchFilter.value.toLowerCase())).toList();
    }
    
    // Aplicar filtro de categoria
    if (categoryFilter.value.isNotEmpty) {
      filtered = filtered.where((bovino) =>
        bovino.raca.toLowerCase() == categoryFilter.value.toLowerCase()).toList();
    }
    
    return filtered;
  }
  
  /// Estado de carregamento global ou local
  bool get isLoading => _dataService.isLoadingBovinos.value || isPageLoading.value;
  
  /// Verifica se há bovinos carregados
  bool get hasBovinos => bovinos.isNotEmpty;
  
  /// Contagem de bovinos filtrados
  int get filteredCount => filteredBovinos.length;

  // ========== INICIALIZAÇÃO ==========
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('🐄 EnhancedBovinosController: Inicializando controller aprimorado');
    _setupDependencies();
    _setupReactiveListeners();
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  /// Configura dependências do service locator
  void _setupDependencies() {
    _serviceLocator = AgrihurbiServiceLocator.instance;
    _dataService = _serviceLocator.dataService;
    _stateManager = _serviceLocator.stateManager;
  }

  /// Configura listeners reativos
  void _setupReactiveListeners() {
    // Listener para mudanças nos dados centralizados
    ever(_dataService.bovinos, (List<BovinoClass> bovinos) {
      debugPrint('🔄 EnhancedBovinosController: Lista de bovinos atualizada (${bovinos.length} itens)');
      
      // Se bovino selecionado foi removido, limpar seleção
      if (selectedBovino.value != null) {
        final exists = bovinos.any((b) => b.id == selectedBovino.value!.id);
        if (!exists) {
          selectedBovino.value = null;
          debugPrint('🧹 EnhancedBovinosController: Bovino selecionado foi removido');
        }
      }
    });

    // Listener para mudanças no estado de carregamento
    ever(_dataService.isLoadingBovinos, (bool loading) {
      debugPrint('🔄 EnhancedBovinosController: Estado de carregamento: $loading');
    });

    // Listener para eventos de estado global
    _stateManager.stateStream.listen((event) {
      switch (event.type) {
        case StateEventType.dataRefreshCompleted:
          if (event.data == 'all' || event.data == 'bovinos') {
            debugPrint('✅ EnhancedBovinosController: Dados atualizados via evento global');
          }
          break;
        default:
          break;
      }
    });
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    await refreshData();
  }

  // ========== MÉTODOS PÚBLICOS - CRUD ==========

  /// Atualiza lista de bovinos
  Future<void> refreshData() async {
    await _serviceLocator.executeOperation(
      () => _dataService.refreshBovinos(),
      operationName: 'refreshBovinos',
      customErrorMessage: 'Erro ao carregar lista de bovinos',
    );
  }

  /// Adiciona novo bovino
  Future<bool> addBovino(BovinoClass bovino) async {
    // Validar operação
    if (!await _serviceLocator.validateOperation(
      requiresNetwork: true,
      operationName: 'addBovino',
    )) {
      return false;
    }

    try {
      await _serviceLocator.executeOperation(
        () => _dataService.addBovino(bovino),
        operationName: 'addBovino',
        customErrorMessage: 'Erro ao adicionar bovino ${bovino.nomeComum}',
      );
      
      debugPrint('✅ EnhancedBovinosController: Bovino ${bovino.nomeComum} adicionado com sucesso');
      // Não precisamos atualizar a lista manualmente - o service centralizado já faz isso
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza bovino existente
  Future<bool> updateBovino(BovinoClass bovino) async {
    if (!await _serviceLocator.validateOperation(
      requiresNetwork: true,
      operationName: 'updateBovino',
    )) {
      return false;
    }

    try {
      await _serviceLocator.executeOperation(
        () => _dataService.updateBovino(bovino),
        operationName: 'updateBovino',
        customErrorMessage: 'Erro ao atualizar bovino ${bovino.nomeComum}',
      );
      
      debugPrint('✅ EnhancedBovinosController: Bovino ${bovino.nomeComum} atualizado com sucesso');
      
      // Atualizar bovino selecionado se for o mesmo
      if (selectedBovino.value?.id == bovino.id) {
        selectedBovino.value = bovino;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove bovino
  Future<bool> deleteBovino(String bovinoId) async {
    if (!await _serviceLocator.validateOperation(
      requiresNetwork: true,
      operationName: 'deleteBovino',
    )) {
      return false;
    }

    // Encontrar bovino para mensagem de confirmação
    final bovino = bovinos.firstWhereOrNull((b) => b.id == bovinoId);
    final bovinoName = bovino?.nomeComum ?? 'bovino';

    try {
      await _serviceLocator.executeOperation(
        () => _dataService.deleteBovino(bovinoId),
        operationName: 'deleteBovino',
        customErrorMessage: 'Erro ao remover $bovinoName',
      );
      
      debugPrint('✅ EnhancedBovinosController: Bovino $bovinoName removido com sucesso');
      
      // Limpar seleção se bovino removido era o selecionado
      if (selectedBovino.value?.id == bovinoId) {
        selectedBovino.value = null;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== MÉTODOS PÚBLICOS - UI ACTIONS ==========

  /// Seleciona bovino para edição/visualização
  void selectBovino(BovinoClass? bovino) {
    selectedBovino.value = bovino;
    debugPrint('🎯 EnhancedBovinosController: Bovino selecionado: ${bovino?.nomeComum ?? 'nenhum'}');
  }

  /// Altera modo de visualização
  void setViewMode(String mode) {
    viewMode.value = mode;
    debugPrint('👁️ EnhancedBovinosController: Modo de visualização: $mode');
  }

  /// Aplica filtro de busca
  void setSearchFilter(String filter) {
    searchFilter.value = filter;
    debugPrint('🔍 EnhancedBovinosController: Filtro de busca: "$filter"');
  }

  /// Aplica filtro de categoria
  void setCategoryFilter(String category) {
    categoryFilter.value = category;
    debugPrint('🏷️ EnhancedBovinosController: Filtro de categoria: "$category"');
  }

  /// Limpa todos os filtros
  void clearFilters() {
    searchFilter.value = '';
    categoryFilter.value = '';
    debugPrint('🧹 EnhancedBovinosController: Filtros limpos');
  }

  // ========== MÉTODOS PÚBLICOS - BATCH OPERATIONS ==========

  /// Remove múltiplos bovinos
  Future<bool> deleteBovinos(List<String> bovinoIds) async {
    if (bovinoIds.isEmpty) return true;

    if (!await _serviceLocator.validateOperation(
      requiresNetwork: true,
      operationName: 'deleteBovinos',
    )) {
      return false;
    }

    bool allSuccessful = true;
    int successCount = 0;

    for (final id in bovinoIds) {
      final success = await deleteBovino(id);
      if (success) {
        successCount++;
      } else {
        allSuccessful = false;
      }
    }

    debugPrint('📊 EnhancedBovinosController: Remoção em lote: $successCount/${bovinoIds.length} bem-sucedidas');
    return allSuccessful;
  }

  /// Sincroniza com outros controllers
  Future<void> syncWithOtherControllers() async {
    debugPrint('🔄 EnhancedBovinosController: Sincronizando com outros controllers...');
    
    // Com o sistema centralizado, não precisamos fazer sincronização manual
    // Todos os controllers usam o mesmo UnifiedDataService
    
    debugPrint('✅ EnhancedBovinosController: Sincronização automática via service centralizado');
  }

  // ========== INFORMAÇÕES DE DEBUG ==========

  /// Obtém informações de debug do controller
  Map<String, dynamic> getDebugInfo() {
    return {
      'controllerName': 'EnhancedBovinosController',
      'isPageLoading': isPageLoading.value,
      'viewMode': viewMode.value,
      'searchFilter': searchFilter.value,
      'categoryFilter': categoryFilter.value,
      'selectedBovinoId': selectedBovino.value?.id,
      'totalBovinos': bovinos.length,
      'filteredBovinos': filteredCount,
      'isLoading': isLoading,
      'hasBovinos': hasBovinos,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Imprime informações de debug
  void printDebugInfo() {
    final info = getDebugInfo();
    debugPrint('🔍 EnhancedBovinosController Debug Info:');
    info.forEach((key, value) {
      debugPrint('   $key: $value');
    });
  }

  // ========== CLEANUP ==========

  @override
  void onClose() {
    debugPrint('🔚 EnhancedBovinosController: Finalizando controller');
    
    // Com o service centralizado, não precisamos fazer cleanup manual dos dados
    // Os dados permanecem disponíveis para outros controllers
    
    super.onClose();
  }
}
