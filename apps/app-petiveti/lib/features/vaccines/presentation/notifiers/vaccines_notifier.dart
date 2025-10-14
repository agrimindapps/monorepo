import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/vaccine.dart';
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

part 'vaccines_notifier.g.dart';

class VaccinesState {
  final List<Vaccine> vaccines;
  final List<Vaccine> overdueVaccines;
  final List<Vaccine> upcomingVaccines;
  final bool isLoading;
  final String? error;
  final VaccinesFilter filter;
  final String searchQuery;

  const VaccinesState({
    this.vaccines = const [],
    this.overdueVaccines = const [],
    this.upcomingVaccines = const [],
    this.isLoading = false,
    this.error,
    this.filter = VaccinesFilter.all,
    this.searchQuery = '',
  });

  VaccinesState copyWith({
    List<Vaccine>? vaccines,
    List<Vaccine>? overdueVaccines,
    List<Vaccine>? upcomingVaccines,
    bool? isLoading,
    String? error,
    VaccinesFilter? filter,
    String? searchQuery,
  }) {
    return VaccinesState(
      vaccines: vaccines ?? this.vaccines,
      overdueVaccines: overdueVaccines ?? this.overdueVaccines,
      upcomingVaccines: upcomingVaccines ?? this.upcomingVaccines,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Vaccine> get filteredVaccines {
    List<Vaccine> filtered = List.from(vaccines);
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((vaccine) =>
          vaccine.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          vaccine.veterinarian.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    switch (filter) {
      case VaccinesFilter.all:
        return filtered;
      case VaccinesFilter.completed:
        return filtered.where((v) => v.isCompleted).toList();
      case VaccinesFilter.pending:
        return filtered.where((v) => v.isPending).toList();
      case VaccinesFilter.overdue:
        return filtered.where((v) => v.isOverdue).toList();
      case VaccinesFilter.dueToday:
        return filtered.where((v) => v.isDueToday).toList();
      case VaccinesFilter.dueSoon:
        return filtered.where((v) => v.isDueSoon).toList();
    }
  }

  int get totalVaccines => vaccines.length;
  int get completedCount => vaccines.where((v) => v.isCompleted).length;
  int get pendingCount => vaccines.where((v) => v.isPending).length;
  int get overdueCount => vaccines.where((v) => v.isOverdue).length;
}

enum VaccinesFilter {
  all,
  completed,
  pending,
  overdue,
  dueToday,
  dueSoon,
}

extension VaccinesFilterExtension on VaccinesFilter {
  String get displayName {
    switch (this) {
      case VaccinesFilter.all:
        return 'Todas';
      case VaccinesFilter.completed:
        return 'Concluídas';
      case VaccinesFilter.pending:
        return 'Pendentes';
      case VaccinesFilter.overdue:
        return 'Vencidas';
      case VaccinesFilter.dueToday:
        return 'Vencem Hoje';
      case VaccinesFilter.dueSoon:
        return 'Vencem em Breve';
    }
  }
}

@riverpod
class VaccinesNotifier extends _$VaccinesNotifier {
  late final GetVaccines _getVaccines;
  late final GetVaccineById _getVaccineById;
  late final GetVaccinesByAnimal _getVaccinesByAnimal;
  late final GetOverdueVaccines _getOverdueVaccines;
  late final GetUpcomingVaccines _getUpcomingVaccines;
  late final SearchVaccines _searchVaccines;
  late final AddVaccine _addVaccine;
  late final UpdateVaccine _updateVaccine;
  late final DeleteVaccine _deleteVaccine;
  late final MarkVaccineCompleted _markVaccineCompleted;
  late final ScheduleVaccineReminder _scheduleVaccineReminder;

  @override
  VaccinesState build() {
    _getVaccines = di.getIt<GetVaccines>();
    _getVaccineById = di.getIt<GetVaccineById>();
    _getVaccinesByAnimal = di.getIt<GetVaccinesByAnimal>();
    _getOverdueVaccines = di.getIt<GetOverdueVaccines>();
    _getUpcomingVaccines = di.getIt<GetUpcomingVaccines>();
    _searchVaccines = di.getIt<SearchVaccines>();
    _addVaccine = di.getIt<AddVaccine>();
    _updateVaccine = di.getIt<UpdateVaccine>();
    _deleteVaccine = di.getIt<DeleteVaccine>();
    _markVaccineCompleted = di.getIt<MarkVaccineCompleted>();
    _scheduleVaccineReminder = di.getIt<ScheduleVaccineReminder>();

    return const VaccinesState();
  }

  Future<void> loadVaccines() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _getVaccines(GetVaccinesParams.all()),
        _getOverdueVaccines(GetOverdueVaccinesParams.all()),
        _getUpcomingVaccines(GetUpcomingVaccinesParams.all()),
      ]);

      final vaccinesResult = results[0];
      final overdueResult = results[1];
      final upcomingResult = results[2];

      if (vaccinesResult.isLeft() || overdueResult.isLeft() || upcomingResult.isLeft()) {
        final error = vaccinesResult.fold((l) => l.message, (r) => null) ??
                     overdueResult.fold((l) => l.message, (r) => null) ??
                     upcomingResult.fold((l) => l.message, (r) => null);
        state = state.copyWith(isLoading: false, error: error);
        return;
      }

      vaccinesResult.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (vaccines) {
          overdueResult.fold(
            (failure) => state = state.copyWith(isLoading: false, error: failure.message),
            (overdueVaccines) {
              upcomingResult.fold(
                (failure) => state = state.copyWith(isLoading: false, error: failure.message),
                (upcomingVaccines) {
                  state = state.copyWith(
                    vaccines: vaccines,
                    overdueVaccines: overdueVaccines,
                    upcomingVaccines: upcomingVaccines,
                    isLoading: false,
                    error: null,
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadVaccinesByAnimal(String animalId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getVaccinesByAnimal(animalId);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (vaccines) => state = state.copyWith(
        vaccines: vaccines,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<void> addVaccine(Vaccine vaccine) async {
    final result = await _addVaccine(vaccine);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedVaccines = [vaccine, ...state.vaccines];
        state = state.copyWith(
          vaccines: updatedVaccines,
          error: null,
        );
      },
    );
  }

  Future<void> updateVaccine(Vaccine vaccine) async {
    final result = await _updateVaccine(vaccine);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedVaccines = state.vaccines.map((v) {
          return v.id == vaccine.id ? vaccine : v;
        }).toList();

        state = state.copyWith(
          vaccines: updatedVaccines,
          error: null,
        );
      },
    );
  }

  Future<void> deleteVaccine(String id) async {
    final result = await _deleteVaccine(id);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedVaccines = state.vaccines.where((v) => v.id != id).toList();
        state = state.copyWith(
          vaccines: updatedVaccines,
          error: null,
        );
      },
    );
  }

  Future<void> markAsCompleted(String id) async {
    final result = await _markVaccineCompleted(id);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (completedVaccine) {
        final updatedVaccines = state.vaccines.map((v) {
          return v.id == id ? completedVaccine : v;
        }).toList();

        state = state.copyWith(
          vaccines: updatedVaccines,
          error: null,
        );
      },
    );
  }

  Future<void> scheduleReminder(String vaccineId, DateTime reminderDate) async {
    final params = ScheduleVaccineReminderParams(vaccineId: vaccineId, reminderDate: reminderDate);
    final result = await _scheduleVaccineReminder(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (updatedVaccine) {
        final updatedVaccines = state.vaccines.map((v) {
          return v.id == vaccineId ? updatedVaccine : v;
        }).toList();

        state = state.copyWith(
          vaccines: updatedVaccines,
          error: null,
        );
      },
    );
  }

  Future<Vaccine?> getVaccineById(String id) async {
    final result = await _getVaccineById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (vaccine) => vaccine,
    );
  }

  Future<void> searchVaccines(String query) async {
    state = state.copyWith(searchQuery: query);

    if (query.isEmpty) {
      return;
    }

    final result = await _searchVaccines(SearchVaccinesParams.global(query));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (vaccines) => state = state.copyWith(
        vaccines: vaccines,
        error: null,
      ),
    );
  }

  void setFilter(VaccinesFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

// Derived providers
@riverpod
Future<Vaccine?> vaccineById(VaccineByIdRef ref, String id) async {
  final notifier = ref.read(vaccinesNotifierProvider.notifier);
  return await notifier.getVaccineById(id);
}

@riverpod
Future<Map<DateTime, List<Vaccine>>> vaccineCalendar(
  VaccineCalendarRef ref,
  DateTime startDate,
) async {
  final useCase = di.getIt<GetVaccineCalendar>();
  final endDate = startDate.add(const Duration(days: 30)); // 30 days calendar
  final result = await useCase(GetVaccineCalendarParams(startDate: startDate, endDate: endDate));

  return result.fold(
    (failure) => throw Exception(failure.message),
    (calendar) => calendar,
  );
}

@riverpod
VaccinesFilter vaccinesFilter(VaccinesFilterRef ref) {
  final state = ref.watch(vaccinesNotifierProvider);
  return state.filter;
}

@riverpod
Future<Map<String, int>> vaccineStatistics(VaccineStatisticsRef ref) async {
  final useCase = di.getIt<GetVaccineStatistics>();
  final result = await useCase(GetVaccineStatisticsParams.all());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (statistics) => statistics,
  );
}
