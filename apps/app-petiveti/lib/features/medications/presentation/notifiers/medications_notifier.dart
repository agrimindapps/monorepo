import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/performance/performance_service.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/usecases/add_medication.dart';
import '../../domain/usecases/delete_medication.dart';
import '../../domain/usecases/get_active_medications.dart';
import '../../domain/usecases/get_expiring_medications.dart';
import '../../domain/usecases/get_medication_by_id.dart';
import '../../domain/usecases/get_medications.dart';
import '../../domain/usecases/get_medications_by_animal_id.dart';
import '../../domain/usecases/update_medication.dart';

part 'medications_notifier.g.dart';

class MedicationsState {
  final List<Medication> medications;
  final List<Medication> activeMedications;
  final List<Medication> expiringMedications;
  final bool isLoading;
  final String? error;

  const MedicationsState({
    this.medications = const [],
    this.activeMedications = const [],
    this.expiringMedications = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationsState copyWith({
    List<Medication>? medications,
    List<Medication>? activeMedications,
    List<Medication>? expiringMedications,
    bool? isLoading,
    String? error,
  }) {
    return MedicationsState(
      medications: medications ?? this.medications,
      activeMedications: activeMedications ?? this.activeMedications,
      expiringMedications: expiringMedications ?? this.expiringMedications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
  late final DiscontinueMedication _discontinueMedication;
  late final GetExpiringSoonMedications _getExpiringSoonMedications;

  @override
  MedicationsState build() {
    _getMedications = di.getIt<GetMedications>();
    _getMedicationsByAnimalId = di.getIt<GetMedicationsByAnimalId>();
    _getActiveMedications = di.getIt<GetActiveMedications>();
    _getMedicationById = di.getIt<GetMedicationById>();
    _addMedication = di.getIt<AddMedication>();
    _updateMedication = di.getIt<UpdateMedication>();
    _deleteMedication = di.getIt<DeleteMedication>();
    _discontinueMedication = di.getIt<DiscontinueMedication>();
    _getExpiringSoonMedications = di.getIt<GetExpiringSoonMedications>();

    return const MedicationsState();
  }

  Future<void> loadMedications() async {
    return trackAsync('loadMedications', () async {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _getMedications(const local.NoParams());

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

  Future<void> discontinueMedication(String id, String reason) async {
    final params = DiscontinueMedicationParams(id: id, reason: reason);
    final result = await _discontinueMedication(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        loadMedications();
        loadActiveMedications();
        loadExpiringMedications();
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
}

// Derived providers
@riverpod
Future<Medication?> medicationById(MedicationByIdRef ref, String id) async {
  final notifier = ref.read(medicationsNotifierProvider.notifier);
  return await notifier.getMedicationById(id);
}

@riverpod
Stream<List<Medication>> medicationsStream(MedicationsStreamRef ref) {
  final repository = di.getIt.get<MedicationRepository>();
  return repository.watchMedications();
}

@riverpod
Stream<List<Medication>> medicationsByAnimalStream(
  MedicationsByAnimalStreamRef ref,
  String animalId,
) {
  final repository = di.getIt.get<MedicationRepository>();
  return repository.watchMedicationsByAnimalId(animalId);
}

@riverpod
Stream<List<Medication>> activeMedicationsStream(ActiveMedicationsStreamRef ref) {
  final repository = di.getIt.get<MedicationRepository>();
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
List<Medication> filteredMedications(FilteredMedicationsRef ref) {
  final medications = ref.watch(medicationsNotifierProvider).medications;
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
