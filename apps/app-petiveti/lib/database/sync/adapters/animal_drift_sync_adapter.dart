import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/animals/domain/entities/sync_animal_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/animals_table.dart';

/// Adapter de sincronização para Animals
/// Usa dynamic para burlar type constraint do DriftSyncAdapterBase
class AnimalDriftSyncAdapter extends DriftSyncAdapterBase<dynamic, Animal> {
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
  Insertable<Animal> entityToCompanion(dynamic entity) {
    final animalEntity = entity as AnimalEntity;
    return AnimalsCompanion(
      id: animalEntity.id != null && animalEntity.id!.isNotEmpty
          ? Value(int.parse(animalEntity.id!))
          : const Value.absent(),
      firebaseId: Value(animalEntity.firebaseId),
      userId: Value(animalEntity.userId),
      name: Value(animalEntity.name),
      species: Value(animalEntity.species),
      breed: Value(animalEntity.breed),
      birthDate: Value(animalEntity.birthDate),
      gender: Value(animalEntity.gender),
      weight: Value(animalEntity.weight),
      photo: Value(animalEntity.photo),
      color: Value(animalEntity.color),
      microchipNumber: Value(animalEntity.microchipNumber),
      notes: Value(animalEntity.notes),
      isActive: Value(animalEntity.isActive),
      createdAt: Value(animalEntity.createdAt),
      updatedAt: Value(animalEntity.updatedAt),
      isDeleted: Value(animalEntity.isDeleted),
      isCastrated: Value(animalEntity.isCastrated),
      allergies: Value(animalEntity.allergies),
      bloodType: Value(animalEntity.bloodType),
      preferredVeterinarian: Value(animalEntity.preferredVeterinarian),
      insuranceInfo: Value(animalEntity.insuranceInfo),
      // Sync fields
      lastSyncAt: Value(animalEntity.lastSyncAt),
      isDirty: Value(animalEntity.isDirty),
      version: Value(animalEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final animalEntity = entity as AnimalEntity;
    return {
      'userId': animalEntity.userId,
      'name': animalEntity.name,
      'species': animalEntity.species,
      'breed': animalEntity.breed,
      'birthDate': animalEntity.birthDate != null
          ? fs.Timestamp.fromDate(animalEntity.birthDate!)
          : null,
      'gender': animalEntity.gender,
      'weight': animalEntity.weight,
      'photo': animalEntity.photo,
      'color': animalEntity.color,
      'microchipNumber': animalEntity.microchipNumber,
      'notes': animalEntity.notes,
      'isActive': animalEntity.isActive,
      'createdAt': fs.Timestamp.fromDate(animalEntity.createdAt),
      'updatedAt': animalEntity.updatedAt != null
          ? fs.Timestamp.fromDate(animalEntity.updatedAt!)
          : null,
      'isDeleted': animalEntity.isDeleted,
      'isCastrated': animalEntity.isCastrated,
      'allergies': animalEntity.allergies,
      'bloodType': animalEntity.bloodType,
      'preferredVeterinarian': animalEntity.preferredVeterinarian,
      'insuranceInfo': animalEntity.insuranceInfo,
      'lastSyncAt': fs.Timestamp.now(),
      'version': animalEntity.version,
    };
  }

  @override
  AnimalEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return AnimalEntity(
      id: null, // Will be set by local DB
      firebaseId: data['id'] as String?,
      userId: data['userId'] as String,
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
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
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
