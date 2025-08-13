// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Serviço de storage temporário em memória para usar quando Hive falha
///
/// Fornece funcionalidade básica de armazenamento sem persistência
/// para manter o app funcionando em caso de falha do Hive
class FallbackStorageService {
  static final FallbackStorageService _instance =
      FallbackStorageService._internal();
  factory FallbackStorageService() => _instance;
  FallbackStorageService._internal();

  final Map<String, dynamic> _memoryStorage = {};
  bool _isActive = false;

  /// Ativa o modo fallback
  void activate() {
    _isActive = true;
    debugPrint(
        '⚠️ FallbackStorageService ativado - dados não serão persistidos');
  }

  /// Desativa o modo fallback
  void deactivate() {
    _isActive = false;
    _memoryStorage.clear();
    debugPrint('✅ FallbackStorageService desativado');
  }

  /// Verifica se está em modo fallback
  bool get isActive => _isActive;

  /// Salva dados na memória temporariamente
  Future<void> put(String key, dynamic value) async {
    if (!_isActive) return;

    try {
      // Serializa dados complexos
      final serializedValue = _serializeValue(value);
      _memoryStorage[key] = serializedValue;
      debugPrint('📝 Fallback: salvou $key');
    } catch (e) {
      debugPrint('❌ Erro ao salvar no fallback: $e');
    }
  }

  /// Recupera dados da memória
  T? get<T>(String key, {T? defaultValue}) {
    if (!_isActive) return defaultValue;

    try {
      final value = _memoryStorage[key];
      if (value == null) return defaultValue;

      return _deserializeValue<T>(value) ?? defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao ler do fallback: $e');
      return defaultValue;
    }
  }

  /// Lista todas as chaves disponíveis
  List<String> get keys => _isActive ? _memoryStorage.keys.toList() : [];

  /// Remove uma chave específica
  Future<void> delete(String key) async {
    if (!_isActive) return;

    _memoryStorage.remove(key);
    debugPrint('🗑️ Fallback: removeu $key');
  }

  /// Limpa todos os dados
  Future<void> clear() async {
    if (!_isActive) return;

    _memoryStorage.clear();
    debugPrint('🧹 Fallback: limpou todos os dados');
  }

  /// Obtém estatísticas do storage
  Map<String, dynamic> getStats() {
    return {
      'active': _isActive,
      'keys_count': _memoryStorage.length,
      'keys': _memoryStorage.keys.toList(),
      'memory_usage_kb': _calculateMemoryUsage(),
    };
  }

  dynamic _serializeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is int || value is double || value is bool) {
      return value;
    }
    if (value is List || value is Map) {
      return jsonEncode(value);
    }
    // Para objetos complexos, tenta converter para string
    return value.toString();
  }

  T? _deserializeValue<T>(dynamic value) {
    if (value == null) return null;

    // Tipos primitivos
    if (T == String) return value.toString() as T?;
    if (T == int) {
      return (value is int ? value : int.tryParse(value.toString())) as T?;
    }
    if (T == double) {
      return (value is double ? value : double.tryParse(value.toString())) as T?;
    }
    if (T == bool) {
      return (value is bool ? value : value.toString().toLowerCase() == 'true') as T?;
    }

    // Tenta decodificar JSON para List/Map
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return decoded as T?;
      } catch (e) {
        debugPrint('⚠️ Falha ao decodificar JSON: $e');
      }
    }

    return value as T?;
  }

  double _calculateMemoryUsage() {
    try {
      final jsonString = jsonEncode(_memoryStorage);
      return jsonString.length / 1024; // KB aproximado
    } catch (e) {
      return 0.0;
    }
  }
}
