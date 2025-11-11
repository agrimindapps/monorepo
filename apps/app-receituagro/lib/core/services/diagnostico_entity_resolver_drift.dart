import 'package:flutter/foundation.dart';

import '../../database/receituagro_database.dart';
import '../di/injection_container.dart';

/// Serviço unificado para resolver nomes de entidades em diagnósticos
///
/// Centraliza a lógica de resolução de IDs para nomes legíveis,
/// garantindo consistência em toda a aplicação e otimizando performance
/// através de cache inteligente.
///
/// **Funcionalidades:**
/// - Resolução de culturas por ID ou nome
/// - Resolução de defensivos por ID ou nome
/// - Resolução de pragas por ID ou nome
/// - Cache automático com invalidação inteligente
/// - Fallback strategies para dados incompletos
/// - Batch resolution para operações em lote
///
/// **MIGRADO PARA DRIFT**: Agora usa tabelas estáticas do Drift
/// ao invés de repositórios Hive.
class DiagnosticoEntityResolver {
  static DiagnosticoEntityResolver? _instance;
  static DiagnosticoEntityResolver get instance =>
      _instance ??= DiagnosticoEntityResolver._internal();

  DiagnosticoEntityResolver._internal();

  // Database Drift (dados estáticos)
  late final ReceituagroDatabase _db = sl<ReceituagroDatabase>();

  // Caches mantidos (dados estáticos não mudam frequentemente)
  final Map<String, String> _culturaCache = {};
  final Map<String, String> _defensivoCache = {};
  final Map<String, String> _pragaCache = {};

  DateTime? _lastCacheUpdate;
  static const Duration _cacheTTL = Duration(minutes: 30);

  /// Verifica se o cache está válido
  bool get _isCacheValid {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTTL;
  }

  /// Limpa todos os caches
  void clearCache() {
    _culturaCache.clear();
    _defensivoCache.clear();
    _pragaCache.clear();
    _lastCacheUpdate = null;
    debugPrint('🗑️ DiagnosticoEntityResolver: Cache limpo');
  }

  /// Resolve nome de cultura APENAS usando ID (NUNCA aceita nome cached)
  ///
  /// ✅ REGRA CRÍTICA: SEMPRE resolve via database Drift
  /// ❌ NUNCA usa campos nomeCultura cached
  ///
  /// Ordem de resolução:
  /// 1. Cache (se válido)
  /// 2. Busca por idCultura na tabela culturas
  /// 3. Retorna valor padrão
  Future<String> resolveCulturaNome({
    required String idCultura,
    String defaultValue = 'Cultura não especificada',
  }) async {
    try {
      if (_isCacheValid && _culturaCache.containsKey(idCultura)) {
        return _culturaCache[idCultura]!;
      }

      if (idCultura.isNotEmpty) {
        // Query direta na tabela culturas do Drift
        final culturaQuery = _db.select(_db.culturas)
          ..where((c) => c.idCultura.equals(idCultura));
        final cultura = await culturaQuery.getSingleOrNull();

        if (cultura != null && cultura.nome.isNotEmpty) {
          final resolvedName = cultura.nome;
          _culturaCache[idCultura] = resolvedName;
          _updateCacheTimestamp();
          return resolvedName;
        }
      }

      _culturaCache[idCultura] = defaultValue;
      _updateCacheTimestamp();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver cultura: $e');
      return defaultValue;
    }
  }

  /// Resolve nome de defensivo APENAS usando ID (NUNCA aceita nome cached)
  ///
  /// ✅ REGRA CRÍTICA: SEMPRE resolve via database Drift
  /// ❌ NUNCA usa campos nomeDefensivo cached
  ///
  /// Ordem de resolução:
  /// 1. Cache (se válido)
  /// 2. Busca por idDefensivo na tabela fitossanitarios
  /// 3. Retorna valor padrão
  Future<String> resolveDefensivoNome({
    required String idDefensivo,
    String defaultValue = 'Defensivo não especificado',
  }) async {
    try {
      if (_isCacheValid && _defensivoCache.containsKey(idDefensivo)) {
        return _defensivoCache[idDefensivo]!;
      }

      if (idDefensivo.isNotEmpty) {
        // Query direta na tabela fitossanitarios do Drift
        final defensivoQuery = _db.select(_db.fitossanitarios)
          ..where((f) => f.idDefensivo.equals(idDefensivo));
        final defensivo = await defensivoQuery.getSingleOrNull();

        if (defensivo != null && defensivo.nome.isNotEmpty) {
          final resolvedName = defensivo.nome;
          _defensivoCache[idDefensivo] = resolvedName;
          _updateCacheTimestamp();
          return resolvedName;
        }
      }

      _defensivoCache[idDefensivo] = defaultValue;
      _updateCacheTimestamp();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver defensivo: $e');
      return defaultValue;
    }
  }

  /// Resolve nome de praga APENAS usando ID (NUNCA aceita nome cached)
  ///
  /// ✅ REGRA CRÍTICA: SEMPRE resolve via database Drift
  /// ❌ NUNCA usa campos nomePraga cached
  ///
  /// Ordem de resolução:
  /// 1. Cache (se válido)
  /// 2. Busca por idPraga na tabela pragas
  /// 3. Retorna valor padrão
  Future<String> resolvePragaNome({
    required String idPraga,
    String defaultValue = 'Praga não especificada',
  }) async {
    try {
      if (_isCacheValid && _pragaCache.containsKey(idPraga)) {
        return _pragaCache[idPraga]!;
      }

      if (idPraga.isNotEmpty) {
        // Query direta na tabela pragas do Drift
        final pragaQuery = _db.select(_db.pragas)
          ..where((p) => p.idPraga.equals(idPraga));
        final praga = await pragaQuery.getSingleOrNull();

        if (praga != null && praga.nome.isNotEmpty) {
          final resolvedName = praga.nome;
          _pragaCache[idPraga] = resolvedName;
          _updateCacheTimestamp();
          return resolvedName;
        }
      }

      _pragaCache[idPraga] = defaultValue;
      _updateCacheTimestamp();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver praga: $e');
      return defaultValue;
    }
  }

  /// Resolve múltiplas entidades em batch para otimização
  Future<Map<String, String>> resolveBatchCulturas(List<String> ids) async {
    final results = <String, String>{};

    for (final id in ids) {
      final resolvedName = await resolveCulturaNome(idCultura: id);
      results[id] = resolvedName;
    }

    return results;
  }

  /// Resolve múltiplos defensivos em batch
  Future<Map<String, String>> resolveBatchDefensivos(List<String> ids) async {
    final results = <String, String>{};

    for (final id in ids) {
      final resolvedName = await resolveDefensivoNome(idDefensivo: id);
      results[id] = resolvedName;
    }

    return results;
  }

  /// Resolve múltiplas pragas em batch
  Future<Map<String, String>> resolveBatchPragas(List<String> ids) async {
    final results = <String, String>{};

    for (final id in ids) {
      final resolvedName = await resolvePragaNome(idPraga: id);
      results[id] = resolvedName;
    }

    return results;
  }

  /// Atualiza timestamp do cache
  void _updateCacheTimestamp() {
    _lastCacheUpdate = DateTime.now();
  }

  /// Obtém estatísticas do cache
  CacheStats get cacheStats {
    return CacheStats(
      culturasCached: _culturaCache.length,
      defensivosCached: _defensivoCache.length,
      pragasCached: _pragaCache.length,
      lastUpdate: _lastCacheUpdate,
      isValid: _isCacheValid,
    );
  }

  /// Valida se uma entidade existe nas tabelas estáticas do Drift
  Future<ValidationResult> validateEntity({
    String? idCultura,
    String? idDefensivo,
    String? idPraga,
  }) async {
    final issues = <String>[];

    if (idCultura?.isNotEmpty == true) {
      final culturaQuery = _db.select(_db.culturas)
        ..where((c) => c.idCultura.equals(idCultura!));
      final cultura = await culturaQuery.getSingleOrNull();
      if (cultura == null) {
        issues.add('Cultura com ID $idCultura não encontrada');
      }
    }

    if (idDefensivo?.isNotEmpty == true) {
      final defensivoQuery = _db.select(_db.fitossanitarios)
        ..where((f) => f.idDefensivo.equals(idDefensivo!));
      final defensivo = await defensivoQuery.getSingleOrNull();
      if (defensivo == null) {
        issues.add('Defensivo com ID $idDefensivo não encontrado');
      }
    }

    if (idPraga?.isNotEmpty == true) {
      final pragaQuery = _db.select(_db.pragas)
        ..where((p) => p.idPraga.equals(idPraga!));
      final praga = await pragaQuery.getSingleOrNull();
      if (praga == null) {
        issues.add('Praga com ID $idPraga não encontrada');
      }
    }

    return ValidationResult(isValid: issues.isEmpty, issues: issues);
  }
}

/// Classe para requisições de resolução em batch
class ResolveRequest {
  final String key;
  final String? id;
  final String? nome;
  final String? defaultValue;

  const ResolveRequest({
    required this.key,
    this.id,
    this.nome,
    this.defaultValue,
  });
}

/// Estatísticas do cache
class CacheStats {
  final int culturasCached;
  final int defensivosCached;
  final int pragasCached;
  final DateTime? lastUpdate;
  final bool isValid;

  const CacheStats({
    required this.culturasCached,
    required this.defensivosCached,
    required this.pragasCached,
    required this.lastUpdate,
    required this.isValid,
  });

  int get totalCached => culturasCached + defensivosCached + pragasCached;

  @override
  String toString() {
    return 'CacheStats{total: $totalCached, valid: $isValid, lastUpdate: $lastUpdate}';
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> issues;

  const ValidationResult({required this.isValid, required this.issues});

  @override
  String toString() {
    if (isValid) return 'Validação: ✅ Todas as entidades são válidas';
    return 'Validação: ❌ Issues: ${issues.join(', ')}';
  }
}
