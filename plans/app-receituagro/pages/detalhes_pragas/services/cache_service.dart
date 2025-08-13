// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/cache/i_cache_service.dart';
import '../../../models/praga_unica_model.dart';
import 'error_handler_service.dart';

/// Refactored cache service for pragas using unified cache service
class PragaCacheService extends GetxService {
  static const String _pragaPrefix = 'praga_data_';
  static const String _diagnosticosPrefix = 'praga_diagnosticos_';
  static const Duration _pragaCacheValidityDuration = Duration(hours: 24);
  
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final ICacheService _cacheService = Get.find<ICacheService>();
  
  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _errorHandler.log(
        LogLevel.info,
        'PragaCacheService initialized with unified cache service',
      );
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Falha na inicialização do cache service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Salva dados da praga no cache usando serviço centralizado
  Future<bool> cachePraga(String pragaId, PragaUnica praga) async {
    try {
      final pragaKey = '$_pragaPrefix$pragaId';
      
      // Store praga data as map to ensure serialization compatibility
      await _cacheService.put(
        pragaKey,
        praga.toMap(),
        ttl: _pragaCacheValidityDuration,
      );
      
      _errorHandler.log(
        LogLevel.info,
        'Praga cached successfully with unified service',
        metadata: {'pragaId': pragaId},
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao salvar praga no cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
  
  /// Recupera dados da praga do cache usando serviço centralizado
  Future<PragaUnica?> getCachedPraga(String pragaId) async {
    try {
      final pragaKey = '$_pragaPrefix$pragaId';
      
      final pragaMap = await _cacheService.get<Map<String, dynamic>>(pragaKey);
      
      if (pragaMap == null) {
        _errorHandler.log(
          LogLevel.debug,
          'Dados da praga não encontrados no cache',
          metadata: {'pragaId': pragaId},
        );
        return null;
      }
      
      final praga = PragaUnica.fromMap(pragaMap);
      
      _errorHandler.log(
        LogLevel.info,
        'Praga recuperada do cache centralizado com sucesso',
        metadata: {'pragaId': pragaId},
      );
      
      return praga;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao recuperar praga do cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return null;
    }
  }
  
  /// Salva diagnósticos no cache usando serviço centralizado
  Future<bool> cacheDiagnosticos(String pragaId, List<dynamic> diagnosticos) async {
    try {
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      
      await _cacheService.put(
        diagnosticosKey,
        diagnosticos,
        ttl: _pragaCacheValidityDuration,
      );
      
      _errorHandler.log(
        LogLevel.info,
        'Diagnósticos cached successfully with unified service',
        metadata: {
          'pragaId': pragaId,
          'count': diagnosticos.length,
        },
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao salvar diagnósticos no cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
  
  /// Recupera diagnósticos do cache usando serviço centralizado
  Future<List<dynamic>?> getCachedDiagnosticos(String pragaId) async {
    try {
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      
      final diagnosticos = await _cacheService.get<List<dynamic>>(diagnosticosKey);
      
      if (diagnosticos == null) {
        _errorHandler.log(
          LogLevel.debug,
          'Diagnósticos não encontrados no cache',
          metadata: {'pragaId': pragaId},
        );
        return null;
      }
      
      _errorHandler.log(
        LogLevel.info,
        'Diagnósticos recuperados do cache centralizado com sucesso',
        metadata: {
          'pragaId': pragaId,
          'count': diagnosticos.length,
        },
      );
      
      return diagnosticos;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao recuperar diagnósticos do cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return null;
    }
  }
  
  /// Remove dados da praga do cache
  Future<bool> removeCachedPraga(String pragaId) async {
    try {
      final pragaKey = '$_pragaPrefix$pragaId';
      
      await _cacheService.remove(pragaKey);
      
      _errorHandler.log(
        LogLevel.debug,
        'Dados da praga removidos do cache centralizado',
        metadata: {'pragaId': pragaId},
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao remover praga do cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
  
  /// Remove diagnósticos do cache
  Future<bool> removeCachedDiagnosticos(String pragaId) async {
    try {
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      
      await _cacheService.remove(diagnosticosKey);
      
      _errorHandler.log(
        LogLevel.debug,
        'Diagnósticos removidos do cache centralizado',
        metadata: {'pragaId': pragaId},
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao remover diagnósticos do cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
  
  /// Limpa todo o cache de pragas usando serviço centralizado
  Future<bool> clearCache() async {
    try {
      await _cacheService.clearByPrefix(_pragaPrefix);
      await _cacheService.clearByPrefix(_diagnosticosPrefix);
      
      _errorHandler.log(
        LogLevel.info,
        'Cache de pragas limpo com sucesso através do serviço centralizado',
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao limpar cache de pragas',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// Verifica se existe cache válido para uma praga
  Future<bool> hasCachedPraga(String pragaId) async {
    try {
      final pragaKey = '$_pragaPrefix$pragaId';
      
      return await _cacheService.has(pragaKey);
    } catch (e) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao verificar cache da praga',
        error: e,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
  
  /// Verifica se existe cache válido para diagnósticos
  Future<bool> hasCachedDiagnosticos(String pragaId) async {
    try {
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      
      return await _cacheService.has(diagnosticosKey);
    } catch (e) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao verificar cache dos diagnósticos',
        error: e,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
  
  /// Retorna estatísticas do cache usando serviço centralizado
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final overallStats = await _cacheService.getStats();
      final keys = await _cacheService.getKeys();
      
      final pragaKeys = keys.where((key) => key.startsWith(_pragaPrefix));
      final diagnosticosKeys = keys.where((key) => key.startsWith(_diagnosticosPrefix));
      
      return {
        'pragaEntries': pragaKeys.length,
        'diagnosticosEntries': diagnosticosKeys.length,
        'totalEntries': pragaKeys.length + diagnosticosKeys.length,
        'strategy': 'unified_cache_service',
        'overallCacheStats': overallStats,
      };
    } catch (e) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao obter estatísticas do cache',
        error: e,
      );
      return {
        'pragaEntries': 0,
        'diagnosticosEntries': 0,
        'totalEntries': 0,
        'error': e.toString(),
      };
    }
  }

  /// Remove todas as entradas de cache relacionadas a uma praga específica
  Future<bool> removeAllPragaCache(String pragaId) async {
    try {
      await removeCachedPraga(pragaId);
      await removeCachedDiagnosticos(pragaId);
      
      _errorHandler.log(
        LogLevel.info,
        'Todos os dados de cache da praga removidos',
        metadata: {'pragaId': pragaId},
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao remover todos os dados de cache da praga',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }
}