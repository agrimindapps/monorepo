import '../models/animal_model.dart';

/// Strategy pattern para diferentes tipos de delete
/// Permite expandir sem modificar código existente (OCP)
abstract class DeleteStrategy {
  Future<AnimalModel> execute(AnimalModel animal);
}

/// Soft delete - marca como deletado sem remover da DB
class SoftDeleteStrategy implements DeleteStrategy {
  @override
  Future<AnimalModel> execute(AnimalModel animal) async {
    return animal.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }
}

/// Hard delete - remove completamente (futuro uso)
class HardDeleteStrategy implements DeleteStrategy {
  @override
  Future<AnimalModel> execute(AnimalModel animal) async {
    // Implementação para hard delete quando necessário
    // Por enquanto não usado, mas disponível para extensão
    throw UnimplementedError('Hard delete not yet implemented');
  }
}
