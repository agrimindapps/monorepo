// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../models/praga_unica_model.dart';
import 'error_handler_service.dart';

/// Service para gerenciar cache local de dados de pragas
class PragaCacheService extends GetxService {
  static const String _pragaPrefix = 'praga_cache_';
  static const String _diagnosticosPrefix = 'diagnosticos_cache_';
  static const String _timestampSuffix = '_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);
  
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  SharedPreferences? _prefs;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Falha na inicialização do cache service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Salva dados da praga no cache
  Future<bool> cachePraga(String pragaId, PragaUnica praga) async {
    try {
      if (_prefs == null) return false;
      
      final pragaJson = jsonEncode(praga.toMap());
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final pragaKey = '$_pragaPrefix$pragaId';
      final timestampKey = '$pragaKey$_timestampSuffix';
      
      final success = await _prefs!.setString(pragaKey, pragaJson) &&
                     await _prefs!.setInt(timestampKey, timestamp);
      
      if (success) {
      }
      
      return success;
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
  
  /// Recupera dados da praga do cache
  Future<PragaUnica?> getCachedPraga(String pragaId) async {
    try {
      if (_prefs == null) return null;
      
      final pragaKey = '$_pragaPrefix$pragaId';
      final timestampKey = '$pragaKey$_timestampSuffix';
      
      final pragaJson = _prefs!.getString(pragaKey);
      final timestamp = _prefs!.getInt(timestampKey);
      
      if (pragaJson == null || timestamp == null) {
        _errorHandler.log(
          LogLevel.debug,
          'Dados da praga não encontrados no cache',
          metadata: {'pragaId': pragaId},
        );
        return null;
      }
      
      // Verificar se o cache ainda é válido
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > _cacheValidityDuration.inMilliseconds) {
        _errorHandler.log(
          LogLevel.info,
          'Cache da praga expirado, removendo dados antigos',
          metadata: {
            'pragaId': pragaId,
            'cacheAgeHours': (cacheAge / (1000 * 60 * 60)).round(),
          },
        );
        await _removeCachedPraga(pragaId);
        return null;
      }
      
      final pragaMap = jsonDecode(pragaJson) as Map<String, dynamic>;
      final praga = PragaUnica.fromMap(pragaMap);
      
      _errorHandler.log(
        LogLevel.info,
        'Praga recuperada do cache com sucesso',
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
  
  /// Salva diagnósticos no cache
  Future<bool> cacheDiagnosticos(String pragaId, List<dynamic> diagnosticos) async {
    try {
      if (_prefs == null) return false;
      
      final diagnosticosJson = jsonEncode(diagnosticos);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      final timestampKey = '$diagnosticosKey$_timestampSuffix';
      
      final success = await _prefs!.setString(diagnosticosKey, diagnosticosJson) &&
                     await _prefs!.setInt(timestampKey, timestamp);
      
      if (success) {
      }
      
      return success;
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
  
  /// Recupera diagnósticos do cache
  Future<List<dynamic>?> getCachedDiagnosticos(String pragaId) async {
    try {
      if (_prefs == null) return null;
      
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      final timestampKey = '$diagnosticosKey$_timestampSuffix';
      
      final diagnosticosJson = _prefs!.getString(diagnosticosKey);
      final timestamp = _prefs!.getInt(timestampKey);
      
      if (diagnosticosJson == null || timestamp == null) {
        _errorHandler.log(
          LogLevel.debug,
          'Diagnósticos não encontrados no cache',
          metadata: {'pragaId': pragaId},
        );
        return null;
      }
      
      // Verificar se o cache ainda é válido
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > _cacheValidityDuration.inMilliseconds) {
        _errorHandler.log(
          LogLevel.info,
          'Cache de diagnósticos expirado, removendo dados antigos',
          metadata: {
            'pragaId': pragaId,
            'cacheAgeHours': (cacheAge / (1000 * 60 * 60)).round(),
          },
        );
        await _removeCachedDiagnosticos(pragaId);
        return null;
      }
      
      final diagnosticos = jsonDecode(diagnosticosJson) as List<dynamic>;
      
      _errorHandler.log(
        LogLevel.info,
        'Diagnósticos recuperados do cache com sucesso',
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
  Future<bool> _removeCachedPraga(String pragaId) async {
    try {
      if (_prefs == null) return false;
      
      final pragaKey = '$_pragaPrefix$pragaId';
      final timestampKey = '$pragaKey$_timestampSuffix';
      
      final success = await _prefs!.remove(pragaKey) &&
                     await _prefs!.remove(timestampKey);
      
      if (success) {
        _errorHandler.log(
          LogLevel.debug,
          'Dados da praga removidos do cache',
          metadata: {'pragaId': pragaId},
        );
      }
      
      return success;
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
  Future<bool> _removeCachedDiagnosticos(String pragaId) async {
    try {
      if (_prefs == null) return false;
      
      final diagnosticosKey = '$_diagnosticosPrefix$pragaId';
      final timestampKey = '$diagnosticosKey$_timestampSuffix';
      
      final success = await _prefs!.remove(diagnosticosKey) &&
                     await _prefs!.remove(timestampKey);
      
      if (success) {
        _errorHandler.log(
          LogLevel.debug,
          'Diagnósticos removidos do cache',
          metadata: {'pragaId': pragaId},
        );
      }
      
      return success;
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
  
  /// Limpa todo o cache de pragas
  Future<bool> clearCache() async {
    try {
      if (_prefs == null) return false;
      
      final keys = _prefs!.getKeys();
      final pragaKeys = keys.where((key) => 
        key.startsWith(_pragaPrefix) || 
        key.startsWith(_diagnosticosPrefix)
      ).toList();
      
      for (final key in pragaKeys) {
        await _prefs!.remove(key);
      }
      
      _errorHandler.log(
        LogLevel.info,
        'Cache de pragas limpo com sucesso',
        metadata: {'removedKeys': pragaKeys.length},
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
      if (_prefs == null) return false;
      
      final pragaKey = '$_pragaPrefix$pragaId';
      final timestampKey = '$pragaKey$_timestampSuffix';
      
      final hasData = _prefs!.containsKey(pragaKey);
      if (!hasData) return false;
      
      final timestamp = _prefs!.getInt(timestampKey);
      if (timestamp == null) return false;
      
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      return cacheAge <= _cacheValidityDuration.inMilliseconds;
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
  
  /// Retorna estatísticas do cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (_prefs == null) {
        return {
          'totalEntries': 0,
          'pragaEntries': 0,
          'diagnosticosEntries': 0,
          'totalSize': 0,
        };
      }
      
      final keys = _prefs!.getKeys();
      final pragaKeys = keys.where((key) => key.startsWith(_pragaPrefix) && !key.endsWith(_timestampSuffix));
      final diagnosticosKeys = keys.where((key) => key.startsWith(_diagnosticosPrefix) && !key.endsWith(_timestampSuffix));
      
      int totalSize = 0;
      for (final key in keys) {
        if (key.startsWith(_pragaPrefix) || key.startsWith(_diagnosticosPrefix)) {
          final value = _prefs!.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return {
        'totalEntries': pragaKeys.length + diagnosticosKeys.length,
        'pragaEntries': pragaKeys.length,
        'diagnosticosEntries': diagnosticosKeys.length,
        'totalSize': totalSize,
      };
    } catch (e) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao obter estatísticas do cache',
        error: e,
      );
      return {
        'totalEntries': 0,
        'pragaEntries': 0,
        'diagnosticosEntries': 0,
        'totalSize': 0,
        'error': e.toString(),
      };
    }
  }
}
