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
    List<DefensivoEntity> defensivosFiltrados = defensivos;
    if (filtroTexto != null && filtroTexto.isNotEmpty) {
      defensivosFiltrados = _aplicarFiltroTexto(defensivos, filtroTexto);
    }
    final Map<String, List<DefensivoEntity>> grupos = {};
    final isIngredienteAtivo = _isIngredienteAtivoGrouping(tipoAgrupamento);
    final isModoAcao = _isModoAcaoGrouping(tipoAgrupamento);
    final isClasseAgronomica = _isClasseAgronomicaGrouping(tipoAgrupamento);

    for (final defensivo in defensivosFiltrados) {
      if (isIngredienteAtivo) {
        final ingredientes = _extrairIngredientesAtivos(defensivo);
        for (final ingrediente in ingredientes) {
          grupos.putIfAbsent(ingrediente, () => <DefensivoEntity>[]);
          grupos[ingrediente]!.add(defensivo);
        }
      } else if (isModoAcao) {
        final modosAcao = _extrairModosAcao(defensivo);
        for (final modo in modosAcao) {
          grupos.putIfAbsent(modo, () => <DefensivoEntity>[]);
          grupos[modo]!.add(defensivo);
        }
      } else if (isClasseAgronomica) {
        final classes = _extrairClassesAgronomicas(defensivo);
        for (final classe in classes) {
          grupos.putIfAbsent(classe, () => <DefensivoEntity>[]);
          grupos[classe]!.add(defensivo);
        }
      } else {
        final chaveGrupo = _obterChaveGrupo(defensivo, tipoAgrupamento);
        grupos.putIfAbsent(chaveGrupo, () => <DefensivoEntity>[]);
        grupos[chaveGrupo]!.add(defensivo);
      }
    }
    final gruposEntity = grupos.entries
        .map((entry) => DefensivoGroupEntity.fromDefensivos(
              tipoAgrupamento: tipoAgrupamento,
              nomeGrupo: entry.key,
              defensivos: entry.value,
              descricao: _obterDescricaoGrupo(tipoAgrupamento, entry.key),
            ))
        .toList();
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
      case 'modoAcao':
        return defensivo.displayModoAcao;
      
      case 'ingrediente_ativo':
      case 'ingredienteativo':
      case 'ingredienteAtivo':
        return defensivo.displayIngredient;
      
      case 'classe':
      case 'classe_agronomica':
      case 'classeagronomica':
        return defensivo.displayClass;
      
      case 'categoria':
        return defensivo.displayCategoria;
      
      case 'toxico':
      case 'toxicidade':
        return defensivo.displayToxico;
      
      default:
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
      
      case 'ingrediente_ativo':
      case 'ingredienteativo':
      case 'ingredienteAtivo':
        return 'Defensivos com ingrediente ativo: $nomeGrupo';
      
      case 'classe':
      case 'classe_agronomica':
      case 'classeagronomica':
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
      'modoAcao',
      'ingrediente_ativo',
      'ingredienteativo',
      'ingredienteAtivo',
      'classe',
      'classe_agronomica',
      'classeagronomica',
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
      case 'modoAcao':
        return 'Modo de Ação';
      case 'ingrediente_ativo':
      case 'ingredienteativo':
      case 'ingredienteAtivo':
        return 'Ingrediente Ativo';
      case 'classe':
      case 'classe_agronomica':
      case 'classeagronomica':
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

  /// Verifica se o tipo de agrupamento é por ingrediente ativo
  bool _isIngredienteAtivoGrouping(String tipoAgrupamento) {
    final tipo = tipoAgrupamento.toLowerCase();
    return tipo == 'ingrediente_ativo' || 
           tipo == 'ingredienteativo' || 
           tipo == 'ingredienteAtivo';
  }

  /// Verifica se o tipo de agrupamento é por modo de ação
  bool _isModoAcaoGrouping(String tipoAgrupamento) {
    final tipo = tipoAgrupamento.toLowerCase();
    return tipo == 'modo_acao' ||
           tipo == 'modoacao' ||
           tipo == 'modoAcao';
  }

  /// Verifica se o tipo de agrupamento é por classe agronômica
  bool _isClasseAgronomicaGrouping(String tipoAgrupamento) {
    final tipo = tipoAgrupamento.toLowerCase();
    return tipo == 'classe' ||
           tipo == 'classe_agronomica' ||
           tipo == 'classeagronomica';
  }

  /// Extrai ingredientes ativos individuais separados por "+"
  /// Normaliza para Title Case para consistência visual
  List<String> _extrairIngredientesAtivos(DefensivoEntity defensivo) {
    final ingredientesText = defensivo.displayIngredient;

    if (ingredientesText.isEmpty || ingredientesText == 'Sem ingrediente ativo') {
      return ['Não informado'];
    }
    final ingredientes = ingredientesText
        .split('+')
        .map((ingrediente) => _normalizeString(ingrediente))
        .where((ingrediente) => ingrediente.isNotEmpty && ingrediente.length >= 3)
        .toList();

    return ingredientes.isEmpty ? ['Não informado'] : ingredientes;
  }

  /// Extrai modos de ação individuais separados por vírgula
  /// Normaliza para Title Case para consistência visual
  List<String> _extrairModosAcao(DefensivoEntity defensivo) {
    final modoAcaoText = defensivo.displayModoAcao;

    if (modoAcaoText.isEmpty || modoAcaoText == 'Não especificado') {
      return ['Não especificado'];
    }
    final modosAcao = modoAcaoText
        .split(',')
        .map((modo) => _normalizeString(modo))
        .where((modo) => modo.isNotEmpty && modo.length >= 3)
        .toList();

    return modosAcao.isEmpty ? ['Não especificado'] : modosAcao;
  }

  /// Extrai classes agronômicas individuais separadas por vírgula
  /// Normaliza para Title Case para consistência visual
  List<String> _extrairClassesAgronomicas(DefensivoEntity defensivo) {
    final classeText = defensivo.displayClass;

    if (classeText.isEmpty || classeText == 'Não especificado') {
      return ['Não especificado'];
    }
    final classes = classeText
        .split(',')
        .map((classe) => _normalizeString(classe))
        .where((classe) => classe.isNotEmpty && classe.length >= 3)
        .toList();

    return classes.isEmpty ? ['Não especificado'] : classes;
  }

  /// Normaliza string: trim + primeira letra maiúscula
  /// Garante consistência mesmo com variações de capitalização
  String _normalizeString(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    // Capitaliza primeira letra de cada palavra importante
    return trimmed
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          // Mantém palavras conectoras em lowercase
          if (['de', 'da', 'do', 'e', 'a', 'o'].contains(word.toLowerCase())) {
            return word.toLowerCase();
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
