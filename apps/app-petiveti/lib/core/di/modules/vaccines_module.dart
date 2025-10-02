import 'package:get_it/get_it.dart';

import '../../../core/network/firebase_service.dart';
import '../../../features/vaccines/data/datasources/vaccine_local_datasource.dart';
import '../../../features/vaccines/data/datasources/vaccine_remote_datasource.dart';
import '../../../features/vaccines/data/repositories/vaccine_repository_impl.dart';
import '../../../features/vaccines/domain/repositories/vaccine_repository.dart';
import '../../../features/vaccines/domain/usecases/add_vaccine.dart';
import '../../../features/vaccines/domain/usecases/delete_vaccine.dart';
import '../../../features/vaccines/domain/usecases/get_overdue_vaccines.dart';
import '../../../features/vaccines/domain/usecases/get_upcoming_vaccines.dart';
import '../../../features/vaccines/domain/usecases/get_vaccine_by_id.dart';
import '../../../features/vaccines/domain/usecases/get_vaccine_calendar.dart';
import '../../../features/vaccines/domain/usecases/get_vaccine_statistics.dart';
import '../../../features/vaccines/domain/usecases/get_vaccines.dart';
import '../../../features/vaccines/domain/usecases/get_vaccines_by_animal.dart';
import '../../../features/vaccines/domain/usecases/mark_vaccine_completed.dart';
import '../../../features/vaccines/domain/usecases/schedule_vaccine_reminder.dart';
import '../../../features/vaccines/domain/usecases/search_vaccines.dart';
import '../../../features/vaccines/domain/usecases/update_vaccine.dart';
import '../di_module.dart';

/// Vaccines module responsible for vaccines feature dependencies
///
/// Follows SRP: Single responsibility of vaccines feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class VaccinesModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<VaccineLocalDataSource>(
      () => VaccineLocalDataSourceImpl(getIt()),
    );

    getIt.registerLazySingleton<VaccineRemoteDataSource>(
      () => VaccineRemoteDataSourceImpl(
        getIt(),
        getIt<FirebaseService>().currentUserId ?? 'temp_user_id',
      ),
    );

    // Repository
    getIt.registerLazySingleton<VaccineRepository>(
      () => VaccineRepositoryImpl(
        localDataSource: getIt<VaccineLocalDataSource>(),
        remoteDataSource: getIt<VaccineRemoteDataSource>(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton<GetVaccines>(
      () => GetVaccines(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<GetVaccineById>(
      () => GetVaccineById(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<GetVaccinesByAnimal>(
      () => GetVaccinesByAnimal(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<GetOverdueVaccines>(
      () => GetOverdueVaccines(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<GetUpcomingVaccines>(
      () => GetUpcomingVaccines(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<GetVaccineCalendar>(
      () => GetVaccineCalendar(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<GetVaccineStatistics>(
      () => GetVaccineStatistics(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<SearchVaccines>(
      () => SearchVaccines(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<AddVaccine>(
      () => AddVaccine(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<UpdateVaccine>(
      () => UpdateVaccine(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<DeleteVaccine>(
      () => DeleteVaccine(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<MarkVaccineCompleted>(
      () => MarkVaccineCompleted(getIt<VaccineRepository>()),
    );

    getIt.registerLazySingleton<ScheduleVaccineReminder>(
      () => ScheduleVaccineReminder(getIt<VaccineRepository>()),
    );
  }
}
