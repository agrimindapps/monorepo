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
    // Query com LEFT JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(_db.plants.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.plants.createdAt)]);

    final results = await query.get();

    return results.map((row) {
      final plant = row.readTable(_db.plants);
      final space = row.readTableOrNull(_db.spaces);
      return _plantDriftToModelWithSpace(plant, space?.firebaseId);
    }).toList();
  }

  /// Retorna planta pelo firebaseId ou ID local
  Future<Plant?> getPlantById(String id) async {
    // Query com LEFT JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ]);

    // 1. Tenta buscar pelo firebaseId (padrão)
    query.where(_db.plants.firebaseId.equals(id));
    var result = await query.getSingleOrNull();

    // 2. Se não encontrou, tenta buscar pelo ID local (fallback para dados legados)
    if (result == null) {
      final localId = int.tryParse(id);
      if (localId != null) {
        final queryById = _db.select(_db.plants).join([
          leftOuterJoin(
            _db.spaces,
            _db.spaces.id.equalsExp(_db.plants.spaceId),
          ),
        ])
          ..where(_db.plants.id.equals(localId));
        result = await queryById.getSingleOrNull();
      }
    }

    if (result == null) return null;

    final plant = result.readTable(_db.plants);
    final space = result.readTableOrNull(_db.spaces);
    return _plantDriftToModelWithSpace(plant, space?.firebaseId);
  }

  /// Retorna plantas de um espaço específico
  Future<List<Plant>> getPlantsBySpace(String spaceFirebaseId) async {
    final localSpaceId = await _resolveSpaceId(spaceFirebaseId);
    if (localSpaceId == null) return [];

    // Query com JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(
        _db.plants.spaceId.equals(localSpaceId) &
            _db.plants.isDeleted.equals(false),
      )
      ..orderBy([OrderingTerm.asc(_db.plants.name)]);

    final results = await query.get();

    return results.map((row) {
      final plant = row.readTable(_db.plants);
      final space = row.readTableOrNull(_db.spaces);
      return _plantDriftToModelWithSpace(plant, space?.firebaseId);
    }).toList();
  }

  /// Busca plantas por query (nome, espécie, notas)
  Future<List<Plant>> searchPlants(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';

    // Query com LEFT JOIN para obter o firebaseId do espaço
    final joinQuery = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(
        _db.plants.isDeleted.equals(false) &
            (_db.plants.name.lower().like(searchTerm) |
                _db.plants.species.lower().like(searchTerm) |
                _db.plants.notes.lower().like(searchTerm)),
      )
      ..orderBy([OrderingTerm.asc(_db.plants.name)]);

    final results = await joinQuery.get();

    return results.map((row) {
      final plant = row.readTable(_db.plants);
      final space = row.readTableOrNull(_db.spaces);
      return _plantDriftToModelWithSpace(plant, space?.firebaseId);
    }).toList();
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
    // Query com LEFT JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(_db.plants.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.plants.createdAt)]);

    return query.watch().map((results) {
      return results.map((row) {
        final plant = row.readTable(_db.plants);
        final space = row.readTableOrNull(_db.spaces);
        return _plantDriftToModelWithSpace(plant, space?.firebaseId);
      }).toList();
    });
  }

  /// Watch planta específica
  Stream<Plant?> watchPlantById(String firebaseId) {
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(_db.plants.firebaseId.equals(firebaseId));

    return query.watchSingleOrNull().map((result) {
      if (result == null) return null;
      final plant = result.readTable(_db.plants);
      final space = result.readTableOrNull(_db.spaces);
      return _plantDriftToModelWithSpace(plant, space?.firebaseId);
    });
  }

  /// Watch plantas de um espaço
  Stream<List<Plant>> watchPlantsBySpace(String spaceFirebaseId) {
    return Stream.fromFuture(_resolveSpaceId(spaceFirebaseId)).asyncExpand((
      localSpaceId,
    ) {
      if (localSpaceId == null) {
        return Stream.value(<Plant>[]);
      }

      final query = _db.select(_db.plants).join([
        leftOuterJoin(
          _db.spaces,
          _db.spaces.id.equalsExp(_db.plants.spaceId),
        ),
      ])
        ..where(
          _db.plants.spaceId.equals(localSpaceId) &
              _db.plants.isDeleted.equals(false),
        )
        ..orderBy([OrderingTerm.asc(_db.plants.name)]);

      return query.watch().map((results) {
        return results.map((row) {
          final plant = row.readTable(_db.plants);
          final space = row.readTableOrNull(_db.spaces);
          return _plantDriftToModelWithSpace(plant, space?.firebaseId);
        }).toList();
      });
    });
  }

  // ==================== SYNC HELPERS ====================

  /// Retorna plantas dirty
  Future<List<Plant>> getDirtyPlants() async {
    // Query com LEFT JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(_db.plants.isDirty.equals(true));

    final results = await query.get();

    return results.map((row) {
      final plant = row.readTable(_db.plants);
      final space = row.readTableOrNull(_db.spaces);
      return _plantDriftToModelWithSpace(plant, space?.firebaseId);
    }).toList();
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

  /// Converte Drift Plant → PlantModel com spaceId já resolvido
  PlantModel _plantDriftToModelWithSpace(db.Plant plant, String? spaceFirebaseId) {
    // Parse imageUrls CSV
    final imageUrls = plant.imageUrls != null && plant.imageUrls!.isNotEmpty
        ? plant.imageUrls!.split(',')
        : <String>[];

    return PlantModel(
      id: plant.firebaseId ?? plant.id.toString(),
      name: plant.name,
      species: plant.species,
      spaceId: spaceFirebaseId, // Usar firebaseId do espaço
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

  /// Converte Drift Plant → PlantModel COM config carregado e spaceId resolvido
  Future<PlantModel> _plantDriftToModelWithConfigAndSpace(
    db.Plant plant,
    String? spaceFirebaseId,
  ) async {
    final model = _plantDriftToModelWithSpace(plant, spaceFirebaseId);

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
    // Query com LEFT JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ])
      ..where(_db.plants.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_db.plants.createdAt)]);

    final results = await query.get();

    return Future.wait(results.map((row) {
      final plant = row.readTable(_db.plants);
      final space = row.readTableOrNull(_db.spaces);
      return _plantDriftToModelWithConfigAndSpace(plant, space?.firebaseId);
    }));
  }

  /// Retorna planta pelo ID COM config carregado
  Future<Plant?> getPlantByIdWithConfig(String id) async {
    // Query com LEFT JOIN para obter o firebaseId do espaço
    final query = _db.select(_db.plants).join([
      leftOuterJoin(
        _db.spaces,
        _db.spaces.id.equalsExp(_db.plants.spaceId),
      ),
    ]);

    // 1. Tenta buscar pelo firebaseId (padrão)
    query.where(_db.plants.firebaseId.equals(id));
    var result = await query.getSingleOrNull();

    // 2. Se não encontrou, tenta buscar pelo ID local (fallback para dados legados)
    if (result == null) {
      final localId = int.tryParse(id);
      if (localId != null) {
        final queryById = _db.select(_db.plants).join([
          leftOuterJoin(
            _db.spaces,
            _db.spaces.id.equalsExp(_db.plants.spaceId),
          ),
        ])
          ..where(_db.plants.id.equals(localId));
        result = await queryById.getSingleOrNull();
      }
    }

    if (result == null) return null;

    final plant = result.readTable(_db.plants);
    final space = result.readTableOrNull(_db.spaces);
    return _plantDriftToModelWithConfigAndSpace(plant, space?.firebaseId);
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

  /// Obtém o ID local de uma planta pelo firebaseId
  /// 
  /// Útil para operações que precisam do ID local do Drift,
  /// como salvar imagens na tabela PlantImages
  Future<int?> getLocalIdByFirebaseId(String firebaseId) async {
    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(firebaseId)))
        .getSingleOrNull();

    return plant?.id;
  }

  /// Helper: Obter ID local da planta (privado)
  Future<int?> _getLocalIdByFirebaseId(String firebaseId) async {
    return getLocalIdByFirebaseId(firebaseId);
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
