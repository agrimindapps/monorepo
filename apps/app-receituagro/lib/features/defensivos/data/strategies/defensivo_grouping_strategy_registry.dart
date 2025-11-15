import 'defensivo_grouping_strategies.dart';
import 'i_defensivo_grouping_strategy.dart';

/// Registry para gerenciar todas as estratégias de agrupamento de defensivos
/// 
/// Pattern: Strategy Registry
/// - Centraliza todas as estratégias disponíveis
/// - Facilita adicionar novas estratégias sem modificar código existente
/// - Segue Open/Closed Principle
class DefensivoGroupingStrategyRegistry {
  final Map<String, IDefensivoGroupingStrategy> _strategies;

  DefensivoGroupingStrategyRegistry()
      : _strategies = {
          'fabricante': ByFabricanteGrouping(),
          'ingrediente_ativo': ByIngredienteAtivoGrouping(),
          'modo_acao': ByModoAcaoGrouping(),
          'classe_agronomica': ByClasseAgronomicaGrouping(),
          'toxicidade': ByToxicidadeGrouping(),
          'categoria': ByCategoriaGrouping(),
        };

  /// Obtém estratégia pelo ID
  IDefensivoGroupingStrategy? get(String strategyId) {
    return _strategies[strategyId.toLowerCase()];
  }

  /// Obtém estratégia ou retorna padrão (fabricante)
  IDefensivoGroupingStrategy getOrDefault(String? strategyId) {
    if (strategyId == null || strategyId.isEmpty) {
      return _strategies['fabricante']!;
    }
    return _strategies[strategyId.toLowerCase()] ?? _strategies['fabricante']!;
  }

  /// Lista IDs de todas as estratégias disponíveis
  List<String> getAvailableIds() => _strategies.keys.toList()..sort();

  /// Lista todas as estratégias disponíveis
  List<IDefensivoGroupingStrategy> getAvailable() =>
      _strategies.values.toList();

  /// Verifica se estratégia existe
  bool exists(String strategyId) =>
      _strategies.containsKey(strategyId.toLowerCase());

  /// Obtém nome de exibição para um ID de estratégia
  String getDisplayName(String strategyId) {
    return get(strategyId)?.name ?? 'Desconhecido';
  }

  /// Obtém descrição para um ID de estratégia
  String getDescription(String strategyId) {
    return get(strategyId)?.description ?? '';
  }
}
