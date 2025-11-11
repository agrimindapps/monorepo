import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../data/repositories/cultura_legacy_repository.dart';
import '../data/repositories/diagnostico_legacy_repository.dart';
import '../data/repositories/fitossanitario_legacy_repository.dart';
import '../data/repositories/fitossanitario_info_legacy_repository.dart';
import '../data/repositories/plantas_inf_legacy_repository.dart';
import '../data/repositories/pragas_legacy_repository.dart';
import '../data/repositories/pragas_inf_legacy_repository.dart';
import 'data_initialization_service.dart';

/// Interface para o gerenciador de dados da aplicação
abstract class IAppDataManager {
  Future<Either<Exception, void>> initialize();
  Future<Either<Exception, void>> forceReloadData();
  Future<Map<String, dynamic>> getDataStats();
  Future<bool> isDataReady();
  DataInitializationService get dataService;
  Future<void> dispose();
  bool get isInitialized;
}

/// Implementação do gerenciador principal de dados da aplicação
/// Responsável por inicializar o Hive, registrar adapters e coordenar o carregamento de dados
/// Agora integrado com sistema de controle automático de versão
class AppDataManager implements IAppDataManager {
  late final DataInitializationService _dataService;
  bool _isInitialized = false;

  /// Construtor que permite injeção de dependência
  AppDataManager();

  /// Inicializa completamente o sistema de dados com controle automático de versão
  /// ✅ PADRÃO APP-PLANTIS: Hive.initFlutter() e LegacyAdapterRegistry.registerAdapters()
  /// já foram chamados no main.dart ANTES de ReceitaAgroStorageInitializer
  @override
  Future<Either<Exception, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      developer.log(
        'Iniciando inicialização do sistema de dados...',
        name: 'AppDataManager',
      );

      // ✅ Hive.initFlutter() e LegacyAdapterRegistry.registerAdapters()
      // já foram executados no main.dart antes de registrar boxes
      // Isso garante que adapters estejam disponíveis quando BoxRegistryService
      // tentar abrir boxes persistentes

      await _createServices();
      developer.log(
        'Inicializando dados diretamente...',
        name: 'AppDataManager',
      );
      final isDataReady = await _dataService.isDataLoaded();
      if (!isDataReady) {
        return Left(
          Exception(
            'Dados não foram carregados corretamente após controle de versão',
          ),
        );
      }

      _isInitialized = true;

      developer.log(
        'Sistema de dados inicializado com sucesso',
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

  /// Cria instâncias de todos os serviços necessários
  Future<void> _createServices() async {
    try {
      developer.log(
        'Criando instâncias dos serviços...',
        name: 'AppDataManager',
      );
      final assetLoader = AssetLoaderService();
      final versionManager = VersionManagerService();
      final culturaRepo = CulturaLegacyRepository();
      final pragasRepo = PragasLegacyRepository();
      final fitossanitarioRepo = FitossanitarioLegacyRepository();
      final diagnosticoRepo = DiagnosticoLegacyRepository();
      final fitossanitarioInfoRepo = FitossanitarioInfoLegacyRepository();
      final plantasInfRepo = PlantasInfLegacyRepository();
      final pragasInfRepo = PragasInfLegacyRepository();
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
        'Forçando recarregamento de dados...',
        name: 'AppDataManager',
      );
      developer.log(
        'Force reload requested but method not implemented',
        name: 'AppDataManager',
      );

      return const Right(null);
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
      final dataStats = await _dataService.getLoadingStats();

      return {
        'data_initialization': dataStats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log('Erro ao obter estatísticas: $e', name: 'AppDataManager');
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

  /// Version control service removed - no longer available
  dynamic get versionControlService {
    throw Exception(
      'Version control service was removed - functionality not available',
    );
  }

  /// Limpa recursos do sistema
  /// ✅ PADRÃO APP-PLANTIS: BoxRegistryService gerencia fechamento de boxes
  @override
  Future<void> dispose() async {
    try {
      developer.log(
        'Fazendo dispose do AppDataManager...',
        name: 'AppDataManager',
      );

      // ❌ REMOVIDO: await LegacyAdapterRegistry.closeBoxes();
      // ✅ BoxRegistryService gerencia fechamento de boxes
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
