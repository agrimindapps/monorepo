import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

/// Serviço para gerenciar sincronização em tempo real do Plantis
/// com otimizações de performance e bateria
class PlantisRealtimeService with WidgetsBindingObserver {
  static final PlantisRealtimeService _instance =
      PlantisRealtimeService._internal();
  static PlantisRealtimeService get instance => _instance;

  PlantisRealtimeService._internal();

  bool _isInitialized = false;
  bool _isRealtimeActive = false;
  AppLifecycleState _currentLifecycleState = AppLifecycleState.resumed;
  Timer? _backgroundTimer;
  final StreamController<bool> _realtimeStatusController =
      StreamController<bool>.broadcast();
  final StreamController<String> _syncEventController =
      StreamController<String>.broadcast();

  /// Inicializa o serviço de real-time
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      WidgetsBinding.instance.addObserver(this);
      await _configureSyncMode();

      _isInitialized = true;
      developer.log(
        'PlantisRealtimeService inicializado',
        name: 'RealtimeService',
      );
    } catch (e) {
      developer.log(
        'Erro ao inicializar PlantisRealtimeService: $e',
        name: 'RealtimeService',
      );
    }
  }

  /// Ativa sincronização em tempo real
  Future<void> enableRealtime() async {
    if (_isRealtimeActive) return;

    try {
      _isRealtimeActive = true;
      _realtimeStatusController.add(true);

      developer.log('Real-time sync ativado', name: 'RealtimeService');
      _syncEventController.add('Real-time sync ativado');
    } catch (e) {
      developer.log('Erro ao ativar real-time: $e', name: 'RealtimeService');
      _syncEventController.add('Erro ao ativar real-time: $e');
    }
  }

  /// Desativa sincronização em tempo real (fallback para intervalos)
  Future<void> disableRealtime() async {
    if (!_isRealtimeActive) return;

    try {
      _isRealtimeActive = false;
      _realtimeStatusController.add(false);

      developer.log(
        'Real-time sync desativado - fallback para intervalos',
        name: 'RealtimeService',
      );
      _syncEventController.add('Fallback para sync por intervalos');
    } catch (e) {
      developer.log('Erro ao desativar real-time: $e', name: 'RealtimeService');
    }
  }

  /// Força uma sincronização manual
  Future<void> forceSync() async {
    try {
      await UnifiedSyncManager.instance.forceSyncApp('plantis');
      _syncEventController.add('Sincronização manual executada');
      developer.log('Sincronização manual executada', name: 'RealtimeService');
    } catch (e) {
      developer.log(
        'Erro na sincronização manual: $e',
        name: 'RealtimeService',
      );
      _syncEventController.add('Erro na sincronização manual');
    }
  }

  /// Verifica status de conectividade e ajusta modo de sync
  Future<void> handleConnectivityChange(bool isConnected) async {
    if (!_isInitialized) return;

    if (isConnected) {
      developer.log(
        'Conectividade restaurada - tentando ativar real-time',
        name: 'RealtimeService',
      );
      await _configureSyncMode();
    } else {
      developer.log(
        'Sem conectividade - mantendo dados locais',
        name: 'RealtimeService',
      );
      _syncEventController.add('Modo offline ativo');
    }
  }

  /// Otimiza sync baseado no estado do app (foreground/background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final oldState = _currentLifecycleState;
    _currentLifecycleState = state;

    developer.log(
      'App lifecycle mudou: ${oldState.name} -> ${state.name}',
      name: 'RealtimeService',
    );

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  /// App voltou para foreground - ativar real-time
  void _handleAppResumed() async {
    _backgroundTimer?.cancel();
    await forceSync();
    if (!_isRealtimeActive) {
      await enableRealtime();
    }

    _syncEventController.add('App em foreground - real-time ativo');
  }

  /// App foi para background - otimizar para economia de bateria
  void _handleAppPaused() async {
    _backgroundTimer = Timer(const Duration(minutes: 5), () async {
      if (_currentLifecycleState != AppLifecycleState.resumed) {
        await disableRealtime();
        developer.log(
          'Real-time desativado após 5min em background',
          name: 'RealtimeService',
        );
      }
    });

    _syncEventController.add('App em background - real-time temporário');
  }

  /// App foi ocultado - preparar para economia de bateria
  void _handleAppHidden() async {
    await disableRealtime();
    _syncEventController.add('App oculto - sync por intervalos');
  }

  /// App foi fechado - cleanup
  void _handleAppDetached() async {
    await disableRealtime();
    _syncEventController.add('App fechado - sync desativado');
  }

  /// Configura modo de sync baseado nas condições atuais
  Future<void> _configureSyncMode() async {
    try {
      final shouldUseRealtime = _shouldUseRealtime();

      if (shouldUseRealtime && !_isRealtimeActive) {
        await enableRealtime();
      } else if (!shouldUseRealtime && _isRealtimeActive) {
        await disableRealtime();
      }
    } catch (e) {
      developer.log(
        'Erro ao configurar modo de sync: $e',
        name: 'RealtimeService',
      );
    }
  }

  /// Determina se deve usar real-time baseado nas condições atuais
  bool _shouldUseRealtime() {
    if (_currentLifecycleState == AppLifecycleState.resumed) {
      return true;
    }
    if (_currentLifecycleState == AppLifecycleState.paused &&
        _backgroundTimer?.isActive == true) {
      return true;
    }

    return false;
  }

  /// Stream do status do real-time (true = ativo, false = intervalos)
  Stream<bool> get realtimeStatusStream => _realtimeStatusController.stream;

  /// Stream de eventos de sincronização
  Stream<String> get syncEventStream => _syncEventController.stream;

  /// Status atual do real-time
  bool get isRealtimeActive => _isRealtimeActive;

  /// Estado atual do lifecycle
  AppLifecycleState get currentLifecycleState => _currentLifecycleState;

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'is_initialized': _isInitialized,
      'is_realtime_active': _isRealtimeActive,
      'current_lifecycle_state': _currentLifecycleState.name,
      'should_use_realtime': _shouldUseRealtime(),
      'background_timer_active': _backgroundTimer?.isActive ?? false,
      'unified_sync_debug': UnifiedSyncManager.instance.getAppDebugInfo(
        'plantis',
      ),
    };
  }

  /// Limpa recursos
  Future<void> dispose() async {
    try {
      WidgetsBinding.instance.removeObserver(this);
      _backgroundTimer?.cancel();

      await _realtimeStatusController.close();
      await _syncEventController.close();

      _isInitialized = false;

      developer.log('PlantisRealtimeService disposed', name: 'RealtimeService');
    } catch (e) {
      developer.log(
        'Erro ao fazer dispose do PlantisRealtimeService: $e',
        name: 'RealtimeService',
      );
    }
  }
}
