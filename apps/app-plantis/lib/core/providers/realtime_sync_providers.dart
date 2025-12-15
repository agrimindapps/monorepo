import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/providers/database_providers.dart';
import '../../features/plants/presentation/providers/plants_notifier.dart';
import '../services/realtime_sync_service.dart';
import 'comments_providers.dart';
import 'repository_providers.dart';
import 'spaces_providers.dart';

part 'realtime_sync_providers.g.dart';

/// Provider para o serviço de sincronização em tempo real
@Riverpod(keepAlive: true)
RealtimeSyncService realtimeSyncService(Ref ref) {
  final service = RealtimeSyncService(
    firestore: ref.watch(firebaseFirestoreProvider),
    plantsRepository: ref.watch(plantsDriftRepositoryProvider),
    commentsRepository: ref.watch(commentsDriftRepositoryProvider),
    tasksRepository: ref.watch(plantTasksDriftRepositoryProvider),
    spacesRepository: ref.watch(spacesDriftRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );

  // Inicia os listeners automaticamente
  service.startListening();

  // Escuta eventos e atualiza providers relevantes
  service.changesStream.listen((event) {
    if (kDebugMode) {
      debugPrint('[RealtimeSync] Event received: $event');
    }

    // Invalida providers baseado na coleção que mudou
    switch (event.collection) {
      case 'plants':
        ref.invalidate(plantsNotifierProvider);
        break;
      case 'comments':
        // Refresh comments se estiver na mesma planta
        final commentsNotifier = ref.read(commentsNotifierProvider.notifier);
        commentsNotifier.refresh();
        break;
      case 'spaces':
        ref.invalidate(spacesNotifierProvider);
        break;
      case 'tasks':
        // Tasks são gerenciados pelo PlantTaskNotifier
        // que já escuta mudanças do Drift via streams
        break;
    }
  });

  // Dispõe quando o provider é destruído
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Provider para stream de eventos de sincronização
/// Útil para UI reagir a mudanças em tempo real
@riverpod
Stream<RealtimeSyncEvent> realtimeSyncEvents(Ref ref) {
  final service = ref.watch(realtimeSyncServiceProvider);
  return service.changesStream;
}

/// Provider para verificar se o realtime sync está ativo
@riverpod
bool isRealtimeSyncActive(Ref ref) {
  final service = ref.watch(realtimeSyncServiceProvider);
  return service.isListening;
}
