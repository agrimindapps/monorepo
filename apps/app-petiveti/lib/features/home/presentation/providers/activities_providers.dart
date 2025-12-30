import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/providers/appointments_providers.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/presentation/providers/medications_providers.dart';
import '../../../vaccines/domain/entities/vaccine.dart';
import '../../../vaccines/presentation/providers/vaccines_providers.dart';
import '../../../weight/domain/entities/weight.dart';
import '../../../weight/presentation/providers/weight_providers.dart';

part 'activities_providers.g.dart';

/// Estado contendo as últimas atividades de cada categoria
class RecentActivitiesState {
  final List<Vaccine> recentVaccines;
  final List<Appointment> recentAppointments;
  final List<Medication> recentMedications;
  final List<Weight> recentWeights;
  final bool isLoading;
  final String? error;

  const RecentActivitiesState({
    this.recentVaccines = const [],
    this.recentAppointments = const [],
    this.recentMedications = const [],
    this.recentWeights = const [],
    this.isLoading = false,
    this.error,
  });

  RecentActivitiesState copyWith({
    List<Vaccine>? recentVaccines,
    List<Appointment>? recentAppointments,
    List<Medication>? recentMedications,
    List<Weight>? recentWeights,
    bool? isLoading,
    String? error,
  }) {
    return RecentActivitiesState(
      recentVaccines: recentVaccines ?? this.recentVaccines,
      recentAppointments: recentAppointments ?? this.recentAppointments,
      recentMedications: recentMedications ?? this.recentMedications,
      recentWeights: recentWeights ?? this.recentWeights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isEmpty =>
      recentVaccines.isEmpty &&
      recentAppointments.isEmpty &&
      recentMedications.isEmpty &&
      recentWeights.isEmpty;
}

/// Provider para atividades recentes de um animal específico
@riverpod
class RecentActivities extends _$RecentActivities {
  @override
  RecentActivitiesState build(String? animalId) {
    return const RecentActivitiesState();
  }

  /// Carrega as últimas 3 atividades de cada categoria para o animal
  Future<void> loadRecentActivities() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final vaccinesState = ref.read(vaccinesProvider);
      final appointmentsState = ref.read(appointmentsProvider);
      final medicationsState = ref.read(medicationsProvider);
      final weightsState = ref.read(weightsProvider);

      // Filtra por animal se especificado
      List<Vaccine> vaccines = vaccinesState.vaccines;
      List<Appointment> appointments = appointmentsState.appointments;
      List<Medication> medications = medicationsState.medications;
      List<Weight> weights = weightsState.weights;

      final currentAnimalId = animalId;
      if (currentAnimalId != null) {
        vaccines = vaccines.where((v) => v.animalId == currentAnimalId).toList();
        appointments = appointments.where((a) => a.animalId == currentAnimalId).toList();
        medications = medications.where((m) => m.animalId == currentAnimalId).toList();
        weights = weights.where((w) => w.animalId == currentAnimalId).toList();
      }

      // Ordena por data mais recente e pega os últimos 3
      vaccines.sort((a, b) => b.date.compareTo(a.date));
      appointments.sort((a, b) => b.date.compareTo(a.date));
      medications.sort((a, b) => b.startDate.compareTo(a.startDate));
      weights.sort((a, b) => b.date.compareTo(a.date));

      state = state.copyWith(
        recentVaccines: vaccines.take(3).toList(),
        recentAppointments: appointments.take(3).toList(),
        recentMedications: medications.take(3).toList(),
        recentWeights: weights.take(3).toList(),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para obter o peso anterior (usado para calcular variação)
@riverpod
double? previousWeight(Ref ref, String animalId, int currentIndex) {
  final weightsState = ref.watch(weightsProvider);
  final weights = weightsState.weights
      .where((w) => w.animalId == animalId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  if (currentIndex + 1 < weights.length) {
    return weights[currentIndex + 1].weight;
  }
  return null;
}
