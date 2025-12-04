import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/data/models/planta_config_model.dart';
import '../../features/plants/data/models/plant_model.dart';
import '../../features/plants/domain/entities/plant.dart';
import '../plantis_database.dart' as db;
import 'plant_configs_drift_repository.dart';

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

class PlantsDriftRepository {
  final db.PlantisDatabase _db;
  late final PlantConfigsDriftRepository _configsRepo;

  PlantsDriftRepository(this._db) {
    _configsRepo = PlantConfigsDriftRepository(_db);
  }

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

    final id = await _db.into(_db.plants).insert(companion);

    // Salvar config se existir
    if (model.config != null) {
      await _saveOrUpdateConfig(model.id, model.config!);
    }

    return id;
  }

  // ==================== READ ====================

  /// Retorna todas as plantas ativas
  Future<List<Plant>> getAllPlants() async {
    final plants = await (_db.select(_db.plants)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();

    return plants.map(_plantDriftToModel).toList();
  }

  /// Retorna planta pelo firebaseId ou ID local
  Future<Plant?> getPlantById(String id) async {
    // 1. Tenta buscar pelo firebaseId (padrão)
    var plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(id)))
        .getSingleOrNull();

    // 2. Se não encontrou, tenta buscar pelo ID local (fallback para dados legados)
    if (plant == null) {
      final localId = int.tryParse(id);
      if (localId != null) {
        plant = await (_db.select(
          _db.plants,
        )..where((p) => p.id.equals(localId)))
            .getSingleOrNull();
      }
    }

    return plant != null ? _plantDriftToModel(plant) : null;
  }

  /// Retorna plantas de um espaço específico
  Future<List<Plant>> getPlantsBySpace(String spaceFirebaseId) async {
    final localSpaceId = await _resolveSpaceId(spaceFirebaseId);
    if (localSpaceId == null) return [];

    final plants = await (_db.select(_db.plants)
          ..where(
            (p) => p.spaceId.equals(localSpaceId) & p.isDeleted.equals(false),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();

    return plants.map(_plantDriftToModel).toList();
  }

  /// Busca plantas por query (nome, espécie, notas)
  Future<List<Plant>> searchPlants(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';

    final plants = await (_db.select(_db.plants)
          ..where(
            (p) =>
                p.isDeleted.equals(false) &
                (p.name.lower().like(searchTerm) |
                    p.species.lower().like(searchTerm) |
                    p.notes.lower().like(searchTerm)),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();

    return plants.map(_plantDriftToModel).toList();
  }

  // ==================== UPDATE ====================

  /// Atualiza planta existente ou insere se não existir (Upsert)
  Future<bool> updatePlant(PlantModel model) async {
    var localId = await _getLocalIdByFirebaseId(model.id);

    // Se não existe, insere
    if (localId == null) {
      try {
        final id = await insertPlant(model);
        return id > 0;
      } catch (e) {
        // Se falhar por constraint (race condition), tenta recuperar o ID novamente
        if (e.toString().contains('UNIQUE constraint failed') ||
            e.toString().contains('constraint failed')) {
          localId = await _getLocalIdByFirebaseId(model.id);
          if (localId == null) rethrow; // Se ainda for null, é outro erro
        } else {
          rethrow;
        }
      }
    }

    final localSpaceId = await _resolveSpaceId(model.spaceId);

    if (kDebugMode) {
      print('🔄 PlantsDriftRepository.updatePlant() - localId: $localId');
      print('   model.id: ${model.id}');
      print('   model.spaceId: ${model.spaceId} -> localSpaceId: $localSpaceId');
      print('   model.config: ${model.config}');
    }

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
      updatedAt: Value(DateTime.now()),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      isFavorited: Value(model.isFavorited),
    );

    final updated = await (_db.update(
      _db.plants,
    )..where((p) => p.id.equals(localId!)))
        .write(companion);

    // Salvar/atualizar config se existir
    if (model.config != null) {
      await _saveOrUpdateConfig(model.id, model.config!);
    }

    return updated > 0;
  }

  /// Salva ou atualiza a configuração de cuidados da planta
  Future<void> _saveOrUpdateConfig(String plantFirebaseId, PlantConfig config) async {
    try {
      final plantaConfigModel = PlantaConfigModel.fromPlantConfig(
        plantaId: plantFirebaseId,
        plantConfig: config,
      );

      if (kDebugMode) {
        print('🔧 PlantsDriftRepository._saveOrUpdateConfig()');
        print('   plantFirebaseId: $plantFirebaseId');
        print('   aguaAtiva: ${plantaConfigModel.aguaAtiva}');
        print('   intervaloRegaDias: ${plantaConfigModel.intervaloRegaDias}');
        print('   aduboAtivo: ${plantaConfigModel.aduboAtivo}');
      }

      // Verificar se já existe config para esta planta
      final existingConfig = await _configsRepo.getConfigByPlantId(plantFirebaseId);
      
      if (existingConfig != null) {
        // Atualizar config existente
        final updated = await _configsRepo.updateConfig(plantaConfigModel);
        if (kDebugMode) {
          print('✅ PlantsDriftRepository._saveOrUpdateConfig() - Config atualizado: $updated');
        }
      } else {
        // Inserir novo config
        final id = await _configsRepo.insertConfig(plantaConfigModel);
        if (kDebugMode) {
          print('✅ PlantsDriftRepository._saveOrUpdateConfig() - Config inserido com id: $id');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsDriftRepository._saveOrUpdateConfig() - Erro: $e');
      }
      // Não propagar erro - config é secondary
    }
  }

  // ==================== DELETE ====================

  /// Soft delete
  Future<bool> deletePlant(String firebaseId) async {
    final updated = await (_db.update(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId)))
        .write(
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
    )..where((p) => p.firebaseId.equals(firebaseId)))
        .go();

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
            (p) => OrderingTerm.desc(p.createdAt),
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
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch()
          .map((plants) => plants.map(_plantDriftToModel).toList());
    });
  }

  // ==================== SYNC HELPERS ====================

  /// Retorna plantas dirty
  Future<List<Plant>> getDirtyPlants() async {
    final plants = await (_db.select(
      _db.plants,
    )..where((p) => p.isDirty.equals(true)))
        .get();

    return plants.map(_plantDriftToModel).toList();
  }

  /// Marca como sincronizada
  Future<void> markAsSynced(String firebaseId) async {
    await (_db.update(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId)))
        .write(
      db.PlantsCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== CONVERTERS ====================

  /// Converte Drift Plant → PlantModel (sem config - para operações rápidas)
  PlantModel _plantDriftToModel(db.Plant plant) {
    // Parse imageUrls CSV
    final imageUrls = plant.imageUrls != null && plant.imageUrls!.isNotEmpty
        ? plant.imageUrls!.split(',')
        : <String>[];

    return PlantModel(
      id: plant.firebaseId ?? plant.id.toString(),
      name: plant.name,
      species: plant.species,
      spaceId: plant.spaceId?.toString(), // Converter de volta para String
      imageBase64: plant.imageBase64,
      imageUrls: imageUrls,
      plantingDate: plant.plantingDate,
      notes: plant.notes,
      config: null, // Config será carregado separadamente se necessário
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

  /// Converte Drift Plant → PlantModel COM config carregado
  Future<PlantModel> _plantDriftToModelWithConfig(db.Plant plant) async {
    final model = _plantDriftToModel(plant);
    
    // Carregar config da tabela separada
    final plantFirebaseId = plant.firebaseId ?? plant.id.toString();
    final configModel = await _configsRepo.getConfigByPlantId(plantFirebaseId);
    
    if (configModel != null) {
      return PlantModel(
        id: model.id,
        name: model.name,
        species: model.species,
        spaceId: model.spaceId,
        imageBase64: model.imageBase64,
        imageUrls: model.imageUrls,
        plantingDate: model.plantingDate,
        notes: model.notes,
        config: configModel.toPlantConfig(),
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        lastSyncAt: model.lastSyncAt,
        isDirty: model.isDirty,
        isDeleted: model.isDeleted,
        version: model.version,
        userId: model.userId,
        moduleName: model.moduleName,
        isFavorited: model.isFavorited,
      );
    }
    
    return model;
  }

  /// Retorna todas as plantas ativas COM configs carregados
  Future<List<Plant>> getAllPlantsWithConfig() async {
    final plants = await (_db.select(_db.plants)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();

    return Future.wait(plants.map(_plantDriftToModelWithConfig));
  }

  /// Retorna planta pelo ID COM config carregado
  Future<Plant?> getPlantByIdWithConfig(String id) async {
    // 1. Tenta buscar pelo firebaseId (padrão)
    var plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(id)))
        .getSingleOrNull();

    // 2. Se não encontrou, tenta buscar pelo ID local (fallback para dados legados)
    if (plant == null) {
      final localId = int.tryParse(id);
      if (localId != null) {
        plant = await (_db.select(
          _db.plants,
        )..where((p) => p.id.equals(localId)))
            .getSingleOrNull();
      }
    }

    return plant != null ? _plantDriftToModelWithConfig(plant) : null;
  }

  /// Helper: Converte spaceId String (firebaseId) → INTEGER (local id)
  ///
  /// **Comportamento:**
  /// 1. Se spaceFirebaseId é null → retorna null
  /// 2. Busca space no banco pelo firebaseId → retorna space.id (local)
  /// 3. Se não encontrar, tenta int.tryParse() e VALIDA se existe com esse ID local
  /// 4. Se não encontrar nada → retorna null (evita FK constraint violation)
  Future<int?> _resolveSpaceId(String? spaceFirebaseId) async {
    if (spaceFirebaseId == null) return null;

    // 1. Busca no banco pelo firebaseId (prioridade)
    final spaceByFirebaseId = await (_db.select(
      _db.spaces,
    )..where((s) => s.firebaseId.equals(spaceFirebaseId)))
        .getSingleOrNull();

    if (spaceByFirebaseId != null) return spaceByFirebaseId.id;

    // 2. Fallback: tenta interpretar como INTEGER direto (dados legados)
    final asInt = int.tryParse(spaceFirebaseId);
    if (asInt != null) {
      // VALIDA se esse ID local existe antes de retornar
      final spaceByLocalId = await (_db.select(
        _db.spaces,
      )..where((s) => s.id.equals(asInt)))
          .getSingleOrNull();

      // Só retorna se validado (evita FK constraint violation)
      if (spaceByLocalId != null) return asInt;
    }

    // 3. Não encontrou: retorna null (FK aceita nullable)
    return null;
  }

  /// Helper: Obter ID local da planta
  Future<int?> _getLocalIdByFirebaseId(String firebaseId) async {
    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId)))
        .getSingleOrNull();

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
