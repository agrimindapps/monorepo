// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../../models/11_animal_model.dart';

/// Controller para sincronização de animais usando SyncFirebaseService
class AnimalsSyncController extends GetxController {
  late final SyncFirebaseService<Animal> _syncService;
  
  // Estado reativo
  final RxList<Animal> animals = <Animal>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.offline.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // Subscriptions para streams
  StreamSubscription<List<Animal>>? _dataSubscription;
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
      _syncService = SyncFirebaseService.getInstance<Animal>(
        'animais',
        Animal.fromMap,
        (animal) => animal.toMap(),
      );
      
      // Inicializar o serviço
      await _syncService.initialize();
      
      // Configurar listeners para streams
      _setupStreams();
      
      isLoading.value = false;
    } catch (e) {
      _handleError('Erro ao inicializar sincronização de animais', e);
    }
  }
  
  /// Configurar listeners para os streams do SyncFirebaseService
  void _setupStreams() {
    // Stream de dados - atualiza lista automaticamente
    _dataSubscription = _syncService.dataStream.listen(
      (data) {
        animals.value = data;
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
  
  /// Criar novo animal
  Future<String?> createAnimal(Animal animal) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final id = await _syncService.create(animal);
      
      Get.snackbar(
        'Sucesso',
        'Animal ${animal.nome} foi adicionado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return id;
    } catch (e) {
      _handleError('Erro ao criar animal', e);
      return null;
    }
  }
  
  /// Atualizar animal existente
  Future<bool> updateAnimal(String id, Animal animal) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.update(id, animal);
      
      Get.snackbar(
        'Sucesso',
        'Animal ${animal.nome} foi atualizado',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao atualizar animal', e);
      return false;
    }
  }
  
  /// Deletar animal
  Future<bool> deleteAnimal(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Encontrar animal para mostrar nome na confirmação
      final animal = animals.firstWhereOrNull((a) => a.id == id);
      final nomeAnimal = animal?.nome ?? 'Animal';
      
      await _syncService.delete(id);
      
      Get.snackbar(
        'Sucesso',
        '$nomeAnimal foi removido',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      _handleError('Erro ao deletar animal', e);
      return false;
    }
  }
  
  /// Buscar animal por ID
  Future<Animal?> getAnimalById(String id) async {
    try {
      return await _syncService.findById(id);
    } catch (e) {
      _handleError('Erro ao buscar animal', e);
      return null;
    }
  }
  
  /// Recarregar dados manualmente
  Future<void> refreshAnimals() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // Forçar sincronização se online
      if (_syncService.canSync) {
        await _syncService.forceSync();
      }
      
      // Os dados serão atualizados automaticamente via stream
    } catch (e) {
      _handleError('Erro ao recarregar animais', e);
    }
  }
  
  /// Limpar todos os dados (apenas para desenvolvimento/debug)
  Future<void> clearAllAnimals() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      await _syncService.clear();
      
      Get.snackbar(
        'Sucesso',
        'Todos os animais foram removidos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('Erro ao limpar dados', e);
    }
  }
  
  // Métodos utilitários
  
  /// Verificar se tem animais cadastrados
  bool get hasAnimals => animals.isNotEmpty;
  
  /// Obter total de animais
  int get totalAnimals => animals.length;
  
  /// Obter animais por espécie
  List<Animal> getAnimalsByEspecie(String especie) {
    return animals.where((animal) => 
      animal.especie.toLowerCase() == especie.toLowerCase()
    ).toList();
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
