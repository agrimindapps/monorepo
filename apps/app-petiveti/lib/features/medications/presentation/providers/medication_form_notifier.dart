import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/medication.dart';
import 'medication_form_state.dart';
import 'medications_providers.dart';

part 'medication_form_notifier.g.dart';

@riverpod
class MedicationFormNotifier extends _$MedicationFormNotifier {
  @override
  MedicationFormState build(String? animalId) {
    return MedicationFormState(animalId: animalId);
  }

  Future<void> initialize({String? medicationId}) async {
    if (medicationId == null) {
      state = MedicationFormState(animalId: animalId);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final notifier = ref.read(medicationsProvider.notifier);
      final medications = notifier.state.medications;
      final medication = medications.firstWhere((m) => m.id == medicationId);

      state = MedicationFormState(
        medication: medication,
        animalId: medication.animalId,
        name: medication.name,
        dosage: medication.dosage,
        frequency: medication.frequency,
        duration: medication.duration ?? '',
        notes: medication.notes ?? '',
        prescribedBy: medication.prescribedBy ?? '',
        type: medication.type,
        startDate: medication.startDate,
        endDate: medication.endDate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar medicamento: $e',
      );
    }
  }

  void updateName(String value) => state = state.copyWith(name: value);
  void updateDosage(String value) => state = state.copyWith(dosage: value);
  void updateFrequency(String value) => state = state.copyWith(frequency: value);
  void updateDuration(String value) => state = state.copyWith(duration: value);
  void updateNotes(String value) => state = state.copyWith(notes: value);
  void updatePrescribedBy(String value) => state = state.copyWith(prescribedBy: value);
  void updateType(MedicationType value) => state = state.copyWith(type: value);
  void updateStartDate(DateTime value) => state = state.copyWith(startDate: value);
  void updateEndDate(DateTime value) => state = state.copyWith(endDate: value);

  Future<bool> save() async {
    if (state.animalId == null || state.animalId!.isEmpty) {
      state = state.copyWith(errorMessage: 'Animal não selecionado');
      return false;
    }

    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Nome é obrigatório');
      return false;
    }

    if (state.dosage.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Dosagem é obrigatória');
      return false;
    }

    if (state.frequency.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Frequência é obrigatória');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final medication = Medication(
        id: state.medication?.id ?? '',
        animalId: state.animalId!,
        name: state.name.trim(),
        dosage: state.dosage.trim(),
        frequency: state.frequency.trim(),
        duration: state.duration.trim().isEmpty ? null : state.duration.trim(),
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        prescribedBy: state.prescribedBy.trim().isEmpty ? null : state.prescribedBy.trim(),
        type: state.type,
        startDate: state.startDate,
        endDate: state.endDate,
        createdAt: state.medication?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (state.isEditing) {
        await ref.read(medicationsProvider.notifier).updateMedication(medication);
      } else {
        await ref.read(medicationsProvider.notifier).addMedication(medication);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao salvar medicamento: $e',
      );
      return false;
    }
  }

  Future<bool> delete() async {
    if (state.medication == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await ref.read(medicationsProvider.notifier).deleteMedication(state.medication!.id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao excluir medicamento: $e',
      );
      return false;
    }
  }
}
