import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../data/repositories/cultura_hive_repository.dart';
import '../data/repositories/diagnostico_hive_repository.dart';
import '../data/repositories/fitossanitario_hive_repository.dart';
import '../data/repositories/fitossanitario_info_hive_repository.dart';
import '../data/repositories/plantas_inf_hive_repository.dart';
import '../data/repositories/pragas_hive_repository.dart';
import '../data/repositories/pragas_inf_hive_repository.dart';

/// Serviço responsável por inicializar e gerenciar dados da aplicação
/// Orquestra o carregamento de JSONs e populacião das Hive boxes
class DataInitializationService {
  final AssetLoaderService _assetLoader;
  final VersionManagerService _versionManager;
  final CulturaHiveRepository _culturaRepository;
  final PragasHiveRepository _pragasRepository;
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final DiagnosticoHiveRepository _diagnosticoRepository;
  final FitossanitarioInfoHiveRepository _fitossanitarioInfoRepository;
  final PlantasInfHiveRepository _plantasInfRepository;
  final PragasInfHiveRepository _pragasInfRepository;

  DataInitializationService({
    required AssetLoaderService assetLoader,
    required VersionManagerService versionManager,
    required CulturaHiveRepository culturaRepository,
    required PragasHiveRepository pragasRepository,
    required FitossanitarioHiveRepository fitossanitarioRepository,
    required DiagnosticoHiveRepository diagnosticoRepository,
    required FitossanitarioInfoHiveRepository fitossanitarioInfoRepository,
    required PlantasInfHiveRepository plantasInfRepository,
    required PragasInfHiveRepository pragasInfRepository,
  })  : _assetLoader = assetLoader,
        _versionManager = versionManager,
        _culturaRepository = culturaRepository,
        _pragasRepository = pragasRepository,
        _fitossanitarioRepository = fitossanitarioRepository,
        _diagnosticoRepository = diagnosticoRepository,
        _fitossanitarioInfoRepository = fitossanitarioInfoRepository,
        _plantasInfRepository = plantasInfRepository,
        _pragasInfRepository = pragasInfRepository;

  /// Inicializa todos os dados da aplicação se necessário
  Future<Either<Exception, void>> initializeData() async {
    try {
      developer.log('Iniciando carregamento de dados...', name: 'DataInitializationService');
      
      final currentVersion = await _versionManager.getCurrentVersionAsync();
      developer.log('Versão atual da aplicação: $currentVersion', name: 'DataInitializationService');
      final categories = [
        _CategoryData('tbculturas', _culturaRepository),
        _CategoryData('tbpragas', _pragasRepository),
        _CategoryData('tbfitossanitarios', _fitossanitarioRepository),
        _CategoryData('tbdiagnostico', _diagnosticoRepository),
        _CategoryData('tbfitossanitariosinfo', _fitossanitarioInfoRepository),
        _CategoryData('tbplantasinf', _plantasInfRepository),
        _CategoryData('tbpragasinf', _pragasInfRepository),
      ];
      for (final category in categories) {
        final result = await _loadCategoryData(category, currentVersion);
        if (result.isLeft()) {
          return result;
        }
      }
      
      developer.log('Carregamento de dados concluído com sucesso', name: 'DataInitializationService');
      return const Right(null);
      
    } catch (e) {
      developer.log('Erro durante inicialização de dados: $e', name: 'DataInitializationService');
      return Left(Exception('Falha na inicialização: ${e.toString()}'));
    }
  }

  /// Carrega dados de uma categoria específica
  Future<Either<Exception, void>> _loadCategoryData(_CategoryData category, String currentVersion) async {
    try {
      developer.log('🔍 Verificando necessidade de atualização para ${category.name}...', name: 'DataInitializationService');
      final storedVersion = await _versionManager.getStoredVersion(category.name);
      developer.log('📱 VERSION CHECK ${category.name}: Stored="$storedVersion", Current="$currentVersion"', name: 'DataInitializationService');
      final needsReload = await _versionManager.needsDataReload(category.name);
      developer.log('🔄 NEEDS RELOAD ${category.name}: $needsReload', name: 'DataInitializationService');
      
      if (!needsReload) {
        developer.log('✅ Dados de ${category.name} já estão atualizados (SKIP)', name: 'DataInitializationService');
        return const Right(null);
      }
      
      developer.log('📥 Carregando dados de ${category.name}...', name: 'DataInitializationService');
      final jsonResult = await _assetLoader.loadCategoryData(category.name);
      if (jsonResult.isLeft()) {
        return Left(Exception('Erro ao carregar JSON de ${category.name}: ${jsonResult.fold((e) => e.toString(), (r) => '')}'));
      }
      
      final jsonData = jsonResult.fold((l) => <Map<String, dynamic>>[], (r) => r);
      developer.log('📊 Carregados ${jsonData.length} registros de ${category.name}', name: 'DataInitializationService');
      developer.log('💾 Salvando ${jsonData.length} registros no Hive para ${category.name}...', name: 'DataInitializationService');
      final dynamic saveResult = await category.repository.loadFromJson(jsonData, currentVersion);
      if (saveResult is Either && saveResult.isLeft()) {
        return Left(Exception('Erro ao salvar dados de ${category.name}: ${saveResult.fold((e) => e.toString(), (r) => '')}'));
      }
      developer.log('🔖 Marcando ${category.name} como atualizado para versão $currentVersion', name: 'DataInitializationService');
      await _versionManager.markAsUpdated(currentVersion, category.name);
      
      developer.log('✅ Dados de ${category.name} carregados com sucesso', name: 'DataInitializationService');
      return const Right(null);
      
    } catch (e) {
      developer.log('Erro ao carregar categoria ${category.name}: $e', name: 'DataInitializationService');
      return Left(Exception('Erro na categoria ${category.name}: ${e.toString()}'));
    }
  }

  /// Força recarregamento de todos os dados (útil para desenvolvimento)
  Future<Either<Exception, void>> forceReloadAllData() async {
    try {
      developer.log('Forçando recarregamento de todos os dados...', name: 'DataInitializationService');
      
      await _versionManager.forceDataUpdate();
      return await initializeData();
      
    } catch (e) {
      developer.log('Erro durante recarregamento forçado: $e', name: 'DataInitializationService');
      return Left(Exception('Falha no recarregamento: ${e.toString()}'));
    }
  }

  /// Obtém estatísticas de carregamento para debug
  Future<Map<String, dynamic>> getLoadingStats() async {
    try {
      final versionStats = await _versionManager.getVersionStats();
      
      return {
        'version_info': versionStats,
        'repositories': {
          'culturas': await _culturaRepository.countAsync(),
          'pragas': await _pragasRepository.countAsync(),
          'fitossanitarios': await _fitossanitarioRepository.countAsync(),
          'diagnosticos': await _diagnosticoRepository.countAsync(),
          'fitossanitarios_info': await _fitossanitarioInfoRepository.countAsync(),
          'plantas_inf': await _plantasInfRepository.countAsync(),
          'pragas_inf': await _pragasInfRepository.countAsync(),
        },
        'last_update': await _versionManager.getLastDataVersion(),
      };
    } catch (e) {
      developer.log('Erro ao obter estatísticas: $e', name: 'DataInitializationService');
      return {'error': e.toString()};
    }
  }

  /// Verifica se todos os dados estão carregados
  Future<bool> isDataLoaded() async {
    try {
      final counts = await Future.wait([
        _culturaRepository.countAsync(),
        _pragasRepository.countAsync(),
        _fitossanitarioRepository.countAsync(),
        _diagnosticoRepository.countAsync(),
        _fitossanitarioInfoRepository.countAsync(),
        _plantasInfRepository.countAsync(),
        _pragasInfRepository.countAsync(),
      ]);
      return counts.any((itemCount) => itemCount > 0);
    } catch (e) {
      developer.log('Erro ao verificar se dados estão carregados: $e', name: 'DataInitializationService');
      return false;
    }
  }
}

/// Classe auxiliar para agrupar dados de categoria
class _CategoryData {
  final String name;
  final dynamic repository;
  
  _CategoryData(this.name, this.repository);
}
