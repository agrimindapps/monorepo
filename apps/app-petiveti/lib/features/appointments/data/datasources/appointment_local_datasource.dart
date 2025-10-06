import 'package:core/core.dart' show Hive, Box;

import '../../../../core/error/exceptions.dart';
import '../models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments(String animalId);
  Future<List<AppointmentModel>> getUpcomingAppointments(String animalId);
  Future<AppointmentModel?> getAppointmentById(String id);
  Future<void> cacheAppointment(AppointmentModel appointment);
  Future<void> cacheAppointments(List<AppointmentModel> appointments);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String id);
  Future<void> clearCache();
}

class AppointmentLocalDataSourceImpl implements AppointmentLocalDataSource {
  static const String boxName = 'appointments';
  late Box<AppointmentModel> _box;

  AppointmentLocalDataSourceImpl() {
    _initBox();
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<AppointmentModel>(boxName);
    } else {
      _box = Hive.box<AppointmentModel>(boxName);
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointments(String animalId) async {
    try {
      await _initBox();
      final appointments =
          _box.values
              .where(
                (appointment) =>
                    appointment.animalId == animalId && !appointment.isDeleted,
              )
              .toList();
      appointments.sort((a, b) => b.dateTimestamp.compareTo(a.dateTimestamp));

      return appointments;
    } catch (e) {
      throw CacheException(message: 'Failed to get appointments: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String animalId,
  ) async {
    try {
      await _initBox();
      final now = DateTime.now().millisecondsSinceEpoch;

      final upcomingAppointments =
          _box.values
              .where(
                (appointment) =>
                    appointment.animalId == animalId &&
                    !appointment.isDeleted &&
                    appointment.dateTimestamp > now &&
                    appointment.status == 0,
              ) // scheduled status
              .toList();
      upcomingAppointments.sort(
        (a, b) => a.dateTimestamp.compareTo(b.dateTimestamp),
      );

      return upcomingAppointments;
    } catch (e) {
      throw CacheException(message: 'Failed to get upcoming appointments: $e');
    }
  }

  @override
  Future<AppointmentModel?> getAppointmentById(String id) async {
    try {
      await _initBox();
      return _box.values
          .where(
            (appointment) => appointment.id == id && !appointment.isDeleted,
          )
          .firstOrNull;
    } catch (e) {
      throw CacheException(message: 'Failed to get appointment by id: $e');
    }
  }

  @override
  Future<void> cacheAppointment(AppointmentModel appointment) async {
    try {
      await _initBox();
      await _box.put(appointment.id, appointment);
    } catch (e) {
      throw CacheException(message: 'Failed to cache appointment: $e');
    }
  }

  @override
  Future<void> cacheAppointments(List<AppointmentModel> appointments) async {
    try {
      await _initBox();
      final Map<String, AppointmentModel> appointmentMap = {
        for (var appointment in appointments) appointment.id: appointment,
      };
      await _box.putAll(appointmentMap);
    } catch (e) {
      throw CacheException(message: 'Failed to cache appointments: $e');
    }
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _initBox();
      await _box.put(appointment.id, appointment);
    } catch (e) {
      throw CacheException(message: 'Failed to update appointment: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    try {
      await _initBox();
      final appointment = await getAppointmentById(id);
      if (appointment != null) {
        final deletedAppointment = appointment.copyWith(
          isDeleted: true,
          updatedAtTimestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await _box.put(id, deletedAppointment);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete appointment: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _initBox();
      await _box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear appointments cache: $e');
    }
  }
}
