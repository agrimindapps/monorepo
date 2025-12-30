import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/performance/performance_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/medication_local_datasource.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../data/services/medication_error_handling_service.dart';
import '../../domain/entities/medication.dart';
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
  Ref ref,
) {
  return MedicationValidationService();
}

@riverpod
MedicationErrorHandlingService medicationErrorHandlingService(
  Ref ref,
) {
  return MedicationErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
MedicationLocalDataSource medicationLocalDataSource(
  Ref ref,
) {
  return MedicationLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
MedicationRepository medicationRepository(Ref ref) {
  return MedicationRepositoryImpl(
    ref.watch(medicationLocalDataSourceProvider),
    ref.watch(medicationErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetMedications getMedications(Ref ref) {
  return GetMedications(ref.watch(medicationRepositoryProvider));
}

@riverpod
GetMedicationsByAnimalId getMedicationsByAnimalId(
  Ref ref,
) {
  return GetMedicationsByAnimalId(ref.watch(medicationRepositoryProvider));
}

@riverpod
GetActiveMedications getActiveMedications(Ref ref) {
  return GetActiveMedications(ref.watch(medicationRepositoryProvider));
}

@riverpod
GetMedicationById getMedicationById(Ref ref) {
  return GetMedicationById(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
CheckMedicationConflicts checkMedicationConflicts(Ref ref) {
  return CheckMedicationConflicts(ref.watch(medicationRepositoryProvider));
}

@riverpod
AddMedication addMedication(Ref ref) {
  return AddMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(checkMedicationConflictsProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
UpdateMedication updateMedication(Ref ref) {
  return UpdateMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
DeleteMedication deleteMedication(Ref ref) {
  return DeleteMedication(
    ref.watch(medicationRepositoryProvider),
    ref.watch(medicationValidationServiceProvider),
  );
}

@riverpod
GetExpiringSoonMedications getExpiringSoonMedications(
  Ref ref,
) {
  return GetExpiringSoonMedications(ref.watch(medicationRepositoryProvider));
}

// ============================================================================
// NOTIFIER & STATE
// ============================================================================

class MedicationsState {
  final List<Medication> medications;
  final List<Medication> activeMedications;
  final List<Medication> expiringMedications;
  final bool isLoading;
  final String? error;
  final DateTime? selectedMonth;

  const MedicationsState({
    this.medications = const [],
    this.activeMedications = const [],
    this.expiringMedications = const [],
    this.isLoading = false,
    this.error,
    this.selectedMonth,
  });

  MedicationsState copyWith({
    List<Medication>? medications,
    List<Medication>? activeMedications,
    List<Medication>? expiringMedications,
    bool? isLoading,
    String? error,
    DateTime? selectedMonth,
  }) {
    return MedicationsState(
      medications: medications ?? this.medications,
      activeMedications: activeMedications ?? this.activeMedications,
      expiringMedications: expiringMedications ?? this.expiringMedications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

@riverpod
class MedicationsNotifier extends _$MedicationsNotifier with PerformanceMonitoring {
  late final GetMedications _getMedications;
  late final GetMedicationsByAnimalId _getMedicationsByAnimalId;
  late final GetActiveMedications _getActiveMedications;
  late final GetMedicationById _getMedicationById;
  late final AddMedication _addMedication;
  late final UpdateMedication _updateMedication;
  late final DeleteMedication _deleteMedication;
  late final GetExpiringSoonMedications _getExpiringSoonMedications;

  @override
  MedicationsState build() {
    _getMedications = ref.watch(getMedicationsProvider);
    _getMedicationsByAnimalId = ref.watch(getMedicationsByAnimalIdProvider);
    _getActiveMedications = ref.watch(getActiveMedicationsProvider);
    _getMedicationById = ref.watch(getMedicationByIdProvider);
    _addMedication = ref.watch(addMedicationProvider);
    _updateMedication = ref.watch(updateMedicationProvider);
    _deleteMedication = ref.watch(deleteMedicationProvider);
    _getExpiringSoonMedications = ref.watch(getExpiringSoonMedicationsProvider);

    return const MedicationsState();
  }

  Future<void> loadMedications() async {
    return trackAsync('loadMedications', () async {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _getMedications(const local.NoParams());

      if (!ref.mounted) return;

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
        ),
        (medications) => state = state.copyWith(
          medications: medications,
          isLoading: false,
          error: null,
        ),
      );
    });
  }

  Future<void> loadMedicationsByAnimalId(String animalId) async {
    return trackAsync('loadMedicationsByAnimalId', () async {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _getMedicationsByAnimalId(animalId);

      if (!ref.mounted) return;

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
        ),
        (medications) => state = state.copyWith(
          medications: medications,
          isLoading: false,
          error: null,
        ),
      );
    });
  }

  Future<void> loadActiveMedications() async {
    final result = await _getActiveMedications(const local.NoParams());

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (activeMedications) => state = state.copyWith(
        activeMedications: activeMedications,
        error: null,
      ),
    );
  }

  Future<void> loadExpiringMedications() async {
    final result = await _getExpiringSoonMedications(const local.NoParams());

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (expiringMedications) => state = state.copyWith(
        expiringMedications: expiringMedications,
        error: null,
      ),
    );
  }

  Future<void> addMedication(Medication medication) async {
    final result = await _addMedication(medication);

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedMedications = [medication, ...state.medications];
        state = state.copyWith(
          medications: updatedMedications,
          error: null,
        );
        loadActiveMedications();
        loadExpiringMedications();
      },
    );
  }

  Future<void> updateMedication(Medication medication) async {
    final result = await _updateMedication(medication);

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedMedications = state.medications.map((m) {
          return m.id == medication.id ? medication : m;
        }).toList();

        state = state.copyWith(
          medications: updatedMedications,
          error: null,
        );
        loadActiveMedications();
        loadExpiringMedications();
      },
    );
  }

  Future<void> deleteMedication(String id) async {
    final result = await _deleteMedication(id);

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedMedications = state.medications.where((m) => m.id != id).toList();
        final updatedActiveMedications = state.activeMedications.where((m) => m.id != id).toList();
        final updatedExpiringMedications = state.expiringMedications.where((m) => m.id != id).toList();

        state = state.copyWith(
          medications: updatedMedications,
          activeMedications: updatedActiveMedications,
          expiringMedications: updatedExpiringMedications,
          error: null,
        );
      },
    );
  }

  Future<Medication?> getMedicationById(String id) async {
    final result = await _getMedicationById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (medication) => medication,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  List<Medication> getMedicationsForAnimal(String animalId) {
    return state.medications.where((m) => m.animalId == animalId).toList();
  }

  List<Medication> getActiveMedicationsForAnimal(String animalId) {
    return state.activeMedications.where((m) => m.animalId == animalId).toList();
  }

  List<Medication> getMedicationsByType(MedicationType type) {
    return state.medications.where((m) => m.type == type).toList();
  }

  List<Medication> getMedicationsByStatus(MedicationStatus status) {
    return state.medications.where((m) => m.status == status).toList();
  }

  int getActiveMedicationsCount() {
    return state.activeMedications.length;
  }

  int getExpiringMedicationsCount() {
    return state.expiringMedications.length;
  }

  void filterByAnimal(String animalId) {
    loadMedicationsByAnimalId(animalId);
  }

  void clearAnimalFilter() {
    loadMedications();
  }

  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: month);
  }

  void clearMonthFilter() {
    state = state.copyWith(selectedMonth: null);
  }
}

// Derived providers
@riverpod
Future<Medication?> medicationById(Ref ref, String id) async {
  final notifier = ref.read(medicationsProvider.notifier);
  return await notifier.getMedicationById(id);
}

@riverpod
Stream<List<Medication>> medicationsStream(Ref ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.watchMedications();
}

@riverpod
Stream<List<Medication>> medicationsByAnimalStream(
  Ref ref,
  String animalId,
) {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.watchMedicationsByAnimalId(animalId);
}

@riverpod
Stream<List<Medication>> activeMedicationsStream(Ref ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.watchActiveMedications();
}

@riverpod
class MedicationTypeFilter extends _$MedicationTypeFilter {
  @override
  MedicationType? build() => null;

  void set(MedicationType? type) => state = type;
}

@riverpod
class MedicationStatusFilter extends _$MedicationStatusFilter {
  @override
  MedicationStatus? build() => null;

  void set(MedicationStatus? status) => state = status;
}

@riverpod
class MedicationSearchQuery extends _$MedicationSearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
}

@riverpod
List<Medication> filteredMedications(Ref ref) {
  final medications = ref.watch(medicationsProvider).medications;
  final typeFilter = ref.watch(medicationTypeFilterProvider);
  final statusFilter = ref.watch(medicationStatusFilterProvider);
  final searchQuery = ref.watch(medicationSearchQueryProvider);

  var filtered = medications;
  if (typeFilter != null) {
    filtered = filtered.where((m) => m.type == typeFilter).toList();
  }
  if (statusFilter != null) {
    filtered = filtered.where((m) => m.status == statusFilter).toList();
  }
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered = filtered.where((m) =>
        m.name.toLowerCase().contains(query) ||
        m.type.displayName.toLowerCase().contains(query) ||
        (m.prescribedBy?.toLowerCase().contains(query) ?? false)).toList();
  }

  return filtered;
}
