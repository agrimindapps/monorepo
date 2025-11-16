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
  appointmentsNotifierProvider,
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
  AppointmentValidationServiceRef ref,
) {
  return AppointmentValidationService();
}

@riverpod
AppointmentErrorHandlingService appointmentErrorHandlingService(
  AppointmentErrorHandlingServiceRef ref,
) {
  return AppointmentErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
AppointmentLocalDataSource appointmentLocalDataSource(
  AppointmentLocalDataSourceRef ref,
) {
  return AppointmentLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  return AppointmentRepositoryImpl(
    ref.watch(appointmentLocalDataSourceProvider),
    ref.watch(appointmentErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetAppointments getAppointments(GetAppointmentsRef ref) {
  return GetAppointments(ref.watch(appointmentRepositoryProvider));
}

@riverpod
GetUpcomingAppointments getUpcomingAppointments(
  GetUpcomingAppointmentsRef ref,
) {
  return GetUpcomingAppointments(ref.watch(appointmentRepositoryProvider));
}

@riverpod
GetAppointmentById getAppointmentById(GetAppointmentByIdRef ref) {
  return GetAppointmentById(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}

@riverpod
AddAppointment addAppointment(AddAppointmentRef ref) {
  return AddAppointment(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}

@riverpod
UpdateAppointment updateAppointment(UpdateAppointmentRef ref) {
  return UpdateAppointment(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}

@riverpod
DeleteAppointment deleteAppointment(DeleteAppointmentRef ref) {
  return DeleteAppointment(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(appointmentValidationServiceProvider),
  );
}
