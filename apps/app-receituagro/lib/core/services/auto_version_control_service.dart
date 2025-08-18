import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'version_manager_service.dart';
import 'data_cleaning_service.dart';
import 'auto_data_import_service.dart';
import 'asset_loader_service.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../repositories/plantas_inf_hive_repository.dart';
import '../repositories/pragas_inf_hive_repository.dart';

/// Resultado da execução do controle automático de versão
class VersionControlResult {
  final bool success;
  final String message;
  final VersionControlAction actionTaken;
  final Map<String, dynamic> details;
  final Duration executionTime;

  VersionControlResult({
    required this.success,
    required this.message,
    required this.actionTaken,
    required this.details,
    required this.executionTime,
  });

  @override
  String toString() {
    return 'VersionControlResult(success: $success, action: $actionTaken, message: $message)';
  }
}

/// Ações que podem ser tomadas pelo controle de versão
enum VersionControlAction {
  noActionNeeded,      // Dados já estão atualizados
  dataImported,        // Dados foram importados pela primeira vez
  dataReimported,      // Dados foram limpos e reimportados
  errorOccurred,       // Ocorreu erro durante processo
}

/// Callback para progresso da operação
typedef VersionControlProgressCallback = void Function(String stage, String message, double progress);

/// Serviço principal de controle automático de versão
/// Implementa a regra: "Toda vez que trocar a versão do app, as boxes Hive devem ser limpas e os JSONs reimportados"
class AutoVersionControlService {
  final VersionManagerService _versionManager;
  final DataCleaningService _cleaningService;
  final AutoDataImportService _importService;

  bool _isInitialized = false;

  AutoVersionControlService({
    required VersionManagerService versionManager,
    required DataCleaningService cleaningService,
    required AutoDataImportService importService,
  })  : _versionManager = versionManager,
        _cleaningService = cleaningService,
        _importService = importService;

  /// Factory method para criar instância com todas as dependências
  factory AutoVersionControlService.create() {
    final versionManager = VersionManagerService();
    final cleaningService = DataCleaningService();
    
    final assetLoader = AssetLoaderService();
    final importService = AutoDataImportService(
      assetLoader: assetLoader,
      cleaningService: cleaningService,
      versionManager: versionManager,
      culturaRepository: CulturaHiveRepository(),
      pragasRepository: PragasHiveRepository(),
      fitossanitarioRepository: FitossanitarioHiveRepository(),
      diagnosticoRepository: DiagnosticoHiveRepository(),
      fitossanitarioInfoRepository: FitossanitarioInfoHiveRepository(),
      plantasInfRepository: PlantasInfHiveRepository(),
      pragasInfRepository: PragasInfHiveRepository(),
    );

    return AutoVersionControlService(
      versionManager: versionManager,
      cleaningService: cleaningService,
      importService: importService,
    );
  }

  /// Executa verificação e controle automático de versão
  /// Esta é a função principal que implementa a regra de negócio
  Future<Either<Exception, VersionControlResult>> executeVersionControl({
    VersionControlProgressCallback? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      developer.log('Iniciando controle automático de versão...', name: 'AutoVersionControlService');
      
      onProgress?.call('Verificação', 'Verificando versão da aplicação...', 0.1);

      // 1. Verifica mudança de versão
      final versionCheck = await _versionManager.performVersionCheck();
      
      developer.log('Resultado da verificação: ${versionCheck.toString()}', 
        name: 'AutoVersionControlService');

      // 2. Decide ação baseada no resultado
      if (!versionCheck.needsUpdate) {
        stopwatch.stop();
        
        onProgress?.call('Concluído', 'Dados já estão atualizados', 1.0);
        
        return Right(VersionControlResult(
          success: true,
          message: 'Dados já estão atualizados para a versão ${versionCheck.currentVersion}',
          actionTaken: VersionControlAction.noActionNeeded,
          details: {
            'version_check': versionCheck.toString(),
            'current_version': versionCheck.currentVersion,
            'last_saved_version': versionCheck.lastSavedVersion,
          },
          executionTime: stopwatch.elapsed,
        ));
      }

      // 3. Executa reimportação automática
      onProgress?.call('Importação', 'Iniciando reimportação automática...', 0.2);

      final importResult = await _importService.executeAutoImport(
        newVersion: versionCheck.currentVersion,
        onProgress: (importProgress) {
          final overallProgress = 0.2 + (importProgress.progressPercentage / 100 * 0.7);
          onProgress?.call(
            'Importação', 
            'Importando ${importProgress.currentCategory}...', 
            overallProgress
          );
        },
      );

      if (importResult.isLeft()) {
        stopwatch.stop();
        final error = importResult.fold((e) => e.toString(), (r) => '');
        
        return Right(VersionControlResult(
          success: false,
          message: 'Erro durante reimportação: $error',
          actionTaken: VersionControlAction.errorOccurred,
          details: {
            'error': error,
            'version_check': versionCheck.toString(),
          },
          executionTime: stopwatch.elapsed,
        ));
      }

      final autoImportResult = importResult.fold((l) => null, (r) => r)!;

      // 4. Finaliza processo
      onProgress?.call('Finalizando', 'Salvando informações de versão...', 0.95);
      
      await _versionManager.completeVersionUpdate();

      stopwatch.stop();

      onProgress?.call('Concluído', 'Controle de versão executado com sucesso', 1.0);

      final actionTaken = versionCheck.isFirstRun 
        ? VersionControlAction.dataImported 
        : VersionControlAction.dataReimported;

      return Right(VersionControlResult(
        success: autoImportResult.success,
        message: autoImportResult.success 
          ? 'Controle de versão executado com sucesso. ${autoImportResult.message}'
          : 'Controle de versão executado com erros. ${autoImportResult.message}',
        actionTaken: actionTaken,
        details: {
          'version_check': versionCheck.toString(),
          'import_result': {
            'imported_counts': autoImportResult.importedCounts,
            'total_time': autoImportResult.totalTime.toString(),
            'errors': autoImportResult.errors,
          },
          'current_version': versionCheck.currentVersion,
          'is_first_run': versionCheck.isFirstRun,
          'version_changed': versionCheck.versionChanged,
        },
        executionTime: stopwatch.elapsed,
      ));

    } catch (e) {
      stopwatch.stop();
      developer.log('Erro crítico no controle de versão: $e', name: 'AutoVersionControlService');
      
      return Left(Exception('Falha crítica no controle automático de versão: ${e.toString()}'));
    }
  }

  /// Verifica rapidamente se ação é necessária (sem executar)
  Future<bool> isVersionControlNeeded() async {
    try {
      return await _versionManager.detectVersionChange();
    } catch (e) {
      developer.log('Erro ao verificar necessidade de controle de versão: $e', 
        name: 'AutoVersionControlService');
      return true; // Em caso de erro, assume que é necessário
    }
  }

  /// Obtém informações detalhadas sobre o estado atual
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final versionCheck = await _versionManager.performVersionCheck();
      final importStats = await _importService.getImportStatistics();
      final dataStats = await _cleaningService.getDataStatistics();
      
      return {
        'version_status': {
          'current_version': versionCheck.currentVersion,
          'last_saved_version': versionCheck.lastSavedVersion,
          'needs_update': versionCheck.needsUpdate,
          'is_first_run': versionCheck.isFirstRun,
          'version_changed': versionCheck.versionChanged,
        },
        'data_statistics': dataStats,
        'import_statistics': importStats,
        'system_health': {
          'version_integrity': await _versionManager.verifyVersionIntegrity(),
          'has_data': await _cleaningService.hasAnyData(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      developer.log('Erro ao obter status do sistema: $e', name: 'AutoVersionControlService');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Força execução do controle de versão (útil para desenvolvimento e testes)
  Future<Either<Exception, VersionControlResult>> forceVersionControl({
    VersionControlProgressCallback? onProgress,
  }) async {
    try {
      developer.log('Forçando controle de versão...', name: 'AutoVersionControlService');
      
      // Força limpeza das informações de versão
      await _versionManager.forceDataUpdate();
      
      // Executa controle normal
      return await executeVersionControl(onProgress: onProgress);
      
    } catch (e) {
      developer.log('Erro ao forçar controle de versão: $e', name: 'AutoVersionControlService');
      return Left(Exception('Falha ao forçar controle de versão: ${e.toString()}'));
    }
  }

  /// Executa apenas verificação sem ações (modo dry-run)
  Future<VersionCheckResult> performDryRun() async {
    try {
      developer.log('Executando verificação dry-run...', name: 'AutoVersionControlService');
      return await _versionManager.performVersionCheck();
    } catch (e) {
      developer.log('Erro durante dry-run: $e', name: 'AutoVersionControlService');
      rethrow;
    }
  }

  /// Executa reimportação de categoria específica (para correções)
  Future<Either<Exception, int>> reimportSpecificCategory(String category) async {
    try {
      developer.log('Reimportando categoria específica: $category', 
        name: 'AutoVersionControlService');
      
      final currentVersion = await _versionManager.getCurrentVersionAsync();
      return await _importService.importSpecificCategory(category, currentVersion);
      
    } catch (e) {
      developer.log('Erro ao reimportar categoria $category: $e', 
        name: 'AutoVersionControlService');
      return Left(Exception('Erro na reimportação de $category: ${e.toString()}'));
    }
  }

  /// Getter para verificar se o serviço está inicializado
  bool get isInitialized => _isInitialized;

  /// Marca serviço como inicializado (usado pelo AppDataManager)
  void markAsInitialized() {
    _isInitialized = true;
    developer.log('AutoVersionControlService marcado como inicializado', 
      name: 'AutoVersionControlService');
  }
}