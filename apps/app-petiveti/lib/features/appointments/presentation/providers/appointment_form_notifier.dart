import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/add_appointment.dart';
import '../../domain/usecases/delete_appointment.dart';
import '../../domain/usecases/get_appointment_by_id.dart';
import '../../domain/usecases/update_appointment.dart';
import 'appointment_form_state.dart';
import 'appointments_providers.dart';

part 'appointment_form_notifier.g.dart';

@riverpod
class AppointmentFormNotifier extends _$AppointmentFormNotifier {
  @override
  AppointmentFormState build(String animalId) {
    return AppointmentFormState.initial();
  }

  /// Inicializa o formulário
  Future<void> initialize({
    String? appointmentId,
    Appointment? appointment,
  }) async {
    state = state.copyWith(isLoading: true, clearErrors: true);

    try {
      // Carregar animal
      final animal = await ref.read(animalByIdProvider(animalId).future);

      if (animal == null) {
        state = state.copyWith(
          isLoading: false,
          reasonError: 'Animal não encontrado',
        );
        return;
      }

      // Se tem appointmentId, carregar dados
      Appointment? loadedAppointment = appointment;
      if (appointmentId != null && appointment == null) {
        final appointments = await ref.read(appointmentsProvider(animalId).future);
        loadedAppointment = appointments.firstWhere(
          (a) => a.id == appointmentId,
          orElse: () => throw Exception('Consulta não encontrada'),
        );
      }

      // Preencher estado com dados carregados
      if (loadedAppointment != null) {
        state = AppointmentFormState(
          isInitialized: true,
          isLoading: false,
          animal: animal,
          appointment: loadedAppointment,
          veterinarianName: loadedAppointment.veterinarianName,
          reason: loadedAppointment.reason,
          diagnosis: loadedAppointment.diagnosis,
          notes: loadedAppointment.notes,
          date: loadedAppointment.date,
          status: loadedAppointment.status,
          cost: loadedAppointment.cost,
        );
      } else {
        // Novo registro
        state = state.copyWith(
          isInitialized: true,
          isLoading: false,
          animal: animal,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        reasonError: 'Erro ao carregar dados: $e',
      );
    }
  }

  /// Atualiza campo de texto
  void updateField(String field, String value) {
    switch (field) {
      case 'veterinarianName':
        state = state.copyWith(
          veterinarianName: value,
          veterinarianNameError: null,
        );
        break;
      case 'reason':
        state = state.copyWith(reason: value, reasonError: null);
        break;
      case 'diagnosis':
        state = state.copyWith(diagnosis: value);
        break;
      case 'notes':
        state = state.copyWith(notes: value);
        break;
    }
  }

  /// Atualiza data
  void updateDate(DateTime date) {
    state = state.copyWith(date: date, dateError: null);
  }

  /// Atualiza status
  void updateStatus(AppointmentStatus status) {
    state = state.copyWith(status: status);
  }

  /// Atualiza custo
  void updateCost(double? cost) {
    state = state.copyWith(cost: cost, costError: null);
  }

  /// Valida formulário
  bool validate() {
    String? veterinarianNameError;
    String? reasonError;
    String? dateError;
    String? costError;

    if (state.veterinarianName.isEmpty) {
      veterinarianNameError = 'Nome do veterinário é obrigatório';
    }

    if (state.reason.isEmpty) {
      reasonError = 'Motivo da consulta é obrigatório';
    }

    if (state.cost != null && state.cost! < 0) {
      costError = 'Custo não pode ser negativo';
    }

    state = state.copyWith(
      veterinarianNameError: veterinarianNameError,
      reasonError: reasonError,
      dateError: dateError,
      costError: costError,
    );

    return state.isValid;
  }

  /// Submete formulário
  Future<bool> submit() async {
    if (!validate()) return false;

    state = state.copyWith(isSaving: true);

    try {
      final now = DateTime.now();

      final appointment = Appointment(
        id: state.appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        animalId: animalId,
        veterinarianName: state.veterinarianName,
        date: state.date,
        reason: state.reason,
        diagnosis: state.diagnosis,
        notes: state.notes,
        status: state.status,
        cost: state.cost,
        createdAt: state.appointment?.createdAt ?? now,
        updatedAt: now,
      );

      if (state.appointment == null) {
        final addUseCase = ref.read(addAppointmentProvider);
        await addUseCase(AddAppointmentParams(appointment));
      } else {
        final updateUseCase = ref.read(updateAppointmentProvider);
        await updateUseCase(UpdateAppointmentParams(appointment));
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        reasonError: 'Erro ao salvar: $e',
      );
      return false;
    }
  }

  /// Exclui consulta
  Future<bool> delete() async {
    if (state.appointment == null) return false;

    state = state.copyWith(isSaving: true);

    try {
      final deleteUseCase = ref.read(deleteAppointmentProvider);
      await deleteUseCase(DeleteAppointmentParams(state.appointment!.id));
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        reasonError: 'Erro ao excluir: $e',
      );
      return false;
    }
  }
}
