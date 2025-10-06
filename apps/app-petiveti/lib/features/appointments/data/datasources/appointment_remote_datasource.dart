import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments(String animalId);
  Future<AppointmentModel> createAppointment(AppointmentModel appointment);
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String id);
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String collectionName = 'appointments';

  AppointmentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AppointmentModel>> getAppointments(String animalId) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('animalId', isEqualTo: animalId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dateTimestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get appointments from server: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    try {
      final docRef = await firestore
          .collection(collectionName)
          .add(appointment.toMap());

      final createdAppointment = appointment.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});
      
      return createdAppointment;
    } catch (e) {
      throw ServerException(message: 'Failed to create appointment: $e');
    }
  }

  @override
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(appointment.id)
          .update(appointment.toMap());

      return appointment;
    } catch (e) {
      throw ServerException(message: 'Failed to update appointment: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(id)
          .update({
            'isDeleted': true,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      throw ServerException(message: 'Failed to delete appointment: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('animalId', isEqualTo: animalId)
          .where('isDeleted', isEqualTo: false)
          .where('dateTimestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('dateTimestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('dateTimestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get appointments by date range: $e');
    }
  }
}
