// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache inteligente para dados de diagnósticos
/// Implementa estratégia offline-first com TTL (Time To Live)
class DiagnosticoCacheService extends GetxService {
  static const String _cachePrefix = 'diagnostico_cache_';
  static const String _timestampPrefix = 'diagnostico_timestamp_';
  static const int _cacheTtlMinutes = 30; // Cache válido por 30 minutos

  late SharedPreferences _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }

  /// Verifica se o cache é válido para um diagnóstico específico
  bool _isCacheValid(String diagnosticoId) {
    final timestamp = _prefs.getInt('$_timestampPrefix$diagnosticoId');
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime).inMinutes;

    return difference < _cacheTtlMinutes;
  }

  /// Armazena dados do diagnóstico no cache
  Future<void> cacheDiagnostico(
      String diagnosticoId, Map<String, dynamic> data) async {
    try {
      final jsonData = json.encode(data);
      await _prefs.setString('$_cachePrefix$diagnosticoId', jsonData);
      await _prefs.setInt('$_timestampPrefix$diagnosticoId',
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Erro silencioso ao cachear diagnóstico
    }
  }

  /// Recupera dados do diagnóstico do cache
  Map<String, dynamic>? getCachedDiagnostico(String diagnosticoId) {
    try {
      if (!_isCacheValid(diagnosticoId)) {
        return null;
      }

      final jsonData = _prefs.getString('$_cachePrefix$diagnosticoId');
      if (jsonData == null) return null;

      return json.decode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      // Erro silencioso ao recuperar cache do diagnóstico
      return null;
    }
  }

  /// Limpa cache expirado de todos os diagnósticos
  Future<void> clearExpiredCache() async {
    try {
      final keys = _prefs.getKeys();
      final now = DateTime.now();

      for (final key in keys) {
        if (key.startsWith(_timestampPrefix)) {
          final timestamp = _prefs.getInt(key);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final difference = now.difference(cacheTime).inMinutes;

            if (difference >= _cacheTtlMinutes) {
              final diagnosticoId = key.replaceFirst(_timestampPrefix, '');
              await _prefs.remove(key);
              await _prefs.remove('$_cachePrefix$diagnosticoId');
            }
          }
        }
      }
    } catch (e) {
      // Erro silencioso ao limpar cache expirado
    }
  }

  /// Limpa todo o cache de diagnósticos
  Future<void> clearAllCache() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      // Erro silencioso ao limpar todo o cache
    }
  }

  /// Obtém estatísticas do cache
  Map<String, int> getCacheStats() {
    final keys = _prefs.getKeys();
    int totalCached = 0;
    int validCached = 0;

    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        totalCached++;
        final diagnosticoId = key.replaceFirst(_cachePrefix, '');
        if (_isCacheValid(diagnosticoId)) {
          validCached++;
        }
      }
    }

    return {
      'total': totalCached,
      'valid': validCached,
      'expired': totalCached - validCached,
    };
  }
}
