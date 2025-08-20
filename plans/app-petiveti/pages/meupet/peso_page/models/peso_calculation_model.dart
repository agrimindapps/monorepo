// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';

/// Model for peso calculations and business logic
class PesoCalculationModel {
  
  /// Calculates BMI for dogs (approximate formula)
  static double? calculateBMI(double weight, Animal animal) {
    // BMI calculation varies by animal type and breed
    // This is a simplified calculation
    if (animal.especie == 'Cachorro') {
      // Approximate formula for dogs: weight / (height^2 * 0.45)
      // Using a simplified version since we don't have height data
      return weight / 0.45; // Simplified BMI approximation
    } else if (animal.especie == 'Gato') {
      // Cats have different body structure
      return weight / 0.35; // Simplified BMI approximation for cats
    }
    
    return null; // Unknown animal type
  }

  /// Determines weight category based on animal type and weight
  static WeightCategory getWeightCategory(double weight, Animal animal) {
    if (animal.especie == 'Cachorro') {
      return _getDogWeightCategory(weight, animal.raca);
    } else if (animal.especie == 'Gato') {
      return _getCatWeightCategory(weight);
    }
    
    return WeightCategory.normal; // Default for unknown types
  }

  /// Get ideal weight range for animal
  static WeightRange? getIdealWeightRange(Animal animal) {
    if (animal.especie == 'Cachorro') {
      return _getDogIdealWeight(animal.raca);
    } else if (animal.especie == 'Gato') {
      return _getCatIdealWeight();
    }
    
    return null;
  }

  /// Calculate weight change percentage
  static double calculateWeightChangePercentage(double currentWeight, double previousWeight) {
    if (previousWeight == 0) return 0;
    return ((currentWeight - previousWeight) / previousWeight) * 100;
  }

  /// Calculate average weight over time period
  static double calculateAverageWeight(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0;
    
    final totalWeight = pesos.fold<double>(0, (sum, peso) => sum + peso.peso);
    return totalWeight / pesos.length;
  }

  /// Get weight trend over multiple records
  static WeightTrend getWeightTrend(List<PesoAnimal> pesos) {
    if (pesos.length < 3) return WeightTrend.stable;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    // Take last 3 records to determine trend
    final recentPesos = sortedPesos.length >= 3 
        ? sortedPesos.sublist(sortedPesos.length - 3)
        : sortedPesos;
    
    if (recentPesos.length < 3) return WeightTrend.stable;
    
    // Calculate differences
    final diff1 = recentPesos[1].peso - recentPesos[0].peso;
    final diff2 = recentPesos[2].peso - recentPesos[1].peso;
    
    // Determine trend
    if (diff1 > 0.1 && diff2 > 0.1) return WeightTrend.consistentGaining;
    if (diff1 < -0.1 && diff2 < -0.1) return WeightTrend.consistentLosing;
    if (diff1 > 0.1 || diff2 > 0.1) return WeightTrend.gaining;
    if (diff1 < -0.1 || diff2 < -0.1) return WeightTrend.losing;
    
    return WeightTrend.stable;
  }

  /// Calculate days since last weighing
  static int daysSinceLastWeighing(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    
    final lastWeighing = DateTime.fromMillisecondsSinceEpoch(sortedPesos.first.dataPesagem);
    final now = DateTime.now();
    
    return now.difference(lastWeighing).inDays;
  }

  /// Get recommended weighing frequency based on animal age and condition
  static int getRecommendedWeighingFrequency(Animal animal, WeightCategory category) {
    // Puppies and kittens need more frequent weighing
    final age = _calculateAge(animal.dataNascimento);
    
    if (age < 365) { // Less than 1 year
      return 7; // Weekly
    } else if (category == WeightCategory.underweight || category == WeightCategory.overweight) {
      return 14; // Bi-weekly for weight management
    } else {
      return 30; // Monthly for healthy adults
    }
  }

  /// Calculate age in days
  static int _calculateAge(int birthTimestamp) {
    final birth = DateTime.fromMillisecondsSinceEpoch(birthTimestamp);
    final now = DateTime.now();
    return now.difference(birth).inDays;
  }

  /// Dog weight categories based on breed
  static WeightCategory _getDogWeightCategory(double weight, String? breed) {
    // This would need a comprehensive breed database
    // For now, using general categories
    if (weight < 5) return WeightCategory.underweight;
    if (weight < 25) return WeightCategory.normal;
    if (weight < 40) return WeightCategory.normal;
    return WeightCategory.overweight;
  }

  /// Cat weight categories
  static WeightCategory _getCatWeightCategory(double weight) {
    if (weight < 2.5) return WeightCategory.underweight;
    if (weight <= 5.5) return WeightCategory.normal;
    if (weight <= 7) return WeightCategory.overweight;
    return WeightCategory.obese;
  }

  /// Dog ideal weight ranges by breed (simplified)
  static WeightRange _getDogIdealWeight(String? breed) {
    // This would need a comprehensive breed database
    // Using general ranges for now
    return const WeightRange(min: 5, max: 35);
  }

  /// Cat ideal weight range
  static WeightRange _getCatIdealWeight() {
    return const WeightRange(min: 2.5, max: 5.5);
  }

  /// Validate peso data
  static String? validatePeso(double peso, Animal animal) {
    if (peso <= 0) {
      return 'Peso deve ser maior que zero';
    }
    
    if (peso > 200) {
      return 'Peso muito alto, verifique se está correto';
    }
    
    if (animal.especie == 'Gato' && peso > 20) {
      return 'Peso muito alto para um gato';
    }
    
    if (animal.especie == 'Cachorro' && peso > 100) {
      return 'Peso muito alto, verifique se está correto';
    }
    
    return null; // Valid
  }

  /// Generate peso insights
  static List<String> generateInsights(List<PesoAnimal> pesos, Animal animal) {
    final insights = <String>[];
    
    if (pesos.isEmpty) {
      insights.add('Registre o primeiro peso do ${animal.nome}');
      return insights;
    }
    
    final trend = getWeightTrend(pesos);
    final daysSince = daysSinceLastWeighing(pesos);
    final category = getWeightCategory(pesos.last.peso, animal);
    
    // Trend insights
    switch (trend) {
      case WeightTrend.consistentGaining:
        insights.add('${animal.nome} está ganhando peso consistentemente');
        break;
      case WeightTrend.consistentLosing:
        insights.add('${animal.nome} está perdendo peso consistentemente');
        break;
      case WeightTrend.gaining:
        insights.add('${animal.nome} ganhou peso recentemente');
        break;
      case WeightTrend.losing:
        insights.add('${animal.nome} perdeu peso recentemente');
        break;
      case WeightTrend.stable:
        insights.add('Peso do ${animal.nome} está estável');
        break;
    }
    
    // Category insights
    switch (category) {
      case WeightCategory.underweight:
        insights.add('${animal.nome} está abaixo do peso ideal');
        break;
      case WeightCategory.overweight:
        insights.add('${animal.nome} está acima do peso ideal');
        break;
      case WeightCategory.obese:
        insights.add('${animal.nome} está obeso - consulte um veterinário');
        break;
      case WeightCategory.normal:
        insights.add('Peso do ${animal.nome} está normal');
        break;
    }
    
    // Frequency insights
    if (daysSince > 60) {
      insights.add('Faz tempo que ${animal.nome} não é pesado');
    }
    
    return insights;
  }
}

/// Weight categories
enum WeightCategory {
  underweight,
  normal,
  overweight,
  obese,
}

/// Weight trends
enum WeightTrend {
  consistentGaining,
  gaining,
  stable,
  losing,
  consistentLosing,
}

/// Weight range for ideal weights
class WeightRange {
  final double min;
  final double max;
  
  const WeightRange({
    required this.min,
    required this.max,
  });
  
  bool contains(double weight) {
    return weight >= min && weight <= max;
  }
  
  double get average => (min + max) / 2;
  
  @override
  String toString() => '${min.toStringAsFixed(1)}kg - ${max.toStringAsFixed(1)}kg';
}
