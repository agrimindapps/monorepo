import 'package:core/core.dart';

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
class MedicationsNotifier extends StateNotifier<MedicationsState> with PerformanceMonitoring {
  final GetMedications _getMedications;
  final GetMedicationsByAnimalId _getMedicationsByAnimalId;
  final GetActiveMedications _getActiveMedications;
  final GetMedicationById _getMedicationById;
  final AddMedication _addMedication;
  final UpdateMedication _updateMedication;
  final DeleteMedication _deleteMedication;
  final DiscontinueMedication _discontinueMedication;
  final GetExpiringSoonMedications _getExpiringSoonMedications;

  MedicationsNotifier({
    required GetMedications getMedications,
    required GetMedicationsByAnimalId getMedicationsByAnimalId,
    required GetActiveMedications getActiveMedications,
    required GetMedicationById getMedicationById,
    required AddMedication addMedication,
    required UpdateMedication updateMedication,
    required DeleteMedication deleteMedication,
    required DiscontinueMedication discontinueMedication,
    required GetExpiringSoonMedications getExpiringSoonMedications,
  })  : _getMedications = getMedications,
        _getMedicationsByAnimalId = getMedicationsByAnimalId,
        _getActiveMedications = getActiveMedications,
        _getMedicationById = getMedicationById,
        _addMedication = addMedication,
        _updateMedication = updateMedication,
        _deleteMedication = deleteMedication,
        _discontinueMedication = discontinueMedication,
        _getExpiringSoonMedications = getExpiringSoonMedications,
        super(const MedicationsState());

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
final medicationsProvider = StateNotifierProvider<MedicationsNotifier, MedicationsState>((ref) {
  return MedicationsNotifier(
    getMedications: di.getIt<GetMedications>(),
    getMedicationsByAnimalId: di.getIt<GetMedicationsByAnimalId>(),
    getActiveMedications: di.getIt<GetActiveMedications>(),
    getMedicationById: di.getIt<GetMedicationById>(),
    addMedication: di.getIt<AddMedication>(),
    updateMedication: di.getIt<UpdateMedication>(),
    deleteMedication: di.getIt<DeleteMedication>(),
    discontinueMedication: di.getIt<DiscontinueMedication>(),
    getExpiringSoonMedications: di.getIt<GetExpiringSoonMedications>(),
  );
});
final medicationProvider = FutureProvider.family<Medication?, String>((ref, id) async {
  final notifier = ref.read(medicationsProvider.notifier);
  return await notifier.getMedicationById(id);
});
final medicationsStreamProvider = StreamProvider<List<Medication>>((ref) {
  final repository = di.getIt.get<MedicationRepository>();
  return repository.watchMedications();
});
final medicationsByAnimalStreamProvider = StreamProvider.family<List<Medication>, String>((ref, animalId) {
  final repository = di.getIt.get<MedicationRepository>();
  return repository.watchMedicationsByAnimalId(animalId);
});
final activeMedicationsStreamProvider = StreamProvider<List<Medication>>((ref) {
  final repository = di.getIt.get<MedicationRepository>();
  return repository.watchActiveMedications();
});
final selectedMedicationProvider = StateProvider<Medication?>((ref) => null);
final medicationTypeFilterProvider = StateProvider<MedicationType?>((ref) => null);
final medicationStatusFilterProvider = StateProvider<MedicationStatus?>((ref) => null);
final medicationSearchQueryProvider = StateProvider<String>((ref) => '');
final filteredMedicationsProvider = Provider<List<Medication>>((ref) {
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
});
