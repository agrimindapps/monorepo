import '../../domain/entities/defensivo_entity.dart';

/// Strategy interface para diferentes estratégias de agrupamento de defensivos
/// 
/// Segue princípios SOLID:
/// - Open/Closed Principle: aberto para extensão (novos strategies)
/// - Single Responsibility: cada strategy responsável por um tipo de agrupamento
/// - Dependency Inversion: repositórios dependem da interface, não da implementação
abstract class IDefensivoGroupingStrategy {
  /// Agrupa defensivos conforme estratégia específica
  /// 
  /// Retorna mapa com chave = nome do grupo, valor = lista de defensivos
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos);

  /// Nome da estratégia para exibição na UI
  String get name;

  /// ID único para identificação (ex: 'por_nome', 'por_tipo')
  String get id;

  /// Descrição legível da estratégia
  String get description;
}
