import 'package:drift/drift.dart';

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
    // Map status text to int
    int statusInt = 0; // default to scheduled
    switch (appointment.status) {
      case 'completed':
        statusInt = 1;
        break;
      case 'cancelled':
        statusInt = 2;
        break;
      case 'inProgress':
        statusInt = 3;
        break;
      default:
        statusInt = 0; // scheduled
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
      cost: appointment.cost,
      createdAtTimestamp: appointment.createdAt.millisecondsSinceEpoch,
      updatedAtTimestamp: appointment.updatedAt?.millisecondsSinceEpoch,
      isDeleted: appointment.isDeleted,
    );
  }

  AppointmentsCompanion _toCompanion(
    AppointmentModel model, {
    bool forUpdate = false,
  }) {
    // Map status int to text
    String statusText;
    switch (model.status) {
      case 1:
        statusText = 'completed';
        break;
      case 2:
        statusText = 'cancelled';
        break;
      case 3:
        statusText = 'inProgress';
        break;
      default:
        statusText = 'scheduled';
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
        location: const Value.absent(),
        notes: Value.absentIfNull(model.notes),
        status: Value(statusText),
        cost: Value.absentIfNull(model.cost),
        userId: const Value.absent(),
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
      location: const Value.absent(),
      notes: Value.absentIfNull(model.notes),
      status: statusText,
      cost: Value.absentIfNull(model.cost),
      userId: '',
      createdAt: Value(
        DateTime.fromMillisecondsSinceEpoch(model.createdAtTimestamp),
      ),
    );
  }
}
