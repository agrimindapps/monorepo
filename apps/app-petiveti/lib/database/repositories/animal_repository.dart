// ignore_for_file: deprecated_member_use
import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../petiveti_database.dart';
import '../tables/animals_table.dart';

/// ============================================================================
/// ANIMAL REPOSITORY - Padrão DriftRepositoryBase
/// ============================================================================
///
/// Repository de Animals usando DriftRepositoryBase do core.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos (watchAll, watchById)
/// - Queries tipadas type-safe
/// - Métodos de busca especializados
///
/// **USO:**
/// ```dart
/// final repo = AnimalRepository(database);
/// final result = await repo.getActiveAnimalsByUser(userId);
/// if (result.isSuccess) {
///   final animals = result.data!;
/// }
/// ```
/// ============================================================================

class AnimalRepository extends DriftRepositoryBase<Animal, Animals> {
  AnimalRepository(PetivetiDatabase db)
    : _db = db,
      super(database: db, table: db.animals);

  final PetivetiDatabase _db;

  @override
  String get tableName => 'animals';

  @override
  GeneratedColumn get idColumn => _db.animals.id;

  // ==================== QUERIES ESPECÍFICAS ====================

  /// Busca todos os animais ativos de um usuário
  Future<Either<Failure, List<Animal>>> getActiveAnimalsByUser(
    String userId,
  ) async {
    return findWhere(
      (t) =>
          t.userId.equals(userId) &
          t.isActive.equals(true) &
          t.isDeleted.equals(false),
    );
  }

  /// Stream de animais do usuário (reativo)
  Stream<List<Animal>> watchAnimalsByUser(String userId) {
    return (_db.select(_db.animals)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.isActive.equals(true) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Stream de um animal específico
  Stream<Animal?> watchAnimalById(int animalId) {
    return (_db.select(_db.animals)
          ..where((t) => t.id.equals(animalId) & t.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  /// Busca animais por espécie
  Future<Either<Failure, List<Animal>>> getAnimalsBySpecies(
    String userId,
    String species,
  ) async {
    return findWhere(
      (t) =>
          t.userId.equals(userId) &
          t.species.equals(species) &
          t.isDeleted.equals(false),
    );
  }

  /// Busca animais por nome (like search)
  Future<Either<Failure, List<Animal>>> searchAnimalsByName(
    String userId,
    String query,
  ) async {
    try {
      final results =
          await (_db.select(_db.animals)
                ..where(
                  (t) =>
                      t.userId.equals(userId) &
                      t.isDeleted.equals(false) &
                      t.name.like('%$query%'),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.name)]))
              .get();

      return Right(results);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Conta animais ativos do usuário
  Future<Either<Failure, int>> countActiveAnimalsByUser(String userId) async {
    try {
      final count = _db.animals.id.count();
      final query = _db.selectOnly(_db.animals)
        ..addColumns([count])
        ..where(
          _db.animals.userId.equals(userId) &
              _db.animals.isActive.equals(true) &
              _db.animals.isDeleted.equals(false),
        );

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // ==================== SOFT DELETE ====================

  /// Soft delete de animal
  Future<Either<Failure, int>> softDelete(int animalId) async {
    return updateWhere(
      (t) => t.id.equals(animalId),
      AnimalsCompanion(
        isDeleted: const Value(true),
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Restaura animal deletado
  Future<Either<Failure, int>> restore(int animalId) async {
    return updateWhere(
      (t) => t.id.equals(animalId),
      AnimalsCompanion(
        isDeleted: const Value(false),
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== HELPERS ====================

  /// Atualiza peso do animal
  Future<Either<Failure, int>> updateWeight(
    int animalId,
    double newWeight,
  ) async {
    return updateWhere(
      (t) => t.id.equals(animalId),
      AnimalsCompanion(
        weight: Value(newWeight),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Atualiza foto do animal
  Future<Either<Failure, int>> updatePhoto(
    int animalId,
    String photoPath,
  ) async {
    return updateWhere(
      (t) => t.id.equals(animalId),
      AnimalsCompanion(
        photo: Value(photoPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
