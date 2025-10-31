import 'package:core/core.dart' show GetIt;

import '../../../features/appointments/data/datasources/appointment_local_datasource.dart';
import '../../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../../features/appointments/data/services/appointment_error_handling_service.dart';
import '../../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../../features/appointments/domain/services/appointment_validation_service.dart';
import '../../../features/appointments/domain/usecases/add_appointment.dart';
import '../../../features/appointments/domain/usecases/delete_appointment.dart';
import '../../../features/appointments/domain/usecases/get_appointment_by_id.dart';
import '../../../features/appointments/domain/usecases/get_appointments.dart';
import '../../../features/appointments/domain/usecases/get_upcoming_appointments.dart';
import '../../../features/appointments/domain/usecases/update_appointment.dart';
import '../di_module.dart';

/// Appointments module responsible for appointments feature dependencies
///
/// Follows SRP: Single responsibility of appointments feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class AppointmentsModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Services
    getIt.registerLazySingleton<AppointmentValidationService>(
      () => AppointmentValidationService(),
    );

    getIt.registerLazySingleton<AppointmentErrorHandlingService>(
      () => AppointmentErrorHandlingService(),
    );

    // Data Sources
    getIt.registerLazySingleton<AppointmentLocalDataSource>(
      () => AppointmentLocalDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(
        getIt<AppointmentLocalDataSource>(),
        getIt<AppointmentErrorHandlingService>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<GetAppointments>(
      () => GetAppointments(getIt<AppointmentRepository>()),
    );

    getIt.registerLazySingleton<GetUpcomingAppointments>(
      () => GetUpcomingAppointments(getIt<AppointmentRepository>()),
    );

    getIt.registerLazySingleton<GetAppointmentById>(
      () => GetAppointmentById(
        getIt<AppointmentRepository>(),
        getIt<AppointmentValidationService>(),
      ),
    );

    getIt.registerLazySingleton<AddAppointment>(
      () => AddAppointment(
        getIt<AppointmentRepository>(),
        getIt<AppointmentValidationService>(),
      ),
    );

    getIt.registerLazySingleton<UpdateAppointment>(
      () => UpdateAppointment(
        getIt<AppointmentRepository>(),
        getIt<AppointmentValidationService>(),
      ),
    );

    getIt.registerLazySingleton<DeleteAppointment>(
      () => DeleteAppointment(
        getIt<AppointmentRepository>(),
        getIt<AppointmentValidationService>(),
      ),
    );
  }
}
