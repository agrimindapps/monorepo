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
  final Map<String, Fitossanitario> _defensivoCache = {};
  final Map<String, Cultura> _culturaCache = {};
  final Map<String, Praga> _pragaCache = {};

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
      final diagnostico = await _diagnosticoRepo.findByIdReg(idReg);
      if (diagnostico == null) return null;

      final defensivo = await _getDefensivoByIdDefensivo(diagnostico.fkIdDefensivo);
      final cultura = await _getCulturaByIdCultura(diagnostico.fkIdCultura);
      final praga = await _getPragaByIdPraga(diagnostico.fkIdPraga);

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
      final diagnosticos = await _diagnosticoRepo.findByCulturaId(culturaId);
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
      final diagnosticos = await _diagnosticoRepo.findByPragaId(pragaId);
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
      final diagnosticos = await _diagnosticoRepo.findByDefensivoId(defensivoId);
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
      final diagnosticos = await _diagnosticoRepo.findAll();
      List<Diagnostico> filtered = diagnosticos;

      if (culturaId != null && culturaId.isNotEmpty) {
        filtered = filtered
            .where((d) => d.fkIdCultura == culturaId)
            .toList();
      }

      if (pragaId != null && pragaId.isNotEmpty) {
        filtered = filtered.where((d) => d.fkIdPraga == pragaId).toList();
      }

      if (defensivoId != null && defensivoId.isNotEmpty) {
        filtered = filtered
            .where((d) => d.fkIdDefensivo == defensivoId)
            .toList();
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
          defensivo.idDefensivo,
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

  Future<Fitossanitario?> _getDefensivoByIdDefensivo(String idDefensivo) async {
    if (_defensivoCache.containsKey(idDefensivo)) {
      return _defensivoCache[idDefensivo];
    }

    final defensivo = await _fitossanitarioRepo.findByIdDefensivo(idDefensivo);
    if (defensivo != null) {
      _defensivoCache[idDefensivo] = defensivo;
    }
    return defensivo;
  }

  Future<Cultura?> _getCulturaByIdCultura(String idCultura) async {
    if (_culturaCache.containsKey(idCultura)) {
      return _culturaCache[idCultura];
    }

    final cultura = await _culturaRepo.findByIdCultura(idCultura);
    if (cultura != null) {
      _culturaCache[idCultura] = cultura;
    }
    return cultura;
  }

  Future<Praga?> _getPragaByIdPraga(String idPraga) async {
    if (_pragaCache.containsKey(idPraga)) {
      return _pragaCache[idPraga];
    }

    final praga = await _pragasRepo.findByIdPraga(idPraga);
    if (praga != null) {
      _pragaCache[idPraga] = praga;
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
  final Diagnostico diagnostico;
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
  String get nomeTecnicoDefensivo => defensivo?.nomeTecnico ?? defensivo?.nome ?? 'N/A';
  String get nomeCultura => cultura?.nome ?? 'Cultura não encontrada';
  String get nomePraga => praga?.nome ?? 'Praga não encontrada';
  String get nomeCientificoPraga => praga?.nomeLatino ?? 'N/A';

  String get dosagem {
    final dsMin = diagnostico.dsMin;
    final dsMax = diagnostico.dsMax ?? '';
    final um = diagnostico.um ?? '';
    
    if (dsMin != null && dsMin.isNotEmpty) {
      return '$dsMin - $dsMax $um'.trim();
    }
    return '$dsMax $um'.trim();
  }

  String get fabricante => defensivo?.fabricante ?? 'N/A';
  String get classeAgronomica => defensivo?.classeAgronomica ?? 'N/A';
  String get modoAcao => defensivo?.modoAcao ?? 'N/A';
  String get ingredienteAtivo => defensivo?.ingredienteAtivo ?? 'N/A';

  bool get hasInfoCompleta =>
      defensivo != null && cultura != null && praga != null;

  /// Propriedades adicionais para widgets especializados
  bool get isCritico {
    final dosageValue = double.tryParse(diagnostico.dsMax ?? '0') ?? 0;
    final isHighDosage = dosageValue > 1000;
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
    return diagnostico.minAplicacaoT != null || diagnostico.maxAplicacaoT != null;
  }

  bool get temAplicacaoAerea {
    return diagnostico.minAplicacaoA != null || diagnostico.maxAplicacaoA != null;
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
