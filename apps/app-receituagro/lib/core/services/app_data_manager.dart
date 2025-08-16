import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'hive_adapter_registry.dart';
import 'data_initialization_service.dart';
import 'asset_loader_service.dart';
import 'version_manager_service.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../repositories/plantas_inf_hive_repository.dart';
import '../repositories/pragas_inf_hive_repository.dart';

/// Gerenciador principal de dados da aplicação
/// Responsável por inicializar o Hive, registrar adapters e coordenar o carregamento de dados
class AppDataManager {
  static AppDataManager? _instance;
  static AppDataManager get instance => _instance ??= AppDataManager._();
  
  AppDataManager._();

  late final DataInitializationService _dataService;
  bool _isInitialized = false;

  /// Inicializa completamente o sistema de dados
  Future<Either<Exception, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      developer.log('Iniciando inicialização do sistema de dados...', name: 'AppDataManager');

      // 1. Inicializa o Hive
      await _initializeHive();
      
      // 2. Registra adapters
      await HiveAdapterRegistry.registerAdapters();
      
      // 3. Abre boxes
      await HiveAdapterRegistry.openBoxes();
      
      // 4. Cria instâncias dos serviços
      await _createServices();
      
      // 5. Carrega dados
      final result = await _dataService.initializeData();
      if (result.isLeft()) {
        return result;
      }

      _isInitialized = true;
      developer.log('Sistema de dados inicializado com sucesso', name: 'AppDataManager');
      
      return const Right(null);
      
    } catch (e) {
      developer.log('Erro na inicialização do sistema de dados: $e', name: 'AppDataManager');
      return Left(Exception('Falha na inicialização: ${e.toString()}'));
    }
  }

  /// Inicializa o Hive com configurações adequadas
  Future<void> _initializeHive() async {
    try {
      developer.log('Inicializando Hive...', name: 'AppDataManager');
      
      // Obtém diretório de documentos para armazenamento
      final appDocumentDir = await getApplicationDocumentsDirectory();
      
      // Inicializa Hive com Flutter
      await Hive.initFlutter(appDocumentDir.path);
      
      developer.log('Hive inicializado no caminho: ${appDocumentDir.path}', name: 'AppDataManager');
      
    } catch (e) {
      developer.log('Erro ao inicializar Hive: $e', name: 'AppDataManager');
      rethrow;
    }
  }

  /// Cria instâncias de todos os serviços necessários
  Future<void> _createServices() async {
    try {
      developer.log('Criando instâncias dos serviços...', name: 'AppDataManager');
      
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
      
      // Serviço de inicialização de dados
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
      
      developer.log('Serviços criados com sucesso', name: 'AppDataManager');
      
    } catch (e) {
      developer.log('Erro ao criar serviços: $e', name: 'AppDataManager');
      rethrow;
    }
  }

  /// Força recarregamento de todos os dados
  Future<Either<Exception, void>> forceReloadData() async {
    if (!_isInitialized) {
      return Left(Exception('Sistema não foi inicializado'));
    }
    
    return await _dataService.forceReloadAllData();
  }

  /// Obtém estatísticas do carregamento de dados
  Future<Map<String, dynamic>> getDataStats() async {
    if (!_isInitialized) {
      return {'error': 'Sistema não foi inicializado'};
    }
    
    return await _dataService.getLoadingStats();
  }

  /// Verifica se os dados estão carregados
  Future<bool> isDataReady() async {
    if (!_isInitialized) {
      return false;
    }
    
    return await _dataService.isDataLoaded();
  }

  /// Obtém instância do serviço de inicialização (para uso em DI)
  DataInitializationService get dataService {
    if (!_isInitialized) {
      throw Exception('Sistema não foi inicializado');
    }
    return _dataService;
  }

  /// Limpa recursos do sistema
  Future<void> dispose() async {
    try {
      developer.log('Fazendo dispose do AppDataManager...', name: 'AppDataManager');
      
      await HiveAdapterRegistry.closeBoxes();
      await Hive.close();
      
      _isInitialized = false;
      _instance = null;
      
      developer.log('Dispose do AppDataManager concluído', name: 'AppDataManager');
      
    } catch (e) {
      developer.log('Erro durante dispose do AppDataManager: $e', name: 'AppDataManager');
    }
  }

  /// Getter para verificar se está inicializado
  bool get isInitialized => _isInitialized;
}