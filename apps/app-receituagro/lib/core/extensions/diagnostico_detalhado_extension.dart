import '../services/diagnostico_integration_service.dart';

/// Extensions para facilitar o trabalho com dados relacionais
extension DiagnosticoDetalhadoExtension on DiagnosticoDetalhado {
  
  /// Verifica se o diagnóstico tem todas as informações necessárias
  bool get isValid => 
      diagnostico.idReg.isNotEmpty &&
      diagnostico.fkIdDefensivo.isNotEmpty &&
      diagnostico.fkIdCultura.isNotEmpty &&
      diagnostico.fkIdPraga.isNotEmpty;

  /// Retorna uma descrição resumida do diagnóstico
  String get descricaoResumida {
    if (!hasInfoCompleta) {
      return 'Informações incompletas';
    }
    return '$nomePraga em $nomeCultura - $nomeComercialDefensivo';
  }

  /// Verifica se é um diagnóstico crítico (baseado em critérios específicos)
  bool get isCritico {
    if (praga?.tipoPraga == 'Crítica') return true;
    final dosMaxDouble = double.tryParse(diagnostico.dsMax);
    if (dosMaxDouble != null && dosMaxDouble > 5.0) return true;
    
    return false;
  }

  /// Retorna informações de segurança se disponíveis
  Map<String, String> get informacoesSeguranca {
    final info = <String, String>{};
    
    if (defensivo?.toxico != null) {
      info['Toxicidade'] = defensivo!.toxico!;
    }
    
    if (defensivo?.classAmbiental != null) {
      info['Classe Ambiental'] = defensivo!.classAmbiental!;
    }
    
    if (defensivo?.corrosivo != null && defensivo!.corrosivo == 'Sim') {
      info['Corrosivo'] = 'Sim';
    }
    
    if (defensivo?.inflamavel != null && defensivo!.inflamavel == 'Sim') {
      info['Inflamável'] = 'Sim';
    }
    
    return info;
  }

  /// Retorna dados técnicos organizados
  Map<String, String> get dadosTecnicos {
    final dados = <String, String>{};
    
    dados['Dosagem'] = dosagem;
    
    if (diagnostico.intervalo != null) {
      dados['Intervalo'] = diagnostico.intervalo!;
    }
    
    if (diagnostico.epocaAplicacao != null) {
      dados['Época de Aplicação'] = diagnostico.epocaAplicacao!;
    }
    
    if (defensivo?.modoAcao != null) {
      dados['Modo de Ação'] = defensivo!.modoAcao!;
    }
    
    if (defensivo?.formulacao != null) {
      dados['Formulação'] = defensivo!.formulacao!;
    }
    
    return dados;
  }

  /// Verifica se há aplicação terrestre
  bool get temAplicacaoTerrestre => 
      diagnostico.minAplicacaoT != null || diagnostico.maxAplicacaoT != null;

  /// Verifica se há aplicação aérea
  bool get temAplicacaoAerea => 
      diagnostico.minAplicacaoA != null || diagnostico.maxAplicacaoA != null;

  /// Retorna informações de aplicação terrestre
  String? get aplicacaoTerrestre {
    if (!temAplicacaoTerrestre) return null;
    
    if (diagnostico.minAplicacaoT != null && diagnostico.maxAplicacaoT != null) {
      return '${diagnostico.minAplicacaoT} - ${diagnostico.maxAplicacaoT} ${diagnostico.umT ?? ''}';
    } else if (diagnostico.maxAplicacaoT != null) {
      return '${diagnostico.maxAplicacaoT} ${diagnostico.umT ?? ''}';
    }
    
    return null;
  }

  /// Retorna informações de aplicação aérea
  String? get aplicacaoAerea {
    if (!temAplicacaoAerea) return null;
    
    if (diagnostico.minAplicacaoA != null && diagnostico.maxAplicacaoA != null) {
      return '${diagnostico.minAplicacaoA} - ${diagnostico.maxAplicacaoA} ${diagnostico.umA ?? ''}';
    } else if (diagnostico.maxAplicacaoA != null) {
      return '${diagnostico.maxAplicacaoA} ${diagnostico.umA ?? ''}';
    }
    
    return null;
  }
}

/// Extension para lista de diagnósticos detalhados
extension DiagnosticoDetalhadoListExtension on List<DiagnosticoDetalhado> {
  
  /// Filtra diagnósticos válidos
  List<DiagnosticoDetalhado> get validos => 
      where((d) => d.isValid).toList();

  /// Filtra diagnósticos críticos
  List<DiagnosticoDetalhado> get criticos => 
      where((d) => d.isCritico).toList();

  /// Agrupa por cultura
  Map<String, List<DiagnosticoDetalhado>> get agrupadosPorCultura {
    final grupos = <String, List<DiagnosticoDetalhado>>{};
    
    for (final diagnostico in this) {
      final cultura = diagnostico.nomeCultura;
      if (!grupos.containsKey(cultura)) {
        grupos[cultura] = [];
      }
      grupos[cultura]!.add(diagnostico);
    }
    
    return grupos;
  }

  /// Agrupa por praga
  Map<String, List<DiagnosticoDetalhado>> get agrupadosPorPraga {
    final grupos = <String, List<DiagnosticoDetalhado>>{};
    
    for (final diagnostico in this) {
      final praga = diagnostico.nomePraga;
      if (!grupos.containsKey(praga)) {
        grupos[praga] = [];
      }
      grupos[praga]!.add(diagnostico);
    }
    
    return grupos;
  }

  /// Agrupa por defensivo
  Map<String, List<DiagnosticoDetalhado>> get agrupadosPorDefensivo {
    final grupos = <String, List<DiagnosticoDetalhado>>{};
    
    for (final diagnostico in this) {
      final defensivo = diagnostico.nomeDefensivo;
      if (!grupos.containsKey(defensivo)) {
        grupos[defensivo] = [];
      }
      grupos[defensivo]!.add(diagnostico);
    }
    
    return grupos;
  }

  /// Retorna todas as culturas únicas
  List<String> get culturasUnicas => 
      map((d) => d.nomeCultura)
          .where((nome) => nome != 'Cultura não encontrada')
          .toSet()
          .toList()..sort();

  /// Retorna todas as pragas únicas
  List<String> get pragasUnicas => 
      map((d) => d.nomePraga)
          .where((nome) => nome != 'Praga não encontrada')
          .toSet()
          .toList()..sort();

  /// Retorna todos os defensivos únicos
  List<String> get defensivosUnicos => 
      map((d) => d.nomeDefensivo)
          .where((nome) => nome != 'Defensivo não encontrado')
          .toSet()
          .toList()..sort();

  /// Estatísticas da lista
  Map<String, int> get estatisticas => {
    'total': length,
    'validos': validos.length,
    'criticos': criticos.length,
    'culturas_unicas': culturasUnicas.length,
    'pragas_unicas': pragasUnicas.length,
    'defensivos_unicos': defensivosUnicos.length,
  };
}

/// Extension para DefensivoCompleto
extension DefensivoCompletoExtension on DefensivoCompleto {
  
  /// Verifica se é um defensivo comercializado
  bool get isComercializado => defensivo.comercializado == 1;

  /// Verifica se é elegível
  bool get isElegivel => defensivo.elegivel;

  /// Verifica se tem informações de segurança importantes
  bool get temAlertas {
    return defensivo.toxico != null ||
           defensivo.corrosivo == 'Sim' ||
           defensivo.inflamavel == 'Sim';
  }

  /// Retorna nível de prioridade baseado em critérios
  int get nivelPrioridade {
    int prioridade = 0;
    
    if (isComercializado) prioridade += 2;
    if (isElegivel) prioridade += 1;
    if (quantidadeDiagnosticos > 10) prioridade += 3;
    if (quantidadeDiagnosticos > 5) prioridade += 1;
    
    return prioridade;
  }

  /// Categoriza o defensivo
  String get categoria {
    if (nivelPrioridade >= 6) return 'Alta Prioridade';
    if (nivelPrioridade >= 3) return 'Média Prioridade';
    return 'Baixa Prioridade';
  }
}

/// Extension para PragaPorCultura
extension PragaPorCulturaExtension on PragaPorCultura {
  
  /// Verifica se é uma praga crítica
  bool get isCritica => praga.tipoPraga == 'Crítica';

  /// Retorna o nível de ameaça baseado no número de diagnósticos
  String get nivelAmeaca {
    if (quantidadeDiagnosticos >= 10) return 'Alto';
    if (quantidadeDiagnosticos >= 5) return 'Médio';
    return 'Baixo';
  }

  /// Retorna informações taxonômicas organizadas
  Map<String, String> get informacoesTaxonomicas {
    final info = <String, String>{};
    
    if (praga.reino != null) info['Reino'] = praga.reino!;
    if (praga.classe != null) info['Classe'] = praga.classe!;
    if (praga.ordem != null) info['Ordem'] = praga.ordem!;
    if (praga.familia != null) info['Família'] = praga.familia!;
    if (praga.genero != null) info['Gênero'] = praga.genero!;
    if (praga.especie != null) info['Espécie'] = praga.especie!;
    
    return info;
  }
}
