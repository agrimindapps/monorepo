import 'package:flutter_test/flutter_test.dart';

import 'package:app_petiveti/features/appointments/domain/entities/appointment.dart';

void main() {
  group('Appointment Entity', () {
    final tAppointment = Appointment(
      id: '1',
      animalId: 'animal1',
      veterinarianName: 'Dr. Test',
      date: DateTime(2024, 1, 1, 10, 0),
      reason: 'Routine checkup',
      diagnosis: 'Healthy',
      notes: 'Test notes',
      status: AppointmentStatus.scheduled,
      cost: 150.0,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('should have correct properties', () {
      expect(tAppointment.id, '1');
      expect(tAppointment.animalId, 'animal1');
      expect(tAppointment.veterinarianName, 'Dr. Test');
      expect(tAppointment.date, DateTime(2024, 1, 1, 10, 0));
      expect(tAppointment.reason, 'Routine checkup');
      expect(tAppointment.diagnosis, 'Healthy');
      expect(tAppointment.notes, 'Test notes');
      expect(tAppointment.status, AppointmentStatus.scheduled);
      expect(tAppointment.cost, 150.0);
      expect(tAppointment.isDeleted, false);
    });

    test('should format cost correctly', () {
      expect(tAppointment.formattedCost, 'R\$ 150.00');
      
      final appointmentWithoutCost = Appointment(
        id: '2',
        animalId: 'animal1',
        veterinarianName: 'Dr. Test',
        date: DateTime(2024, 1, 1, 10, 0),
        reason: 'Routine checkup',
        cost: null,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(appointmentWithoutCost.formattedCost, '');
      
      final appointmentWithZeroCost = Appointment(
        id: '3',
        animalId: 'animal1',
        veterinarianName: 'Dr. Test',
        date: DateTime(2024, 1, 1, 10, 0),
        reason: 'Routine checkup',
        cost: 0.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(appointmentWithZeroCost.formattedCost, '');
    });

    test('should display status correctly', () {
      expect(tAppointment.displayStatus, 'Agendada');
      
      final completedAppointment = tAppointment.copyWith(status: AppointmentStatus.completed);
      expect(completedAppointment.displayStatus, 'Realizada');
      
      final cancelledAppointment = tAppointment.copyWith(status: AppointmentStatus.cancelled);
      expect(cancelledAppointment.displayStatus, 'Cancelada');
      
      final inProgressAppointment = tAppointment.copyWith(status: AppointmentStatus.inProgress);
      expect(inProgressAppointment.displayStatus, 'Em andamento');
    });

    test('should identify upcoming appointments correctly', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final upcomingAppointment = tAppointment.copyWith(
        date: futureDate,
        status: AppointmentStatus.scheduled,
      );
      expect(upcomingAppointment.isUpcoming, true);
      
      final pastAppointment = tAppointment.copyWith(
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: AppointmentStatus.scheduled,
      );
      expect(pastAppointment.isUpcoming, false);
      
      final completedFutureAppointment = tAppointment.copyWith(
        date: futureDate,
        status: AppointmentStatus.completed,
      );
      expect(completedFutureAppointment.isUpcoming, false);
    });

    test('should identify past appointments correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final pastAppointment = tAppointment.copyWith(date: pastDate);
      expect(pastAppointment.isPast, true);
      
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final futureAppointment = tAppointment.copyWith(date: futureDate);
      expect(futureAppointment.isPast, false);
    });

    test('should identify today appointments correctly', () {
      final today = DateTime.now();
      final todayAppointment = tAppointment.copyWith(
        date: DateTime(today.year, today.month, today.day, 10, 0),
      );
      expect(todayAppointment.isToday, true);
      
      final tomorrowAppointment = tAppointment.copyWith(
        date: today.add(const Duration(days: 1)),
      );
      expect(tomorrowAppointment.isToday, false);
    });

    test('should create copy with updated values', () {
      final updatedAppointment = tAppointment.copyWith(
        veterinarianName: 'Dr. New',
        cost: 200.0,
      );
      
      expect(updatedAppointment.veterinarianName, 'Dr. New');
      expect(updatedAppointment.cost, 200.0);
      expect(updatedAppointment.id, tAppointment.id); // Should remain the same
      expect(updatedAppointment.reason, tAppointment.reason); // Should remain the same
    });

    test('should be equal when ids are the same', () {
      final sameAppointment = Appointment(
        id: '1',
        animalId: 'different_animal',
        veterinarianName: 'Different Dr.',
        date: DateTime(2025, 1, 1),
        reason: 'Different reason',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(tAppointment, equals(sameAppointment));
    });

    test('should not be equal when ids are different', () {
      final differentAppointment = tAppointment.copyWith(id: '2');
      
      expect(tAppointment, isNot(equals(differentAppointment)));
    });
  });
}