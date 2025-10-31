import 'package:core/core.dart' show GetIt;

import '../../../features/medications/data/datasources/medication_local_datasource.dart';
import '../../../features/medications/data/repositories/medication_repository_impl.dart';
import '../../../features/medications/data/services/medication_error_handling_service.dart';
import '../../../features/medications/domain/repositories/medication_repository.dart';
import '../../../features/medications/domain/services/medication_validation_service.dart';
import '../../../features/medications/domain/usecases/add_medication.dart';
import '../../../features/medications/domain/usecases/check_medication_conflicts.dart';
import '../../../features/medications/domain/usecases/delete_medication.dart';
import '../../../features/medications/domain/usecases/get_active_medications.dart';
import '../../../features/medications/domain/usecases/get_expiring_medications.dart';
import '../../../features/medications/domain/usecases/get_medication_by_id.dart';
import '../../../features/medications/domain/usecases/get_medications.dart';
import '../../../features/medications/domain/usecases/get_medications_by_animal_id.dart';
import '../../../features/medications/domain/usecases/update_medication.dart';
import '../di_module.dart';

/// Medications module responsible for medications feature dependencies
///
/// Follows SRP: Single responsibility of medications feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class MedicationsModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Services
    getIt.registerLazySingleton<MedicationValidationService>(
      () => MedicationValidationService(),
    );

    getIt.registerLazySingleton<MedicationErrorHandlingService>(
      () => MedicationErrorHandlingService(),
    );

    // Data Sources
    getIt.registerLazySingleton<MedicationLocalDataSource>(
      () => MedicationLocalDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<MedicationRepository>(
      () => MedicationRepositoryImpl(
        getIt<MedicationLocalDataSource>(),
        getIt<MedicationErrorHandlingService>(),
      ),
    );

    // Use Cases (Read)
    getIt.registerLazySingleton<GetMedications>(
      () => GetMedications(getIt<MedicationRepository>()),
    );

    getIt.registerLazySingleton<GetMedicationById>(
      () => GetMedicationById(
        getIt<MedicationRepository>(),
        getIt<MedicationValidationService>(),
      ),
    );

    getIt.registerLazySingleton<GetMedicationsByAnimalId>(
      () => GetMedicationsByAnimalId(getIt<MedicationRepository>()),
    );

    getIt.registerLazySingleton<GetActiveMedications>(
      () => GetActiveMedications(getIt<MedicationRepository>()),
    );

    getIt.registerLazySingleton<GetExpiringSoonMedications>(
      () => GetExpiringSoonMedications(getIt<MedicationRepository>()),
    );

    getIt.registerLazySingleton<CheckMedicationConflicts>(
      () => CheckMedicationConflicts(getIt<MedicationRepository>()),
    );

    // Use Cases (Write)
    getIt.registerLazySingleton<AddMedication>(
      () => AddMedication(
        getIt<MedicationRepository>(),
        getIt<CheckMedicationConflicts>(),
        getIt<MedicationValidationService>(),
      ),
    );

    getIt.registerLazySingleton<UpdateMedication>(
      () => UpdateMedication(
        getIt<MedicationRepository>(),
        getIt<MedicationValidationService>(),
      ),
    );

    getIt.registerLazySingleton<DeleteMedication>(
      () => DeleteMedication(
        getIt<MedicationRepository>(),
        getIt<MedicationValidationService>(),
      ),
    );

    getIt.registerLazySingleton<DiscontinueMedication>(
      () => DiscontinueMedication(
        getIt<MedicationRepository>(),
        getIt<MedicationValidationService>(),
      ),
    );
  }
}
