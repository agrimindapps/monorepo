/// Entity representing dashboard statistics
class HomeStats {
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

  const HomeStats({
    required this.totalAnimals,
    required this.upcomingAppointments,
    required this.pendingVaccinations,
    required this.activeMedications,
    required this.totalReminders,
    required this.overdueItems,
    required this.todayTasks,
    this.nextAppointment,
    this.nextVaccination,
    this.speciesBreakdown = const {},
    this.averageAge = 0.0,
  });

  /// Computed property: whether there are urgent tasks
  bool get hasUrgentTasks => overdueItems > 0 || todayTasks > 0;

  /// Computed property: health status string
  String get healthStatus =>
      overdueItems > 5 ? 'Atenção' : overdueItems > 0 ? 'Cuidado' : 'Em dia';

  /// Copy with pattern
  HomeStats copyWith({
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
  }) {
    return HomeStats(
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
    );
  }
}
