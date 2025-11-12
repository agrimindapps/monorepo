import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../core/data/models/planta_config_model.dart';
import '../plantis_database.dart' as db;

/// Repository Drift para PlantConfigs (configurações de cuidados - 1:1 com Plants)
@lazySingleton
class PlantConfigsDriftRepository {
  final db.PlantisDatabase _db;

  PlantConfigsDriftRepository(this._db);

  Future<int> insertConfig(PlantaConfigModel model) async {
    final localPlantId = await _resolvePlantId(model.plantaId);
    if (localPlantId == null) {
      throw CacheFailure('Plant not found for plantaId: ${model.plantaId}');
    }

    final companion = db.PlantConfigsCompanion.insert(
      firebaseId: Value(model.id),
      plantId: localPlantId,
      aguaAtiva: Value(model.aguaAtiva),
      intervaloRegaDias: Value(model.intervaloRegaDias),
      aduboAtivo: Value(model.aduboAtivo),
      intervaloAdubacaoDias: Value(model.intervaloAdubacaoDias),
      banhoSolAtivo: Value(model.banhoSolAtivo),
      intervaloBanhoSolDias: Value(model.intervaloBanhoSolDias),
      inspecaoPragasAtiva: Value(model.inspecaoPragasAtiva),
      intervaloInspecaoPragasDias: Value(model.intervaloInspecaoPragasDias),
      podaAtiva: Value(model.podaAtiva),
      intervaloPodaDias: Value(model.intervaloPodaDias),
      replantarAtivo: Value(model.replantarAtivo),
      intervaloReplantarDias: Value(model.intervaloReplantarDias),
      createdAt: Value(model.createdAt ?? DateTime.now()),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      lastSyncAt: Value(model.lastSyncAt),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      userId: Value(model.userId),
      moduleName: Value(model.moduleName ?? 'plantis'),
    );

    return await _db.into(_db.plantConfigs).insert(companion);
  }

  Future<PlantaConfigModel?> getConfigByPlantId(String plantFirebaseId) async {
    final localPlantId = await _resolvePlantId(plantFirebaseId);
    if (localPlantId == null) return null;

    final config = await (_db.select(
      _db.plantConfigs,
    )..where((c) => c.plantId.equals(localPlantId))).getSingleOrNull();

    return config != null ? _configDriftToModel(config) : null;
  }

  Future<bool> updateConfig(PlantaConfigModel model) async {
    final localPlantId = await _resolvePlantId(model.plantaId);
    if (localPlantId == null) return false;

    final updated =
        await (_db.update(
          _db.plantConfigs,
        )..where((c) => c.plantId.equals(localPlantId))).write(
          db.PlantConfigsCompanion(
            aguaAtiva: Value(model.aguaAtiva),
            intervaloRegaDias: Value(model.intervaloRegaDias),
            aduboAtivo: Value(model.aduboAtivo),
            intervaloAdubacaoDias: Value(model.intervaloAdubacaoDias),
            banhoSolAtivo: Value(model.banhoSolAtivo),
            intervaloBanhoSolDias: Value(model.intervaloBanhoSolDias),
            inspecaoPragasAtiva: Value(model.inspecaoPragasAtiva),
            intervaloInspecaoPragasDias: Value(
              model.intervaloInspecaoPragasDias,
            ),
            podaAtiva: Value(model.podaAtiva),
            intervaloPodaDias: Value(model.intervaloPodaDias),
            replantarAtivo: Value(model.replantarAtivo),
            intervaloReplantarDias: Value(model.intervaloReplantarDias),
            updatedAt: Value(DateTime.now()),
            isDirty: Value(model.isDirty),
          ),
        );

    return updated > 0;
  }

  PlantaConfigModel _configDriftToModel(db.PlantConfig config) {
    return PlantaConfigModel(
      id: config.firebaseId ?? config.id.toString(),
      plantaId: config.plantId.toString(),
      aguaAtiva: config.aguaAtiva,
      intervaloRegaDias: config.intervaloRegaDias,
      aduboAtivo: config.aduboAtivo,
      intervaloAdubacaoDias: config.intervaloAdubacaoDias,
      banhoSolAtivo: config.banhoSolAtivo,
      intervaloBanhoSolDias: config.intervaloBanhoSolDias,
      inspecaoPragasAtiva: config.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: config.intervaloInspecaoPragasDias,
      podaAtiva: config.podaAtiva,
      intervaloPodaDias: config.intervaloPodaDias,
      replantarAtivo: config.replantarAtivo,
      intervaloReplantarDias: config.intervaloReplantarDias,
      createdAtMs: config.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: config.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs: config.lastSyncAt?.millisecondsSinceEpoch,
      isDirty: config.isDirty,
      isDeleted: config.isDeleted,
      version: config.version,
      userId: config.userId,
      moduleName: config.moduleName,
    );
  }

  Future<int?> _resolvePlantId(String? plantFirebaseId) async {
    if (plantFirebaseId == null) return null;
    final asInt = int.tryParse(plantFirebaseId);
    if (asInt != null) return asInt;

    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(plantFirebaseId))).getSingleOrNull();
    return plant?.id;
  }
}
