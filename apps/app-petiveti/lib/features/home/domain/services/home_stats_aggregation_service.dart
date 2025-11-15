import '../../../animals/domain/entities/animal.dart';
import '../../../animals/domain/entities/animal_enums.dart';

/// Data class for aggregated home statistics
class HomeStatsData {
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

  const HomeStatsData({
    required this.totalAnimals,
    required this.upcomingAppointments,
    required this.pendingVaccinations,
    required this.activeMedications,
    required this.totalReminders,
    required this.overdueItems,
    required this.todayTasks,
    this.nextAppointment,
    this.nextVaccination,
    required this.speciesBreakdown,
    required this.averageAge,
  });
}

/// Service specialized in home statistics aggregation
/// Aggregates data from multiple sources to compute home dashboard statistics
/// Single Responsibility: Statistical data aggregation for home dashboard
class HomeStatsAggregationService {
  /// Aggregates statistics from a list of animals
  HomeStatsData aggregateStats(List<Animal> animals) {
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
    final overdueItems = (animals.length * 0.1)
        .round(); // 10% have overdue items
    final todayTasks = (animals.length * 0.2).round(); // 20% have tasks today

    return HomeStatsData(
      totalAnimals: animals.length,
      upcomingAppointments: 1,
      pendingVaccinations: (animals.length * 0.3).round(),
      activeMedications: (animals.length * 0.4).round(),
      totalReminders: animals.length * 2, // 2 reminders per animal
      overdueItems: overdueItems,
      todayTasks: todayTasks,
      nextAppointment: animals.isNotEmpty
          ? 'Consulta do ${animals.first.name}'
          : null,
      nextVaccination: animals.isNotEmpty
          ? 'Vacina antirrábica - ${animals.first.name}'
          : null,
      speciesBreakdown: speciesBreakdown,
      averageAge: averageAge,
    );
  }

  /// Calculates urgency status based on stats
  String calculateHealthStatus(int overdueItems) {
    return overdueItems > 5
        ? 'Atenção'
        : overdueItems > 0
        ? 'Cuidado'
        : 'Em dia';
  }

  /// Determines if there are urgent tasks pending
  bool hasUrgentTasks(int overdueItems, int todayTasks) {
    return overdueItems > 0 || todayTasks > 0;
  }
}
