import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../repositories/cultura_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../repositories/plantas_inf_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../repositories/pragas_inf_hive_repository.dart';
import 'asset_loader_service.dart';
import 'data_cleaning_service.dart';
import 'version_manager_service.dart';

/// Modelo para callback de progresso
class ImportProgress {
  final String currentCategory;
  final int currentIndex;
  final int totalCategories;
  final String status;
  final int? itemsProcessed;

  ImportProgress({
    required this.currentCategory,
    required this.currentIndex,
    required this.totalCategories,
    required this.status,
    this.itemsProcessed,
  });

  double get progressPercentage => (currentIndex / totalCategories) * 100;
}

/// Resultado da importação automática
class AutoImportResult {
  final bool success;
  final String message;
  final Map<String, int> importedCounts;
  final Duration totalTime;
  final List<String> errors;

  AutoImportResult({
    required this.success,
    required this.message,
    required this.importedCounts,
    required this.totalTime,
    required this.errors,
  });
}

/// Serviço responsável pela reimportação automática de dados JSON
/// Executa limpeza completa seguida de importação de todos os JSONs
class AutoDataImportService {
  final AssetLoaderService _assetLoader;
  final DataCleaningService _cleaningService;
  final VersionManagerService _versionManager;

  // Repositórios
  final CulturaHiveRepository _culturaRepository;
  final PragasHiveRepository _pragasRepository;
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final DiagnosticoHiveRepository _diagnosticoRepository;
  final FitossanitarioInfoHiveRepository _fitossanitarioInfoRepository;
  final PlantasInfHiveRepository _plantasInfRepository;
  final PragasInfHiveRepository _pragasInfRepository;

  /// Lista ordenada de categorias para importação
  static const List<_CategoryInfo> _categories = [
    _CategoryInfo('tbculturas', 'Culturas'),
    _CategoryInfo('tbpragas', 'Pragas'),
    _CategoryInfo('tbplantasinf', 'Plantas Inf'),
    _CategoryInfo('tbfitossanitarios', 'Fitossanitários'),
    _CategoryInfo('tbfitossanitariosinfo', 'Fitossanitários Info'),
    _CategoryInfo('tbdiagnostico', 'Diagnósticos'),
    _CategoryInfo('tbpragasinf', 'Pragas Inf'),
  ];

  AutoDataImportService({
    required AssetLoaderService assetLoader,
    required DataCleaningService cleaningService,
    required VersionManagerService versionManager,
    required CulturaHiveRepository culturaRepository,
    required PragasHiveRepository pragasRepository,
    required FitossanitarioHiveRepository fitossanitarioRepository,
    required DiagnosticoHiveRepository diagnosticoRepository,
    required FitossanitarioInfoHiveRepository fitossanitarioInfoRepository,
    required PlantasInfHiveRepository plantasInfRepository,
    required PragasInfHiveRepository pragasInfRepository,
  })  : _assetLoader = assetLoader,
        _cleaningService = cleaningService,
        _versionManager = versionManager,
        _culturaRepository = culturaRepository,
        _pragasRepository = pragasRepository,
        _fitossanitarioRepository = fitossanitarioRepository,
        _diagnosticoRepository = diagnosticoRepository,
        _fitossanitarioInfoRepository = fitossanitarioInfoRepository,
        _plantasInfRepository = plantasInfRepository,
        _pragasInfRepository = pragasInfRepository;

  /// Executa reimportação automática completa
  /// Limpa dados antigos e importa todos os JSONs atualizados
  Future<Either<Exception, AutoImportResult>> executeAutoImport({
    required String newVersion,
    void Function(ImportProgress)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    final importedCounts = <String, int>{};
    final errors = <String>[];

    try {
      developer.log(
          'Iniciando reimportação automática para versão $newVersion...',
          name: 'AutoDataImportService');

      // Callback inicial
      onProgress?.call(ImportProgress(
        currentCategory: 'Iniciando',
        currentIndex: 0,
        totalCategories: _categories.length + 1,
        status: 'Preparando importação...',
      ));

      // 1. Obter estatísticas antes da limpeza (para logs)
      final statsBefore = await _cleaningService.getDataStatistics();
      developer.log('Estatísticas antes da limpeza: $statsBefore',
          name: 'AutoDataImportService');

      // 2. Limpeza completa das boxes
      onProgress?.call(ImportProgress(
        currentCategory: 'Limpeza',
        currentIndex: 0,
        totalCategories: _categories.length + 1,
        status: 'Limpando dados antigos...',
      ));

      final cleanResult = await _cleaningService.clearAllDataBoxes();
      if (cleanResult.isLeft()) {
        final error = cleanResult.fold((e) => e.toString(), (r) => '');
        errors.add('Erro na limpeza: $error');

        return Right(AutoImportResult(
          success: false,
          message: 'Falha na limpeza dos dados: $error',
          importedCounts: importedCounts,
          totalTime: stopwatch.elapsed,
          errors: errors,
        ));
      }

      developer.log('Limpeza concluída com sucesso',
          name: 'AutoDataImportService');

      // 3. Importação de cada categoria
      for (int i = 0; i < _categories.length; i++) {
        final category = _categories[i];

        onProgress?.call(ImportProgress(
          currentCategory: category.displayName,
          currentIndex: i + 1,
          totalCategories: _categories.length + 1,
          status: 'Carregando ${category.displayName}...',
        ));

        try {
          final result = await _importSingleCategory(
            category.key,
            newVersion,
            onProgress: (itemsProcessed) {
              onProgress?.call(ImportProgress(
                currentCategory: category.displayName,
                currentIndex: i + 1,
                totalCategories: _categories.length + 1,
                status: 'Processando ${category.displayName}...',
                itemsProcessed: itemsProcessed,
              ));
            },
          );

          result.fold(
            (error) => errors.add('${category.key}: ${error.toString()}'),
            (count) => importedCounts[category.key] = count,
          );
        } catch (e) {
          errors.add('${category.key}: $e');
          developer.log('Erro ao importar categoria ${category.key}: $e',
              name: 'AutoDataImportService');
        }
      }

      stopwatch.stop();

      // 4. Resultado final
      final totalImported =
          importedCounts.values.fold(0, (sum, count) => sum + count);
      final hasErrors = errors.isNotEmpty;

      final message = hasErrors
          ? 'Importação concluída com erros. Total: $totalImported registros'
          : 'Importação concluída com sucesso. Total: $totalImported registros';

      developer.log('$message. Tempo total: ${stopwatch.elapsed}',
          name: 'AutoDataImportService');

      return Right(AutoImportResult(
        success: !hasErrors,
        message: message,
        importedCounts: importedCounts,
        totalTime: stopwatch.elapsed,
        errors: errors,
      ));
    } catch (e) {
      stopwatch.stop();
      developer.log('Erro crítico durante reimportação automática: $e',
          name: 'AutoDataImportService');

      return Left(Exception('Falha crítica na reimportação: ${e.toString()}'));
    }
  }

  /// Importa dados de uma categoria específica
  Future<Either<Exception, int>> _importSingleCategory(
    String category,
    String version, {
    void Function(int)? onProgress,
  }) async {
    try {
      developer.log('Importando categoria: $category',
          name: 'AutoDataImportService');

      // 1. Carrega dados do JSON
      final jsonResult = await _assetLoader.loadCategoryData(category);
      if (jsonResult.isLeft()) {
        return Left(Exception(
            'Erro ao carregar JSON: ${jsonResult.fold((e) => e.toString(), (r) => '')}'));
      }

      final jsonData =
          jsonResult.fold((l) => <Map<String, dynamic>>[], (r) => r);
      developer.log('Carregados ${jsonData.length} registros de $category',
          name: 'AutoDataImportService');

      onProgress?.call(jsonData.length);

      // 2. Obtém repositório correspondente
      final repository = _getRepositoryForCategory(category);
      if (repository == null) {
        return Left(
            Exception('Repositório não encontrado para categoria: $category'));
      }

      // 3. Salva no repositório
      final dynamic saveResult =
          await repository.loadFromJson(jsonData, version);
      if (saveResult is Either && saveResult.isLeft()) {
        final error =
            saveResult.fold((e) => e.toString(), (r) => 'Erro desconhecido');
        return Left(Exception('Erro ao salvar: $error'));
      }

      // 4. Marca como atualizado
      await _versionManager.markAsUpdated(version, category);

      developer.log(
          'Categoria $category importada com sucesso (${jsonData.length} registros)',
          name: 'AutoDataImportService');

      return Right(jsonData.length);
    } catch (e) {
      developer.log('Erro ao importar categoria $category: $e',
          name: 'AutoDataImportService');
      return Left(Exception('Erro na categoria $category: ${e.toString()}'));
    }
  }

  /// Obtém repositório correspondente à categoria
  dynamic _getRepositoryForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tbculturas':
        return _culturaRepository;
      case 'tbpragas':
        return _pragasRepository;
      case 'tbfitossanitarios':
        return _fitossanitarioRepository;
      case 'tbdiagnostico':
        return _diagnosticoRepository;
      case 'tbfitossanitariosinfo':
        return _fitossanitarioInfoRepository;
      case 'tbplantasinf':
        return _plantasInfRepository;
      case 'tbpragasinf':
        return _pragasInfRepository;
      default:
        return null;
    }
  }

  /// Verifica se reimportação é necessária
  Future<bool> isReimportNeeded(String currentVersion) async {
    try {
      // Verifica se pelo menos uma categoria precisa de atualização
      for (final category in _categories) {
        final needsReload = await _versionManager.needsDataReload(category.key);
        if (needsReload) {
          developer.log('Categoria ${category.key} precisa de atualização',
              name: 'AutoDataImportService');
          return true;
        }
      }

      return false;
    } catch (e) {
      developer.log('Erro ao verificar necessidade de reimportação: $e',
          name: 'AutoDataImportService');
      return true; // Em caso de erro, prefere reimportar
    }
  }

  /// Obtém estatísticas do último import
  Future<Map<String, dynamic>> getImportStatistics() async {
    try {
      final stats = <String, dynamic>{};

      // Adiciona contagem de cada repositório
      stats['culturas'] = await _culturaRepository.countAsync();
      stats['pragas'] = await _pragasRepository.countAsync();
      stats['fitossanitarios'] = await _fitossanitarioRepository.countAsync();
      stats['diagnosticos'] = await _diagnosticoRepository.countAsync();
      stats['fitossanitarios_info'] =
          await _fitossanitarioInfoRepository.countAsync();
      stats['plantas_inf'] = await _plantasInfRepository.countAsync();
      stats['pragas_inf'] = await _pragasInfRepository.countAsync();

      // Calcula total
      final total = stats.values.fold(0, (sum, count) => sum + (count as int));
      stats['total'] = total;

      // Adiciona informações de versão
      stats['last_version'] = await _versionManager.getLastDataVersion();
      stats['version_stats'] = await _versionManager.getVersionStats();

      return stats;
    } catch (e) {
      developer.log('Erro ao obter estatísticas de importação: $e',
          name: 'AutoDataImportService');
      return {'error': e.toString()};
    }
  }

  /// Executa importação de categoria específica (para testes ou correções)
  Future<Either<Exception, int>> importSpecificCategory(
    String category,
    String version,
  ) async {
    try {
      developer.log('Importação específica da categoria: $category',
          name: 'AutoDataImportService');

      // Limpa apenas esta categoria
      final cleanResult = await _cleaningService.clearCategoryData(category);
      if (cleanResult.isLeft()) {
        return Left(Exception(
            'Erro na limpeza: ${cleanResult.fold((e) => e.toString(), (r) => '')}'));
      }

      // Importa categoria
      return await _importSingleCategory(category, version);
    } catch (e) {
      developer.log('Erro na importação específica de $category: $e',
          name: 'AutoDataImportService');
      return Left(Exception('Erro na importação específica: ${e.toString()}'));
    }
  }
}

/// Classe auxiliar para informações de categoria
class _CategoryInfo {
  final String key;
  final String displayName;

  const _CategoryInfo(this.key, this.displayName);
}
