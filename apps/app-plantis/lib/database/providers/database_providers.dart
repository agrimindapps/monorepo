import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plantis_database.dart';
import '../repositories/tasks_drift_repository.dart';
import '../repositories/plants_drift_repository.dart';
import '../repositories/plant_tasks_drift_repository.dart';
import '../repositories/spaces_drift_repository.dart';

/// ============================================================================
/// DATABASE PROVIDERS - Riverpod 3.0 (Manual Providers)
/// ============================================================================
///
/// Providers Riverpod para acesso ao PlantisDatabase em toda aplicação.
///
/// **PADRÃO ESTABELECIDO:**
/// - Manual providers (sem @riverpod) para evitar problemas com tipos Drift
/// - Provider único para database instance
/// - Lifecycle gerenciado automaticamente pelo Riverpod
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
/// Retorna a instância singleton do banco de dados.
/// O Riverpod cuida automaticamente do lifecycle (não precisa dispose manual).
///
/// **Características:**
/// - Lazy initialization (criado apenas quando usado)
/// - Singleton (mesma instância em toda aplicação)
/// - Auto-dispose quando não mais necessário
final plantisDatabaseProvider = Provider<PlantisDatabase>((ref) {
  // Usa factory method production
  final db = PlantisDatabase.production();

  // Cleanup quando o provider for disposed
  ref.onDispose(() {
    print('🗑️ PlantisDatabase provider disposed');
    db.close();
  });

  return db;
});

// ============================================================================
// PROVIDERS DERIVADOS (QUERIES COMUNS)
// ============================================================================

/// Provider para contagem de plantas ativas
///
/// Atualiza automaticamente quando o database muda (via ref.watch)
final activePlantsCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.countActivePlants();
});

/// Provider para contagem de tarefas pendentes
final pendingTasksCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.countPendingTasks();
});

/// Provider para contagem de registros sujos (precisando sync)
final dirtyRecordsCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.countDirtyRecords();
});

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
final activePlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getActivePlants();
});

/// Provider para lista de tarefas pendentes
final pendingTasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPendingTasks();
});

/// Provider para itens pendentes de sincronização
final pendingSyncItemsProvider = FutureProvider<List<PlantsSyncQueueData>>((ref) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPendingSyncItems();
});

// ============================================================================
// PROVIDERS PARAMETRIZADOS
// ============================================================================

/// Provider para plantas de um espaço específico
///
/// **USO:**
/// ```dart
/// final spacePlantsAsync = ref.watch(plantsBySpaceProvider(spaceId: 1));
/// ```
final plantsBySpaceProvider = FutureProvider.family<List<Plant>, int>((ref, spaceId) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPlantsBySpace(spaceId);
});

/// Provider para configuração de uma planta específica
///
/// **USO:**
/// ```dart
/// final configAsync = ref.watch(plantConfigProvider(plantId: 1));
/// ```
final plantConfigProvider = FutureProvider.family<PlantConfig?, int>((ref, plantId) async {
  final db = ref.watch(plantisDatabaseProvider);
  return db.getPlantConfig(plantId);
});

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

final tasksDriftRepositoryProvider = Provider<TasksDriftRepository>((ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return TasksDriftRepository(db);
});

final plantsDriftRepositoryProvider = Provider<PlantsDriftRepository>((ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return PlantsDriftRepository(db);
});

final plantTasksDriftRepositoryProvider = Provider<PlantTasksDriftRepository>((ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return PlantTasksDriftRepository(db);
});

final spacesDriftRepositoryProvider = Provider<SpacesDriftRepository>((ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return SpacesDriftRepository(db);
});
