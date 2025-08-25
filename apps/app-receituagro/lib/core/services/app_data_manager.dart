import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../repositories/cultura_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../repositories/plantas_inf_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../repositories/pragas_inf_hive_repository.dart';
import 'asset_loader_service.dart';
import 'auto_version_control_service.dart';
import 'data_initialization_service.dart';
import 'hive_adapter_registry.dart';
import 'version_manager_service.dart';

/// Interface para o gerenciador de dados da aplicação
abstract class IAppDataManager {
  Future<Either<Exception, void>> initialize();
  Future<Either<Exception, void>> forceReloadData();
  Future<Map<String, dynamic>> getDataStats();
  Future<bool> isDataReady();
  DataInitializationService get dataService;
  AutoVersionControlService get versionControlService;
  Future<void> dispose();
  bool get isInitialized;
}

/// Implementação do gerenciador principal de dados da aplicação
/// Responsável por inicializar o Hive, registrar adapters e coordenar o carregamento de dados
/// Agora integrado com sistema de controle automático de versão
class AppDataManager implements IAppDataManager {
  late final DataInitializationService _dataService;
  late final AutoVersionControlService _versionControlService;
  bool _isInitialized = false;

  /// Construtor que permite injeção de dependência
  AppDataManager();

  /// Inicializa completamente o sistema de dados com controle automático de versão
  @override
  Future<Either<Exception, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      developer.log(
        'Iniciando inicialização do sistema de dados com controle de versão...',
        name: 'AppDataManager',
      );

      // 1. Inicializa o Hive
      await _initializeHive();

      // 2. Registra adapters
      await HiveAdapterRegistry.registerAdapters();

      // 3. Abre boxes
      await HiveAdapterRegistry.openBoxes();

      // 4. Cria instâncias dos serviços
      await _createServices();

      // 5. NOVA LÓGICA: Executa controle automático de versão
      developer.log(
        'Executando controle automático de versão...',
        name: 'AppDataManager',
      );

      final versionControlResult = await _versionControlService
          .executeVersionControl(
            onProgress: (stage, message, progress) {
              developer.log(
                '[$stage] $message (${(progress * 100).toInt()}%)',
                name: 'AppDataManager',
              );
            },
          );

      if (versionControlResult.isLeft()) {
        final error = versionControlResult.fold((e) => e.toString(), (r) => '');
        developer.log(
          'Erro no controle de versão: $error',
          name: 'AppDataManager',
        );
        return Left(Exception('Falha no controle de versão: $error'));
      }

      final result = versionControlResult.fold((l) => null, (r) => r)!;
      developer.log(
        'Controle de versão executado: ${result.toString()}',
        name: 'AppDataManager',
      );

      // 6. Verifica se dados estão carregados
      final isDataReady = await _dataService.isDataLoaded();
      if (!isDataReady) {
        return Left(
          Exception(
            'Dados não foram carregados corretamente após controle de versão',
          ),
        );
      }

      _isInitialized = true;
      _versionControlService.markAsInitialized();

      developer.log(
        'Sistema de dados inicializado com sucesso via controle automático de versão',
        name: 'AppDataManager',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Erro na inicialização do sistema de dados: $e',
        name: 'AppDataManager',
      );
      return Left(Exception('Falha na inicialização: ${e.toString()}'));
    }
  }

  /// Inicializa o Hive com configurações adequadas
  Future<void> _initializeHive() async {
    try {
      developer.log('Inicializando Hive...', name: 'AppDataManager');

      // Inicializa Hive com Flutter (usa configuração padrão multiplataforma)
      await Hive.initFlutter();

      developer.log('Hive inicializado com sucesso', name: 'AppDataManager');
    } catch (e) {
      developer.log('Erro ao inicializar Hive: $e', name: 'AppDataManager');
      rethrow;
    }
  }

  /// Cria instâncias de todos os serviços necessários
  Future<void> _createServices() async {
    try {
      developer.log(
        'Criando instâncias dos serviços...',
        name: 'AppDataManager',
      );

      // Serviços base
      final assetLoader = AssetLoaderService();
      final versionManager = VersionManagerService();

      // Repositórios
      final culturaRepo = CulturaHiveRepository();
      final pragasRepo = PragasHiveRepository();
      final fitossanitarioRepo = FitossanitarioHiveRepository();
      final diagnosticoRepo = DiagnosticoHiveRepository();
      final fitossanitarioInfoRepo = FitossanitarioInfoHiveRepository();
      final plantasInfRepo = PlantasInfHiveRepository();
      final pragasInfRepo = PragasInfHiveRepository();

      // Serviço de inicialização de dados (mantido para compatibilidade)
      _dataService = DataInitializationService(
        assetLoader: assetLoader,
        versionManager: versionManager,
        culturaRepository: culturaRepo,
        pragasRepository: pragasRepo,
        fitossanitarioRepository: fitossanitarioRepo,
        diagnosticoRepository: diagnosticoRepo,
        fitossanitarioInfoRepository: fitossanitarioInfoRepo,
        plantasInfRepository: plantasInfRepo,
        pragasInfRepository: pragasInfRepo,
      );

      // NOVO: Serviço de controle automático de versão
      _versionControlService = AutoVersionControlService.create();

      developer.log(
        'Serviços criados com sucesso (incluindo controle de versão)',
        name: 'AppDataManager',
      );
    } catch (e) {
      developer.log('Erro ao criar serviços: $e', name: 'AppDataManager');
      rethrow;
    }
  }

  /// Força recarregamento de todos os dados usando controle automático de versão
  @override
  Future<Either<Exception, void>> forceReloadData() async {
    if (!_isInitialized) {
      return Left(Exception('Sistema não foi inicializado'));
    }

    try {
      developer.log(
        'Forçando recarregamento via controle de versão...',
        name: 'AppDataManager',
      );

      final result = await _versionControlService.forceVersionControl(
        onProgress: (stage, message, progress) {
          developer.log(
            '[$stage] $message (${(progress * 100).toInt()}%)',
            name: 'AppDataManager',
          );
        },
      );

      return result.fold(
        (error) => Left(error),
        (versionResult) =>
            versionResult.success
                ? const Right(null)
                : Left(
                  Exception('Recarregamento falhou: ${versionResult.message}'),
                ),
      );
    } catch (e) {
      developer.log(
        'Erro ao forçar recarregamento: $e',
        name: 'AppDataManager',
      );
      return Left(
        Exception('Falha no recarregamento forçado: ${e.toString()}'),
      );
    }
  }

  /// Obtém estatísticas do carregamento de dados incluindo informações de versão
  @override
  Future<Map<String, dynamic>> getDataStats() async {
    if (!_isInitialized) {
      return {'error': 'Sistema não foi inicializado'};
    }

    try {
      // Combina estatísticas do serviço de dados com informações de controle de versão
      final dataStats = await _dataService.getLoadingStats();
      final systemStatus = await _versionControlService.getSystemStatus();

      return {
        'data_initialization': dataStats,
        'version_control': systemStatus,
        'combined_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log(
        'Erro ao obter estatísticas combinadas: $e',
        name: 'AppDataManager',
      );
      return {
        'error': e.toString(),
        'fallback_data': await _dataService.getLoadingStats(),
      };
    }
  }

  /// Verifica se os dados estão carregados
  @override
  Future<bool> isDataReady() async {
    if (!_isInitialized) {
      return false;
    }

    return await _dataService.isDataLoaded();
  }

  /// Obtém instância do serviço de inicialização (para uso em DI)
  @override
  DataInitializationService get dataService {
    if (!_isInitialized) {
      throw Exception('Sistema não foi inicializado');
    }
    return _dataService;
  }

  /// Obtém instância do serviço de controle de versão (para uso em DI)
  @override
  AutoVersionControlService get versionControlService {
    if (!_isInitialized) {
      throw Exception('Sistema não foi inicializado');
    }
    return _versionControlService;
  }

  /// Limpa recursos do sistema
  @override
  Future<void> dispose() async {
    try {
      developer.log(
        'Fazendo dispose do AppDataManager...',
        name: 'AppDataManager',
      );

      await HiveAdapterRegistry.closeBoxes();
      await Hive.close();

      _isInitialized = false;

      developer.log(
        'Dispose do AppDataManager concluído',
        name: 'AppDataManager',
      );
    } catch (e) {
      developer.log(
        'Erro durante dispose do AppDataManager: $e',
        name: 'AppDataManager',
      );
    }
  }

  /// Getter para verificar se está inicializado
  @override
  bool get isInitialized => _isInitialized;
}
