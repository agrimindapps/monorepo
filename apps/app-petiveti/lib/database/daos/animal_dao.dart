import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/animals_table.dart';

part 'animal_dao.g.dart';

@DriftAccessor(tables: [Animals])
class AnimalDao extends DatabaseAccessor<PetivetiDatabase> with _$AnimalDaoMixin {
  AnimalDao(PetivetiDatabase db) : super(db);

  /// Get all active animals for a user
  Future<List<Animal>> getAllAnimals(String userId) {
    return (select(animals)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  /// Get animal by ID
  Future<Animal?> getAnimalById(int id) {
    return (select(animals)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Watch all animals (for real-time updates)
  Stream<List<Animal>> watchAllAnimals(String userId) {
    return (select(animals)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
  }

  /// Watch single animal
  Stream<Animal?> watchAnimal(int id) {
    return (select(animals)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .watchSingleOrNull();
  }

  /// Create new animal
  Future<int> createAnimal(AnimalsCompanion animal) {
    return into(animals).insert(animal);
  }

  /// Update animal
  Future<bool> updateAnimal(int id, AnimalsCompanion animal) async {
    final count = await (update(animals)..where((tbl) => tbl.id.equals(id)))
      .write(animal.copyWith(updatedAt: Value(DateTime.now())));
    return count > 0;
  }

  /// Soft delete animal
  Future<bool> deleteAnimal(int id) async {
    final count = await (update(animals)..where((tbl) => tbl.id.equals(id)))
      .write(AnimalsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    return count > 0;
  }

  /// Hard delete animal (permanent)
  Future<int> hardDeleteAnimal(int id) {
    return (delete(animals)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get active animals count
  Future<int> getActiveAnimalsCount(String userId) async {
    final count = countAll();
    final query = selectOnly(animals)
      ..addColumns([count])
      ..where(animals.userId.equals(userId) & animals.isDeleted.equals(false));
    
    final result = await query.getSingleOrNull();
    return result?.read(count) ?? 0;
  }

  /// Search animals by name
  Future<List<Animal>> searchAnimals(String userId, String query) {
    return (select(animals)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.name.like('%$query%'))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();
  }
}
