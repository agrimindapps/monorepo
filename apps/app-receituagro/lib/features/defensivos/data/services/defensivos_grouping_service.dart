import '../../../defensivos/domain/entities/defensivo_entity.dart';
import '../../../defensivos/domain/entities/defensivo_group_entity.dart';

/// Service responsável pela lógica de agrupamento de defensivos
/// Otimizado para performance com grandes volumes de dados
/// Seguindo princípios SOLID
class DefensivosGroupingService {
  /// Agrupa defensivos por tipo de agrupamento
  List<DefensivoGroupEntity> agruparDefensivos({
    required List<DefensivoEntity> defensivos,
    required String tipoAgrupamento,
    String? filtroTexto,
  }) {
    // Aplicar filtro de texto primeiro se fornecido
    List<DefensivoEntity> defensivosFiltrados = defensivos;
    if (filtroTexto != null && filtroTexto.isNotEmpty) {
      defensivosFiltrados = _aplicarFiltroTexto(defensivos, filtroTexto);
    }

    // Agrupar por tipo
    final Map<String, List<DefensivoEntity>> grupos = {};
    for (final defensivo in defensivosFiltrados) {
      final chaveGrupo = _obterChaveGrupo(defensivo, tipoAgrupamento);
      
      grupos.putIfAbsent(chaveGrupo, () => <DefensivoEntity>[]);
      grupos[chaveGrupo]!.add(defensivo);
    }

    // Converter para DefensivoGroupEntity e ordenar
    final gruposEntity = grupos.entries
        .map((entry) => DefensivoGroupEntity.fromDefensivos(
              tipoAgrupamento: tipoAgrupamento,
              nomeGrupo: entry.key,
              defensivos: entry.value,
              descricao: _obterDescricaoGrupo(tipoAgrupamento, entry.key),
            ))
        .toList();

    // Ordenar grupos por nome
    gruposEntity.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

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
            grupo.hasItems || 
            grupo.nome.toLowerCase().contains(filtroLower))
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
    final totalItens = grupos.fold<int>(0, (sum, grupo) => sum + grupo.quantidadeItens);
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
      'mediaItensPerGrupo': totalGrupos > 0 ? (totalItens / totalGrupos).round() : 0,
      'grupoComMaisItens': grupoMaior?.nome,
      'grupoComMenosItens': grupoMenor?.nome,
      'maxItensPorGrupo': grupoMaior?.quantidadeItens ?? 0,
      'minItensPorGrupo': grupoMenor?.quantidadeItens ?? 0,
    };
  }

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

  /// Obtém chave do grupo baseada no tipo de agrupamento
  String _obterChaveGrupo(DefensivoEntity defensivo, String tipoAgrupamento) {
    switch (tipoAgrupamento.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return defensivo.displayFabricante;
      
      case 'modo_acao':
      case 'modoacao':
        return defensivo.displayModoAcao;
      
      case 'classe':
      case 'classe_agronomica':
        return defensivo.displayClass;
      
      case 'categoria':
        return defensivo.displayCategoria;
      
      case 'toxico':
      case 'toxicidade':
        return defensivo.displayToxico;
      
      default:
        // Fallback para fabricante se tipo não reconhecido
        return defensivo.displayFabricante;
    }
  }

  /// Obtém descrição do grupo (opcional)
  String? _obterDescricaoGrupo(String tipoAgrupamento, String nomeGrupo) {
    switch (tipoAgrupamento.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return 'Defensivos do fabricante $nomeGrupo';
      
      case 'modo_acao':
      case 'modoacao':
        return 'Defensivos com modo de ação: $nomeGrupo';
      
      case 'classe':
      case 'classe_agronomica':
        return 'Defensivos da classe agronômica: $nomeGrupo';
      
      case 'categoria':
        return 'Defensivos da categoria: $nomeGrupo';
      
      case 'toxico':
      case 'toxicidade':
        return 'Defensivos com toxicidade: $nomeGrupo';
      
      default:
        return null;
    }
  }

  /// Valida tipo de agrupamento
  bool isValidTipoAgrupamento(String tipoAgrupamento) {
    const tiposValidos = [
      'fabricante',
      'fabricantes',
      'modo_acao',
      'modoacao',
      'classe',
      'classe_agronomica',
      'categoria',
      'toxico',
      'toxicidade',
    ];
    
    return tiposValidos.contains(tipoAgrupamento.toLowerCase());
  }

  /// Obtém tipos de agrupamento disponíveis
  List<String> getTiposAgrupamentoDisponiveis() {
    return [
      'fabricante',
      'modo_acao',
      'classe',
      'categoria',
      'toxico',
    ];
  }

  /// Obtém nome de exibição para tipo de agrupamento
  String getTipoAgrupamentoDisplayName(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return 'Fabricante';
      case 'modo_acao':
      case 'modoacao':
        return 'Modo de Ação';
      case 'classe':
      case 'classe_agronomica':
        return 'Classe Agronômica';
      case 'categoria':
        return 'Categoria';
      case 'toxico':
      case 'toxicidade':
        return 'Toxicidade';
      default:
        return tipo.substring(0, 1).toUpperCase() + tipo.substring(1);
    }
  }
}