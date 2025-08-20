/// Serviço de taxonomia e classificação de bovinos
class BovinoTaxonomyService {
  /// Raças bovinas organizadas por categoria
  static const Map<String, List<String>> racasPorCategoria = {
    'Zebuínos': [
      'Nelore',
      'Gir',
      'Guzerá',
      'Indubrasil',
      'Sindi',
      'Brahman',
      'Guzolando',
      'Girolando',
    ],
    'Taurinos Europeus': [
      'Angus',
      'Hereford',
      'Charolês',
      'Limousin',
      'Simmental',
      'Pardo Suíço',
      'Holstein',
      'Jersey',
      'Shorthorn',
      'Devon',
    ],
    'Taurinos Sintéticos': [
      'Canchim',
      'Santa Gertrudis',
      'Brangus',
      'Braford',
      'Simbrasil',
      'Senepol',
      'Bonsmara',
    ],
    'Raças Especiais': [
      'Wagyu',
      'Chianina',
      'Marchigiana',
      'Piemontês',
      'Blonde d\'Aquitaine',
      'Maine-Anjou',
    ],
    'Búfalos': [
      'Murrah',
      'Jafarabadi',
      'Mediterrâneo',
      'Carabao',
    ],
  };

  /// Aptidões principais dos bovinos
  static const List<String> aptidoes = [
    'Corte',
    'Leite',
    'Dupla Aptidão',
    'Trabalho',
    'Esporte',
  ];

  /// Características especiais organizadas por categoria
  static const Map<String, List<String>> caracteristicasEspeciais = {
    'Adaptação Climática': [
      'Resistência ao Calor',
      'Adaptação ao Frio',
      'Resistência à Umidade',
      'Tolerância à Seca',
      'Adaptação Tropical',
    ],
    'Produtividade': [
      'Alta Produção de Leite',
      'Alto Ganho de Peso',
      'Conversão Alimentar Eficiente',
      'Precocidade Sexual',
      'Fertilidade Elevada',
      'Longevidade Produtiva',
    ],
    'Qualidade': [
      'Carne Marmorizada',
      'Baixo Colesterol',
      'Alta Proteína',
      'Maciez da Carne',
      'Rendimento de Carcaça',
    ],
    'Manejo': [
      'Temperamento Dócil',
      'Facilidade de Parto',
      'Instinto Materno',
      'Resistência a Doenças',
      'Facilidade de Ordenha',
      'Rusticidade',
    ],
    'Físicas': [
      'Porte Grande',
      'Porte Médio',
      'Porte Pequeno',
      'Pelagem Clara',
      'Pelagem Escura',
      'Chifres Naturais',
      'Mochos (Sem Chifres)',
    ],
  };

  /// Sistemas de criação
  static const List<String> sistemasCriacao = [
    'Extensivo',
    'Semi-Intensivo',
    'Intensivo',
    'Confinamento',
    'Pasto Rotacionado',
    'Integração Lavoura-Pecuária',
    'Orgânico',
  ];

  /// Finalidades de uso
  static const List<String> finalidades = [
    'Reprodução',
    'Engorda',
    'Ordenha',
    'Exposição',
    'Melhoramento Genético',
    'Venda',
    'Descarte',
  ];

  /// Obtém todas as raças em uma lista plana
  static List<String> get todasRacas {
    return racasPorCategoria.values.expand((racas) => racas).toList()..sort();
  }

  /// Obtém categoria de uma raça específica
  static String? getCategoriaRaca(String raca) {
    for (final entry in racasPorCategoria.entries) {
      if (entry.value.contains(raca)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Obtém raças por categoria
  static List<String> getRacasPorCategoria(String categoria) {
    return racasPorCategoria[categoria] ?? [];
  }

  /// Obtém todas as características em uma lista plana
  static List<String> get todasCaracteristicas {
    return caracteristicasEspeciais.values
        .expand((caracteristicas) => caracteristicas)
        .toList()
      ..sort();
  }

  /// Obtém características por categoria
  static List<String> getCaracteristicasPorCategoria(String categoria) {
    return caracteristicasEspeciais[categoria] ?? [];
  }

  /// Sugere raças baseadas na aptidão
  static List<String> sugerirRacasPorAptidao(String aptidao) {
    switch (aptidao.toLowerCase()) {
      case 'corte':
        return [
          'Nelore',
          'Angus',
          'Hereford',
          'Charolês',
          'Limousin',
          'Canchim',
          'Brangus',
          'Wagyu',
          'Brahman'
        ];
      case 'leite':
        return [
          'Holstein',
          'Jersey',
          'Gir',
          'Guzerá',
          'Girolando',
          'Pardo Suíço',
          'Shorthorn'
        ];
      case 'dupla aptidão':
        return [
          'Simmental',
          'Santa Gertrudis',
          'Sindi',
          'Indubrasil',
          'Devon',
          'Shorthorn'
        ];
      default:
        return [];
    }
  }

  /// Sugere características baseadas na raça
  static List<String> sugerirCaracteristicasPorRaca(String raca) {
    switch (raca.toLowerCase()) {
      case 'nelore':
        return [
          'Resistência ao Calor',
          'Adaptação Tropical',
          'Rusticidade',
          'Alto Ganho de Peso',
          'Temperamento Dócil'
        ];
      case 'angus':
        return [
          'Carne Marmorizada',
          'Precocidade Sexual',
          'Facilidade de Parto',
          'Temperamento Dócil',
          'Mochos (Sem Chifres)'
        ];
      case 'holstein':
        return [
          'Alta Produção de Leite',
          'Facilidade de Ordenha',
          'Porte Grande',
          'Conversão Alimentar Eficiente',
          'Pelagem Clara'
        ];
      case 'gir':
        return [
          'Resistência ao Calor',
          'Alta Produção de Leite',
          'Adaptação Tropical',
          'Instinto Materno',
          'Longevidade Produtiva'
        ];
      case 'brahman':
        return [
          'Resistência ao Calor',
          'Resistência a Doenças',
          'Adaptação Tropical',
          'Rusticidade',
          'Alto Ganho de Peso'
        ];
      default:
        return [];
    }
  }

  /// Valida se uma raça é válida
  static bool isRacaValida(String raca) {
    return todasRacas.contains(raca);
  }

  /// Valida se uma aptidão é válida
  static bool isAptidaoValida(String aptidao) {
    return aptidoes.contains(aptidao);
  }

  /// Valida se uma característica é válida
  static bool isCaracteristicaValida(String caracteristica) {
    return todasCaracteristicas.contains(caracteristica);
  }

  /// Filtra bovinos por múltiplos critérios
  static List<T> filtrarBovinos<T>({
    required List<T> bovinos,
    required String Function(T) getRaca,
    required String Function(T) getAptidao,
    required List<String> Function(T) getCaracteristicas,
    String? racaFiltro,
    String? aptidaoFiltro,
    List<String>? caracteristicasFiltro,
    String? categoriaRacaFiltro,
  }) {
    return bovinos.where((bovino) {
      // Filtrar por raça
      if (racaFiltro != null && racaFiltro.isNotEmpty) {
        if (getRaca(bovino) != racaFiltro) return false;
      }

      // Filtrar por categoria de raça
      if (categoriaRacaFiltro != null && categoriaRacaFiltro.isNotEmpty) {
        final racaBovino = getRaca(bovino);
        final categoriaBovino = getCategoriaRaca(racaBovino);
        if (categoriaBovino != categoriaRacaFiltro) return false;
      }

      // Filtrar por aptidão
      if (aptidaoFiltro != null && aptidaoFiltro.isNotEmpty) {
        if (getAptidao(bovino) != aptidaoFiltro) return false;
      }

      // Filtrar por características (deve ter pelo menos uma das características)
      if (caracteristicasFiltro != null && caracteristicasFiltro.isNotEmpty) {
        final caracteristicasBovino = getCaracteristicas(bovino);
        final hasCaracteristica = caracteristicasFiltro.any((filtro) =>
            caracteristicasBovino.any((caracteristica) =>
                caracteristica.toLowerCase().contains(filtro.toLowerCase())));
        if (!hasCaracteristica) return false;
      }

      return true;
    }).toList();
  }

  /// Gera sugestões de categorização baseado no texto de características
  static List<String> analisarCaracteristicas(String texto) {
    final sugestoes = <String>[];
    final textoLower = texto.toLowerCase();

    // Analisar por palavras-chave
    final palavrasChave = {
      'calor': ['Resistência ao Calor', 'Adaptação Tropical'],
      'leite': ['Alta Produção de Leite', 'Facilidade de Ordenha'],
      'carne': ['Carne Marmorizada', 'Rendimento de Carcaça'],
      'docil': ['Temperamento Dócil'],
      'rustico': ['Rusticidade', 'Resistência a Doenças'],
      'peso': ['Alto Ganho de Peso'],
      'parto': ['Facilidade de Parto'],
      'grande': ['Porte Grande'],
      'pequeno': ['Porte Pequeno'],
      'chifres': ['Chifres Naturais'],
      'mocho': ['Mochos (Sem Chifres)'],
    };

    for (final entry in palavrasChave.entries) {
      if (textoLower.contains(entry.key)) {
        sugestoes.addAll(entry.value);
      }
    }

    return sugestoes.toSet().toList(); // Remove duplicatas
  }

  /// Obtém estatísticas de categorização
  static Map<String, int> getEstatisticasCategorias<T>({
    required List<T> bovinos,
    required String Function(T) getRaca,
  }) {
    final estatisticas = <String, int>{};

    for (final bovino in bovinos) {
      final raca = getRaca(bovino);
      final categoria = getCategoriaRaca(raca) ?? 'Não Classificado';
      estatisticas[categoria] = (estatisticas[categoria] ?? 0) + 1;
    }

    return estatisticas;
  }

  /// Obtém estatísticas de aptidões
  static Map<String, int> getEstatisticasAptidoes<T>({
    required List<T> bovinos,
    required String Function(T) getAptidao,
  }) {
    final estatisticas = <String, int>{};

    for (final bovino in bovinos) {
      final aptidao = getAptidao(bovino);
      if (aptidao.isNotEmpty) {
        estatisticas[aptidao] = (estatisticas[aptidao] ?? 0) + 1;
      }
    }

    return estatisticas;
  }
}
