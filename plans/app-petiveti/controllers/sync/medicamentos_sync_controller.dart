// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/15_medicamento_model.dart';

/// Controller para sincronização de medicamentos usando SyncFirebaseService
class MedicamentosSyncController extends GetxController {
  late final SyncFirebaseService<MedicamentoVet> _syncService;
  
  // Estado reativo
  final RxList<MedicamentoVet> medicamentos = <MedicamentoVet>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<MedicamentoVet>>? _dataSubscription;
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
      _syncService = SyncFirebaseService.getInstance<MedicamentoVet>(
        'medicamentos',
        MedicamentoVet.fromMap,
        (medicamento) => medicamento.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de medicamentos', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        medicamentos.value = data;
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
  
  /// Criar novo medicamento
  Future<String?> createMedicamento(MedicamentoVet medicamento) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(medicamento);
      
      Get.snackbar(
        'Sucesso',
        'Medicamento ${medicamento.nomeMedicamento} registrado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar medicamento', e);
      return null;
    }
  }
  
  /// Atualizar medicamento existente
  Future<bool> updateMedicamento(String id, MedicamentoVet medicamento) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, medicamento);
      
      Get.snackbar(
        'Sucesso',
        'Medicamento atualizado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar medicamento', e);
      return false;
    }
  }
  
  /// Deletar medicamento
  Future<bool> deleteMedicamento(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        'Medicamento removido',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar medicamento', e);
      return false;
    }
  }
  
  /// Buscar medicamento por ID
  Future<MedicamentoVet?> getMedicamentoById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar medicamento', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshMedicamentos() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar medicamentos', e);
    }
  }
  
  // Métodos específicos para medicamentos
  
  /// Obter medicamentos por animal
  List<MedicamentoVet> getMedicamentosByAnimal(String animalId) {
    return medicamentos.where((medicamento) => 
      medicamento.animalId == animalId
    ).toList();
  }
  
  /// Obter medicamentos ativos (em tratamento)
  List<MedicamentoVet> getMedicamentosAtivos() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    
    return medicamentos.where((medicamento) => 
      medicamento.inicioTratamento <= agora && 
      (medicamento.fimTratamento >= agora)
    ).toList();
  }
  
  /// Obter medicamentos finalizados
  List<MedicamentoVet> getMedicamentosFinalizados() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    
    return medicamentos.where((medicamento) => 
      medicamento.fimTratamento < agora
    ).toList();
  }
  
  /// Obter medicamentos por nome
  List<MedicamentoVet> getMedicamentosByNome(String nome) {
    return medicamentos.where((medicamento) => 
      medicamento.nomeMedicamento.toLowerCase().contains(nome.toLowerCase())
    ).toList();
  }
  
  /// Obter medicamentos por período
  List<MedicamentoVet> getMedicamentosByPeriodo(int dataInicio, int dataFim) {
    return medicamentos.where((medicamento) => 
      medicamento.inicioTratamento >= dataInicio && 
      medicamento.inicioTratamento <= dataFim
    ).toList();
  }
  
  /// Obter próximas aplicações (próximas 24 horas)
  List<Map<String, dynamic>> getProximasAplicacoes() {
    final agora = DateTime.now();
    final proximasHoras = agora.add(const Duration(hours: 24));
    final aplicacoes = <Map<String, dynamic>>[];
    
    for (final medicamento in getMedicamentosAtivos()) {
      // Calcular próxima aplicação baseada na frequência
      final proximaAplicacao = _calcularProximaAplicacao(medicamento, agora);
      
      if (proximaAplicacao != null && 
          proximaAplicacao.isBefore(proximasHoras)) {
        aplicacoes.add({
          'medicamento': medicamento,
          'proximaAplicacao': proximaAplicacao,
        });
      }
    }
    
    // Ordenar por proximidade
    aplicacoes.sort((a, b) => 
      (a['proximaAplicacao'] as DateTime).compareTo(b['proximaAplicacao']));
    
    return aplicacoes;
  }
  
  /// Calcular próxima aplicação baseada na frequência
  DateTime? _calcularProximaAplicacao(MedicamentoVet medicamento, DateTime agora) {
    if (medicamento.frequencia.isEmpty) return null;
    
    // Parse da frequência (ex: "8 em 8 horas", "2x ao dia", etc.)
    final frequenciaLower = medicamento.frequencia.toLowerCase();
    
    if (frequenciaLower.contains('hora')) {
      final match = RegExp(r'(\d+)').firstMatch(frequenciaLower);
      if (match != null) {
        final horas = int.parse(match.group(1)!);
        return agora.add(Duration(hours: horas));
      }
    } else if (frequenciaLower.contains('dia')) {
      if (frequenciaLower.contains('2x')) {
        return agora.add(const Duration(hours: 12));
      } else if (frequenciaLower.contains('3x')) {
        return agora.add(const Duration(hours: 8));
      } else {
        return agora.add(const Duration(days: 1));
      }
    }
    
    return null;
  }
  
  /// Verificar se tem medicamentos cadastrados
  bool get hasMedicamentos => medicamentos.isNotEmpty;
  
  /// Obter total de medicamentos
  int get totalMedicamentos => medicamentos.length;
  
  /// Obter total de medicamentos ativos
  int get totalAtivos => getMedicamentosAtivos().length;
  
  /// Formatar data para exibição
  String formatDate(int timestamp) {
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
