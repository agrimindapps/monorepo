import 'dart:async';
import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/sync/domain/services/gasometer_sync_service.dart';
import '../services/gasometer_realtime_service.dart';
import 'dependency_providers.dart';

part 'realtime_sync_notifier.g.dart';

/// Provider para o GasometerRealtimeService
@Riverpod(keepAlive: true)
GasometerRealtimeService gasometerRealtimeService(Ref ref) {
  final syncService = ref.watch(gasometerSyncServiceProvider);
  return GasometerRealtimeService(syncService: syncService);
}

/// Provider para monitorar mudanças em tempo real e invalidar providers
@Riverpod(keepAlive: true)
class RealtimeSyncNotifier extends _$RealtimeSyncNotifier {
  GasometerRealtimeService? _realtimeService;

  @override
  Future<void> build() async {
    developer.log(
      '[RealtimeSync] Initializing realtime sync for Gasometer',
      name: 'RealtimeSync',
    );

    _realtimeService = ref.watch(gasometerRealtimeServiceProvider);
    await _realtimeService?.initialize();
  }

  /// Força uma sincronização manual
  Future<void> forceSync() async {
    try {
      await _realtimeService?.forceSync();
      // Aguarda um pouco para os listeners serem notificados
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      developer.log(
        '[RealtimeSync] Error forcing sync: $e',
        name: 'RealtimeSync',
      );
    }
  }

  /// Verifica se o realtime está ativo
  bool get isRealtimeActive => _realtimeService?.isRealtimeActive ?? false;

  /// Stream de eventos de sincronização
  Stream<String>? get syncEventStream => _realtimeService?.syncEventStream;
}
