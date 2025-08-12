// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/12_consulta_model.dart';

/// Controller para sincronização de consultas usando SyncFirebaseService
class ConsultasSyncController extends GetxController {
  late final SyncFirebaseService<Consulta> _syncService;
  
  // Estado reativo
  final RxList<Consulta> consultas = <Consulta>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<Consulta>>? _dataSubscription;
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
      _syncService = SyncFirebaseService.getInstance<Consulta>(
        'consultas',
        Consulta.fromMap,
        (consulta) => consulta.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de consultas', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        consultas.value = data;
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
  
  /// Criar nova consulta
  Future<String?> createConsulta(Consulta consulta) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(consulta);
      
      Get.snackbar(
        'Sucesso',
        'Consulta agendada para ${_formatDate(consulta.dataConsulta)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar consulta', e);
      return null;
    }
  }
  
  /// Atualizar consulta existente
  Future<bool> updateConsulta(String id, Consulta consulta) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, consulta);
      
      Get.snackbar(
        'Sucesso',
        'Consulta atualizada',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar consulta', e);
      return false;
    }
  }
  
  /// Deletar consulta
  Future<bool> deleteConsulta(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        'Consulta removida',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar consulta', e);
      return false;
    }
  }
  
  /// Buscar consulta por ID
  Future<Consulta?> getConsultaById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar consulta', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshConsultas() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar consultas', e);
    }
  }
  
  // Métodos específicos para consultas
  
  /// Obter consultas por animal
  List<Consulta> getConsultasByAnimal(String animalId) {
    return consultas.where((consulta) => 
      consulta.animalId == animalId
    ).toList();
  }
  
  /// Obter consultas por período
  List<Consulta> getConsultasByPeriodo(int dataInicio, int dataFim) {
    return consultas.where((consulta) => 
      consulta.dataConsulta >= dataInicio && consulta.dataConsulta <= dataFim
    ).toList();
  }
  
  /// Obter próximas consultas (próximos 7 dias)
  List<Consulta> getProximasConsultas() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    final proximosDias = agora + (7 * 24 * 60 * 60 * 1000); // 7 dias
    
    return consultas.where((consulta) => 
      consulta.dataConsulta >= agora && consulta.dataConsulta <= proximosDias
    ).toList()..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));
  }
  
  /// Calcular total gasto em consultas
  double getTotalGasto() {
    return consultas.fold(0.0, (total, consulta) => total + consulta.valor);
  }
  
  /// Verificar se tem consultas cadastradas
  bool get hasConsultas => consultas.isNotEmpty;
  
  /// Obter total de consultas
  int get totalConsultas => consultas.length;
  
  /// Formatar data para exibição
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
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
