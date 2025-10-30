import '../../../domain/entities/animal.dart';
import 'animal_filter_strategy.dart';

/// Compositor de filtros - aplicar múltiplos filtros em sequência
/// Responsabilidade única: orquestrar aplicação de filtros
class AnimalFilterEngine {
  final List<AnimalFilterStrategy> _strategies = [];

  /// Adicionar estratégia de filtro
  void addStrategy(AnimalFilterStrategy strategy) {
    if (strategy.hasActiveFilter) {
      _strategies.add(strategy);
    }
  }

  /// Limpar todas as estratégias
  void clearStrategies() {
    _strategies.clear();
  }

  /// Aplicar todos os filtros em sequência
  List<Animal> applyFilters(List<Animal> animals) {
    if (_strategies.isEmpty) return animals;

    return _strategies.fold(animals, (filtered, strategy) {
      return strategy.apply(filtered);
    });
  }

  /// Verificar se há filtros ativos
  bool get hasActiveFilters => _strategies.isNotEmpty;

  /// Obter número de filtros ativos
  int get activeFilterCount => _strategies.length;
}
