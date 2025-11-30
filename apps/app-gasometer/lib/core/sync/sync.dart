/// Drift-Firestore Sync Foundation Layer
///
/// Fornece infraestrutura base para sincronização bidirecional entre
/// Drift (SQLite local) e Firestore (cloud storage).
///
/// **Componentes principais:**
/// - [IDriftSyncAdapter]: Interface para adapters de sincronização
/// - [DriftSyncAdapterBase]: Classe base abstrata com lógica comum
/// - [SyncPushResult]: Resultado de operações de upload (local → Firestore)
/// - [SyncPullResult]: Resultado de operações de download (Firestore → local)
///
/// **Uso:**
/// ```dart
/// // 1. Criar adapter concreto
/// class VehicleDriftSyncAdapter extends DriftSyncAdapterBase<VehicleEntity, VehicleTableData> {
///   // Implementar conversões e operações específicas
/// }
///
/// // 2. Push registros dirty
/// final pushResult = await adapter.pushDirtyRecords(userId);
/// pushResult.fold(
///   (failure) => print('Push failed: ${failure.message}'),
///   (result) => print(result.summary),
/// );
///
/// // 3. Pull mudanças remotas
/// final pullResult = await adapter.pullRemoteChanges(userId, since: lastSync);
/// pullResult.fold(
///   (failure) => print('Pull failed: ${failure.message}'),
///   (result) => print(result.summary),
/// );
/// ```
library;

// Base classes
export 'package:core/src/infrastructure/storage/drift/sync/adapters/drift_sync_adapter_base.dart';
// Interfaces
export 'package:core/src/infrastructure/storage/drift/sync/interfaces/i_drift_sync_adapter.dart';
// Models
export 'package:core/src/infrastructure/storage/drift/sync/models/sync_results.dart';
