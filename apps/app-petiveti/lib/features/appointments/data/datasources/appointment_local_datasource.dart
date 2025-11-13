import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart';
import '../models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments(String userId);
  Future<List<AppointmentModel>> getAppointmentsByAnimalId(int animalId);
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId);
  Future<List<AppointmentModel>> getAppointmentsByStatus(String userId, String status);
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
    final appointments = await _database.appointmentDao.getAllAppointments(userId);
    return appointments.map(_toModel).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByAnimalId(int animalId) async {
    final appointments = await _database.appointmentDao.getAppointmentsByAnimal(animalId);
    return appointments.map(_toModel).toList();
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId) async {
    final appointments = await _database.appointmentDao.getUpcomingAppointments(userId);
    return appointments.map(_toModel).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByStatus(String userId, String status) async {
    final appointments = await _database.appointmentDao.getAppointmentsByStatus(userId, status);
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
    return await _database.appointmentDao.updateAppointment(int.parse(appointment.id!), companion);
  }

  @override
  Future<bool> deleteAppointment(int id) async {
    return await _database.appointmentDao.deleteAppointment(id);
  }

  @override
  Stream<List<AppointmentModel>> watchAppointmentsByAnimalId(int animalId) {
    return _database.appointmentDao.watchAppointmentsByAnimal(animalId)
        .map((appointments) => appointments.map(_toModel).toList());
  }

  AppointmentModel _toModel(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id.toString(),
      animalId: appointment.animalId.toString(),
      title: appointment.title,
      description: appointment.description,
      dateTime: appointment.dateTime,
      veterinarian: appointment.veterinarian,
      location: appointment.location,
      notes: appointment.notes,
      status: appointment.status,
      userId: appointment.userId,
      createdAt: appointment.createdAt,
      updatedAt: appointment.updatedAt,
      isDeleted: appointment.isDeleted,
    );
  }

  AppointmentsCompanion _toCompanion(AppointmentModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return AppointmentsCompanion(
        id: model.id != null ? Value(int.parse(model.id!)) : const Value.absent(),
        animalId: Value(int.parse(model.animalId)),
        title: Value(model.title),
        description: Value.ofNullable(model.description),
        dateTime: Value(model.dateTime),
        veterinarian: Value.ofNullable(model.veterinarian),
        location: Value.ofNullable(model.location),
        notes: Value.ofNullable(model.notes),
        status: Value(model.status),
        userId: Value(model.userId),
        updatedAt: Value(DateTime.now()),
      );
    }

    return AppointmentsCompanion.insert(
      animalId: int.parse(model.animalId),
      title: model.title,
      description: Value.ofNullable(model.description),
      dateTime: model.dateTime,
      veterinarian: Value.ofNullable(model.veterinarian),
      location: Value.ofNullable(model.location),
      notes: Value.ofNullable(model.notes),
      status: model.status,
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }
}
