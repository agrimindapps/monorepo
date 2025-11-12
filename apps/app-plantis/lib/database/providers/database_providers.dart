import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../plantis_database.dart';

part 'database_providers.g.dart';

/// ============================================================================
/// DATABASE PROVIDERS - Riverpod
/// ============================================================================
///
/// Providers Riverpod para acesso ao PlantisDatabase em toda aplicação.
///
/// **PADRÃO ESTABELECIDO:**
/// - @riverpod annotation para code generation
/// - Provider único para database instance
/// - Lifecycle gerenciado automaticamente pelo Riverpod
/// - Injectable no GetIt, exposto via Riverpod
///
/// **USO:**
/// ```dart
/// // Em qualquer widget/provider:
/// final db = ref.watch(plantisDatabaseProvider);
/// final plants = await db.getActivePlants();
/// ```
/// ============================================================================

/// Provider principal do PlantisDatabase
///
/// Retorna a instância singleton do banco de dados configurada via Injectable.
/// O Riverpod cuida automaticamente do lifecycle (não precisa dispose manual).
///
/// **Características:**
/// - Lazy initialization (criado apenas quando usado)
/// - Singleton (mesma instância em toda aplicação)
/// - Auto-dispose quando não mais necessário
@riverpod
PlantisDatabase plantisDatabase(PlantisDatabaseRef ref) {
  // Usa factory method injectable que pega instância do GetIt
  final db = PlantisDatabase.injectable();

  // Cleanup quando o provider for disposed
  ref.onDispose(() {
    print('🗑️ PlantisDatabase provider disposed');
    // Nota: db.close() será chamado automaticamente pelo singleton do GetIt
  });

  return db;
}

// ============================================================================
// PROVIDERS DERIVADOS (QUERIES COMUNS)
// ============================================================================

/// Provider para contagem de plantas ativas
///
/// Atualiza automaticamente quando o database muda (via ref.watch)
@riverpod
Future<int> activePlantsCount(ActivePlantsCountRef ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.countActivePlants();
}

/// Provider para contagem de tarefas pendentes
@riverpod
Future<int> pendingTasksCount(PendingTasksCountRef ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.countPendingTasks();
}

/// Provider para contagem de registros sujos (precisando sync)
@riverpod
Future<int> dirtyRecordsCount(DirtyRecordsCountRef ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.countDirtyRecords();
}

/// Provider para lista de plantas ativas
///
/// **USO:**
/// ```dart
/// final plantsAsync = ref.watch(activePlantsProvider);
/// plantsAsync.when(
///   data: (plants) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
/// );
/// ```
@riverpod
Future<List<Plant>> activePlants(ActivePlantsRef ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getActivePlants();
}

/// Provider para lista de tarefas pendentes
@riverpod
Future<List<Task>> pendingTasks(PendingTasksRef ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPendingTasks();
}

/// Provider para itens pendentes de sincronização
@riverpod
Future<List<PlantsSyncQueueData>> pendingSyncItems(PendingSyncItemsRef ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPendingSyncItems();
}

// ============================================================================
// PROVIDERS PARAMETRIZADOS
// ============================================================================

/// Provider para plantas de um espaço específico
///
/// **USO:**
/// ```dart
/// final spacePlantsAsync = ref.watch(plantsBySpaceProvider(spaceId: 1));
/// ```
@riverpod
Future<List<Plant>> plantsBySpace(
  PlantsBySpaceRef ref, {
  required int spaceId,
}) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPlantsBySpace(spaceId);
}

/// Provider para configuração de uma planta específica
///
/// **USO:**
/// ```dart
/// final configAsync = ref.watch(plantConfigProvider(plantId: 1));
/// ```
@riverpod
Future<PlantConfig?> plantConfig(
  PlantConfigRef ref, {
  required int plantId,
}) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPlantConfig(plantId);
}
