import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../features/plants/data/models/plant_model.dart';
import '../../features/plants/domain/entities/plant.dart';
import '../plantis_database.dart' as db;

/// ============================================================================
/// PLANTS DRIFT REPOSITORY
/// ============================================================================
///
/// Repository Drift para gerenciar plantas.
///
/// **RESPONSABILIDADES:**
/// - CRUD completo de plantas
/// - Conversão PlantModel/Plant ↔ Drift Plant entity
/// - Queries com JOIN (Spaces)
/// - Busca e filtragem
/// - Soft/hard delete
/// - Streams reativos
///
/// **COMPLEXIDADE:**
/// - PlantConfig é embedded JSON (não tabela separada aqui)
/// - Relacionamento com Spaces (FK)
/// - Suporte a múltiplas imagens (imageUrls JSON)
/// ============================================================================

@lazySingleton
class PlantsDriftRepository {
  final db.PlantisDatabase _db;

  PlantsDriftRepository(this._db);

  // ==================== CREATE ====================

  /// Insere nova planta no banco Drift
  Future<int> insertPlant(PlantModel model) async {
    // Resolver spaceId (String → INTEGER local)
    final localSpaceId = await _resolveSpaceId(model.spaceId);

    final companion = db.PlantsCompanion.insert(
      firebaseId: Value(model.id),
      name: model.name,
      species: Value(model.species),
      spaceId: Value(localSpaceId),
      imageBase64: Value(model.imageBase64),
      imageUrls: Value(model.imageUrls.join(',')), // CSV
      plantingDate: Value(model.plantingDate),
      notes: Value(model.notes),
      // TODO: config field - PlantConfig is stored in separate PlantConfigs table (1:1 relationship)
      // config: Value(
      //   model.config != null
      //       ? PlantConfigModel.fromEntity(model.config!).toJson().toString()
      //       : null,
      // ),
      createdAt: Value(model.createdAt ?? DateTime.now()),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      lastSyncAt: Value(model.lastSyncAt),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      userId: Value(model.userId),
      moduleName: Value(model.moduleName ?? 'plantis'),
      isFavorited: Value(model.isFavorited),
    );

    return await _db.into(_db.plants).insert(companion);
  }

  // ==================== READ ====================

  /// Retorna todas as plantas ativas
  Future<List<Plant>> getAllPlants() async {
    final plants =
        await (_db.select(_db.plants)
              ..where((p) => p.isDeleted.equals(false))
              ..orderBy([
                (p) => OrderingTerm(
                  expression: p.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    return plants.map(_plantDriftToModel).toList();
  }

  /// Retorna planta pelo firebaseId
  Future<Plant?> getPlantById(String firebaseId) async {
    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId))).getSingleOrNull();

    return plant != null ? _plantDriftToModel(plant) : null;
  }

  /// Retorna plantas de um espaço específico
  Future<List<Plant>> getPlantsBySpace(String spaceFirebaseId) async {
    final localSpaceId = await _resolveSpaceId(spaceFirebaseId);
    if (localSpaceId == null) return [];

    final plants =
        await (_db.select(_db.plants)
              ..where(
                (p) =>
                    p.spaceId.equals(localSpaceId) & p.isDeleted.equals(false),
              )
              ..orderBy([(p) => OrderingTerm(expression: p.name)]))
            .get();

    return plants.map(_plantDriftToModel).toList();
  }

  /// Busca plantas por query (nome, espécie, notas)
  Future<List<Plant>> searchPlants(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';

    final plants =
        await (_db.select(_db.plants)
              ..where(
                (p) =>
                    p.isDeleted.equals(false) &
                    (p.name.lower().like(searchTerm) |
                        p.species.lower().like(searchTerm) |
                        p.notes.lower().like(searchTerm)),
              )
              ..orderBy([(p) => OrderingTerm(expression: p.name)]))
            .get();

    return plants.map(_plantDriftToModel).toList();
  }

  // ==================== UPDATE ====================

  /// Atualiza planta existente
  Future<bool> updatePlant(PlantModel model) async {
    final localId = await _getLocalIdByFirebaseId(model.id);
    if (localId == null) return false;

    final localSpaceId = await _resolveSpaceId(model.spaceId);

    final companion = db.PlantsCompanion(
      id: Value(localId),
      firebaseId: Value(model.id),
      name: Value(model.name),
      species: Value(model.species),
      spaceId: Value(localSpaceId),
      imageBase64: Value(model.imageBase64),
      imageUrls: Value(model.imageUrls.join(',')),
      plantingDate: Value(model.plantingDate),
      notes: Value(model.notes),
      // TODO: config field - PlantConfig stored in separate table
      // config: Value(
      //   model.config != null
      //       ? PlantConfigModel.fromEntity(model.config!).toJson().toString()
      //       : null,
      // ),
      updatedAt: Value(DateTime.now()),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      isFavorited: Value(model.isFavorited),
    );

    final updated = await (_db.update(
      _db.plants,
    )..where((p) => p.id.equals(localId))).write(companion);

    return updated > 0;
  }

  // ==================== DELETE ====================

  /// Soft delete
  Future<bool> deletePlant(String firebaseId) async {
    final updated =
        await (_db.update(
          _db.plants,
        )..where((p) => p.firebaseId.equals(firebaseId))).write(
          db.PlantsCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return updated > 0;
  }

  /// Hard delete
  Future<bool> hardDeletePlant(String firebaseId) async {
    final deleted = await (_db.delete(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId))).go();

    return deleted > 0;
  }

  /// Limpa todas as plantas
  Future<void> clearAll() async {
    await _db.delete(_db.plants).go();
  }

  // ==================== STREAMS ====================

  /// Watch todas as plantas ativas
  Stream<List<Plant>> watchPlants() {
    return (_db.select(_db.plants)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([
            (p) =>
                OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((plants) => plants.map(_plantDriftToModel).toList());
  }

  /// Watch planta específica
  Stream<Plant?> watchPlantById(String firebaseId) {
    return (_db.select(_db.plants)
          ..where((p) => p.firebaseId.equals(firebaseId)))
        .watchSingleOrNull()
        .map((plant) => plant != null ? _plantDriftToModel(plant) : null);
  }

  /// Watch plantas de um espaço
  Stream<List<Plant>> watchPlantsBySpace(String spaceFirebaseId) {
    return Stream.fromFuture(_resolveSpaceId(spaceFirebaseId)).asyncExpand((
      localSpaceId,
    ) {
      if (localSpaceId == null) {
        return Stream.value(<Plant>[]);
      }

      return (_db.select(_db.plants)
            ..where(
              (p) => p.spaceId.equals(localSpaceId) & p.isDeleted.equals(false),
            )
            ..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .watch()
          .map((plants) => plants.map(_plantDriftToModel).toList());
    });
  }

  // ==================== SYNC HELPERS ====================

  /// Retorna plantas dirty
  Future<List<Plant>> getDirtyPlants() async {
    final plants = await (_db.select(
      _db.plants,
    )..where((p) => p.isDirty.equals(true))).get();

    return plants.map(_plantDriftToModel).toList();
  }

  /// Marca como sincronizada
  Future<void> markAsSynced(String firebaseId) async {
    await (_db.update(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId))).write(
      db.PlantsCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== CONVERTERS ====================

  /// Converte Drift Plant → PlantModel
  PlantModel _plantDriftToModel(db.Plant plant) {
    // Parse imageUrls CSV
    final imageUrls = plant.imageUrls != null && plant.imageUrls!.isNotEmpty
        ? plant.imageUrls!.split(',')
        : <String>[];

    // Config is stored in separate PlantConfigs table (1:1 relationship)
    // To get config, query PlantConfigsDriftRepository separately
    PlantConfig? config;
    // TODO: Query PlantConfigsDriftRepository.getConfigByPlantId(plant.firebaseId)
    // For now, return null
    config = null;

    return PlantModel(
      id: plant.firebaseId ?? plant.id.toString(),
      name: plant.name,
      species: plant.species,
      spaceId: plant.spaceId?.toString(), // Converter de volta para String
      imageBase64: plant.imageBase64,
      imageUrls: imageUrls,
      plantingDate: plant.plantingDate,
      notes: plant.notes,
      config: config,
      createdAt: plant.createdAt,
      updatedAt: plant.updatedAt,
      lastSyncAt: plant.lastSyncAt,
      isDirty: plant.isDirty,
      isDeleted: plant.isDeleted,
      version: plant.version,
      userId: plant.userId,
      moduleName: plant.moduleName,
      isFavorited: plant.isFavorited,
    );
  }

  /// Helper: Converte spaceId String (firebaseId) → INTEGER (local id)
  Future<int?> _resolveSpaceId(String? spaceFirebaseId) async {
    if (spaceFirebaseId == null) return null;

    // Tenta interpretar como INTEGER direto (fallback)
    final asInt = int.tryParse(spaceFirebaseId);
    if (asInt != null) return asInt;

    // Busca no banco pelo firebaseId
    final space = await (_db.select(
      _db.spaces,
    )..where((s) => s.firebaseId.equals(spaceFirebaseId))).getSingleOrNull();

    return space?.id;
  }

  /// Helper: Obter ID local da planta
  Future<int?> _getLocalIdByFirebaseId(String firebaseId) async {
    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId))).getSingleOrNull();

    return plant?.id;
  }

  // ==================== STATISTICS ====================

  /// Conta plantas ativas
  Future<int> countActivePlants() async {
    final count = _db.plants.id.count();
    final query = _db.selectOnly(_db.plants)
      ..addColumns([count])
      ..where(_db.plants.isDeleted.equals(false));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Conta plantas favoritadas
  Future<int> countFavoritedPlants() async {
    final count = _db.plants.id.count();
    final query = _db.selectOnly(_db.plants)
      ..addColumns([count])
      ..where(
        _db.plants.isDeleted.equals(false) &
            _db.plants.isFavorited.equals(true),
      );

    return query.map((row) => row.read(count)!).getSingle();
  }
}
