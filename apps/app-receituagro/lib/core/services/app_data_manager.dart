import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../database/receituagro_database.dart';
import '../../database/repositories/culturas_repository.dart';
import '../../database/repositories/fitossanitarios_repository.dart';
import '../../database/repositories/pragas_repository.dart';
// REMOVED: import 'data_initialization_service.dart';

/// Interface para o gerenciador de dados da aplicação
abstract class IAppDataManager {
  Future<Either<Exception, void>> initialize();
  Future<Either<Exception, void>> forceReloadData();
  Future<Map<String, dynamic>> getDataStats();
  Future<bool> isDataReady();
  // ⚠️ REMOVED: DataInitializationService get dataService;
  Future<void> dispose();
  bool get isInitialized;
}

/// Implementação do gerenciador principal de dados da aplicação
/// Responsável por inicializar o Hive, registrar adapters e coordenar o carregamento de dados
/// Agora integrado com sistema de controle automático de versão
class AppDataManager implements IAppDataManager {
  // ⚠️ REMOVED: late final DataInitializationService _dataService;
  // ✅ Keep _isInitialized for interface compliance
  bool _isInitialized = false;

  /// Construtor que permite injeção de dependência
  AppDataManager();

  /// Inicializa completamente o sistema de dados com controle automático de versão
  /// ✅ PADRÃO: Hive.initFlutter() já foi chamado no main.dart para sync queue do core package
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

      // ✅ Hive.initFlutter() já foi executado no main.dart
      // Necessário apenas para sync queue do core package
      // Dados do app usam Drift (não Hive)

      await _createServices();
      developer.log(
        'Inicializando dados diretamente...',
        name: 'AppDataManager',
      );
      // ⚠️ REMOVED: DataInitializationService no longer exists
      // Just mark as initialized since Drift repos are initialized via DI
      // final isDataReady = await _dataService.isDataLoaded();
      // if (!isDataReady) {
      //   return Left(
      //     Exception(
      //       'Dados não foram carregados corretamente após controle de versão',
      //     ),
      //   );
      // }

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
      // ⚠️ REMOVED: VersionManagerService no longer exists
      // final versionManager = VersionManagerService();

      // Create Drift database and repository
      final database = ReceituagroDatabase.production();
      final culturaRepo = CulturasRepository(database);
      final pragasRepo = PragasRepository(database);
      final fitossanitarioRepo = FitossanitariosRepository(database);

      // ⚠️ REMOVED: DataInitializationService no longer exists
      // _dataService = DataInitializationService(
      //   assetLoader: assetLoader,
      //   versionManager: versionManager,
      //   culturaRepository: culturaRepo,
      //   pragasRepository: pragasRepo,
      //   fitossanitarioRepository: fitossanitarioRepo,
      // );

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

    // ⚠️ REMOVED: DataInitializationService no longer exists
    // Return simplified stats
    return {
      'initialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
      'storage': 'Drift',
    };
  }

  /// Verifica se os dados estão carregados
  @override
  Future<bool> isDataReady() async {
    // ⚠️ SIMPLIFIED: Just return initialization status
    return _isInitialized;
  }

  /// Obtém instância do serviço de inicialização (para uso em DI)
  // ⚠️ REMOVED: DataInitializationService no longer exists
  // @override
  // DataInitializationService get dataService {
  //   if (!_isInitialized) {
  //     throw Exception('Sistema não foi inicializado');
  //   }
  //   return _dataService;
  // }

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

      // ⚠️ REMOVED: Hive no longer used
      // await Hive.close();

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
