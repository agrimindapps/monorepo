import '../entities/weight.dart';

/// **ISP - Interface Segregation Principle**
/// Stream operations (Watch/real-time)
/// Single Responsibility: Handle real-time weight data updates
abstract class WeightStreamRepository {
  /// Retorna stream de registros de peso para observar mudanças em tempo real
  Stream<List<Weight>> watchWeights();

  /// Retorna stream de registros de peso de um animal específico
  Stream<List<Weight>> watchWeightsByAnimalId(String animalId);
}
