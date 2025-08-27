import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado para notificações da home
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

// Estado para estatísticas da home
class HomeStatsState {
  final int totalAnimals;
  final int upcomingAppointments;
  final int pendingVaccinations;
  final int activeMedications;

  const HomeStatsState({
    this.totalAnimals = 0,
    this.upcomingAppointments = 0,
    this.pendingVaccinations = 0,
    this.activeMedications = 0,
  });

  HomeStatsState copyWith({
    int? totalAnimals,
    int? upcomingAppointments,
    int? pendingVaccinations,
    int? activeMedications,
  }) {
    return HomeStatsState(
      totalAnimals: totalAnimals ?? this.totalAnimals,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      pendingVaccinations: pendingVaccinations ?? this.pendingVaccinations,
      activeMedications: activeMedications ?? this.activeMedications,
    );
  }
}

// Estado para status geral da home
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

// Notifier para notificações
class HomeNotificationsNotifier extends StateNotifier<HomeNotificationsState> {
  HomeNotificationsNotifier() : super(const HomeNotificationsState());

  Future<void> loadNotifications() async {
    // Simulate loading notifications
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

// Notifier para estatísticas
class HomeStatsNotifier extends StateNotifier<HomeStatsState> {
  HomeStatsNotifier() : super(const HomeStatsState());

  Future<void> loadStats() async {
    // Simulate loading stats from repositories
    await Future<void>.delayed(const Duration(milliseconds: 800));
    
    state = state.copyWith(
      totalAnimals: 2,
      upcomingAppointments: 1,
      pendingVaccinations: 1,
      activeMedications: 3,
    );
  }

  void refreshStats() {
    loadStats();
  }
}

// Notifier para status
class HomeStatusNotifier extends StateNotifier<HomeStatusState> {
  HomeStatusNotifier() : super(HomeStatusState(lastUpdated: DateTime.now()));

  Future<void> checkStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // Simulate network check
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

// Providers
final homeNotificationsProvider = StateNotifierProvider<HomeNotificationsNotifier, HomeNotificationsState>((ref) {
  return HomeNotificationsNotifier();
});

final homeStatsProvider = StateNotifierProvider<HomeStatsNotifier, HomeStatsState>((ref) {
  return HomeStatsNotifier();
});

final homeStatusProvider = StateNotifierProvider<HomeStatusNotifier, HomeStatusState>((ref) {
  return HomeStatusNotifier();
});

// Computed providers
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