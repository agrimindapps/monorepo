import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/core_services_providers.dart';
import '../../data/datasources/vaccine_local_datasource.dart';
import '../../data/datasources/vaccine_remote_datasource.dart';
import '../../data/repositories/vaccine_repository_impl.dart';
import '../../domain/repositories/vaccine_repository.dart';
import '../../domain/usecases/add_vaccine.dart';
import '../../domain/usecases/delete_vaccine.dart';
import '../../domain/usecases/get_overdue_vaccines.dart';
import '../../domain/usecases/get_upcoming_vaccines.dart';
import '../../domain/usecases/get_vaccine_by_id.dart';
import '../../domain/usecases/get_vaccine_calendar.dart';
import '../../domain/usecases/get_vaccine_statistics.dart';
import '../../domain/usecases/get_vaccines.dart';
import '../../domain/usecases/get_vaccines_by_animal.dart';
import '../../domain/usecases/mark_vaccine_completed.dart';
import '../../domain/usecases/schedule_vaccine_reminder.dart';
import '../../domain/usecases/search_vaccines.dart';
import '../../domain/usecases/update_vaccine.dart';

part 'vaccines_providers.g.dart';

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
VaccineLocalDataSource vaccineLocalDataSource(VaccineLocalDataSourceRef ref) {
  return VaccineLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

@riverpod
VaccineRemoteDataSource vaccineRemoteDataSource(VaccineRemoteDataSourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  // TODO: Get actual user ID from auth provider
  final userId = 'temp_user_id'; 
  return VaccineRemoteDataSourceImpl(firestore, userId);
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
VaccineRepository vaccineRepository(VaccineRepositoryRef ref) {
  return VaccineRepositoryImpl(
    localDataSource: ref.watch(vaccineLocalDataSourceProvider),
    remoteDataSource: ref.watch(vaccineRemoteDataSourceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetVaccines getVaccines(GetVaccinesRef ref) {
  return GetVaccines(ref.watch(vaccineRepositoryProvider));
}

@riverpod
GetVaccineById getVaccineById(GetVaccineByIdRef ref) {
  return GetVaccineById(ref.watch(vaccineRepositoryProvider));
}

@riverpod
GetVaccinesByAnimal getVaccinesByAnimal(GetVaccinesByAnimalRef ref) {
  return GetVaccinesByAnimal(ref.watch(vaccineRepositoryProvider));
}

@riverpod
GetOverdueVaccines getOverdueVaccines(GetOverdueVaccinesRef ref) {
  return GetOverdueVaccines(ref.watch(vaccineRepositoryProvider));
}

@riverpod
GetUpcomingVaccines getUpcomingVaccines(GetUpcomingVaccinesRef ref) {
  return GetUpcomingVaccines(ref.watch(vaccineRepositoryProvider));
}

@riverpod
SearchVaccines searchVaccines(SearchVaccinesRef ref) {
  return SearchVaccines(ref.watch(vaccineRepositoryProvider));
}

@riverpod
AddVaccine addVaccine(AddVaccineRef ref) {
  return AddVaccine(ref.watch(vaccineRepositoryProvider));
}

@riverpod
UpdateVaccine updateVaccine(UpdateVaccineRef ref) {
  return UpdateVaccine(ref.watch(vaccineRepositoryProvider));
}

@riverpod
DeleteVaccine deleteVaccine(DeleteVaccineRef ref) {
  return DeleteVaccine(ref.watch(vaccineRepositoryProvider));
}

@riverpod
MarkVaccineCompleted markVaccineCompleted(MarkVaccineCompletedRef ref) {
  return MarkVaccineCompleted(ref.watch(vaccineRepositoryProvider));
}

@riverpod
ScheduleVaccineReminder scheduleVaccineReminder(ScheduleVaccineReminderRef ref) {
  return ScheduleVaccineReminder(ref.watch(vaccineRepositoryProvider));
}

@riverpod
GetVaccineCalendar getVaccineCalendar(GetVaccineCalendarRef ref) {
  return GetVaccineCalendar(ref.watch(vaccineRepositoryProvider));
}

@riverpod
GetVaccineStatistics getVaccineStatistics(GetVaccineStatisticsRef ref) {
  return GetVaccineStatistics(ref.watch(vaccineRepositoryProvider));
}
