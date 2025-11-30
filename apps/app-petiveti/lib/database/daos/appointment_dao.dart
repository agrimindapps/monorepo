import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/appointments_table.dart';

part 'appointment_dao.g.dart';

@DriftAccessor(tables: [Appointments])
class AppointmentDao extends DatabaseAccessor<PetivetiDatabase> with _$AppointmentDaoMixin {
  AppointmentDao(super.db);

  /// Get all appointments for a user
  Future<List<Appointment>> getAllAppointments(String userId) {
    return (select(appointments)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.appointmentDateTime)]))
      .get();
  }

  /// Get appointments by animal ID
  Future<List<Appointment>> getAppointmentsByAnimal(int animalId) {
    return (select(appointments)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.appointmentDateTime)]))
      .get();
  }

  /// Watch appointments for an animal
  Stream<List<Appointment>> watchAppointmentsByAnimal(int animalId) {
    return (select(appointments)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.appointmentDateTime)]))
      .watch();
  }

  /// Get appointment by ID
  Future<Appointment?> getAppointmentById(int id) {
    return (select(appointments)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create appointment
  Future<int> createAppointment(AppointmentsCompanion appointment) {
    return into(appointments).insert(appointment);
  }

  /// Update appointment
  Future<bool> updateAppointment(int id, AppointmentsCompanion appointment) async {
    final count = await (update(appointments)..where((tbl) => tbl.id.equals(id)))
      .write(appointment.copyWith(updatedAt: Value(DateTime.now())));
    return count > 0;
  }

  /// Delete appointment
  Future<bool> deleteAppointment(int id) async {
    final count = await (update(appointments)..where((tbl) => tbl.id.equals(id)))
      .write(AppointmentsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    return count > 0;
  }

  /// Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments(String userId) {
    final now = DateTime.now();
    return (select(appointments)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.appointmentDateTime.isBiggerOrEqualValue(now) &
        tbl.status.equals('scheduled'))
      ..orderBy([(t) => OrderingTerm.asc(t.appointmentDateTime)]))
      .get();
  }

  /// Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(String userId, String status) {
    return (select(appointments)
      ..where((tbl) => 
        tbl.userId.equals(userId) & 
        tbl.isDeleted.equals(false) &
        tbl.status.equals(status))
      ..orderBy([(t) => OrderingTerm.desc(t.appointmentDateTime)]))
      .get();
  }
}
