import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/animals/domain/entities/sync_animal_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/animals_table.dart';

/// Adapter de sincronização para Animals
class AnimalDriftSyncAdapter extends DriftSyncAdapterBase<AnimalEntity, Animal> {
  AnimalDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'animals';

  @override
  TableInfo<Animals, Animal> get table => localDb.animals;

  @override
  Future<Either<Failure, List<AnimalEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.animals)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar animals dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.animals,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        AnimalsCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          firebaseId: firebaseId != null
              ? Value(firebaseId)
              : const Value.absent(),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar animal como sincronizado: $e'));
    }
  }

  @override
  AnimalEntity driftToEntity(Animal row) {
    return AnimalEntity(
      id: row.id.toString(),
      firebaseId: row.firebaseId,
      userId: row.userId,
      name: row.name,
      species: row.species,
      breed: row.breed ?? '',
      birthDate: row.birthDate,
      gender: row.gender,
      weight: row.weight,
      photo: row.photo,
      color: row.color,
      microchipNumber: row.microchipNumber,
      notes: row.notes,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      isCastrated: row.isCastrated,
      allergies: row.allergies,
      bloodType: row.bloodType,
      preferredVeterinarian: row.preferredVeterinarian,
      insuranceInfo: row.insuranceInfo,
      // Sync fields
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<Animal> entityToCompanion(AnimalEntity entity) {
    return AnimalsCompanion(
      id: entity.id.isNotEmpty
          ? Value(int.parse(entity.id))
          : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId ?? ''),
      name: Value(entity.name),
      species: Value(entity.species),
      breed: Value(entity.breed),
      birthDate: Value(entity.birthDate),
      gender: Value(entity.gender),
      weight: Value(entity.weight),
      photo: Value(entity.photo),
      color: Value(entity.color),
      microchipNumber: Value(entity.microchipNumber),
      notes: Value(entity.notes),
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      isDeleted: Value(entity.isDeleted),
      isCastrated: Value(entity.isCastrated),
      allergies: Value(entity.allergies),
      bloodType: Value(entity.bloodType),
      preferredVeterinarian: Value(entity.preferredVeterinarian),
      insuranceInfo: Value(entity.insuranceInfo),
      // Sync fields
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      version: Value(entity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(AnimalEntity entity) {
    return {
      'userId': entity.userId,
      'name': entity.name,
      'species': entity.species,
      'breed': entity.breed,
      'birthDate': entity.birthDate != null
          ? fs.Timestamp.fromDate(entity.birthDate!)
          : null,
      'gender': entity.gender,
      'weight': entity.weight,
      'photo': entity.photo,
      'color': entity.color,
      'microchipNumber': entity.microchipNumber,
      'notes': entity.notes,
      'isActive': entity.isActive,
      'createdAt': entity.createdAt != null 
          ? fs.Timestamp.fromDate(entity.createdAt!) 
          : fs.Timestamp.now(),
      'updatedAt': entity.updatedAt != null
          ? fs.Timestamp.fromDate(entity.updatedAt!)
          : null,
      'isDeleted': entity.isDeleted,
      'isCastrated': entity.isCastrated,
      'allergies': entity.allergies,
      'bloodType': entity.bloodType,
      'preferredVeterinarian': entity.preferredVeterinarian,
      'insuranceInfo': entity.insuranceInfo,
      'lastSyncAt': fs.Timestamp.now(),
      'version': entity.version,
    };
  }

  @override
  AnimalEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return AnimalEntity(
      id: data['localId'] as String? ?? data['id'] as String? ?? '',
      firebaseId: data['id'] as String?,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String,
      species: data['species'] as String,
      breed: data['breed'] as String? ?? '',
      birthDate: (data['birthDate'] as fs.Timestamp?)?.toDate(),
      gender: data['gender'] as String,
      weight: (data['weight'] as num?)?.toDouble(),
      photo: data['photo'] as String?,
      color: data['color'] as String?,
      microchipNumber: data['microchipNumber'] as String?,
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isCastrated: data['isCastrated'] as bool? ?? false,
      allergies: data['allergies'] as String?,
      bloodType: data['bloodType'] as String?,
      preferredVeterinarian: data['preferredVeterinarian'] as String?,
      insuranceInfo: data['insuranceInfo'] as String?,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
