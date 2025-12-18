import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

/// Interface para abstração de Sync - permite inversão de dependência
/// Repository não precisa conhecer UnifiedSyncManager diretamente
abstract class ISyncManager {
  /// Dispara sincronização em background (não-bloqueante)
  Future<void> triggerBackgroundSync(String moduleName);

  /// Força sincronização imediata (bloqueante)
  Future<Either<Failure, void>> forceSync(String moduleName);

  /// Verifica se está sincronizando no momento
  bool get isSyncing;

  /// Stream de eventos de sincronização
  Stream<SyncEvent> get syncEvents;
}

/// Evento de sincronização
class SyncEvent {
  final SyncEventType type;
  final String moduleName;
  final String? message;
  final DateTime timestamp;

  SyncEvent({
    required this.type,
    required this.moduleName,
    this.message,
    required this.timestamp,
  });
}

enum SyncEventType {
  started,
  completed,
  failed,
  paused,
  resumed,
}
