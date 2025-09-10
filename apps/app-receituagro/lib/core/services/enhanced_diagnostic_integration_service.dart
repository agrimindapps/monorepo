import 'package:flutter/foundation.dart';

import '../../features/diagnosticos/data/mappers/diagnostico_mapper.dart';
import '../../features/diagnosticos/domain/entities/diagnostico_entity.dart';
import '../models/cultura_hive.dart';
import '../models/diagnostico_hive.dart';
import '../models/fitossanitario_hive.dart';
import '../models/pragas_hive.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';

/// Enhanced service para integração e enriquecimento de dados de diagnósticos
/// 
/// Responsável por:
/// - Resolver nomes de pragas, culturas e defensivos usando as FKs
/// - Enriquecer dados do DiagnosticoHive com informações relacionais
/// - Melhorar a qualidade de dados exibidos nas telas
/// - Manter cache inteligente para performance
class EnhancedDiagnosticIntegrationService {
  final DiagnosticoHiveRepository _diagnosticoRepo;
  final FitossanitarioHiveRepository _fitossanitarioRepo;
  final CulturaHiveRepository _culturaRepo;
  final PragasHiveRepository _pragasRepo;

  // Cache inteligente com TTL
  final Map<String, _CachedData<FitossanitarioHive>> _defensivoCache = {};
  final Map<String, _CachedData<CulturaHive>> _culturaCache = {};
  final Map<String, _CachedData<PragasHive>> _pragaCache = {};
  
  static const Duration _cacheExpiry = Duration(minutes: 10);

  EnhancedDiagnosticIntegrationService({
    required DiagnosticoHiveRepository diagnosticoRepo,
    required FitossanitarioHiveRepository fitossanitarioRepo,
    required CulturaHiveRepository culturaRepo,
    required PragasHiveRepository pragasRepo,
  })  : _diagnosticoRepo = diagnosticoRepo,
        _fitossanitarioRepo = fitossanitarioRepo,
        _culturaRepo = culturaRepo,
        _pragasRepo = pragasRepo;

  /// Enriquece um diagnóstico com nomes resolvidos das FK
  Future<DiagnosticoEntity> enrichDiagnostic(DiagnosticoHive diagnostic) async {
    try {
      // DEBUG: Log dos dados do diagnóstico
      debugPrint('🔬 === DEBUG DIAGNÓSTICO HIVE ===');
      debugPrint('📋 ID: ${diagnostic.objectId}');
      debugPrint('🔧 FKs do diagnóstico:');
      debugPrint('  • fkIdDefensivo: "${diagnostic.fkIdDefensivo}"');
      debugPrint('  • fkIdCultura: "${diagnostic.fkIdCultura}"');
      debugPrint('  • fkIdPraga: "${diagnostic.fkIdPraga}"');
      debugPrint('🏷️ Nomes atuais:');
      debugPrint('  • nomeDefensivo: "${diagnostic.nomeDefensivo}"');
      debugPrint('  • nomeCultura: "${diagnostic.nomeCultura}"');
      debugPrint('  • nomePraga: "${diagnostic.nomePraga}"');

      // Primeiro converte usando o mapper padrão
      var entity = DiagnosticoMapper.fromHive(diagnostic);
      
      // Depois enriquece com nomes resolvidos se necessário
      final defensivo = await _getDefensivoByIdCached(diagnostic.fkIdDefensivo);
      final cultura = await _getCulturaByIdCached(diagnostic.fkIdCultura);  
      final praga = await _getPragaByIdCached(diagnostic.fkIdPraga);

      // DEBUG: Log dos dados encontrados
      debugPrint('🔍 Dados encontrados:');
      debugPrint('  • defensivo: ${defensivo?.nomeComum ?? "NÃO ENCONTRADO"}');
      debugPrint('  • cultura: ${cultura?.cultura ?? "NÃO ENCONTRADA"}');
      debugPrint('  • praga: ${praga?.nomeComum ?? "NÃO ENCONTRADA"}');

      // RESOLUÇÃO INTELIGENTE DE NOMES
      String? nomeDefensivo = diagnostic.nomeDefensivo?.isNotEmpty == true 
          ? diagnostic.nomeDefensivo
          : defensivo?.nomeComum ?? 'Defensivo não identificado';
          
      String? nomeCultura = diagnostic.nomeCultura?.isNotEmpty == true 
          ? diagnostic.nomeCultura 
          : cultura?.cultura ?? 'Cultura não identificada';
          
      // ESPECIAL PARA PRAGAS: Handle nomes múltiplos como "Mela; Requeima"
      String? nomePraga;
      if (diagnostic.nomePraga?.isNotEmpty == true) {
        if (diagnostic.nomePraga!.contains(';') || diagnostic.nomePraga!.contains(',')) {
          // Mantém nomes múltiplos como estão
          nomePraga = diagnostic.nomePraga;
        } else {
          nomePraga = diagnostic.nomePraga;
        }
      } else if (praga != null) {
        nomePraga = praga.nomeComum;
      } else {
        nomePraga = 'Praga não identificada';
      }

      // Cria nova entidade com nomes resolvidos
      entity = entity.copyWith(
        nomeDefensivo: nomeDefensivo,
        nomeCultura: nomeCultura,
        nomePraga: nomePraga,
      );

      
      return entity;
    } catch (e) {
      // Fallback para mapper padrão em caso de erro
      return DiagnosticoMapper.fromHive(diagnostic);
    }
  }

  /// Enriquece lista de diagnósticos em lote (mais eficiente)
  Future<List<DiagnosticoEntity>> enrichDiagnosticsBatch(List<DiagnosticoHive> diagnostics) async {
    if (diagnostics.isEmpty) return [];
    
    try {
      
      // Pre-load todos os dados necessários em paralelo
      final uniqueDefensivoIds = diagnostics.map((d) => d.fkIdDefensivo).toSet();
      final uniqueCulturaIds = diagnostics.map((d) => d.fkIdCultura).toSet();  
      final uniquePragaIds = diagnostics.map((d) => d.fkIdPraga).toSet();

      await Future.wait([
        _preloadDefensivos(uniqueDefensivoIds),
        _preloadCulturas(uniqueCulturaIds),
        _preloadPragas(uniquePragaIds),
      ]);

      // Processa todos os diagnósticos
      final List<DiagnosticoEntity> enrichedList = [];
      
      for (final diagnostic in diagnostics) {
        final enriched = await enrichDiagnostic(diagnostic);
        enrichedList.add(enriched);
      }
      
      return enrichedList;
      
    } catch (e) {
      // Fallback para conversão simples
      return diagnostics.map(DiagnosticoMapper.fromHive).toList();
    }
  }

  /// Busca diagnósticos por defensivo com enriquecimento automático
  Future<List<DiagnosticoEntity>> getDiagnosticosByDefensivoEnriched(String defensivoId) async {
    try {
      
      // Busca diagnósticos pelo ID do defensivo (tanto fkId quanto nome)
      List<DiagnosticoHive> diagnostics = [];
      
      // Primeiro tenta buscar por fkIdDefensivo 
      diagnostics = _diagnosticoRepo.findByDefensivo(defensivoId);
      
      // Se não encontrou, tenta buscar por nome do defensivo
      if (diagnostics.isEmpty) {
        final defensivo = _fitossanitarioRepo.getById(defensivoId);
        if (defensivo != null) {
          final nomeDefensivo = defensivo.nomeComum;
          diagnostics = _diagnosticoRepo.getAll().where((d) => 
              d.nomeDefensivo?.toLowerCase().contains(nomeDefensivo.toLowerCase()) == true
          ).toList();
        }
      }
      
      
      return await enrichDiagnosticsBatch(diagnostics);
    } catch (e) {
      return [];
    }
  }

  /// Cache methods com TTL

  Future<FitossanitarioHive?> _getDefensivoByIdCached(String id) async {
    if (id.isEmpty) return null;
    
    final cached = _defensivoCache[id];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    try {
      // Primeiro tenta buscar por ID direto
      var defensivo = _fitossanitarioRepo.getById(id);
      
      // Se não encontrou, tenta buscar por idReg
      if (defensivo == null) {
        final allDefensivos = _fitossanitarioRepo.getAll();
        final results = allDefensivos.where((d) => d.idReg == id);
        defensivo = results.isNotEmpty ? results.first : null;
      }
      
      
      _defensivoCache[id] = _CachedData(defensivo, DateTime.now());
      return defensivo;
    } catch (e) {
      return null;
    }
  }

  Future<CulturaHive?> _getCulturaByIdCached(String id) async {
    if (id.isEmpty) return null;
    
    final cached = _culturaCache[id];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    try {
      // Primeiro tenta buscar por ID direto
      var cultura = _culturaRepo.getById(id);
      
      // Se não encontrou, tenta buscar por idReg
      if (cultura == null) {
        final allCulturas = _culturaRepo.getAll();
        final results = allCulturas.where((c) => c.idReg == id);
        cultura = results.isNotEmpty ? results.first : null;
      }
      
      
      _culturaCache[id] = _CachedData(cultura, DateTime.now());
      return cultura;
    } catch (e) {
      return null;
    }
  }

  Future<PragasHive?> _getPragaByIdCached(String id) async {
    if (id.isEmpty) return null;
    
    final cached = _pragaCache[id];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    try {
      // Primeiro tenta buscar por ID direto
      var praga = _pragasRepo.getById(id);
      
      // Se não encontrou, tenta buscar por idReg
      if (praga == null) {
        final allPragas = _pragasRepo.getAll();
        final results = allPragas.where((p) => p.idReg == id);
        praga = results.isNotEmpty ? results.first : null;
      }
      
      
      _pragaCache[id] = _CachedData(praga, DateTime.now());
      return praga;
    } catch (e) {
      return null;
    }
  }

  /// Pre-loading methods para batch processing

  Future<void> _preloadDefensivos(Set<String> ids) async {
    final toLoad = ids.where((id) => id.isNotEmpty && 
        (!_defensivoCache.containsKey(id) || _defensivoCache[id]!.isExpired)).toList();
    
    if (toLoad.isEmpty) return;
    
    for (final id in toLoad) {
      await _getDefensivoByIdCached(id);
    }
  }

  Future<void> _preloadCulturas(Set<String> ids) async {
    final toLoad = ids.where((id) => id.isNotEmpty && 
        (!_culturaCache.containsKey(id) || _culturaCache[id]!.isExpired)).toList();
    
    if (toLoad.isEmpty) return;
    
    for (final id in toLoad) {
      await _getCulturaByIdCached(id);
    }
  }

  Future<void> _preloadPragas(Set<String> ids) async {
    final toLoad = ids.where((id) => id.isNotEmpty && 
        (!_pragaCache.containsKey(id) || _pragaCache[id]!.isExpired)).toList();
    
    if (toLoad.isEmpty) return;
    
    for (final id in toLoad) {
      await _getPragaByIdCached(id);
    }
  }

  /// Diagnostics methods

  /// Obtém estatísticas de qualidade dos dados
  Future<DiagnosticDataQuality> getDiagnosticDataQuality() async {
    final diagnostics = _diagnosticoRepo.getAll();
    
    int total = diagnostics.length;
    int withDefensivoName = 0;
    int withCulturaName = 0;
    int withPragaName = 0;
    int complete = 0;
    
    for (final diagnostic in diagnostics) {
      if (diagnostic.nomeDefensivo?.isNotEmpty == true) withDefensivoName++;
      if (diagnostic.nomeCultura?.isNotEmpty == true) withCulturaName++;
      if (diagnostic.nomePraga?.isNotEmpty == true) withPragaName++;
      
      if (diagnostic.nomeDefensivo?.isNotEmpty == true &&
          diagnostic.nomeCultura?.isNotEmpty == true &&
          diagnostic.nomePraga?.isNotEmpty == true) {
        complete++;
      }
    }
    
    return DiagnosticDataQuality(
      total: total,
      withDefensivoName: withDefensivoName,
      withCulturaName: withCulturaName,
      withPragaName: withPragaName,
      complete: complete,
    );
  }

  /// Cache management

  void clearCache() {
    _defensivoCache.clear();
    _culturaCache.clear();
    _pragaCache.clear();
  }

  Map<String, dynamic> getCacheStats() {
    return {
      'defensivos': _defensivoCache.length,
      'culturas': _culturaCache.length,
      'pragas': _pragaCache.length,
      'cacheExpiry': '${_cacheExpiry.inMinutes} minutes',
    };
  }

}

/// Helper class para cache com TTL
class _CachedData<T> {
  final T? data;
  final DateTime timestamp;
  
  _CachedData(this.data, this.timestamp);
  
  bool get isExpired => DateTime.now().difference(timestamp) > EnhancedDiagnosticIntegrationService._cacheExpiry;
}

/// Value object para qualidade dos dados de diagnósticos
class DiagnosticDataQuality {
  final int total;
  final int withDefensivoName;
  final int withCulturaName;
  final int withPragaName;
  final int complete;
  
  const DiagnosticDataQuality({
    required this.total,
    required this.withDefensivoName,
    required this.withCulturaName,
    required this.withPragaName,
    required this.complete,
  });
  
  double get defensivoNamePercentage => total > 0 ? (withDefensivoName / total) * 100 : 0;
  double get culturaNamePercentage => total > 0 ? (withCulturaName / total) * 100 : 0;
  double get pragaNamePercentage => total > 0 ? (withPragaName / total) * 100 : 0;
  double get completePercentage => total > 0 ? (complete / total) * 100 : 0;
  
  @override
  String toString() {
    return 'DiagnosticDataQuality{total: $total, complete: ${completePercentage.toStringAsFixed(1)}%, '
           'defensivo: ${defensivoNamePercentage.toStringAsFixed(1)}%, '
           'cultura: ${culturaNamePercentage.toStringAsFixed(1)}%, '
           'praga: ${pragaNamePercentage.toStringAsFixed(1)}%}';
  }
}