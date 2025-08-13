// Project imports:
import '../../../models/praga_unica_model.dart';
import '../../../repository/pragas_repository.dart';
import '../models/praga_details_model.dart';
import 'cache_service.dart';
import 'error_handler_service.dart';

/// Service responsável pelo carregamento e cache de dados de pragas
class PragaDataService {
  final PragasRepository _pragasRepository;
  final ErrorHandlerService _errorHandler;
  final PragaCacheService _cacheService;

  PragaDataService({
    required PragasRepository pragasRepository,
    required ErrorHandlerService errorHandler,
    required PragaCacheService cacheService,
  })  : _pragasRepository = pragasRepository,
        _errorHandler = errorHandler,
        _cacheService = cacheService;

  /// Carrega os dados básicos da praga
  Future<PragaUnica?> loadPragaById(String pragaId) async {
    try {
      await _errorHandler.withRetry(
        () => _pragasRepository.getPragaById(pragaId),
        operationName: 'carregamento de dados básicos da praga',
      );
      
      final praga = _pragasRepository.pragaUnica;
      
      // Cache dos dados básicos
      await _cacheService.cachePraga(pragaId, praga);
      
      return praga;
    } catch (e, stackTrace) {
      final exception = _errorHandler.createException(
        'Falha ao carregar dados da praga: $pragaId',
        e,
      );
      
      _errorHandler.log(
        LogLevel.error,
        'Erro crítico no carregamento da praga',
        error: exception,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      
      // Tentar fallback com dados do cache
      return await _tryLoadFromCache(pragaId);
    }
  }

  /// Carrega os diagnósticos da praga
  Future<List<dynamic>> loadDiagnosticos(String pragaId) async {
    try {
      final diagnosticos = await _pragasRepository.getDiagnosticos(pragaId);
      
      // Cache dos diagnósticos
      await _cacheService.cacheDiagnosticos(pragaId, diagnosticos);
      
      
      return diagnosticos;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao carregar diagnósticos',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      
      // Tentar carregar do cache
      final cachedDiagnosticos = await _cacheService.getCachedDiagnosticos(pragaId);
      return cachedDiagnosticos ?? <dynamic>[];
    }
  }

  /// Tenta carregar dados do cache local
  Future<PragaUnica?> _tryLoadFromCache(String pragaId) async {
    try {
      final cachedPraga = await _cacheService.getCachedPraga(pragaId);
      if (cachedPraga != null) {
        return cachedPraga;
      }
      
      return null;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Falha também no carregamento do cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return null;
    }
  }

  /// Carrega dados secundários com tratamento individual de erros
  Future<Map<String, dynamic>> loadSecondaryData(String pragaId) async {
    final results = <String, dynamic>{};
    
    // Carrega diagnósticos com fallback
    results['diagnosticos'] = await _errorHandler.handleWithFallback(
      () => loadDiagnosticos(pragaId),
      () => <dynamic>[], // fallback para lista vazia
      operationName: 'carregamento de diagnósticos',
      showUserMessage: false,
    );
    
    return results;
  }

  /// Cria modelo de dados formatado para a view
  PragaDetailsModel? createPragaDetailsModel(
    PragaUnica? praga,
    List<dynamic> diagnosticos,
    bool isFavorite,
    double fontSize,
  ) {
    if (praga == null) return null;
    
    return PragaDetailsModel(
      praga: praga,
      diagnosticos: diagnosticos,
      isFavorite: isFavorite,
      fontSize: fontSize,
    );
  }
}
