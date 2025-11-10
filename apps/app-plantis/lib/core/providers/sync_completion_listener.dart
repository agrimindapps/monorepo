import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../features/plants/presentation/providers/plants_notifier.dart';
import 'realtime_sync_notifier.dart';

part 'sync_completion_listener.g.dart';

/// Provider que escuta eventos de sincronização e recarrega dados quando necessário
@riverpod
class SyncCompletionListener extends _$SyncCompletionListener {
  SyncStatus? _previousStatus;

  @override
  void build() {
    // Escuta mudanças no status de sincronização
    ref.listen(
      currentSyncStatusProvider,
      (previous, current) async {
        developer.log(
          'Sync status changed: ${_previousStatus?.name} -> ${current.name}',
          name: 'SyncCompletionListener',
        );

        // Detecta quando sync foi concluído (estava syncing e agora está synced)
        if (_previousStatus == SyncStatus.syncing &&
            current == SyncStatus.synced) {
          developer.log(
            '✅ Sync completed - triggering plants reload',
            name: 'SyncCompletionListener',
          );

          // Aguarda um pequeno delay para garantir que dados estão salvos
          await Future<void>.delayed(const Duration(milliseconds: 500));

          // Recarrega a lista de plantas
          await _reloadPlants();
        }

        _previousStatus = current;
      },
      fireImmediately: false,
    );

    developer.log(
      'SyncCompletionListener initialized',
      name: 'SyncCompletionListener',
    );
  }

  /// Recarrega a lista de plantas
  Future<void> _reloadPlants() async {
    try {
      // Invalida o provider de plantas para forçar recarga
      ref.invalidate(plantsNotifierProvider);

      developer.log(
        '🔄 Plants provider invalidated - will reload on next read',
        name: 'SyncCompletionListener',
      );
    } catch (e) {
      developer.log(
        '❌ Error reloading plants after sync: $e',
        name: 'SyncCompletionListener',
        error: e,
      );
    }
  }
}

/// Provider simples para inicializar o listener
/// Use em um widget raiz ou no app initialization
@riverpod
void syncCompletionListenerInitializer(SyncCompletionListenerInitializerRef ref) {
  // Apenas lê o provider para inicializá-lo
  ref.watch(syncCompletionListenerProvider);
}
