import '../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../core/data/repositories/favoritos_hive_repository.dart';
import '../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../core/services/diagnostico_integration_service.dart';
import '../data/favorito_defensivo_model.dart';
import '../data/favorito_diagnostico_model.dart';
import '../data/favorito_praga_model.dart';

/// Serviço de cache inteligente para favoritos
/// Evita consultas repetitivas e otimiza performance
class FavoritosCacheService {
  final FavoritosHiveRepository _favoritosRepository;
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final PragasHiveRepository _pragasRepository;
  final CulturaHiveRepository _culturaRepository;
  final DiagnosticoIntegrationService _integrationService;

  // Cache com timestamp para invalidação
  final Map<String, _CacheEntry<List<FavoritoDefensivoModel>>> _defensivosCache = {};
  final Map<String, _CacheEntry<List<FavoritoPragaModel>>> _pragasCache = {};
  final Map<String, _CacheEntry<List<FavoritoDiagnosticoModel>>> _diagnosticosCache = {};

  // Cache de dados relacionais para evitar consultas repetidas
  final Map<String, _CacheEntry<Map<String, String>>> _culturaNameCache = {};
  final Map<String, _CacheEntry<Map<String, List<String>>>> _pragaCulturaCache = {};

  // Tempo de vida do cache em minutos
  static const int _cacheLifetimeMinutes = 15;

  FavoritosCacheService({
    required FavoritosHiveRepository favoritosRepository,
    required FitossanitarioHiveRepository fitossanitarioRepository,
    required PragasHiveRepository pragasRepository,
    required CulturaHiveRepository culturaRepository,
    required DiagnosticoIntegrationService integrationService,
  })  : _favoritosRepository = favoritosRepository,
        _fitossanitarioRepository = fitossanitarioRepository,
        _pragasRepository = pragasRepository,
        _culturaRepository = culturaRepository,
        _integrationService = integrationService;

  /// Obtém defensivos favoritos com cache inteligente
  Future<List<FavoritoDefensivoModel>> getFavoritosDefensivos() async {
    const cacheKey = 'defensivos_favoritos';
    
    // Verifica se existe cache válido
    if (_defensivosCache.containsKey(cacheKey) && !_isCacheExpired(_defensivosCache[cacheKey]!)) {
      return _defensivosCache[cacheKey]!.data;
    }

    // Busca dados frescos usando método async para garantir que o box esteja aberto
    final favoritosDefensivos = await _favoritosRepository.getFavoritosByTipoAsync('defensivos');
    final List<FavoritoDefensivoModel> defensivosCompletos = [];
    
    print('🔍 [CacheService] Processando ${favoritosDefensivos.length} favoritos de defensivos...');
    
    for (final favorito in favoritosDefensivos) {
      print('📝 Buscando defensivo com ID: ${favorito.itemId}');
      final result = await _fitossanitarioRepository.getByKey(favorito.itemId);
      final defensivo = result.isSuccess ? result.data : null;
      
      if (defensivo != null) {
        print('✅ Defensivo encontrado: ${defensivo.nomeComum}');
        defensivosCompletos.add(FavoritoDefensivoModel(
          id: defensivo.hashCode,
          idReg: defensivo.objectId ?? favorito.itemId,
          line1: defensivo.nomeComum.isNotEmpty ? defensivo.nomeComum : defensivo.nomeTecnico,
          line2: defensivo.ingredienteAtivo?.isNotEmpty == true ? defensivo.ingredienteAtivo! : 'Ingrediente não informado',
          nomeComum: defensivo.nomeComum.isNotEmpty ? defensivo.nomeComum : null,
          ingredienteAtivo: defensivo.ingredienteAtivo,
          classeAgronomica: defensivo.classeAgronomica,
          fabricante: defensivo.fabricante,
          modoAcao: defensivo.modoAcao,
          dataCriacao: DateTime.fromMillisecondsSinceEpoch(favorito.createdAt),
        ));
      } else {
        print('❌ Defensivo não encontrado para ID: ${favorito.itemId}');
      }
    }

    // Armazena no cache
    _defensivosCache[cacheKey] = _CacheEntry(defensivosCompletos, DateTime.now());
    return defensivosCompletos;
  }

  /// Obtém pragas favoritas com cache inteligente
  Future<List<FavoritoPragaModel>> getFavoritosPragas() async {
    const cacheKey = 'pragas_favoritas';
    
    // Verifica se existe cache válido
    if (_pragasCache.containsKey(cacheKey) && !_isCacheExpired(_pragasCache[cacheKey]!)) {
      return _pragasCache[cacheKey]!.data;
    }

    // Busca dados frescos usando método async para garantir que o box esteja aberto
    final favoritosPragas = await _favoritosRepository.getFavoritosByTipoAsync('pragas');
    final List<FavoritoPragaModel> pragasCompletas = [];
    
    print('🔍 [CacheService] Processando ${favoritosPragas.length} favoritos de pragas...');
    
    // Pré-carrega cache de culturas relacionadas
    await _preloadCulturaRelations();
    
    for (final favorito in favoritosPragas) {
      final result = await _pragasRepository.getByKey(favorito.itemId);
      final praga = result.isSuccess ? result.data : null;
      if (praga != null) {
        // Busca diagnósticos relacionados para obter mais informações
        final diagnosticosRelacionados = await _integrationService.buscarPorPraga(praga.objectId);
        final culturas = diagnosticosRelacionados
            .map((d) => d.nomeCultura)
            .where((c) => c != 'Cultura não encontrada')
            .toSet()
            .toList();
        
        pragasCompletas.add(FavoritoPragaModel(
          id: praga.hashCode,
          idReg: praga.objectId,
          nomeComum: praga.nomeComum,
          nomeSecundario: praga.nomeCientifico,
          nomeCientifico: praga.nomeCientifico,
          tipoPraga: _determinaTipoPraga(praga.nomeComum),
          descricao: 'Praga controlada em ${culturas.isNotEmpty ? culturas.join(", ") : "múltiplas culturas"}',
          sintomas: 'Consulte diagnósticos específicos para sintomas detalhados',
          controle: '${diagnosticosRelacionados.length} diagnóstico(s) disponível(is)',
          dataCriacao: DateTime.fromMillisecondsSinceEpoch(favorito.createdAt),
        ));
      }
    }

    // Armazena no cache
    _pragasCache[cacheKey] = _CacheEntry(pragasCompletas, DateTime.now());
    return pragasCompletas;
  }

  /// Obtém diagnósticos favoritos com cache inteligente
  Future<List<FavoritoDiagnosticoModel>> getFavoritosDiagnosticos() async {
    const cacheKey = 'diagnosticos_favoritos';
    
    // Verifica se existe cache válido
    if (_diagnosticosCache.containsKey(cacheKey) && !_isCacheExpired(_diagnosticosCache[cacheKey]!)) {
      return _diagnosticosCache[cacheKey]!.data;
    }

    // Busca dados frescos
    final favoritosDiagnosticos = await _favoritosRepository.getFavoritosByTipoAsync('diagnosticos');
    final List<FavoritoDiagnosticoModel> diagnosticosCompletos = [];
    
    for (final favorito in favoritosDiagnosticos) {
      final diagnosticoCompleto = await _integrationService.getDiagnosticoCompleto(favorito.itemId);
      if (diagnosticoCompleto != null) {
        diagnosticosCompletos.add(FavoritoDiagnosticoModel(
          id: diagnosticoCompleto.diagnostico.hashCode,
          idReg: diagnosticoCompleto.diagnostico.objectId,
          nome: '${diagnosticoCompleto.nomeDefensivo} para ${diagnosticoCompleto.nomePraga}',
          descricao: 'Diagnóstico completo com dosagem: ${diagnosticoCompleto.dosagem}',
          cultura: diagnosticoCompleto.nomeCultura,
          categoria: diagnosticoCompleto.classeAgronomica,
          recomendacoes: 'Fabricante: ${diagnosticoCompleto.fabricante} • Modo de ação: ${diagnosticoCompleto.modoAcao}',
          dataCriacao: DateTime.fromMillisecondsSinceEpoch(favorito.createdAt),
        ));
      }
    }

    // Armazena no cache
    _diagnosticosCache[cacheKey] = _CacheEntry(diagnosticosCompletos, DateTime.now());
    return diagnosticosCompletos;
  }

  /// Pré-carrega relações de culturas para otimizar consultas
  Future<void> _preloadCulturaRelations() async {
    const cacheKey = 'cultura_relations';
    
    if (_culturaNameCache.containsKey(cacheKey) && !_isCacheExpired(_culturaNameCache[cacheKey]!)) {
      return; // Cache ainda válido
    }

    final result = await _culturaRepository.getAll();
    final culturas = result.isSuccess ? result.data ?? [] : <dynamic>[];
    final Map<String, String> culturaNames = {};
    
    for (final cultura in culturas) {
      try {
        final objectId = cultura.objectId?.toString();
        final nomeC = cultura.cultura?.toString();
        if (objectId != null && nomeC != null) {
          culturaNames[objectId] = nomeC;
        }
      } catch (e) {
        continue;
      }
    }

    _culturaNameCache[cacheKey] = _CacheEntry(culturaNames, DateTime.now());
  }

  /// Verifica se o cache expirou
  bool _isCacheExpired<T>(_CacheEntry<T> entry) {
    return DateTime.now().difference(entry.timestamp).inMinutes > _cacheLifetimeMinutes;
  }

  /// Determina o tipo da praga baseado no nome
  String _determinaTipoPraga(String nomeComum) {
    final nomeMinusculo = nomeComum.toLowerCase();
    
    // Palavras-chave para doenças
    if (nomeMinusculo.contains('fusarium') ||
        nomeMinusculo.contains('alternaria') ||
        nomeMinusculo.contains('cercospora') ||
        nomeMinusculo.contains('phoma') ||
        nomeMinusculo.contains('botrytis') ||
        nomeMinusculo.contains('colletotrichum') ||
        nomeMinusculo.contains('rhizoctonia') ||
        nomeMinusculo.contains('sclerotinia') ||
        nomeMinusculo.contains('phytophthora') ||
        nomeMinusculo.contains('pythium') ||
        nomeMinusculo.contains('ferrugem') ||
        nomeMinusculo.contains('oídio') ||
        nomeMinusculo.contains('míldio') ||
        nomeMinusculo.contains('antracnose') ||
        nomeMinusculo.contains('mancha') ||
        nomeMinusculo.contains('podridão') ||
        nomeMinusculo.contains('murcha') ||
        nomeMinusculo.contains('vírus')) {
      return '2'; // Doença
    }
    
    // Palavras-chave para plantas daninhas
    if (nomeMinusculo.contains('capim') ||
        nomeMinusculo.contains('tiririca') ||
        nomeMinusculo.contains('guanxuma') ||
        nomeMinusculo.contains('picao') ||
        nomeMinusculo.contains('caruru') ||
        nomeMinusculo.contains('corda de viola') ||
        nomeMinusculo.contains('trapoeraba') ||
        nomeMinusculo.contains('digitaria') ||
        nomeMinusculo.contains('brachiaria') ||
        nomeMinusculo.contains('cyperus') ||
        nomeMinusculo.contains('ipomoea') ||
        nomeMinusculo.contains('amaranthus') ||
        nomeMinusculo.contains('bidens') ||
        nomeMinusculo.contains('euphorbia')) {
      return '3'; // Planta daninha
    }
    
    return '1'; // Padrão: inseto/praga
  }

  /// Invalida o cache específico quando favorito é removido ou adicionado
  void invalidateCache(String tipo) {
    switch (tipo) {
      case 'defensivos':
        _defensivosCache.clear();
        break;
      case 'pragas':
        _pragasCache.clear();
        break;
      case 'diagnosticos':
        _diagnosticosCache.clear();
        break;
    }
  }

  /// Invalida todo o cache
  void clearAllCache() {
    _defensivosCache.clear();
    _pragasCache.clear();
    _diagnosticosCache.clear();
    _culturaNameCache.clear();
    _pragaCulturaCache.clear();
  }

  /// Estatísticas do cache para debug
  Map<String, dynamic> getCacheStats() {
    return {
      'defensivos_cached': _defensivosCache.isNotEmpty,
      'pragas_cached': _pragasCache.isNotEmpty,
      'diagnosticos_cached': _diagnosticosCache.isNotEmpty,
      'cultura_relations_cached': _culturaNameCache.isNotEmpty,
      'total_cache_entries': _defensivosCache.length + _pragasCache.length + _diagnosticosCache.length + _culturaNameCache.length,
      'cache_lifetime_minutes': _cacheLifetimeMinutes,
    };
  }
}

/// Entrada do cache com timestamp
class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry(this.data, this.timestamp);
}