import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../database/providers/database_providers.dart';
import '../../database/repositories/static_data_version_repository.dart';
import 'culturas_data_loader.dart';
import 'diagnosticos_data_loader.dart';
import 'fitossanitarios_data_loader.dart';
import 'plantas_inf_data_loader.dart';
import 'pragas_data_loader.dart';
import 'pragas_inf_data_loader.dart';

/// Versão dos dados estáticos do JSON
/// Incrementar quando os arquivos JSON forem atualizados
/// v1.0.0 - Versão inicial
/// v1.1.0 - Adicionado PragasInf e PlantasInf
const String kStaticDataVersion = '1.1.0';

/// Serviço para gerenciar carregamento de dados estáticos com controle de versão
///
/// Este serviço garante que:
/// 1. Os dados são carregados do JSON para SQLite apenas UMA VEZ
/// 2. Dados são recarregados apenas quando a versão do app ou dos dados muda
/// 3. Todo o resto do app consome dados apenas do SQLite
class StaticDataLoaderService {
  StaticDataLoaderService._();

  static String? _appVersion;
  static bool _initialized = false;

  /// Inicializa o serviço obtendo a versão do app
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      _appVersion = '1.0.0+1'; // Fallback
      debugPrint('⚠️ [STATIC_DATA] Could not get app version: $e');
    }
    
    _initialized = true;
  }

  /// Carrega todos os dados estáticos se necessário
  ///
  /// Verifica a versão persistida no banco e só carrega se:
  /// - Primeira execução
  /// - Versão do app mudou
  /// - Versão dos dados mudou
  static Future<void> loadAllStaticDataIfNeeded(dynamic ref) async {
    await _ensureInitialized();
    
    final versionRepo = ref.read(staticDataVersionRepositoryProvider) 
        as StaticDataVersionRepository;
    
    developer.log(
      '🔍 [STATIC_DATA] Verificando necessidade de carregamento (appVersion: $_appVersion, dataVersion: $kStaticDataVersion)',
      name: 'StaticDataLoaderService',
    );

    // Verificar e carregar cada tipo de dado (primeira fase - tabelas base)
    await Future.wait([
      _loadIfNeeded(
        ref: ref,
        versionRepo: versionRepo,
        tableName: 'culturas',
        loader: () => CulturasDataLoader.loadCulturasData(ref),
        countGetter: () async {
          final repo = ref.read(culturasRepositoryProvider);
          final all = await (repo.findAll() as Future<List<dynamic>>);
          return all.length;
        },
      ),
      _loadIfNeeded(
        ref: ref,
        versionRepo: versionRepo,
        tableName: 'pragas',
        loader: () => PragasDataLoader.loadPragasData(ref),
        countGetter: () async {
          final repo = ref.read(pragasRepositoryProvider);
          final all = await (repo.findAll() as Future<List<dynamic>>);
          return all.length;
        },
      ),
      _loadIfNeeded(
        ref: ref,
        versionRepo: versionRepo,
        tableName: 'fitossanitarios',
        loader: () => FitossanitariosDataLoader.loadFitossanitariosData(ref),
        countGetter: () async {
          final repo = ref.read(fitossanitariosRepositoryProvider);
          final all = await (repo.findAll() as Future<List<dynamic>>);
          return all.length;
        },
      ),
    ]);

    // Segunda fase - tabelas que dependem das tabelas base (pragas, culturas)
    await Future.wait([
      _loadIfNeeded(
        ref: ref,
        versionRepo: versionRepo,
        tableName: 'pragas_inf',
        loader: () => PragasInfDataLoader.loadPragasInfData(ref),
        countGetter: () async {
          final repo = ref.read(pragasInfRepositoryProvider);
          final all = await (repo.findAll() as Future<List<dynamic>>);
          return all.length;
        },
      ),
      _loadIfNeeded(
        ref: ref,
        versionRepo: versionRepo,
        tableName: 'plantas_inf',
        loader: () => PlantasInfDataLoader.loadPlantasInfData(ref),
        countGetter: () async {
          final repo = ref.read(plantasInfRepositoryProvider);
          final all = await (repo.findAll() as Future<List<dynamic>>);
          return all.length;
        },
      ),
    ]);

    // Terceira fase - diagnósticos (dependem de pragas, culturas e fitossanitarios)
    await _loadIfNeeded(
      ref: ref,
      versionRepo: versionRepo,
      tableName: 'diagnosticos',
      loader: () => DiagnosticosDataLoader.loadDiagnosticosData(ref),
      countGetter: () async {
        final repo = ref.read(diagnosticoRepositoryProvider);
        final all = await (repo.getAll() as Future<List<dynamic>>);
        return all.length;
      },
    );

    developer.log(
      '✅ [STATIC_DATA] Verificação de carregamento concluída',
      name: 'StaticDataLoaderService',
    );
  }

  /// Carrega dados de uma tabela se necessário
  static Future<void> _loadIfNeeded({
    required dynamic ref,
    required StaticDataVersionRepository versionRepo,
    required String tableName,
    required Future<void> Function() loader,
    required Future<int> Function() countGetter,
  }) async {
    try {
      final needsLoad = await versionRepo.needsLoading(
        tableName: tableName,
        appVersion: _appVersion!,
        dataVersion: kStaticDataVersion,
      );

      if (needsLoad) {
        developer.log(
          '📥 [STATIC_DATA] Carregando $tableName (nova versão ou primeiro carregamento)',
          name: 'StaticDataLoaderService',
        );

        await loader();

        final count = await countGetter();
        
        await versionRepo.markAsLoaded(
          tableName: tableName,
          appVersion: _appVersion!,
          dataVersion: kStaticDataVersion,
          recordCount: count,
        );

        developer.log(
          '✅ [STATIC_DATA] $tableName carregado: $count registros',
          name: 'StaticDataLoaderService',
        );
      } else {
        final existing = await versionRepo.getVersionInfo(tableName);
        developer.log(
          '⏭️ [STATIC_DATA] $tableName já carregado (${existing?.recordCount ?? 0} registros, versão ${existing?.dataVersion})',
          name: 'StaticDataLoaderService',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ [STATIC_DATA] Erro ao carregar $tableName: $e',
        name: 'StaticDataLoaderService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Força recarregamento de todos os dados (útil para debug/desenvolvimento)
  static Future<void> forceReloadAll(dynamic ref) async {
    await _ensureInitialized();
    
    final versionRepo = ref.read(staticDataVersionRepositoryProvider) 
        as StaticDataVersionRepository;

    developer.log(
      '🔄 [STATIC_DATA] Forçando recarregamento de todos os dados',
      name: 'StaticDataLoaderService',
    );

    // Invalida todos os registros de versão
    await versionRepo.invalidateAll();

    // Reset flags dos loaders individuais
    CulturasDataLoader.forceReload(ref);
    PragasDataLoader.forceReload(ref);
    FitossanitariosDataLoader.forceReload(ref);
    PragasInfDataLoader.forceReload(ref);
    PlantasInfDataLoader.forceReload(ref);
    DiagnosticosDataLoader.forceReload(ref);

    // Recarrega tudo
    await loadAllStaticDataIfNeeded(ref);
  }

  /// Verifica se todos os dados estáticos estão carregados
  static Future<bool> isAllDataLoaded(dynamic ref) async {
    final versionRepo = ref.read(staticDataVersionRepositoryProvider) 
        as StaticDataVersionRepository;

    final tables = ['culturas', 'pragas', 'fitossanitarios', 'pragas_inf', 'plantas_inf', 'diagnosticos'];
    
    for (final table in tables) {
      final isLoaded = await versionRepo.isTableLoaded(table);
      if (!isLoaded) return false;
    }
    
    return true;
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats(dynamic ref) async {
    final versionRepo = ref.read(staticDataVersionRepositoryProvider) 
        as StaticDataVersionRepository;
    
    return await versionRepo.getStats();
  }
}
