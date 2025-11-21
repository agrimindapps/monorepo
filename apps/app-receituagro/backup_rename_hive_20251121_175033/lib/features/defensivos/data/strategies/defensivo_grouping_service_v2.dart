import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivo_group_entity.dart';
import 'defensivo_grouping_strategy_registry.dart';
import 'i_defensivo_grouping_strategy.dart';

/// Service que utiliza Strategy Pattern para agrupamento de defensivos
/// 
/// Responsabilidades:
/// - Delega agrupamento para estratégias específicas via Strategy Pattern
/// - Normaliza resultado em DefensivoGroupEntity
/// - Aplica filtros e ordenação após agrupamento
/// 
/// Segue SOLID Principles:
/// - Open/Closed: Adicionar nova estratégia = criar novo Strategy, não modificar service
/// - Single Responsibility: Service orquestra, strategies executam agrupamento
/// - Dependency Inversion: Depende de IDefensivoGroupingStrategy, não de implementações
class DefensivoGroupingServiceV2 {
  final DefensivoGroupingStrategyRegistry _registry;

  DefensivoGroupingServiceV2(this._registry);

  /// Agrupa defensivos usando estratégia específica
  /// 
  /// Segue a abordagem Strategy Pattern:
  /// 1. Obtém estratégia do registry
  /// 2. Delega agrupamento para a estratégia
  /// 3. Normaliza resultado em DefensivoGroupEntity
  List<DefensivoGroupEntity> agruparDefensivos({
    required List<DefensivoEntity> defensivos,
    required String tipoAgrupamento,
    String? filtroTexto,
  }) {
    // Aplica filtro de texto se fornecido
    List<DefensivoEntity> defensivosFiltrados = defensivos;
    if (filtroTexto != null && filtroTexto.isNotEmpty) {
      defensivosFiltrados = _aplicarFiltroTexto(defensivos, filtroTexto);
    }

    // Obtém estratégia
    final strategy = _registry.getOrDefault(tipoAgrupamento);

    // Delega agrupamento para a estratégia
    final grupos = strategy.group(defensivosFiltrados);

    // Converte resultado para DefensivoGroupEntity
    final gruposEntity = grupos.entries
        .map((entry) => DefensivoGroupEntity.fromDefensivos(
              tipoAgrupamento: strategy.id,
              nomeGrupo: entry.key,
              defensivos: entry.value,
              descricao: _obterDescricaoGrupo(strategy, entry.key),
            ))
        .toList();

    // Ordena alfabeticamente
    gruposEntity.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return gruposEntity;
  }

  /// Filtra grupos por texto de busca
  List<DefensivoGroupEntity> filtrarGrupos({
    required List<DefensivoGroupEntity> grupos,
    required String filtroTexto,
  }) {
    if (filtroTexto.isEmpty) return grupos;

    final filtroLower = filtroTexto.toLowerCase();
    return grupos
        .map((grupo) => grupo.filtrarItens(filtroTexto))
        .where((grupo) =>
            grupo.hasItems || grupo.nome.toLowerCase().contains(filtroLower))
        .toList();
  }

  /// Ordena grupos
  List<DefensivoGroupEntity> ordenarGrupos({
    required List<DefensivoGroupEntity> grupos,
    required bool ascending,
  }) {
    final gruposOrdenados = List<DefensivoGroupEntity>.from(grupos);
    gruposOrdenados.sort((a, b) {
      final comparison = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    return gruposOrdenados;
  }

  /// Obtém estatísticas de agrupamento
  Map<String, dynamic> obterEstatisticas({
    required List<DefensivoGroupEntity> grupos,
  }) {
    final totalGrupos = grupos.length;
    final totalItens =
        grupos.fold<int>(0, (sum, grupo) => sum + grupo.quantidadeItens);
    final grupoMaior = grupos.isNotEmpty
        ? grupos.reduce((atual, proximo) =>
            atual.quantidadeItens > proximo.quantidadeItens ? atual : proximo)
        : null;
    final grupoMenor = grupos.isNotEmpty
        ? grupos.reduce((atual, proximo) =>
            atual.quantidadeItens < proximo.quantidadeItens ? atual : proximo)
        : null;

    return {
      'totalGrupos': totalGrupos,
      'totalItens': totalItens,
      'mediaItensPerGrupo':
          totalGrupos > 0 ? (totalItens / totalGrupos).round() : 0,
      'grupoComMaisItens': grupoMaior?.nome,
      'grupoComMenosItens': grupoMenor?.nome,
      'maxItensPorGrupo': grupoMaior?.quantidadeItens ?? 0,
      'minItensPorGrupo': grupoMenor?.quantidadeItens ?? 0,
    };
  }

  /// Obtém tipos de agrupamento disponíveis
  List<String> getTiposAgrupamentoDisponiveis() =>
      _registry.getAvailableIds();

  /// Obtém nome de exibição para tipo de agrupamento
  String getTipoAgrupamentoDisplayName(String tipo) =>
      _registry.getDisplayName(tipo);

  /// Valida tipo de agrupamento
  bool isValidTipoAgrupamento(String tipoAgrupamento) =>
      _registry.exists(tipoAgrupamento);

  /// Aplica filtro de texto aos defensivos
  List<DefensivoEntity> _aplicarFiltroTexto(
    List<DefensivoEntity> defensivos,
    String filtroTexto,
  ) {
    final filtroLower = filtroTexto.toLowerCase();
    return defensivos.where((defensivo) {
      return defensivo.displayName.toLowerCase().contains(filtroLower) ||
          defensivo.displayIngredient.toLowerCase().contains(filtroLower) ||
          defensivo.displayFabricante.toLowerCase().contains(filtroLower) ||
          defensivo.displayClass.toLowerCase().contains(filtroLower);
    }).toList();
  }

  /// Obtém descrição do grupo baseada na estratégia
  String? _obterDescricaoGrupo(
    IDefensivoGroupingStrategy strategy,
    String nomeGrupo,
  ) {
    switch (strategy.id) {
      case 'fabricante':
        return 'Defensivos do fabricante $nomeGrupo';
      case 'ingrediente_ativo':
        return 'Defensivos com ingrediente ativo: $nomeGrupo';
      case 'modo_acao':
        return 'Defensivos com modo de ação: $nomeGrupo';
      case 'classe_agronomica':
        return 'Defensivos da classe agronômica: $nomeGrupo';
      case 'categoria':
        return 'Defensivos da categoria: $nomeGrupo';
      case 'toxicidade':
        return 'Defensivos com toxicidade: $nomeGrupo';
      default:
        return null;
    }
  }
}
