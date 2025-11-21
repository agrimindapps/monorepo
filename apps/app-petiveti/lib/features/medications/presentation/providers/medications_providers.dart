import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/medication_local_datasource.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../data/services/medication_error_handling_service.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/services/medication_validation_service.dart';
import '../../domain/usecases/add_medication.dart';
import '../../domain/usecases/check_medication_conflicts.dart';
import '../../domain/usecases/delete_medication.dart';
import '../../domain/usecases/get_active_medications.dart';
import '../../domain/usecases/get_expiring_medications.dart';
import '../../domain/usecases/get_medication_by_id.dart';
import '../../domain/usecases/get_medications.dart';
import '../../domain/usecases/get_medications_by_animal_id.dart';
import '../../domain/usecases/update_medication.dart';

part 'medications_providers.g.dart';

// ============================================================================
// SERVICES
// ============================================================================

@riverpod
MedicationValidationService medicationValidationService(
  MedicationValidationServiceRef ref,
) {
  return MedicationValidationService();
}

@riverpod
MedicationErrorHandlingService medicationErrorHandlingService(
  MedicationErrorHandlingServiceRef ref,
) {
  return MedicationErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
MedicationLocalDataSource medicationLocalDataSource(
  MedicationLocalDataSourceRef ref,
) {
  return MedicationLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  return MedicationRepositoryImpl(
    ref.watch(medicationLocalDataSourceProvider),
    ref.watch(medicationErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetMedications getMedications(GetMedicationsRef ref) {
  return GetMedications(ref.watch(medicationRepositoryProvider));
}

@riverpod
GetMedicationsByAnimalId getMedicationsByAnimalId(
  GetMedicationsByAnimalIdRef ref,
) {
  return GetMedicationsByAnimalId(ref.watch(medicationRepositoryProvider));
}

@riverpod
GetActiveMedications getActiveMedications(GetActiveMedicationsRef ref) {
  return GetActiveMedications(ref.watch(medicationRepositoryProvider));
}

@riverpod
GetMedicationById getMedicationById(GetMedicationByIdRef ref) {
  return GetMedicationById(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
AddMedication addMedication(AddMedicationRef ref) {
  return AddMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
UpdateMedication updateMedication(UpdateMedicationRef ref) {
  return UpdateMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
DeleteMedication deleteMedication(DeleteMedicationRef ref) {
  return DeleteMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
DiscontinueMedication discontinueMedication(DiscontinueMedicationRef ref) {
  return DiscontinueMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
GetExpiringSoonMedications getExpiringSoonMedications(
  GetExpiringSoonMedicationsRef ref,
) {
  return GetExpiringSoonMedications(ref.watch(medicationRepositoryProvider));
}
