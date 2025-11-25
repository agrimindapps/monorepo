import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/appointment_local_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/services/appointment_error_handling_service.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/services/appointment_validation_service.dart';
import '../../domain/usecases/add_appointment.dart';
import '../../domain/usecases/delete_appointment.dart';
import '../../domain/usecases/get_appointment_by_id.dart';
import '../../domain/usecases/get_appointments.dart';
import '../../domain/usecases/get_upcoming_appointments.dart';
import '../../domain/usecases/update_appointment.dart';

// Export state classes and notifiers for use in other modules
export '../notifiers/appointments_notifier.dart' show 
  AppointmentState,
  AppointmentsNotifier,
  appointmentsProvider,
  appointmentsListProvider,
  upcomingAppointmentsListProvider,
  appointmentsLoadingProvider,
  appointmentsErrorProvider,
  selectedAppointmentProvider;

part 'appointments_providers.g.dart';

// ============================================================================
// SERVICES
// ============================================================================

@riverpod
AppointmentValidationService appointmentValidationService(
  Ref ref,
) {
  return AppointmentValidationService();
}

@riverpod
AppointmentErrorHandlingService appointmentErrorHandlingService(
  Ref ref,
) {
  return AppointmentErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
AppointmentLocalDataSource appointmentLocalDataSource(
  Ref ref,
) {
  return AppointmentLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
AppointmentRepository appointmentRepository(Ref ref) {
  return AppointmentRepositoryImpl(
    ref.watch(appointmentLocalDataSourceProvider),
    ref.watch(appointmentErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetAppointments getAppointments(Ref ref) {
  return GetAppointments(ref.watch(appointmentRepositoryProvider));
}

@riverpod
GetUpcomingAppointments getUpcomingAppointments(
  Ref ref,
) {
  return GetUpcomingAppointments(ref.watch(appointmentRepositoryProvider));
}

@riverpod
GetAppointmentById getAppointmentById(Ref ref) {
  return GetAppointmentById(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}

@riverpod
AddAppointment addAppointment(Ref ref) {
  return AddAppointment(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}

@riverpod
UpdateAppointment updateAppointment(Ref ref) {
  return UpdateAppointment(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}

@riverpod
DeleteAppointment deleteAppointment(Ref ref) {
  return DeleteAppointment(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}
