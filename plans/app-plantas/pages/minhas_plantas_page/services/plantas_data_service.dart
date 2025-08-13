// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/planta_model.dart';
import '../../../services/domain/plants/plant_care_service.dart';
import 'plantas_state_service.dart';

/// Serviço especializado para carregamento e sincronização de dados de plantas
/// Separado do controller para melhor organização de responsabilidades
class PlantasDataService extends GetxService {
  static PlantasDataService get instance => Get.find<PlantasDataService>();

  PlantasStateService get _stateService => PlantasStateService.instance;

  /// Inicializa o serviço
  Future<void> initialize() async {
    debugPrint('🔧 PlantasDataService: Inicializando...');
    await PlantCareService.instance.initialize();
    debugPrint('✅ PlantasDataService: Inicializado com sucesso');
  }

  /// Carrega todos os dados necessários
  Future<void> loadAllData() async {
    try {
      debugPrint('📊 PlantasDataService: Iniciando carregamento de dados');
      await _stateService.loadData();
      debugPrint('✅ PlantasDataService: Carregamento concluído');
    } catch (e) {
      debugPrint('❌ PlantasDataService: Erro ao carregar dados: $e');
      _showErrorSnackbar('Erro ao carregar dados', e.toString());
      rethrow;
    }
  }

  /// Força recarregamento completo dos dados
  Future<void> forceReload() async {
    try {
      debugPrint('🔄 PlantasDataService: Forçando recarregamento completo');
      await _stateService.forceReload();
      debugPrint('✅ PlantasDataService: Recarregamento concluído');
    } catch (e) {
      debugPrint('❌ PlantasDataService: Erro no recarregamento: $e');
      _showErrorSnackbar('Erro ao recarregar dados', e.toString());
      rethrow;
    }
  }

  /// Sincroniza dados com a fonte remota/local
  Future<void> syncData() async {
    try {
      debugPrint('🔄 PlantasDataService: Sincronizando dados');

      // Recarregar plantas
      await _loadPlantas();

      // Recarregar espaços
      await _loadEspacos();

      debugPrint('✅ PlantasDataService: Sincronização concluída');
    } catch (e) {
      debugPrint('❌ PlantasDataService: Erro na sincronização: $e');
      _showErrorSnackbar('Erro na sincronização', e.toString());
      rethrow;
    }
  }

  /// Remove uma planta do sistema
  Future<void> removePlanta(PlantaModel planta) async {
    try {
      debugPrint('🗑️ PlantasDataService: Removendo planta: ${planta.nome}');

      await PlantCareService.instance.initialize();
      await PlantCareService.instance.deletePlant(planta.id);

      // Atualizar estado centralizado
      await _stateService.removePlanta(planta.id);

      _showSuccessSnackbar('Planta "${planta.nome}" removida com sucesso!');
      debugPrint('✅ PlantasDataService: Planta removida: ${planta.nome}');
    } catch (e) {
      debugPrint('❌ PlantasDataService: Erro ao remover planta: $e');
      _showErrorSnackbar('Erro ao remover planta', e.toString());
      rethrow;
    }
  }

  /// Obtém nome do espaço por ID
  String getEspacoName(String? espacoId) {
    if (espacoId == null || espacoId.isEmpty) return 'Sem espaço';

    final espaco = _stateService.getEspaco(espacoId);
    return espaco?.nome ?? 'Espaço não encontrado';
  }

  /// Carrega plantas do serviço de cuidados
  Future<void> _loadPlantas() async {
    // PlantasStateService já tem a lógica de carregamento
    // Delegamos para o método loadData existente
    await _stateService.loadData(silent: true);
  }

  /// Carrega espaços do serviço de cuidados
  Future<void> _loadEspacos() async {
    // PlantasStateService já tem a lógica de carregamento
    // Delegamos para o método loadData existente
    await _stateService.loadData(silent: true);
  }

  /// Mostra snackbar de sucesso
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF20B2AA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Mostra snackbar de erro
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
