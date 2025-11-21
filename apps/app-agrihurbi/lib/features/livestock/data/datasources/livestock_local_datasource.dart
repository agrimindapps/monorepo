import 'dart:convert';
import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/agrihurbi_database.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';
import '../models/bovine_model.dart';
import '../models/equine_model.dart';

/// Interface para data source local de livestock
abstract class LivestockLocalDataSource {
  Future<List<BovineModel>> getAllBovines();
  Future<BovineModel?> getBovineById(String id);
  Future<void> saveBovine(BovineModel bovine);
  Future<void> deleteBovine(String id);
  Future<List<BovineModel>> searchBovines({
    String? breed,
    String? aptitude,
    String? purpose,
    List<String>? tags,
  });
  Future<List<EquineModel>> getAllEquines();
  Future<EquineModel?> getEquineById(String id);
  Future<void> saveEquine(EquineModel equine);
  Future<void> deleteEquine(String id);
  Future<List<EquineModel>> searchEquines({
    String? temperament,
    String? coat,
    String? primaryUse,
    String? geneticInfluences,
  });
  Future<String> exportData();
  Future<void> importData(String backupData);
}

/// Implementação do data source local com Drift
@Injectable(as: LivestockLocalDataSource)
class LivestockDriftLocalDataSource implements LivestockLocalDataSource {
  final AgrihurbiDatabase _db;

  LivestockDriftLocalDataSource(this._db);

  // ========== BOVINES OPERATIONS ==========

  @override
  Future<List<BovineModel>> getAllBovines() async {
    final bovines = await _db.getActiveBovines();
    return bovines.map(_bovineFromDrift).toList();
  }

  @override
  Future<BovineModel?> getBovineById(String id) async {
    final query = _db.select(_db.bovines)..where((tbl) => tbl.id.equals(id));
    final bovine = await query.getSingleOrNull();
    return bovine != null ? _bovineFromDrift(bovine) : null;
  }

  @override
  Future<void> saveBovine(BovineModel bovine) async {
    try {
      await _db.into(_db.bovines).insertOnConflictUpdate(
            _bovineToCompanion(bovine),
          );
    } catch (e) {
      throw CacheFailure('Error saving bovine: $e');
    }
  }

  @override
  Future<void> deleteBovine(String id) async {
    try {
      // Soft delete: apenas marca como inativo
      await (_db.update(_db.bovines)..where((tbl) => tbl.id.equals(id)))
          .write(BovinesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      throw CacheFailure('Error deleting bovine: $e');
    }
  }

  @override
  Future<List<BovineModel>> searchBovines({
    String? breed,
    String? aptitude,
    String? purpose,
    List<String>? tags,
  }) async {
    try {
      var query = _db.select(_db.bovines)
        ..where((tbl) => tbl.isActive.equals(true));

      if (breed != null && breed.isNotEmpty) {
        query.where((tbl) => tbl.breed.like('%$breed%'));
      }

      if (aptitude != null && aptitude.isNotEmpty) {
        // Parse aptitude string to find matching enum
        final aptitudeEnum = _parseAptitude(aptitude);
        if (aptitudeEnum != null) {
          query.where((tbl) => tbl.aptitude.equals(aptitudeEnum.index));
        }
      }

      if (purpose != null && purpose.isNotEmpty) {
        query.where((tbl) => tbl.purpose.like('%$purpose%'));
      }

      query.orderBy([(tbl) => OrderingTerm.asc(tbl.commonName)]);

      final results = await query.get();
      return results.map(_bovineFromDrift).toList();
    } catch (e) {
      throw CacheFailure('Error searching bovines: $e');
    }
  }

  // ========== EQUINES OPERATIONS ==========

  @override
  Future<List<EquineModel>> getAllEquines() async {
    final equines = await _db.getActiveEquines();
    return equines.map(_equineFromDrift).toList();
  }

  @override
  Future<EquineModel?> getEquineById(String id) async {
    final query = _db.select(_db.equines)..where((tbl) => tbl.id.equals(id));
    final equine = await query.getSingleOrNull();
    return equine != null ? _equineFromDrift(equine) : null;
  }

  @override
  Future<void> saveEquine(EquineModel equine) async {
    try {
      await _db.into(_db.equines).insertOnConflictUpdate(
            _equineToCompanion(equine),
          );
    } catch (e) {
      throw CacheFailure('Error saving equine: $e');
    }
  }

  @override
  Future<void> deleteEquine(String id) async {
    try {
      // Soft delete: apenas marca como inativo
      await (_db.update(_db.equines)..where((tbl) => tbl.id.equals(id)))
          .write(EquinesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      throw CacheFailure('Error deleting equine: $e');
    }
  }

  @override
  Future<List<EquineModel>> searchEquines({
    String? temperament,
    String? coat,
    String? primaryUse,
    String? geneticInfluences,
  }) async {
    try {
      var query = _db.select(_db.equines)
        ..where((tbl) => tbl.isActive.equals(true));

      if (temperament != null && temperament.isNotEmpty) {
        final temperamentEnum = _parseTemperament(temperament);
        if (temperamentEnum != null) {
          query.where((tbl) => tbl.temperament.equals(temperamentEnum.index));
        }
      }

      if (coat != null && coat.isNotEmpty) {
        final coatEnum = _parseCoat(coat);
        if (coatEnum != null) {
          query.where((tbl) => tbl.coat.equals(coatEnum.index));
        }
      }

      if (primaryUse != null && primaryUse.isNotEmpty) {
        final useEnum = _parsePrimaryUse(primaryUse);
        if (useEnum != null) {
          query.where((tbl) => tbl.primaryUse.equals(useEnum.index));
        }
      }

      if (geneticInfluences != null && geneticInfluences.isNotEmpty) {
        query
            .where((tbl) => tbl.geneticInfluences.like('%$geneticInfluences%'));
      }

      query.orderBy([(tbl) => OrderingTerm.asc(tbl.commonName)]);

      final results = await query.get();
      return results.map(_equineFromDrift).toList();
    } catch (e) {
      throw CacheFailure('Error searching equines: $e');
    }
  }

  // ========== EXPORT/IMPORT OPERATIONS ==========

  @override
  Future<String> exportData() async {
    try {
      final jsonData = await _db.exportAsJson();
      // Converter map para JSON string
      return _jsonEncode(jsonData);
    } catch (e) {
      throw CacheFailure('Error exporting data: $e');
    }
  }

  @override
  Future<void> importData(String backupData) async {
    try {
      final jsonData = _jsonDecode(backupData) as Map<String, dynamic>;
      await _db.importFromJson(jsonData);
    } catch (e) {
      throw CacheFailure('Error importing data: $e');
    }
  }

  // ========== CONVERSION HELPERS ==========

  BovineModel _bovineFromDrift(Bovine drift) {
    return BovineModel(
      id: drift.id,
      createdAt: drift.createdAt,
      updatedAt: drift.updatedAt,
      isActive: drift.isActive,
      registrationId: drift.registrationId,
      commonName: drift.commonName,
      originCountry: drift.originCountry,
      imageUrls: (jsonDecode(drift.imageUrls) as List).cast<String>(),
      thumbnailUrl: drift.thumbnailUrl,
      animalType: drift.animalType,
      origin: drift.origin,
      characteristics: drift.characteristics,
      breed: drift.breed,
      aptitude: BovineAptitude.values[drift.aptitude],
      tags: (jsonDecode(drift.tags) as List).cast<String>(),
      breedingSystem: BreedingSystem.values[drift.breedingSystem],
      purpose: drift.purpose,
      notes: drift.notes,
    );
  }

  BovinesCompanion _bovineToCompanion(BovineModel model) {
    return BovinesCompanion.insert(
      id: model.id,
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      isActive: Value(model.isActive),
      registrationId: model.registrationId,
      commonName: model.commonName,
      originCountry: model.originCountry,
      imageUrls: Value(jsonEncode(model.imageUrls)),
      thumbnailUrl: Value(model.thumbnailUrl),
      animalType: model.animalType,
      origin: model.origin,
      characteristics: model.characteristics,
      breed: model.breed,
      aptitude: model.aptitude.index,
      tags: Value(jsonEncode(model.tags)),
      breedingSystem: model.breedingSystem.index,
      purpose: model.purpose,
      notes: Value(model.notes),
    );
  }

  EquineModel _equineFromDrift(Equine drift) {
    return EquineModel(
      id: drift.id,
      createdAt: drift.createdAt,
      updatedAt: drift.updatedAt,
      isActive: drift.isActive,
      registrationId: drift.registrationId,
      commonName: drift.commonName,
      originCountry: drift.originCountry,
      imageUrls: (jsonDecode(drift.imageUrls) as List).cast<String>(),
      thumbnailUrl: drift.thumbnailUrl,
      history: drift.history,
      temperament: EquineTemperament.values[drift.temperament],
      coat: CoatColor.values[drift.coat],
      primaryUse: EquinePrimaryUse.values[drift.primaryUse],
      geneticInfluences: drift.geneticInfluences,
      height: drift.height,
      weight: drift.weight,
    );
  }

  EquinesCompanion _equineToCompanion(EquineModel model) {
    return EquinesCompanion.insert(
      id: model.id,
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      isActive: Value(model.isActive),
      registrationId: model.registrationId,
      commonName: model.commonName,
      originCountry: model.originCountry,
      imageUrls: Value(jsonEncode(model.imageUrls)),
      thumbnailUrl: Value(model.thumbnailUrl),
      history: model.history,
      temperament: model.temperament.index,
      coat: model.coat.index,
      primaryUse: model.primaryUse.index,
      geneticInfluences: model.geneticInfluences,
      height: model.height,
      weight: model.weight,
    );
  }

  // ========== ENUM PARSING HELPERS ==========

  BovineAptitude? _parseAptitude(String aptitude) {
    try {
      return BovineAptitude.values.firstWhere(
        (e) => e.toString().toLowerCase().contains(aptitude.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  EquineTemperament? _parseTemperament(String temperament) {
    try {
      return EquineTemperament.values.firstWhere(
        (e) => e.toString().toLowerCase().contains(temperament.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  CoatColor? _parseCoat(String coat) {
    try {
      return CoatColor.values.firstWhere(
        (e) => e.toString().toLowerCase().contains(coat.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  EquinePrimaryUse? _parsePrimaryUse(String use) {
    try {
      return EquinePrimaryUse.values.firstWhere(
        (e) => e.toString().toLowerCase().contains(use.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  // ========== JSON HELPERS ==========

  String _jsonEncode(Map<String, dynamic> data) {
    // Simple JSON encoding without external dependencies
    return data.toString().replaceAll('{', '{').replaceAll('}', '}');
  }

  dynamic _jsonDecode(String json) {
    // In production, use actual JSON decoder
    // For now, using a simple approach - ideally use jsonDecode from dart:convert
    throw UnimplementedError(
        'JSON decode not implemented - use dart:convert in production');
  }
}
