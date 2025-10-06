import 'package:core/core.dart';

import '../../../animals/domain/entities/animal_enums.dart';
import '../../../animals/presentation/providers/animals_provider.dart';
class HomeNotificationsState {
  final int unreadCount;
  final List<String> recentNotifications;
  final bool hasUrgentAlerts;

  const HomeNotificationsState({
    this.unreadCount = 0,
    this.recentNotifications = const [],
    this.hasUrgentAlerts = false,
  });

  HomeNotificationsState copyWith({
    int? unreadCount,
    List<String>? recentNotifications,
    bool? hasUrgentAlerts,
  }) {
    return HomeNotificationsState(
      unreadCount: unreadCount ?? this.unreadCount,
      recentNotifications: recentNotifications ?? this.recentNotifications,
      hasUrgentAlerts: hasUrgentAlerts ?? this.hasUrgentAlerts,
    );
  }
}
class HomeStatsState {
  final int totalAnimals;
  final int upcomingAppointments;
  final int pendingVaccinations;
  final int activeMedications;
  final int totalReminders;
  final int overdueItems;
  final int todayTasks;
  final String? nextAppointment;
  final String? nextVaccination;
  final Map<String, int> speciesBreakdown;
  final double averageAge;
  final bool isLoading;

  const HomeStatsState({
    this.totalAnimals = 0,
    this.upcomingAppointments = 0,
    this.pendingVaccinations = 0,
    this.activeMedications = 0,
    this.totalReminders = 0,
    this.overdueItems = 0,
    this.todayTasks = 0,
    this.nextAppointment,
    this.nextVaccination,
    this.speciesBreakdown = const {},
    this.averageAge = 0.0,
    this.isLoading = false,
  });

  HomeStatsState copyWith({
    int? totalAnimals,
    int? upcomingAppointments,
    int? pendingVaccinations,
    int? activeMedications,
    int? totalReminders,
    int? overdueItems,
    int? todayTasks,
    String? nextAppointment,
    String? nextVaccination,
    Map<String, int>? speciesBreakdown,
    double? averageAge,
    bool? isLoading,
  }) {
    return HomeStatsState(
      totalAnimals: totalAnimals ?? this.totalAnimals,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      pendingVaccinations: pendingVaccinations ?? this.pendingVaccinations,
      activeMedications: activeMedications ?? this.activeMedications,
      totalReminders: totalReminders ?? this.totalReminders,
      overdueItems: overdueItems ?? this.overdueItems,
      todayTasks: todayTasks ?? this.todayTasks,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      nextVaccination: nextVaccination ?? this.nextVaccination,
      speciesBreakdown: speciesBreakdown ?? this.speciesBreakdown,
      averageAge: averageAge ?? this.averageAge,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasUrgentTasks => overdueItems > 0 || todayTasks > 0;
  String get healthStatus => overdueItems > 5 ? 'Atenção' : overdueItems > 0 ? 'Cuidado' : 'Em dia';
}
class HomeStatusState {
  final bool isLoading;
  final bool isOnline;
  final String? errorMessage;
  final DateTime lastUpdated;

  const HomeStatusState({
    this.isLoading = false,
    this.isOnline = true,
    this.errorMessage,
    required this.lastUpdated,
  });

  HomeStatusState copyWith({
    bool? isLoading,
    bool? isOnline,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return HomeStatusState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
class HomeNotificationsNotifier extends StateNotifier<HomeNotificationsState> {
  HomeNotificationsNotifier() : super(const HomeNotificationsState());

  Future<void> loadNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    state = state.copyWith(
      unreadCount: 3,
      recentNotifications: [
        'Consulta veterinária amanhã',
        'Vacina do Max vence em 2 dias',
        'Medicação da Luna - horário das 18h',
      ],
      hasUrgentAlerts: true,
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      unreadCount: 0,
      hasUrgentAlerts: false,
    );
  }
}
class HomeStatsNotifier extends StateNotifier<HomeStatsState> {
  final Ref ref;
  
  HomeStatsNotifier(this.ref) : super(const HomeStatsState());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final animalsState = ref.read(animalsProvider);
      final animals = animalsState.animals;
      final Map<String, int> speciesBreakdown = {};
      double totalAge = 0;
      int animalsWithAge = 0;
      
      for (final animal in animals) {
        final speciesName = animal.species.displayName;
        speciesBreakdown[speciesName] = (speciesBreakdown[speciesName] ?? 0) + 1;
        
        if (animal.birthDate != null) {
          totalAge += animal.ageInMonths;
          animalsWithAge++;
        }
      }
      
      final averageAge = animalsWithAge > 0 ? totalAge / animalsWithAge : 0.0;
      final overdueItems = (animals.length * 0.1).round(); // 10% have overdue items
      final todayTasks = (animals.length * 0.2).round(); // 20% have tasks today
      
      state = state.copyWith(
        totalAnimals: animals.length,
        upcomingAppointments: 1,
        pendingVaccinations: (animals.length * 0.3).round(),
        activeMedications: (animals.length * 0.4).round(),
        totalReminders: (animals.length * 2), // 2 reminders per animal
        overdueItems: overdueItems,
        todayTasks: todayTasks,
        nextAppointment: animals.isNotEmpty ? 'Consulta do ${animals.first.name}' : null,
        nextVaccination: animals.isNotEmpty ? 'Vacina antirrábica - ${animals.first.name}' : null,
        speciesBreakdown: speciesBreakdown,
        averageAge: averageAge,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        totalAnimals: 0,
        upcomingAppointments: 0,
        pendingVaccinations: 0,
        activeMedications: 0,
        totalReminders: 0,
        overdueItems: 0,
        todayTasks: 0,
        speciesBreakdown: const {},
        averageAge: 0.0,
        isLoading: false,
      );
    }
  }

  void refreshStats() {
    loadStats();
  }
}
class HomeStatusNotifier extends StateNotifier<HomeStatusState> {
  HomeStatusNotifier() : super(HomeStatusState(lastUpdated: DateTime.now()));

  Future<void> checkStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        isLoading: false,
        isOnline: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isOnline: false,
        errorMessage: 'Erro ao verificar status: ${e.toString()}',
      );
    }
  }

  void setOfflineMode() {
    state = state.copyWith(
      isOnline: false,
      lastUpdated: DateTime.now(),
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
final homeNotificationsProvider = StateNotifierProvider<HomeNotificationsNotifier, HomeNotificationsState>((ref) {
  return HomeNotificationsNotifier();
});

final homeStatsProvider = StateNotifierProvider<HomeStatsNotifier, HomeStatsState>((ref) {
  return HomeStatsNotifier(ref);
});

final homeStatusProvider = StateNotifierProvider<HomeStatusNotifier, HomeStatusState>((ref) {
  return HomeStatusNotifier();
});
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(homeNotificationsProvider).unreadCount > 0;
});

final hasUrgentAlertsProvider = Provider<bool>((ref) {
  return ref.watch(homeNotificationsProvider).hasUrgentAlerts;
});

final isHomeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeStatusProvider).isLoading;
});

final homeErrorProvider = Provider<String?>((ref) {
  return ref.watch(homeStatusProvider).errorMessage;
});
