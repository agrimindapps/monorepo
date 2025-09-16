import 'package:flutter/foundation.dart';

import '../di/injection_container.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';

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
class DiagnosticoEntityResolver {
  static DiagnosticoEntityResolver? _instance;
  static DiagnosticoEntityResolver get instance => _instance ??= DiagnosticoEntityResolver._internal();
  
  DiagnosticoEntityResolver._internal();

  // Repositórios injetados
  late final CulturaHiveRepository _culturaRepository = sl<CulturaHiveRepository>();
  late final FitossanitarioHiveRepository _defensivoRepository = sl<FitossanitarioHiveRepository>();
  late final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();

  // Cache de resolução com TTL
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

  /// Resolve nome de cultura com múltiplas estratégias
  /// 
  /// Ordem de prioridade:
  /// 1. Cache (se válido)
  /// 2. Busca por idCultura no repositório
  /// 3. Usa nomeCultura fornecido
  /// 4. Retorna valor padrão
  String resolveCulturaNome({
    String? idCultura,
    String? nomeCultura,
    String defaultValue = 'Cultura não especificada',
  }) {
    try {
      // 1. Verifica cache primeiro
      final cacheKey = idCultura ?? nomeCultura ?? '';
      if (_isCacheValid && _culturaCache.containsKey(cacheKey)) {
        return _culturaCache[cacheKey]!;
      }

      // 2. Tenta resolver por ID
      if (idCultura?.isNotEmpty == true) {
        final culturaData = _culturaRepository.getById(idCultura!);
        if (culturaData != null && culturaData.cultura.isNotEmpty) {
          final resolvedName = culturaData.cultura;
          _culturaCache[cacheKey] = resolvedName;
          _updateCacheTimestamp();
          return resolvedName;
        }
      }

      // 3. Usa nome fornecido como fallback
      if (nomeCultura?.isNotEmpty == true) {
        _culturaCache[cacheKey] = nomeCultura!;
        _updateCacheTimestamp();
        return nomeCultura!;
      }

      // 4. Retorna valor padrão
      _culturaCache[cacheKey] = defaultValue;
      _updateCacheTimestamp();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver cultura: $e');
      return defaultValue;
    }
  }

  /// Resolve nome de defensivo com múltiplas estratégias
  String resolveDefensivoNome({
    String? idDefensivo,
    String? nomeDefensivo,
    String defaultValue = 'Defensivo não especificado',
  }) {
    try {
      // 1. Verifica cache primeiro
      final cacheKey = idDefensivo ?? nomeDefensivo ?? '';
      if (_isCacheValid && _defensivoCache.containsKey(cacheKey)) {
        return _defensivoCache[cacheKey]!;
      }

      // 2. Tenta resolver por ID
      if (idDefensivo?.isNotEmpty == true) {
        final defensivoData = _defensivoRepository.getById(idDefensivo!);
        if (defensivoData != null && defensivoData.nomeComum.isNotEmpty) {
          final resolvedName = defensivoData.nomeComum;
          _defensivoCache[cacheKey] = resolvedName;
          _updateCacheTimestamp();
          return resolvedName;
        }
      }

      // 3. Usa nome fornecido como fallback
      if (nomeDefensivo?.isNotEmpty == true) {
        _defensivoCache[cacheKey] = nomeDefensivo!;
        _updateCacheTimestamp();
        return nomeDefensivo!;
      }

      // 4. Retorna valor padrão
      _defensivoCache[cacheKey] = defaultValue;
      _updateCacheTimestamp();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver defensivo: $e');
      return defaultValue;
    }
  }

  /// Resolve nome de praga com múltiplas estratégias
  String resolvePragaNome({
    String? idPraga,
    String? nomePraga,
    String defaultValue = 'Praga não especificada',
  }) {
    try {
      // 1. Verifica cache primeiro
      final cacheKey = idPraga ?? nomePraga ?? '';
      if (_isCacheValid && _pragaCache.containsKey(cacheKey)) {
        return _pragaCache[cacheKey]!;
      }

      // 2. Tenta resolver por ID
      if (idPraga?.isNotEmpty == true) {
        final pragaData = _pragasRepository.getById(idPraga!);
        if (pragaData != null && pragaData.nomeComum.isNotEmpty) {
          final resolvedName = pragaData.nomeComum;
          _pragaCache[cacheKey] = resolvedName;
          _updateCacheTimestamp();
          return resolvedName;
        }
      }

      // 3. Usa nome fornecido como fallback
      if (nomePraga?.isNotEmpty == true) {
        _pragaCache[cacheKey] = nomePraga!;
        _updateCacheTimestamp();
        return nomePraga!;
      }

      // 4. Retorna valor padrão
      _pragaCache[cacheKey] = defaultValue;
      _updateCacheTimestamp();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver praga: $e');
      return defaultValue;
    }
  }

  /// Resolve múltiplas entidades em batch para otimização
  Map<String, String> resolveBatchCulturas(List<ResolveRequest> requests) {
    final results = <String, String>{};
    
    for (final request in requests) {
      final key = request.key;
      final resolvedName = resolveCulturaNome(
        idCultura: request.id,
        nomeCultura: request.nome,
        defaultValue: request.defaultValue ?? 'Cultura não especificada',
      );
      results[key] = resolvedName;
    }
    
    return results;
  }

  /// Resolve múltiplos defensivos em batch
  Map<String, String> resolveBatchDefensivos(List<ResolveRequest> requests) {
    final results = <String, String>{};
    
    for (final request in requests) {
      final key = request.key;
      final resolvedName = resolveDefensivoNome(
        idDefensivo: request.id,
        nomeDefensivo: request.nome,
        defaultValue: request.defaultValue ?? 'Defensivo não especificado',
      );
      results[key] = resolvedName;
    }
    
    return results;
  }

  /// Resolve múltiplas pragas em batch
  Map<String, String> resolveBatchPragas(List<ResolveRequest> requests) {
    final results = <String, String>{};
    
    for (final request in requests) {
      final key = request.key;
      final resolvedName = resolvePragaNome(
        idPraga: request.id,
        nomePraga: request.nome,
        defaultValue: request.defaultValue ?? 'Praga não especificada',
      );
      results[key] = resolvedName;
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

  /// Valida se uma entidade existe nos repositórios
  ValidationResult validateEntity({
    String? idCultura,
    String? idDefensivo, 
    String? idPraga,
  }) {
    final issues = <String>[];
    
    if (idCultura?.isNotEmpty == true) {
      final cultura = _culturaRepository.getById(idCultura!);
      if (cultura == null) {
        issues.add('Cultura com ID $idCultura não encontrada');
      }
    }
    
    if (idDefensivo?.isNotEmpty == true) {
      final defensivo = _defensivoRepository.getById(idDefensivo!);
      if (defensivo == null) {
        issues.add('Defensivo com ID $idDefensivo não encontrado');
      }
    }
    
    if (idPraga?.isNotEmpty == true) {
      final praga = _pragasRepository.getById(idPraga!);
      if (praga == null) {
        issues.add('Praga com ID $idPraga não encontrada');
      }
    }
    
    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
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

  const ValidationResult({
    required this.isValid,
    required this.issues,
  });

  @override
  String toString() {
    if (isValid) return 'Validação: ✅ Todas as entidades são válidas';
    return 'Validação: ❌ Issues: ${issues.join(', ')}';
  }
}