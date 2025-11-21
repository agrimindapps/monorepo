import '../../database/receituagro_database.dart';
import '../../database/repositories/culturas_repository.dart';
import '../../database/repositories/diagnostico_repository.dart';
import '../../database/repositories/fitossanitarios_repository.dart';
import '../../database/repositories/pragas_repository.dart';

/// Service responsável por integrar dados de múltiplas tabelas Drift
/// para criar views relacionais completas dos diagnósticos
class DiagnosticoIntegrationService {
  final DiagnosticoRepository _diagnosticoRepo;
  final FitossanitariosRepository _fitossanitarioRepo;
  final CulturasRepository _culturaRepo;
  final PragasRepository _pragasRepo;
  final Map<int, Fitossanitario> _defensivoCache = {};
  final Map<int, Cultura> _culturaCache = {};
  final Map<int, Praga> _pragaCache = {};

  DiagnosticoIntegrationService({
    required DiagnosticoRepository diagnosticoRepo,
    required FitossanitariosRepository fitossanitarioRepo,
    required CulturasRepository culturaRepo,
    required PragasRepository pragasRepo,
  }) : _diagnosticoRepo = diagnosticoRepo,
       _fitossanitarioRepo = fitossanitarioRepo,
       _culturaRepo = culturaRepo,
       _pragasRepo = pragasRepo;

  /// Obtém um diagnóstico completo com todos os dados relacionais
  Future<DiagnosticoDetalhado?> getDiagnosticoCompleto(String idReg) async {
    try {
      // Buscar diagnóstico por idReg (NOTE: userId removed - static table)
      final diagnostico = await _diagnosticoRepo.findByIdReg(idReg);
      if (diagnostico == null) return null;

      final defensivo = await _getDefensivoById(diagnostico.defensivoId);
      final cultura = await _getCulturaById(diagnostico.culturaId);
      final praga = await _getPragaById(diagnostico.pragaId);

      return DiagnosticoDetalhado(
        diagnostico: diagnostico,
        defensivo: defensivo,
        cultura: cultura,
        praga: praga,
      );
    } catch (e) {
      return null;
    }
  }

  /// Busca diagnósticos por cultura com dados relacionais
  Future<List<DiagnosticoDetalhado>> buscarPorCultura(String culturaId) async {
    try {
      // Parse culturaId para int
      final culturaIdInt = int.tryParse(culturaId);
      if (culturaIdInt == null) return [];

      final diagnosticos = await _diagnosticoRepo.findByCultura(
        
        culturaIdInt,
      );
      final List<DiagnosticoDetalhado> detalhados = [];

      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      return [];
    }
  }

  /// Busca diagnósticos por praga com dados relacionais
  Future<List<DiagnosticoDetalhado>> buscarPorPraga(String pragaId) async {
    try {
      // Parse pragaId para int
      final pragaIdInt = int.tryParse(pragaId);
      if (pragaIdInt == null) return [];

      final diagnosticos = await _diagnosticoRepo.findByPraga(
        
        pragaIdInt,
      );
      final List<DiagnosticoDetalhado> detalhados = [];

      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      return [];
    }
  }

  /// Busca diagnósticos por defensivo com dados relacionais
  Future<List<DiagnosticoDetalhado>> buscarPorDefensivo(
    String defensivoId,
  ) async {
    try {
      // Parse defensivoId para int
      final defensivoIdInt = int.tryParse(defensivoId);
      if (defensivoIdInt == null) return [];

      final diagnosticos = await _diagnosticoRepo.findByDefensivo(
        
        defensivoIdInt,
      );
      final List<DiagnosticoDetalhado> detalhados = [];

      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      return [];
    }
  }

  /// Busca com filtros múltiplos
  Future<List<DiagnosticoDetalhado>> buscarComFiltros({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  }) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findAll(); // Static data - no userId
      List<Diagnostico> filtered = diagnosticos;

      if (culturaId != null && culturaId.isNotEmpty) {
        final culturaIdInt = int.tryParse(culturaId);
        if (culturaIdInt != null) {
          filtered = filtered
              .where((d) => d.culturaId == culturaIdInt)
              .toList();
        }
      }

      if (pragaId != null && pragaId.isNotEmpty) {
        final pragaIdInt = int.tryParse(pragaId);
        if (pragaIdInt != null) {
          filtered = filtered.where((d) => d.pragaId == pragaIdInt).toList();
        }
      }

      if (defensivoId != null && defensivoId.isNotEmpty) {
        final defensivoIdInt = int.tryParse(defensivoId);
        if (defensivoIdInt != null) {
          filtered = filtered
              .where((d) => d.defensivoId == defensivoIdInt)
              .toList();
        }
      }

      final List<DiagnosticoDetalhado> detalhados = [];
      for (final diagnostico in filtered) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      return [];
    }
  }

  /// Obtém defensivos completos com informações detalhadas
  Future<List<DefensivoCompleto>> getDefensivosCompletos() async {
    try {
      final defensivos = await _fitossanitarioRepo.findAll();
      final List<DefensivoCompleto> defensivosCompletos = [];

      for (final defensivo in defensivos) {
        final diagnosticosRelacionados = await buscarPorDefensivo(
          defensivo.id.toString(),
        );

        defensivosCompletos.add(
          DefensivoCompleto(
            defensivo: defensivo,
            diagnosticosRelacionados: diagnosticosRelacionados,
          ),
        );
      }

      return defensivosCompletos;
    } catch (e) {
      return [];
    }
  }

  Future<Fitossanitario?> _getDefensivoById(int id) async {
    if (_defensivoCache.containsKey(id)) {
      return _defensivoCache[id];
    }

    final defensivo = await _fitossanitarioRepo.findById(id);
    if (defensivo != null) {
      _defensivoCache[id] = defensivo;
    }
    return defensivo;
  }

  Future<Cultura?> _getCulturaById(int id) async {
    if (_culturaCache.containsKey(id)) {
      return _culturaCache[id];
    }

    final cultura = await _culturaRepo.findById(id);
    if (cultura != null) {
      _culturaCache[id] = cultura;
    }
    return cultura;
  }

  Future<Praga?> _getPragaById(int id) async {
    if (_pragaCache.containsKey(id)) {
      return _pragaCache[id];
    }

    final praga = await _pragasRepo.findById(id);
    if (praga != null) {
      _pragaCache[id] = praga;
    }
    return praga;
  }

  /// Limpa os caches internos
  void clearCache() {
    _defensivoCache.clear();
    _culturaCache.clear();
    _pragaCache.clear();
  }

  /// Retorna estatísticas de uso dos caches
  Map<String, int> getCacheStats() {
    return {
      'defensivos': _defensivoCache.length,
      'culturas': _culturaCache.length,
      'pragas': _pragaCache.length,
    };
  }
}

/// Modelo que representa um diagnóstico com todos os dados relacionais
class DiagnosticoDetalhado {
  final Diagnostico diagnostico; // Changed from DiagnosticoData
  final Fitossanitario? defensivo;
  final Cultura? cultura;
  final Praga? praga;

  DiagnosticoDetalhado({
    required this.diagnostico,
    this.defensivo,
    this.cultura,
    this.praga,
  });

  /// Getters para exibição com fallbacks seguros
  String get nomeDefensivo => defensivo?.nome ?? diagnostico.idReg;
  String get nomeComercialDefensivo => defensivo?.nome ?? 'N/A';
  String get nomeTecnicoDefensivo => defensivo?.nome ?? 'N/A';
  String get nomeCultura => cultura?.nome ?? 'Cultura não encontrada';
  String get nomePraga => praga?.nome ?? 'Praga não encontrada';
  String get nomeCientificoPraga => praga?.nome ?? 'N/A';

  String get dosagem {
    if (diagnostico.dsMin != null && diagnostico.dsMin!.isNotEmpty) {
      return '${diagnostico.dsMin} - ${diagnostico.dsMax} ${diagnostico.um}';
    }
    return '${diagnostico.dsMax} ${diagnostico.um}';
  }

  String get fabricante => defensivo?.fabricante ?? 'N/A';
  String get classeAgronomica => defensivo?.classeAgronomica ?? 'N/A';
  String get modoAcao => 'N/A'; // Informação não disponível na tabela principal
  String get ingredienteAtivo => defensivo?.ingredienteAtivo ?? 'N/A';

  bool get hasInfoCompleta =>
      defensivo != null && cultura != null && praga != null;

  /// Propriedades adicionais para widgets especializados
  bool get isCritico {
    final dosageValue = double.tryParse(diagnostico.dsMax) ?? 0;
    final isHighDosage = dosageValue > 1000; // Exemplo: dosagem > 1L/ha
    final hasCriticalMissingData =
        defensivo == null || cultura == null || praga == null;

    return isHighDosage || hasCriticalMissingData;
  }

  String get descricaoResumida {
    if (hasInfoCompleta) {
      return '$nomeDefensivo para $nomePraga em $nomeCultura';
    } else {
      return 'Diagnóstico ${diagnostico.idReg}';
    }
  }

  bool get temAplicacaoTerrestre {
    // Informação não disponível na tabela principal do Drift
    return true; // Default para terrestre
  }

  bool get temAplicacaoAerea {
    // Informação não disponível na tabela principal do Drift
    return false; // Default para não aéreo
  }

  List<Fitossanitario> get defensivos {
    return defensivo != null ? [defensivo!] : [];
  }
}

/// Modelo que representa um defensivo com informações completas
class DefensivoCompleto {
  final Fitossanitario defensivo;
  final List<DiagnosticoDetalhado> diagnosticosRelacionados;

  DefensivoCompleto({
    required this.defensivo,
    this.diagnosticosRelacionados = const [],
  });

  int get quantidadeDiagnosticos => diagnosticosRelacionados.length;

  List<String> get culturasRelacionadas {
    return diagnosticosRelacionados
        .map((d) => d.nomeCultura)
        .where((nome) => nome != 'Cultura não encontrada')
        .toSet()
        .toList();
  }

  List<String> get pragasRelacionadas {
    return diagnosticosRelacionados
        .map((d) => d.nomePraga)
        .where((nome) => nome != 'Praga não encontrada')
        .toSet()
        .toList();
  }
}

/// Modelo que representa pragas agrupadas por cultura
class PragaPorCultura {
  final Praga praga;
  final List<DiagnosticoDetalhado> diagnosticosRelacionados;

  PragaPorCultura({
    required this.praga,
    this.diagnosticosRelacionados = const [],
  });

  int get quantidadeDiagnosticos => diagnosticosRelacionados.length;

  List<String> get defensivosRelacionados {
    return diagnosticosRelacionados
        .map((d) => d.nomeDefensivo)
        .where((nome) => nome != 'Defensivo não encontrado')
        .toSet()
        .toList();
  }
}
