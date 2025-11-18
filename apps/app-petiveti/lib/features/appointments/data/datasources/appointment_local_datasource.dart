import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart';
import '../models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments(String userId);
  Future<List<AppointmentModel>> getAppointmentsByAnimalId(int animalId);
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId);
  Future<List<AppointmentModel>> getAppointmentsByStatus(
    String userId,
    String status,
  );
  Future<AppointmentModel?> getAppointmentById(int id);
  Future<int> addAppointment(AppointmentModel appointment);
  Future<bool> updateAppointment(AppointmentModel appointment);
  Future<bool> deleteAppointment(int id);
  Stream<List<AppointmentModel>> watchAppointmentsByAnimalId(int animalId);
}

@LazySingleton(as: AppointmentLocalDataSource)
class AppointmentLocalDataSourceImpl implements AppointmentLocalDataSource {
  final PetivetiDatabase _database;

  AppointmentLocalDataSourceImpl(this._database);

  @override
  Future<List<AppointmentModel>> getAppointments(String userId) async {
    final appointments = await _database.appointmentDao.getAllAppointments(
      userId,
    );
    return appointments.map(_toModel).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByAnimalId(int animalId) async {
    final appointments = await _database.appointmentDao.getAppointmentsByAnimal(
      animalId,
    );
    return appointments.map(_toModel).toList();
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId) async {
    final appointments = await _database.appointmentDao.getUpcomingAppointments(
      userId,
    );
    return appointments.map(_toModel).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByStatus(
    String userId,
    String status,
  ) async {
    final appointments = await _database.appointmentDao.getAppointmentsByStatus(
      userId,
      status,
    );
    return appointments.map(_toModel).toList();
  }

  @override
  Future<AppointmentModel?> getAppointmentById(int id) async {
    final appointment = await _database.appointmentDao.getAppointmentById(id);
    return appointment != null ? _toModel(appointment) : null;
  }

  @override
  Future<int> addAppointment(AppointmentModel appointment) async {
    final companion = _toCompanion(appointment);
    return await _database.appointmentDao.createAppointment(companion);
  }

  @override
  Future<bool> updateAppointment(AppointmentModel appointment) async {
    if (appointment.id == null) return false;
    final companion = _toCompanion(appointment, forUpdate: true);
    return await _database.appointmentDao.updateAppointment(
      appointment.id!,
      companion,
    );
  }

  @override
  Future<bool> deleteAppointment(int id) async {
    return await _database.appointmentDao.deleteAppointment(id);
  }

  @override
  Stream<List<AppointmentModel>> watchAppointmentsByAnimalId(int animalId) {
    return _database.appointmentDao
        .watchAppointmentsByAnimal(animalId)
        .map((appointments) => appointments.map(_toModel).toList());
  }

  AppointmentModel _toModel(Appointment appointment) {
    // Map Drift Appointment to AppointmentModel
    // Drift: title -> Model: reason
    // Drift: description -> Model: diagnosis
    // Drift: appointmentDateTime -> Model: dateTimestamp
    // Drift: veterinarian -> Model: veterinarianName
    // Drift: status (text) -> Model: status (int)

    int statusInt = 0; // default to scheduled
    if (appointment.status == 'completed') {
      statusInt = 1;
    } else if (appointment.status == 'cancelled') {
      statusInt = 2;
    }

    return AppointmentModel(
      id: appointment.id,
      animalId: appointment.animalId,
      veterinarianName: appointment.veterinarian ?? '',
      dateTimestamp: appointment.appointmentDateTime.millisecondsSinceEpoch,
      reason: appointment.title,
      diagnosis: appointment.description,
      notes: appointment.notes,
      status: statusInt,
      cost: null, // Not stored in Drift table yet
      createdAtTimestamp: appointment.createdAt.millisecondsSinceEpoch,
      updatedAtTimestamp: appointment.updatedAt?.millisecondsSinceEpoch,
      isDeleted: appointment.isDeleted,
    );
  }

  AppointmentsCompanion _toCompanion(
    AppointmentModel model, {
    bool forUpdate = false,
  }) {
    // Map AppointmentModel to Drift Companion
    // Model: reason -> Drift: title
    // Model: diagnosis -> Drift: description
    // Model: dateTimestamp -> Drift: appointmentDateTime
    // Model: veterinarianName -> Drift: veterinarian
    // Model: status (int) -> Drift: status (text)

    String statusText = 'scheduled';
    if (model.status == 1) {
      statusText = 'completed';
    } else if (model.status == 2) {
      statusText = 'cancelled';
    }

    final dateTime = DateTime.fromMillisecondsSinceEpoch(model.dateTimestamp);

    if (forUpdate) {
      return AppointmentsCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        animalId: Value(model.animalId),
        title: Value(model.reason),
        description: Value.absentIfNull(model.diagnosis),
        appointmentDateTime: Value(dateTime),
        veterinarian: Value.absentIfNull(
          model.veterinarianName.isEmpty ? null : model.veterinarianName,
        ),
        location: const Value.absent(), // Not in new model
        notes: Value.absentIfNull(model.notes),
        status: Value(statusText),
        userId: const Value.absent(), // Will be set by repository/service
        updatedAt: Value(DateTime.now()),
      );
    }

    return AppointmentsCompanion.insert(
      animalId: model.animalId,
      title: model.reason,
      description: Value.absentIfNull(model.diagnosis),
      appointmentDateTime: dateTime,
      veterinarian: Value.absentIfNull(
        model.veterinarianName.isEmpty ? null : model.veterinarianName,
      ),
      location: const Value.absent(), // Not in new model
      notes: Value.absentIfNull(model.notes),
      status: statusText,
      userId: '', // Will be set by repository/service
      createdAt: Value(
        DateTime.fromMillisecondsSinceEpoch(model.createdAtTimestamp),
      ),
    );
  }
}
