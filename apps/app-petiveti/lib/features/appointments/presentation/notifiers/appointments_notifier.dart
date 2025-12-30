import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/usecases/add_appointment.dart';
import '../../domain/usecases/delete_appointment.dart';
import '../../domain/usecases/get_appointment_by_id.dart';
import '../../domain/usecases/get_appointments.dart';
import '../../domain/usecases/get_upcoming_appointments.dart';
import '../../domain/usecases/update_appointment.dart';
import '../providers/appointments_providers.dart';

part 'appointments_notifier.g.dart';

class AppointmentState {
  final List<Appointment> appointments;
  final List<Appointment> upcomingAppointments;
  final bool isLoading;
  final String? errorMessage;
  final Appointment? selectedAppointment;

  const AppointmentState({
    this.appointments = const [],
    this.upcomingAppointments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedAppointment,
  });

  AppointmentState copyWith({
    List<Appointment>? appointments,
    List<Appointment>? upcomingAppointments,
    bool? isLoading,
    String? errorMessage,
    Appointment? selectedAppointment,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedAppointment: clearSelected ? null : (selectedAppointment ?? this.selectedAppointment),
    );
  }
}

@riverpod
class AppointmentsNotifier extends _$AppointmentsNotifier {
  late final GetAppointments _getAppointments;
  late final GetUpcomingAppointments _getUpcomingAppointments;
  late final GetAppointmentById _getAppointmentById;
  late final AddAppointment _addAppointment;
  late final UpdateAppointment _updateAppointment;
  late final DeleteAppointment _deleteAppointment;

  @override
  AppointmentState build() {
    _getAppointments = ref.watch(getAppointmentsProvider);
    _getUpcomingAppointments = ref.watch(getUpcomingAppointmentsProvider);
    _getAppointmentById = ref.watch(getAppointmentByIdProvider);
    _addAppointment = ref.watch(addAppointmentProvider);
    _updateAppointment = ref.watch(updateAppointmentProvider);
    _deleteAppointment = ref.watch(deleteAppointmentProvider);

    return const AppointmentState();
  }

  Future<void> loadAppointments(String animalId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAppointments(GetAppointmentsParams(animalId: animalId));

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (appointments) => state = state.copyWith(
        isLoading: false,
        appointments: appointments,
        clearError: true,
      ),
    );
  }

  Future<void> loadUpcomingAppointments(String animalId) async {
    final result = await _getUpcomingAppointments(
      GetUpcomingAppointmentsParams(animalId: animalId),
    );

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (upcomingAppointments) => state = state.copyWith(
        upcomingAppointments: upcomingAppointments,
        clearError: true,
      ),
    );
  }

  Future<void> loadAppointmentById(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAppointmentById(GetAppointmentByIdParams(id: id));

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (appointment) => state = state.copyWith(
        isLoading: false,
        selectedAppointment: appointment,
        clearError: true,
      ),
    );
  }

  Future<bool> addAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addAppointment(AddAppointmentParams(appointment: appointment));

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (newAppointment) {
        state = state.copyWith(
          isLoading: false,
          appointments: [newAppointment, ...state.appointments],
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateAppointment(UpdateAppointmentParams(appointment: appointment));

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedAppointment) {
        final updatedAppointments = state.appointments.map((appt) {
          return appt.id == updatedAppointment.id ? updatedAppointment : appt;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          appointments: updatedAppointments,
          selectedAppointment: updatedAppointment,
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<bool> deleteAppointment(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deleteAppointment(DeleteAppointmentParams(id: id));

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final updatedAppointments = state.appointments.where((appt) => appt.id != id).toList();
        final updatedUpcoming = state.upcomingAppointments.where((appt) => appt.id != id).toList();

        state = state.copyWith(
          isLoading: false,
          appointments: updatedAppointments,
          upcomingAppointments: updatedUpcoming,
          clearError: true,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSelectedAppointment() {
    state = state.copyWith(clearSelected: true);
  }

  void clearAppointments() {
    state = state.copyWith(
      appointments: [],
      upcomingAppointments: [],
      clearError: true,
      clearSelected: true,
    );
  }
}

// Derived providers
@riverpod
List<Appointment> appointmentsList(Ref ref) {
  return ref.watch(appointmentsProvider).appointments;
}

@riverpod
List<Appointment> upcomingAppointmentsList(Ref ref) {
  return ref.watch(appointmentsProvider).upcomingAppointments;
}

@riverpod
bool appointmentsLoading(Ref ref) {
  return ref.watch(appointmentsProvider).isLoading;
}

@riverpod
String? appointmentsError(Ref ref) {
  return ref.watch(appointmentsProvider).errorMessage;
}

@riverpod
Appointment? selectedAppointment(Ref ref) {
  return ref.watch(appointmentsProvider).selectedAppointment;
}
