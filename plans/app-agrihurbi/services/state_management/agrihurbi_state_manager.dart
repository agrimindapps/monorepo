// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../repository/pluviometros_repository.dart';

/// Gerenciador de estado global centralizado para o app-agrihurbi
///
/// Este service centraliza todo o estado compartilhado entre controllers,
/// eliminando inconsistências e fornecendo uma fonte única de verdade
/// para dados que precisam ser sincronizados entre múltiplas telas.
class AgrihurbiStateManager extends GetxService {
  // ========== SINGLETON PATTERN ==========

  static AgrihurbiStateManager? _instance;
  static AgrihurbiStateManager get instance =>
      _instance ??= AgrihurbiStateManager._();
  AgrihurbiStateManager._();

  // ========== ESTADO GLOBAL ==========

  /// ID do pluviômetro atualmente selecionado
  /// Usado em medições e relatórios para manter contexto
  final RxString selectedPluviometroId = ''.obs;

  /// Estado de autenticação do usuário
  final RxBool isAuthenticated = false.obs;

  /// ID do usuário atual
  final RxString currentUserId = ''.obs;

  /// Estado geral de carregamento do app
  final RxBool isGlobalLoading = false.obs;

  /// Estado de conectividade com a internet
  final RxBool isOnline = true.obs;

  /// Timestamp da última sincronização de dados
  final RxString lastSyncTime = ''.obs;

  /// Contador de operações pendentes
  final RxInt pendingOperations = 0.obs;

  // ========== EVENTOS DE ESTADO ==========

  /// Stream de eventos de mudança de estado
  final _stateEventController = StreamController<StateEvent>.broadcast();
  Stream<StateEvent> get stateStream => _stateEventController.stream;

  // ========== INICIALIZAÇÃO ==========

  @override
  void onInit() {
    super.onInit();
    debugPrint(
        '🎯 AgrihurbiStateManager: Inicializando gerenciador de estado global');
    _initializeState();
    _setupReactiveListeners();
  }

  /// Inicializa o estado a partir do armazenamento persistente
  Future<void> _initializeState() async {
    try {
      // Restaurar pluviômetro selecionado do SharedPreferences
      await _loadSelectedPluviometer();

      // Restaurar timestamp da última sincronização
      _loadLastSyncTime();

      debugPrint('✅ AgrihurbiStateManager: Estado inicial carregado');
    } catch (e) {
      debugPrint(
          '❌ AgrihurbiStateManager: Erro ao carregar estado inicial: $e');
    }
  }

  /// Configura listeners reativos para mudanças de estado
  void _setupReactiveListeners() {
    // Listener para mudanças no pluviômetro selecionado
    ever(selectedPluviometroId, (String pluviometroId) {
      _emitStateEvent(StateEvent(
        type: StateEventType.pluviometerChanged,
        data: pluviometroId,
        timestamp: DateTime.now(),
      ));
      _persistSelectedPluviometer(pluviometroId);
    });

    // Listener para mudanças no estado de autenticação
    ever(isAuthenticated, (bool authenticated) {
      _emitStateEvent(StateEvent(
        type: StateEventType.authenticationChanged,
        data: authenticated,
        timestamp: DateTime.now(),
      ));
    });

    // Listener para mudanças na conectividade
    ever(isOnline, (bool online) {
      _emitStateEvent(StateEvent(
        type: StateEventType.connectivityChanged,
        data: online,
        timestamp: DateTime.now(),
      ));
    });
  }

  // ========== MÉTODOS PÚBLICOS ==========

  /// Atualiza o pluviômetro selecionado
  Future<void> updateSelectedPluviometer(String pluviometroId) async {
    try {
      debugPrint(
          '🎯 AgrihurbiStateManager: Atualizando pluviômetro selecionado: $pluviometroId');
      selectedPluviometroId.value = pluviometroId;
    } catch (e) {
      debugPrint('❌ AgrihurbiStateManager: Erro ao atualizar pluviômetro: $e');
      rethrow;
    }
  }

  /// Atualiza o estado de autenticação
  void updateAuthenticationState(bool authenticated, [String? userId]) {
    isAuthenticated.value = authenticated;
    if (userId != null) {
      currentUserId.value = userId;
    } else if (!authenticated) {
      currentUserId.value = '';
    }
  }

  /// Atualiza o estado de conectividade
  void updateConnectivityState(bool online) {
    isOnline.value = online;
  }

  /// Inicia uma operação global (mostra loading)
  void startGlobalOperation(String operationName) {
    pendingOperations.value++;
    isGlobalLoading.value = true;
    debugPrint(
        '🔄 AgrihurbiStateManager: Iniciando operação: $operationName (${pendingOperations.value} pendentes)');
  }

  /// Finaliza uma operação global
  void completeGlobalOperation(String operationName) {
    if (pendingOperations.value > 0) {
      pendingOperations.value--;
    }

    if (pendingOperations.value == 0) {
      isGlobalLoading.value = false;
    }

    debugPrint(
        '✅ AgrihurbiStateManager: Operação concluída: $operationName (${pendingOperations.value} pendentes)');
  }

  /// Força refresh de todos os dados
  Future<void> refreshAllData() async {
    try {
      startGlobalOperation('refreshAllData');

      _emitStateEvent(StateEvent(
        type: StateEventType.dataRefreshStarted,
        data: 'all',
        timestamp: DateTime.now(),
      ));

      // Emit event para controllers reagirem
      _emitStateEvent(StateEvent(
        type: StateEventType.dataRefreshCompleted,
        data: 'all',
        timestamp: DateTime.now(),
      ));

      _updateLastSyncTime();
    } catch (e) {
      debugPrint('❌ AgrihurbiStateManager: Erro ao atualizar dados: $e');
      rethrow;
    } finally {
      completeGlobalOperation('refreshAllData');
    }
  }

  /// Limpa todo o estado (útil para logout)
  void clearAllState() {
    selectedPluviometroId.value = '';
    isAuthenticated.value = false;
    currentUserId.value = '';
    isGlobalLoading.value = false;
    pendingOperations.value = 0;

    _emitStateEvent(StateEvent(
      type: StateEventType.stateCleared,
      data: null,
      timestamp: DateTime.now(),
    ));

    debugPrint('🧹 AgrihurbiStateManager: Estado global limpo');
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Carrega pluviômetro selecionado do SharedPreferences
  Future<void> _loadSelectedPluviometer() async {
    try {
      final repository = PluviometrosRepository();
      await repository.getSelectedPluviometroId();
      if (repository.selectedPluviometroId.isNotEmpty) {
        selectedPluviometroId.value = repository.selectedPluviometroId;
        debugPrint(
            '📱 AgrihurbiStateManager: Pluviômetro carregado do storage: ${repository.selectedPluviometroId}');
      }
    } catch (e) {
      debugPrint('⚠️ AgrihurbiStateManager: Erro ao carregar pluviômetro: $e');
    }
  }

  /// Persiste pluviômetro selecionado no SharedPreferences
  Future<void> _persistSelectedPluviometer(String pluviometroId) async {
    try {
      final repository = PluviometrosRepository();
      await repository.setSelectedPluviometroId(pluviometroId);
      debugPrint(
          '💾 AgrihurbiStateManager: Pluviômetro persistido: $pluviometroId');
    } catch (e) {
      debugPrint('⚠️ AgrihurbiStateManager: Erro ao persistir pluviômetro: $e');
    }
  }

  /// Carrega timestamp da última sincronização
  void _loadLastSyncTime() {
    // TODO: Implementar carregamento do SharedPreferences
    lastSyncTime.value = '';
  }

  /// Atualiza timestamp da última sincronização
  void _updateLastSyncTime() {
    lastSyncTime.value = DateTime.now().toIso8601String();
    // TODO: Persistir no SharedPreferences
  }

  /// Emite evento de mudança de estado
  void _emitStateEvent(StateEvent event) {
    if (!_stateEventController.isClosed) {
      _stateEventController.add(event);
      debugPrint('📡 AgrihurbiStateManager: Evento emitido: ${event.type}');
    }
  }

  // ========== GETTERS DE CONVENIÊNCIA ==========

  /// Verifica se há operações em andamento
  bool get hasOperationsInProgress => pendingOperations.value > 0;

  /// Verifica se o app está em estado válido para operações
  bool get isReadyForOperations =>
      isAuthenticated.value && isOnline.value && !hasOperationsInProgress;

  /// Obtém pluviômetro selecionado (pode ser null)
  String? get currentPluviometroId =>
      selectedPluviometroId.value.isEmpty ? null : selectedPluviometroId.value;

  // ========== CLEANUP ==========

  @override
  void onClose() {
    _stateEventController.close();
    debugPrint('🔚 AgrihurbiStateManager: Gerenciador de estado finalizado');
    super.onClose();
  }
}

// ========== CLASSES DE APOIO ==========

/// Tipos de eventos de estado
enum StateEventType {
  pluviometerChanged,
  authenticationChanged,
  connectivityChanged,
  dataRefreshStarted,
  dataRefreshCompleted,
  stateCleared,
}

/// Evento de mudança de estado
class StateEvent {
  final StateEventType type;
  final dynamic data;
  final DateTime timestamp;

  StateEvent({
    required this.type,
    this.data,
    required this.timestamp,
  });

  @override
  String toString() =>
      'StateEvent(type: $type, data: $data, timestamp: $timestamp)';
}
