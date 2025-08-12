// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/17_peso_model.dart';

/// Controller para sincronização de pesos usando SyncFirebaseService
class PesosSyncController extends GetxController {
  late final SyncFirebaseService<PesoAnimal> _syncService;
  
  // Estado reativo
  final RxList<PesoAnimal> pesos = <PesoAnimal>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<PesoAnimal>>? _dataSubscription;
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
      _syncService = SyncFirebaseService.getInstance<PesoAnimal>(
        'pesos',
        PesoAnimal.fromMap,
        (peso) => peso.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de pesos', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        pesos.value = data;
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
  
  /// Criar novo registro de peso
  Future<String?> createPeso(PesoAnimal peso) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(peso);
      
      Get.snackbar(
        'Sucesso',
        'Peso de ${peso.peso}kg registrado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar registro de peso', e);
      return null;
    }
  }
  
  /// Atualizar registro de peso existente
  Future<bool> updatePeso(String id, PesoAnimal peso) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, peso);
      
      Get.snackbar(
        'Sucesso',
        'Registro de peso atualizado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar peso', e);
      return false;
    }
  }
  
  /// Deletar registro de peso
  Future<bool> deletePeso(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        'Registro de peso removido',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar peso', e);
      return false;
    }
  }
  
  /// Buscar peso por ID
  Future<PesoAnimal?> getPesoById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar peso', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshPesos() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar pesos', e);
    }
  }
  
  // Métodos específicos para controle de peso
  
  /// Obter registros de peso por animal
  List<PesoAnimal> getPesosByAnimal(String animalId) {
    return pesos.where((peso) => 
      peso.animalId == animalId
    ).toList()..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
  }
  
  /// Obter histórico de peso ordenado por data (mais recente primeiro)
  List<PesoAnimal> getHistoricoPeso(String animalId) {
    return getPesosByAnimal(animalId)
      ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
  }
  
  /// Obter peso atual (mais recente) de um animal
  PesoAnimal? getPesoAtual(String animalId) {
    final pesosAnimal = getPesosByAnimal(animalId);
    if (pesosAnimal.isEmpty) return null;
    
    return pesosAnimal.reduce((a, b) => 
      a.dataPesagem > b.dataPesagem ? a : b);
  }
  
  /// Obter variação de peso entre duas datas
  double? getVariacaoPeso(String animalId, int dataInicio, int dataFim) {
    final pesosAnimal = getPesosByAnimal(animalId);
    
    final pesoInicio = pesosAnimal
        .where((p) => p.dataPesagem >= dataInicio)
        .fold<PesoAnimal?>(null, (prev, curr) => 
          prev == null || curr.dataPesagem < prev.dataPesagem ? curr : prev);
    
    final pesoFim = pesosAnimal
        .where((p) => p.dataPesagem <= dataFim)
        .fold<PesoAnimal?>(null, (prev, curr) => 
          prev == null || curr.dataPesagem > prev.dataPesagem ? curr : prev);
    
    if (pesoInicio == null || pesoFim == null) return null;
    
    return pesoFim.peso - pesoInicio.peso;
  }
  
  /// Obter registros de peso por período
  List<PesoAnimal> getPesosByPeriodo(int dataInicio, int dataFim) {
    return pesos.where((peso) => 
      peso.dataPesagem >= dataInicio && peso.dataPesagem <= dataFim
    ).toList()..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
  }
  
  /// Calcular tendência de peso (ganhando, perdendo, estável)
  String getTendenciaPeso(String animalId) {
    final pesosAnimal = getHistoricoPeso(animalId);
    
    if (pesosAnimal.length < 2) return 'Dados insuficientes';
    
    final pesoAtual = pesosAnimal[0].peso;
    final pesoAnterior = pesosAnimal[1].peso;
    
    final diferenca = pesoAtual - pesoAnterior;
    
    if (diferenca > 0.1) return 'Ganhando peso';
    if (diferenca < -0.1) return 'Perdendo peso';
    return 'Peso estável';
  }
  
  /// Obter dados para gráfico de evolução de peso
  List<Map<String, dynamic>> getDadosGrafico(String animalId) {
    final pesosAnimal = getPesosByAnimal(animalId);
    
    return pesosAnimal.map((peso) => {
      'data': DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem),
      'peso': peso.peso,
      'observacoes': peso.observacoes,
    }).toList();
  }
  
  /// Obter estatísticas de peso por animal
  Map<String, dynamic> getEstatisticasPeso(String animalId) {
    final pesosAnimal = getPesosByAnimal(animalId);
    
    if (pesosAnimal.isEmpty) {
      return {
        'totalRegistros': 0,
        'pesoMinimo': 0.0,
        'pesoMaximo': 0.0,
        'pesoMedio': 0.0,
        'pesoAtual': 0.0,
      };
    }
    
    final pesos = pesosAnimal.map((p) => p.peso).toList();
    
    return {
      'totalRegistros': pesosAnimal.length,
      'pesoMinimo': pesos.reduce((a, b) => a < b ? a : b),
      'pesoMaximo': pesos.reduce((a, b) => a > b ? a : b),
      'pesoMedio': pesos.reduce((a, b) => a + b) / pesos.length,
      'pesoAtual': getPesoAtual(animalId)?.peso ?? 0.0,
      'tendencia': getTendenciaPeso(animalId),
    };
  }
  
  /// Verificar se tem registros de peso cadastrados
  bool get hasPesos => pesos.isNotEmpty;
  
  /// Obter total de registros de peso
  int get totalPesos => pesos.length;
  
  /// Formatar data para exibição
  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
  
  /// Formatar peso para exibição
  String formatPeso(double peso) {
    return '${peso.toStringAsFixed(2)} kg';
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
