import 'package:core/core.dart';

import '../entities/animal_base_entity.dart';
import '../entities/bovine_entity.dart';
import '../entities/equine_entity.dart';

/// Service especializado para analytics e métricas de livestock
///
/// Responsabilidade única: Calcular métricas, análises e relatórios
/// Seguindo Single Responsibility Principle
@singleton
class LivestockAnalyticsService {
  /// Calcula métricas gerais do rebanho
  LivestockMetrics calculateGeneralMetrics({
    required List<BovineEntity> bovines,
    required List<EquineEntity> equines,
  }) {
    final activeBovines = bovines.where((b) => b.isActive).toList();
    final activeEquines = equines.where((e) => e.isActive).toList();

    return LivestockMetrics(
      totalAnimals: bovines.length + equines.length,
      totalBovines: bovines.length,
      totalEquines: equines.length,
      activeBovines: activeBovines.length,
      activeEquines: activeEquines.length,
      inactiveBovines: bovines.length - activeBovines.length,
      inactiveEquines: equines.length - activeEquines.length,
      bovinesPercentage: _calculatePercentage(
        bovines.length,
        bovines.length + equines.length,
      ),
      equinesPercentage: _calculatePercentage(
        equines.length,
        bovines.length + equines.length,
      ),
      lastCalculated: DateTime.now(),
    );
  }

  /// Calcula distribuição por raças de bovinos
  Map<String, int> calculateBovineBreedDistribution(
    List<BovineEntity> bovines,
  ) {
    final distribution = <String, int>{};

    for (final bovine in bovines.where((b) => b.isActive)) {
      final breed = bovine.breed;
      distribution[breed] = (distribution[breed] ?? 0) + 1;
    }

    return Map.fromEntries(
      distribution.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  /// Calcula distribuição por aptidões de bovinos
  Map<BovineAptitude, int> calculateAptitudeDistribution(
    List<BovineEntity> bovines,
  ) {
    final distribution = <BovineAptitude, int>{};

    for (final bovine in bovines.where((b) => b.isActive)) {
      final aptitude = bovine.aptitude;
      distribution[aptitude] = (distribution[aptitude] ?? 0) + 1;
    }

    return distribution;
  }

  /// Calcula distribuição por sistema de criação
  Map<BreedingSystem, int> calculateBreedingSystemDistribution(
    List<BovineEntity> bovines,
  ) {
    final distribution = <BreedingSystem, int>{};

    for (final bovine in bovines.where((b) => b.isActive)) {
      final system = bovine.breedingSystem;
      distribution[system] = (distribution[system] ?? 0) + 1;
    }

    return distribution;
  }

  /// Calcula distribuição por países de origem
  Map<String, int> calculateOriginCountryDistribution(
    List<AnimalBaseEntity> animals,
  ) {
    final distribution = <String, int>{};

    for (final animal in animals.where((a) => a.isActive)) {
      final country = animal.originCountry;
      distribution[country] = (distribution[country] ?? 0) + 1;
    }

    return Map.fromEntries(
      distribution.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  /// Calcula métricas de crescimento mensal
  GrowthMetrics calculateGrowthMetrics(List<AnimalBaseEntity> animals) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);
    final last3Months = DateTime(now.year, now.month - 3, now.day);

    final recentAnimals =
        animals
            .where(
              (a) => a.createdAt != null && a.createdAt!.isAfter(lastMonth),
            )
            .length;

    final last3MonthsAnimals =
        animals
            .where(
              (a) => a.createdAt != null && a.createdAt!.isAfter(last3Months),
            )
            .length;

    return GrowthMetrics(
      totalAnimals: animals.length,
      newThisMonth: recentAnimals,
      newLast3Months: last3MonthsAnimals,
      monthlyGrowthRate: _calculateGrowthRate(
        animals.length - recentAnimals,
        recentAnimals,
      ),
      quarterlyGrowthRate: _calculateGrowthRate(
        animals.length - last3MonthsAnimals,
        last3MonthsAnimals,
      ),
    );
  }

  /// Calcula métricas de idade dos animais baseado na data de criação
  AgeMetrics calculateAgeMetrics(List<AnimalBaseEntity> animals) {
    if (animals.isEmpty) {
      return const AgeMetrics(
        averageAgeMonths: 0,
        youngestAgeMonths: 0,
        oldestAgeMonths: 0,
        animalsUnder1Year: 0,
        animals1to5Years: 0,
        animalsOver5Years: 0,
      );
    }

    final ages =
        animals.where((a) => a.createdAt != null).map((animal) {
          return DateTime.now().difference(animal.createdAt!).inDays ~/
              30; // Aproximação em meses
        }).toList();

    if (ages.isEmpty) {
      return const AgeMetrics(
        averageAgeMonths: 0,
        youngestAgeMonths: 0,
        oldestAgeMonths: 0,
        animalsUnder1Year: 0,
        animals1to5Years: 0,
        animalsOver5Years: 0,
      );
    }

    ages.sort();

    return AgeMetrics(
      averageAgeMonths: ages.reduce((a, b) => a + b) ~/ ages.length,
      youngestAgeMonths: ages.first,
      oldestAgeMonths: ages.last,
      animalsUnder1Year: ages.where((age) => age < 12).length,
      animals1to5Years: ages.where((age) => age >= 12 && age < 60).length,
      animalsOver5Years: ages.where((age) => age >= 60).length,
    );
  }

  /// Gera relatório de saúde do rebanho
  HealthReport generateHealthReport({
    required List<BovineEntity> bovines,
    required List<EquineEntity> equines,
  }) {
    final totalAnimals = bovines.length + equines.length;
    final activeAnimals =
        bovines.where((b) => b.isActive).length +
        equines.where((e) => e.isActive).length;

    final healthScore =
        totalAnimals > 0 ? (activeAnimals / totalAnimals * 100) : 100.0;

    return HealthReport(
      totalAnimals: totalAnimals,
      activeAnimals: activeAnimals,
      inactiveAnimals: totalAnimals - activeAnimals,
      healthScore: healthScore,
      recommendations: _generateHealthRecommendations(healthScore),
      generatedAt: DateTime.now(),
    );
  }

  double _calculatePercentage(int value, int total) {
    return total > 0 ? (value / total * 100) : 0.0;
  }

  double _calculateGrowthRate(int previous, int current) {
    return previous > 0 ? ((current - previous) / previous * 100) : 0.0;
  }

  List<String> _generateHealthRecommendations(double healthScore) {
    final recommendations = <String>[];

    if (healthScore < 80) {
      recommendations.add('Revisar animais inativos e investigar causas');
    }

    if (healthScore < 60) {
      recommendations.add('Implementar plano de recuperação urgente');
    }

    if (healthScore >= 95) {
      recommendations.add('Excelente saúde do rebanho, manter práticas atuais');
    }

    return recommendations;
  }
}

class LivestockMetrics {
  final int totalAnimals;
  final int totalBovines;
  final int totalEquines;
  final int activeBovines;
  final int activeEquines;
  final int inactiveBovines;
  final int inactiveEquines;
  final double bovinesPercentage;
  final double equinesPercentage;
  final DateTime lastCalculated;

  const LivestockMetrics({
    required this.totalAnimals,
    required this.totalBovines,
    required this.totalEquines,
    required this.activeBovines,
    required this.activeEquines,
    required this.inactiveBovines,
    required this.inactiveEquines,
    required this.bovinesPercentage,
    required this.equinesPercentage,
    required this.lastCalculated,
  });
}

class GrowthMetrics {
  final int totalAnimals;
  final int newThisMonth;
  final int newLast3Months;
  final double monthlyGrowthRate;
  final double quarterlyGrowthRate;

  const GrowthMetrics({
    required this.totalAnimals,
    required this.newThisMonth,
    required this.newLast3Months,
    required this.monthlyGrowthRate,
    required this.quarterlyGrowthRate,
  });
}

class AgeMetrics {
  final int averageAgeMonths;
  final int youngestAgeMonths;
  final int oldestAgeMonths;
  final int animalsUnder1Year;
  final int animals1to5Years;
  final int animalsOver5Years;

  const AgeMetrics({
    required this.averageAgeMonths,
    required this.youngestAgeMonths,
    required this.oldestAgeMonths,
    required this.animalsUnder1Year,
    required this.animals1to5Years,
    required this.animalsOver5Years,
  });
}

class HealthReport {
  final int totalAnimals;
  final int activeAnimals;
  final int inactiveAnimals;
  final double healthScore;
  final List<String> recommendations;
  final DateTime generatedAt;

  const HealthReport({
    required this.totalAnimals,
    required this.activeAnimals,
    required this.inactiveAnimals,
    required this.healthScore,
    required this.recommendations,
    required this.generatedAt,
  });
}
