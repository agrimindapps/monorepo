// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/14_lembrete_model.dart';

/// Controller para sincronização de lembretes usando SyncFirebaseService
class LembretesSyncController extends GetxController {
  late final SyncFirebaseService<LembreteVet> _syncService;
  
  // Estado reativo
  final RxList<LembreteVet> lembretes = <LembreteVet>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<LembreteVet>>? _dataSubscription;
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
      _syncService = SyncFirebaseService.getInstance<LembreteVet>(
        'lembretes',
        LembreteVet.fromMap,
        (lembrete) => lembrete.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de lembretes', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        lembretes.value = data;
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
  
  /// Criar novo lembrete
  Future<String?> createLembrete(LembreteVet lembrete) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(lembrete);
      
      Get.snackbar(
        'Sucesso',
        'Lembrete "${lembrete.titulo}" criado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar lembrete', e);
      return null;
    }
  }
  
  /// Atualizar lembrete existente
  Future<bool> updateLembrete(String id, LembreteVet lembrete) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, lembrete);
      
      Get.snackbar(
        'Sucesso',
        'Lembrete atualizado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar lembrete', e);
      return false;
    }
  }
  
  /// Marcar lembrete como concluído
  Future<bool> marcarConcluido(String id, bool concluido) async {
    try {
      final lembrete = lembretes.firstWhereOrNull((l) => l.id == id);
      if (lembrete == null) return false;
      
      final lembreteAtualizado = lembrete.copyWith(concluido: concluido);
      return await updateLembrete(id, lembreteAtualizado);
    } catch (e) {
      _handleError('Erro ao marcar lembrete', e);
      return false;
    }
  }
  
  /// Deletar lembrete
  Future<bool> deleteLembrete(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        'Lembrete removido',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar lembrete', e);
      return false;
    }
  }
  
  /// Buscar lembrete por ID
  Future<LembreteVet?> getLembreteById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar lembrete', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshLembretes() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar lembretes', e);
    }
  }
  
  // Métodos específicos para lembretes
  
  /// Obter lembretes por animal
  List<LembreteVet> getLembretesByAnimal(String animalId) {
    return lembretes.where((lembrete) => 
      lembrete.animalId == animalId
    ).toList();
  }
  
  /// Obter lembretes por tipo
  List<LembreteVet> getLembretesByTipo(String tipo) {
    return lembretes.where((lembrete) => 
      lembrete.tipo.toLowerCase() == tipo.toLowerCase()
    ).toList();
  }
  
  /// Obter lembretes pendentes
  List<LembreteVet> getLembretesPendentes() {
    return lembretes.where((lembrete) => 
      !lembrete.concluido
    ).toList()..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }
  
  /// Obter lembretes concluídos
  List<LembreteVet> getLembretesConcluidos() {
    return lembretes.where((lembrete) => 
      lembrete.concluido
    ).toList();
  }
  
  /// Obter próximos lembretes (próximas 24 horas)
  List<LembreteVet> getProximosLembretes() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    final proximasHoras = agora + (24 * 60 * 60 * 1000); // 24 horas
    
    return lembretes.where((lembrete) => 
      !lembrete.concluido &&
      lembrete.dataHora >= agora && 
      lembrete.dataHora <= proximasHoras
    ).toList()..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }
  
  /// Obter lembretes atrasados
  List<LembreteVet> getLembretesAtrasados() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    
    return lembretes.where((lembrete) => 
      !lembrete.concluido && lembrete.dataHora < agora
    ).toList()..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }
  
  /// Obter lembretes de hoje
  List<LembreteVet> getLembretesDeHoje() {
    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day).millisecondsSinceEpoch;
    final fimHoje = DateTime(agora.year, agora.month, agora.day, 23, 59, 59).millisecondsSinceEpoch;
    
    return lembretes.where((lembrete) => 
      lembrete.dataHora >= inicioHoje && lembrete.dataHora <= fimHoje
    ).toList()..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }
  
  /// Verificar se tem lembretes cadastrados
  bool get hasLembretes => lembretes.isNotEmpty;
  
  /// Obter total de lembretes
  int get totalLembretes => lembretes.length;
  
  /// Obter total de lembretes pendentes
  int get totalPendentes => getLembretesPendentes().length;
  
  /// Obter total de lembretes atrasados
  int get totalAtrasados => getLembretesAtrasados().length;
  
  /// Formatar data e hora para exibição
  String formatDateTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
