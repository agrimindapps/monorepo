import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/reminders_table.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<PetivetiDatabase> with _$ReminderDaoMixin {
  ReminderDao(PetivetiDatabase db) : super(db);

  /// Get all reminders for a user
  Future<List<Reminder>> getAllReminders(String userId) {
    return (select(reminders)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.dateTime)]))
      .get();
  }

  /// Get reminders by animal ID
  Future<List<Reminder>> getRemindersByAnimal(int animalId) {
    return (select(reminders)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.dateTime)]))
      .get();
  }

  /// Watch reminders for an animal
  Stream<List<Reminder>> watchRemindersByAnimal(int animalId) {
    return (select(reminders)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.dateTime)]))
      .watch();
  }

  /// Get reminder by ID
  Future<Reminder?> getReminderById(int id) {
    return (select(reminders)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create reminder
  Future<int> createReminder(RemindersCompanion reminder) {
    return into(reminders).insert(reminder);
  }

  /// Update reminder
  Future<bool> updateReminder(int id, RemindersCompanion reminder) async {
    return (update(reminders)..where((tbl) => tbl.id.equals(id))).write(reminder);
  }

  /// Delete reminder
  Future<bool> deleteReminder(int id) async {
    return (update(reminders)..where((tbl) => tbl.id.equals(id)))
      .write(const RemindersCompanion(isDeleted: Value(true)));
  }

  /// Get active (not completed) reminders
  Future<List<Reminder>> getActiveReminders(String userId) {
    return (select(reminders)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.isCompleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.dateTime)]))
      .get();
  }

  /// Get upcoming reminders (active and in the future)
  Future<List<Reminder>> getUpcomingReminders(String userId) {
    final now = DateTime.now();
    return (select(reminders)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.isCompleted.equals(false) &
        tbl.dateTime.isBiggerOrEqualValue(now))
      ..orderBy([(t) => OrderingTerm.asc(t.dateTime)]))
      .get();
  }

  /// Mark reminder as completed
  Future<bool> markAsCompleted(int id) async {
    return (update(reminders)..where((tbl) => tbl.id.equals(id)))
      .write(const RemindersCompanion(isCompleted: Value(true)));
  }
}
