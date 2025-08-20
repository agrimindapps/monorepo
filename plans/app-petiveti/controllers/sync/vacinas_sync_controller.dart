// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/16_vacina_model.dart';

/// Controller para sincronização de vacinas usando SyncFirebaseService
class VacinasSyncController extends GetxController {
  late final SyncFirebaseService<VacinaVet> _syncService;
  
  // Estado reativo
  final RxList<VacinaVet> vacinas = <VacinaVet>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<VacinaVet>>? _dataSubscription;
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
      _syncService = SyncFirebaseService.getInstance<VacinaVet>(
        'vacinas',
        VacinaVet.fromMap,
        (vacina) => vacina.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de vacinas', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        vacinas.value = data;
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
  
  /// Criar nova vacina
  Future<String?> createVacina(VacinaVet vacina) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(vacina);
      
      Get.snackbar(
        'Sucesso',
        'Vacina ${vacina.nomeVacina} registrada',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar vacina', e);
      return null;
    }
  }
  
  /// Atualizar vacina existente
  Future<bool> updateVacina(String id, VacinaVet vacina) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, vacina);
      
      Get.snackbar(
        'Sucesso',
        'Vacina atualizada',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar vacina', e);
      return false;
    }
  }
  
  /// Deletar vacina
  Future<bool> deleteVacina(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        'Vacina removida',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar vacina', e);
      return false;
    }
  }
  
  /// Buscar vacina por ID
  Future<VacinaVet?> getVacinaById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar vacina', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshVacinas() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar vacinas', e);
    }
  }
  
  // Métodos específicos para vacinas
  
  /// Obter vacinas por animal
  List<VacinaVet> getVacinasByAnimal(String animalId) {
    return vacinas.where((vacina) => 
      vacina.animalId == animalId
    ).toList();
  }
  
  /// Obter vacinas por nome
  List<VacinaVet> getVacinasByNome(String nome) {
    return vacinas.where((vacina) => 
      vacina.nomeVacina.toLowerCase().contains(nome.toLowerCase())
    ).toList();
  }
  
  /// Obter vacinas por período de aplicação
  List<VacinaVet> getVacinasByPeriodo(int dataInicio, int dataFim) {
    return vacinas.where((vacina) => 
      vacina.dataAplicacao >= dataInicio && vacina.dataAplicacao <= dataFim
    ).toList();
  }
  
  /// Obter próximas doses a vencer (próximos 30 dias)
  List<VacinaVet> getProximasDoses() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    final proximos30Dias = agora + (30 * 24 * 60 * 60 * 1000); // 30 dias
    
    return vacinas.where((vacina) => 
      vacina.proximaDose >= agora && 
      vacina.proximaDose <= proximos30Dias
    ).toList()..sort((a, b) => a.proximaDose.compareTo(b.proximaDose));
  }
  
  /// Obter doses atrasadas
  List<VacinaVet> getDosesAtrasadas() {
    final agora = DateTime.now().millisecondsSinceEpoch;
    
    return vacinas.where((vacina) => 
      vacina.proximaDose < agora
    ).toList()..sort((a, b) => a.proximaDose.compareTo(b.proximaDose));
  }
  
  /// Obter cartão de vacinação por animal (vacinas ordenadas por data)
  List<VacinaVet> getCartaoVacinacao(String animalId) {
    return getVacinasByAnimal(animalId)
      ..sort((a, b) => a.dataAplicacao.compareTo(b.dataAplicacao));
  }
  
  /// Verificar se vacina está em dia para um animal
  bool isVacinaEmDia(String animalId, String nomeVacina) {
    final vacinasAnimal = getVacinasByAnimal(animalId);
    final vacinasEspecificas = vacinasAnimal.where((v) => 
      v.nomeVacina.toLowerCase() == nomeVacina.toLowerCase());
    
    if (vacinasEspecificas.isEmpty) return false;
    
    // Pegar a vacina mais recente
    final vacinaMaisRecente = vacinasEspecificas.reduce((a, b) => 
      a.dataAplicacao > b.dataAplicacao ? a : b);
    
    // Verificar se próxima dose não venceu
    final agora = DateTime.now().millisecondsSinceEpoch;
    return vacinaMaisRecente.proximaDose > agora;
  }
  
  /// Obter relatório de vacinação por animal
  Map<String, Map<String, dynamic>> getRelatorioVacinacao() {
    final relatorio = <String, Map<String, dynamic>>{};
    
    for (final vacina in vacinas) {
      if (!relatorio.containsKey(vacina.animalId)) {
        relatorio[vacina.animalId] = {
          'totalVacinas': 0,
          'vacinasEmDia': 0,
          'dosesAtrasadas': 0,
          'proximasDoses': 0,
        };
      }
      
      relatorio[vacina.animalId]!['totalVacinas']++;
      
      final agora = DateTime.now().millisecondsSinceEpoch;
      final proximos30Dias = agora + (30 * 24 * 60 * 60 * 1000);
      
      if (vacina.proximaDose < agora) {
        relatorio[vacina.animalId]!['dosesAtrasadas']++;
      } else if (vacina.proximaDose <= proximos30Dias) {
        relatorio[vacina.animalId]!['proximasDoses']++;
      } else {
        relatorio[vacina.animalId]!['vacinasEmDia']++;
      }
        }
    
    return relatorio;
  }
  
  /// Verificar se tem vacinas cadastradas
  bool get hasVacinas => vacinas.isNotEmpty;
  
  /// Obter total de vacinas
  int get totalVacinas => vacinas.length;
  
  /// Obter total de doses atrasadas
  int get totalDosesAtrasadas => getDosesAtrasadas().length;
  
  /// Obter total de próximas doses
  int get totalProximasDoses => getProximasDoses().length;
  
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
