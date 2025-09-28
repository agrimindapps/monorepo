import '../models/cultura_hive.dart';
import '../models/diagnostico_hive.dart';
import '../models/fitossanitario_hive.dart';
import '../models/fitossanitario_info_hive.dart';
import '../models/pragas_hive.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';

/// Service responsável por integrar dados de múltiplas HiveBoxes
/// para criar views relacionais completas dos diagnósticos
class DiagnosticoIntegrationService {
  final DiagnosticoHiveRepository _diagnosticoRepo;
  final FitossanitarioHiveRepository _fitossanitarioRepo;
  final CulturaHiveRepository _culturaRepo;
  final PragasHiveRepository _pragasRepo;
  final FitossanitarioInfoHiveRepository _fitossanitarioInfoRepo;

  // Cache interno para performance
  final Map<String, FitossanitarioHive> _defensivoCache = {};
  final Map<String, CulturaHive> _culturaCache = {};
  final Map<String, PragasHive> _pragaCache = {};
  final Map<String, FitossanitarioInfoHive> _infoDefensivoCache = {};

  DiagnosticoIntegrationService({
    required DiagnosticoHiveRepository diagnosticoRepo,
    required FitossanitarioHiveRepository fitossanitarioRepo,
    required CulturaHiveRepository culturaRepo,
    required PragasHiveRepository pragasRepo,
    required FitossanitarioInfoHiveRepository fitossanitarioInfoRepo,
  })  : _diagnosticoRepo = diagnosticoRepo,
        _fitossanitarioRepo = fitossanitarioRepo,
        _culturaRepo = culturaRepo,
        _pragasRepo = pragasRepo,
        _fitossanitarioInfoRepo = fitossanitarioInfoRepo;

  /// Obtém um diagnóstico completo com todos os dados relacionais
  Future<DiagnosticoDetalhado?> getDiagnosticoCompleto(String idReg) async {
    try {
      final diagnostico = await _diagnosticoRepo.getByIdOrObjectId(idReg);
      if (diagnostico == null) return null;

      // Buscar dados relacionados com cache
      final defensivo = await _getDefensivoById(diagnostico.fkIdDefensivo);
      final cultura = await _getCulturaById(diagnostico.fkIdCultura);
      final praga = await _getPragaById(diagnostico.fkIdPraga);
      
      // Buscar informações adicionais do defensivo se existir
      FitossanitarioInfoHive? infoDefensivo;
      if (defensivo != null) {
        infoDefensivo = await _getInfoDefensivoById(defensivo.idReg);
      }

      return DiagnosticoDetalhado(
        diagnostico: diagnostico,
        defensivo: defensivo,
        cultura: cultura,
        praga: praga,
        infoDefensivo: infoDefensivo,
      );
    } catch (e) {
      // TODO: Implement proper logging
      return null;
    }
  }

  /// Busca diagnósticos por cultura com dados relacionais
  Future<List<DiagnosticoDetalhado>> buscarPorCultura(String culturaId) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findByCultura(culturaId);
      final List<DiagnosticoDetalhado> detalhados = [];

      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      // TODO: Implement proper logging
      return [];
    }
  }

  /// Busca diagnósticos por praga com dados relacionais
  Future<List<DiagnosticoDetalhado>> buscarPorPraga(String pragaId) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findByPraga(pragaId);
      final List<DiagnosticoDetalhado> detalhados = [];

      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      // TODO: Implement proper logging
      return [];
    }
  }

  /// Busca diagnósticos por defensivo com dados relacionais
  Future<List<DiagnosticoDetalhado>> buscarPorDefensivo(String defensivoId) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findByDefensivo(defensivoId);
      final List<DiagnosticoDetalhado> detalhados = [];

      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      // TODO: Implement proper logging
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
      final result = await _diagnosticoRepo.getAll();
      List<DiagnosticoHive> diagnosticos = result.isSuccess ? result.data! : [];

      // Aplicar filtros
      if (culturaId != null && culturaId.isNotEmpty) {
        diagnosticos = diagnosticos.where((d) => d.fkIdCultura == culturaId).toList();
      }

      if (pragaId != null && pragaId.isNotEmpty) {
        diagnosticos = diagnosticos.where((d) => d.fkIdPraga == pragaId).toList();
      }

      if (defensivoId != null && defensivoId.isNotEmpty) {
        diagnosticos = diagnosticos.where((d) => d.fkIdDefensivo == defensivoId).toList();
      }

      // Converter para diagnósticos detalhados
      final List<DiagnosticoDetalhado> detalhados = [];
      for (final diagnostico in diagnosticos) {
        final detalhado = await getDiagnosticoCompleto(diagnostico.idReg);
        if (detalhado != null) {
          detalhados.add(detalhado);
        }
      }

      return detalhados;
    } catch (e) {
      // TODO: Implement proper logging
      return [];
    }
  }

  /// Obtém defensivos completos com informações detalhadas
  Future<List<DefensivoCompleto>> getDefensivosCompletos() async {
    try {
      final defensivosResult = await _fitossanitarioRepo.getAll();
      final defensivos = defensivosResult.isSuccess ? defensivosResult.data! : <FitossanitarioHive>[];
      final List<DefensivoCompleto> defensivosCompletos = [];

      for (final defensivo in defensivos) {
        final info = await _getInfoDefensivoById(defensivo.idReg);
        
        // Buscar diagnósticos relacionados
        final diagnosticosRelacionados = await buscarPorDefensivo(defensivo.idReg);
        
        defensivosCompletos.add(DefensivoCompleto(
          defensivo: defensivo,
          infoDetalhada: info,
          diagnosticosRelacionados: diagnosticosRelacionados,
        ));
      }

      return defensivosCompletos;
    } catch (e) {
      // TODO: Implement proper logging
      return [];
    }
  }

  /// Obtém pragas por cultura com diagnósticos relacionados (OTIMIZADO)
  Future<List<PragaPorCultura>> getPragasPorCultura(String culturaId) async {
    try {
      print('=== OTIMIZADO: Carregando pragas para cultura $culturaId ===');
      
      // 1. Buscar APENAS os diagnósticos básicos da cultura (sem join completo)
      final diagnosticosBrutos = await _diagnosticoRepo.findByCultura(culturaId);
      print('Encontrados ${diagnosticosBrutos.length} diagnósticos básicos');
      
      if (diagnosticosBrutos.isEmpty) return [];
      
      // 2. Coletar IDs únicos que precisamos buscar
      final pragaIds = diagnosticosBrutos.map((d) => d.fkIdPraga).toSet();
      final defensivoIds = diagnosticosBrutos.map((d) => d.fkIdDefensivo).toSet();
      print('IDs únicos - Pragas: ${pragaIds.length}, Defensivos: ${defensivoIds.length}');
      
      // 3. Carregar em lote todas as pragas e defensivos necessários
      final pragasMap = <String, PragasHive>{};
      final defensivosMap = <String, FitossanitarioHive>{};
      
      // Carregar pragas em cache
      for (final pragaId in pragaIds) {
        if (!_pragaCache.containsKey(pragaId)) {
          final result = await _pragasRepo.getByKey(pragaId);
          if (result.isSuccess && result.data != null) {
            _pragaCache[pragaId] = result.data!;
          }
        }
        if (_pragaCache.containsKey(pragaId)) {
          pragasMap[pragaId] = _pragaCache[pragaId]!;
        }
      }
      
      // Carregar defensivos em cache
      for (final defensivoId in defensivoIds) {
        if (!_defensivoCache.containsKey(defensivoId)) {
          final result = await _fitossanitarioRepo.getByKey(defensivoId);
          if (result.isSuccess && result.data != null) {
            _defensivoCache[defensivoId] = result.data!;
          }
        }
        if (_defensivoCache.containsKey(defensivoId)) {
          defensivosMap[defensivoId] = _defensivoCache[defensivoId]!;
        }
      }
      
      // 4. Agrupar diagnósticos por praga e criar objetos DetalhadorS
      final Map<String, List<DiagnosticoDetalhado>> pragasMapDetalhado = {};
      
      for (final diagnostico in diagnosticosBrutos) {
        final pragaId = diagnostico.fkIdPraga;
        if (!pragasMapDetalhado.containsKey(pragaId)) {
          pragasMapDetalhado[pragaId] = [];
        }
        
        // Criar DiagnosticoDetalhado apenas com dados já carregados
        final diagnosticoDetalhado = DiagnosticoDetalhado(
          diagnostico: diagnostico,
          defensivo: defensivosMap[diagnostico.fkIdDefensivo],
          cultura: _culturaCache[culturaId], // já deveria estar em cache
          praga: pragasMap[pragaId],
          infoDefensivo: null, // Por performance, não carregar info adicional aqui
        );
        
        pragasMapDetalhado[pragaId]!.add(diagnosticoDetalhado);
      }

      // 5. Converter para resultado final
      final List<PragaPorCultura> pragasPorCultura = [];
      for (final entry in pragasMapDetalhado.entries) {
        final praga = pragasMap[entry.key];
        if (praga != null) {
          pragasPorCultura.add(PragaPorCultura(
            praga: praga,
            diagnosticosRelacionados: entry.value,
          ));
        }
      }
      
      print('Criadas ${pragasPorCultura.length} pragas por cultura');
      return pragasPorCultura;
    } catch (e) {
      print('Erro otimizado ao carregar pragas: $e');
      return [];
    }
  }

  /// Métodos auxiliares para cache

  Future<FitossanitarioHive?> _getDefensivoById(String id) async {
    if (_defensivoCache.containsKey(id)) {
      return _defensivoCache[id];
    }

    final result = await _fitossanitarioRepo.getByKey(id);
    final defensivo = result.isSuccess ? result.data : null;
    if (defensivo != null) {
      _defensivoCache[id] = defensivo;
    }
    return defensivo;
  }

  Future<CulturaHive?> _getCulturaById(String id) async {
    if (_culturaCache.containsKey(id)) {
      return _culturaCache[id];
    }

    final result = await _culturaRepo.getByKey(id);
    final cultura = result.isSuccess ? result.data : null;
    if (cultura != null) {
      _culturaCache[id] = cultura;
    }
    return cultura;
  }

  Future<PragasHive?> _getPragaById(String id) async {
    if (_pragaCache.containsKey(id)) {
      return _pragaCache[id];
    }

    final result = await _pragasRepo.getByKey(id);
    final praga = result.isSuccess ? result.data : null;
    if (praga != null) {
      _pragaCache[id] = praga;
    }
    return praga;
  }

  Future<FitossanitarioInfoHive?> _getInfoDefensivoById(String id) async {
    if (_infoDefensivoCache.containsKey(id)) {
      return _infoDefensivoCache[id];
    }

    final result = await _fitossanitarioInfoRepo.getByKey(id);
    final info = result.isSuccess ? result.data : null;
    if (info != null) {
      _infoDefensivoCache[id] = info;
    }
    return info;
  }

  /// Limpa o cache interno
  void clearCache() {
    _defensivoCache.clear();
    _culturaCache.clear();
    _pragaCache.clear();
    _infoDefensivoCache.clear();
  }

  /// Estatísticas para debug
  Map<String, int> getCacheStats() {
    return {
      'defensivos': _defensivoCache.length,
      'culturas': _culturaCache.length,
      'pragas': _pragaCache.length,
      'infosDefensivos': _infoDefensivoCache.length,
    };
  }
}

/// Modelo que representa um diagnóstico com todos os dados relacionais
class DiagnosticoDetalhado {
  final DiagnosticoHive diagnostico;
  final FitossanitarioHive? defensivo;
  final CulturaHive? cultura;
  final PragasHive? praga;
  final FitossanitarioInfoHive? infoDefensivo;

  DiagnosticoDetalhado({
    required this.diagnostico,
    this.defensivo,
    this.cultura,
    this.praga,
    this.infoDefensivo,
  });

  /// Getters para exibição com fallbacks seguros
  String get nomeDefensivo => defensivo?.nomeComum ?? diagnostico.nomeDefensivo ?? 'Defensivo não encontrado';
  String get nomeComercialDefensivo => defensivo?.nomeComum ?? 'N/A';
  String get nomeTecnicoDefensivo => defensivo?.nomeTecnico ?? 'N/A';
  String get nomeCultura => cultura?.cultura ?? diagnostico.nomeCultura ?? 'Cultura não encontrada';
  String get nomePraga => praga?.nomeComum ?? diagnostico.nomePraga ?? 'Praga não encontrada';
  String get nomeCientificoPraga => praga?.nomeCientifico ?? 'N/A';
  
  String get dosagem {
    if (diagnostico.dsMin != null && diagnostico.dsMin!.isNotEmpty) {
      return '${diagnostico.dsMin} - ${diagnostico.dsMax} ${diagnostico.um}';
    }
    return '${diagnostico.dsMax} ${diagnostico.um}';
  }

  String get fabricante => defensivo?.fabricante ?? 'N/A';
  String get classeAgronomica => defensivo?.classeAgronomica ?? 'N/A';
  String get modoAcao => defensivo?.modoAcao ?? 'N/A';
  String get ingredienteAtivo => defensivo?.ingredienteAtivo ?? 'N/A';
  
  bool get hasInfoCompleta => defensivo != null && cultura != null && praga != null;
  
  /// Propriedades adicionais para widgets especializados
  bool get isCritico {
    // Considera crítico se: dosagem alta, toxicidade classe I ou II, ou problema de dados
    final dosageValue = double.tryParse(diagnostico.dsMax) ?? 0;
    final isHighDosage = dosageValue > 1000; // Exemplo: dosagem > 1L/ha
    
    // Verifica se tem dados incompletos críticos
    final hasCriticalMissingData = defensivo == null || cultura == null || praga == null;
    
    return isHighDosage || hasCriticalMissingData;
  }
  
  String get descricaoResumida {
    if (hasInfoCompleta) {
      return '$nomeDefensivo para $nomePraga em $nomeCultura';
    } else {
      return 'Diagnóstico ${diagnostico.objectId}';
    }
  }
  
  bool get temAplicacaoTerrestre {
    // Verifica se tem aplicação terrestre baseado na formulação do defensivo
    final formulacao = defensivo?.formulacao?.toLowerCase() ?? '';
    return formulacao.contains('sc') || formulacao.contains('ec') || formulacao.contains('wg') || formulacao.isEmpty;
  }
  
  bool get temAplicacaoAerea {
    // Verifica se tem aplicação aérea baseado na formulação do defensivo  
    final formulacao = defensivo?.formulacao?.toLowerCase() ?? '';
    return formulacao.contains('ul') || formulacao.contains('eo');
  }

  // Getter para compatibilidade com código legado
  List<FitossanitarioHive> get defensivos {
    return defensivo != null ? [defensivo!] : [];
  }
}

/// Modelo que representa um defensivo com informações completas
class DefensivoCompleto {
  final FitossanitarioHive defensivo;
  final FitossanitarioInfoHive? infoDetalhada;
  final List<DiagnosticoDetalhado> diagnosticosRelacionados;

  DefensivoCompleto({
    required this.defensivo,
    this.infoDetalhada,
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
  final PragasHive praga;
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