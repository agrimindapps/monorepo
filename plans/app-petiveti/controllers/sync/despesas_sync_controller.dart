// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/13_despesa_model.dart';

/// Controller para sincronização de despesas usando SyncFirebaseService
class DespesasSyncController extends GetxController {
  late final SyncFirebaseService<DespesaVet> _syncService;
  
  // Estado reativo
  final RxList<DespesaVet> despesas = <DespesaVet>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<DespesaVet>>? _dataSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSync();
  }
  
  /// Inicializar sincronização com SyncFirebaseService
  Future<void> _initializeSync() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Obter instância singleton do serviço
      _syncService = SyncFirebaseService.getInstance<DespesaVet>(
        'despesas',
        DespesaVet.fromMap,
        (despesa) => despesa.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de despesas', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        despesas.value = data;
        isLoading.value = false;
        hasError.value = false;
      },
      onError: (error) => _handleError('Erro no stream de dados', error),
    );
    
    // Stream de conectividade
    _connectivitySubscription = _syncService.connectivityStream.listen(
      (online) => isOnline.value = online,
    );
    
    // Stream de status de sincronização
    _syncStatusSubscription = _syncService.syncStatusStream.listen(
      (status) => syncStatus.value = status,
    );
  }
  
  /// Gerenciar erros de forma centralizada
  void _handleError(String message, dynamic error) {
    isLoading.value = false;
    hasError.value = true;
    errorMessage.value = message;
    Get.snackbar(
      'Erro',
      '$message: $error',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Operações CRUD usando SyncFirebaseService
  
  /// Criar nova despesa
  Future<String?> createDespesa(DespesaVet despesa) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(despesa);
      
      Get.snackbar(
        'Sucesso',
        'Despesa de ${_formatCurrency(despesa.valor)} registrada',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar despesa', e);
      return null;
    }
  }
  
  /// Atualizar despesa existente
  Future<bool> updateDespesa(String id, DespesaVet despesa) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, despesa);
      
      Get.snackbar(
        'Sucesso',
        'Despesa atualizada',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar despesa', e);
      return false;
    }
  }
  
  /// Deletar despesa
  Future<bool> deleteDespesa(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        'Despesa removida',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar despesa', e);
      return false;
    }
  }
  
  /// Buscar despesa por ID
  Future<DespesaVet?> getDespesaById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar despesa', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshDespesas() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar despesas', e);
    }
  }
  
  // Métodos específicos para despesas
  
  /// Obter despesas por animal
  List<DespesaVet> getDespesasByAnimal(String animalId) {
    return despesas.where((despesa) => 
      despesa.animalId == animalId
    ).toList();
  }
  
  /// Obter despesas por tipo
  List<DespesaVet> getDespesasByTipo(String tipo) {
    return despesas.where((despesa) => 
      despesa.tipo.toLowerCase() == tipo.toLowerCase()
    ).toList();
  }
  
  /// Obter despesas por período
  List<DespesaVet> getDespesasByPeriodo(int dataInicio, int dataFim) {
    return despesas.where((despesa) => 
      despesa.dataDespesa >= dataInicio && despesa.dataDespesa <= dataFim
    ).toList();
  }
  
  /// Calcular total de despesas
  double getTotalDespesas() {
    return despesas.fold(0.0, (total, despesa) => total + despesa.valor);
  }
  
  /// Calcular total de despesas por período
  double getTotalDespesasPeriodo(int dataInicio, int dataFim) {
    final despesasPeriodo = getDespesasByPeriodo(dataInicio, dataFim);
    return despesasPeriodo.fold(0.0, (total, despesa) => total + despesa.valor);
  }
  
  /// Obter relatório de despesas por tipo
  Map<String, double> getRelatorioTipos() {
    final relatorio = <String, double>{};
    
    for (final despesa in despesas) {
      relatorio[despesa.tipo] = (relatorio[despesa.tipo] ?? 0.0) + despesa.valor;
    }
    
    return relatorio;
  }
  
  /// Obter despesas do mês atual
  List<DespesaVet> getDespesasDoMes() {
    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1).millisecondsSinceEpoch;
    final fimMes = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;
    
    return getDespesasByPeriodo(inicioMes, fimMes);
  }
  
  /// Verificar se tem despesas cadastradas
  bool get hasDespesas => despesas.isNotEmpty;
  
  /// Obter total de despesas
  int get totalDespesas => despesas.length;
  
  /// Formatar valor monetário
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
  
  /// Obter informações de debug do serviço
  Map<String, dynamic> getDebugInfo() {
    return _syncService.getDebugInfo();
  }
  
  /// Verificar se pode sincronizar
  bool get canSync => _syncService.canSync;
  
  @override
  void onClose() {
    // Cancelar subscriptions para evitar memory leaks
    _dataSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusSubscription?.cancel();
    super.onClose();
  }
}
