import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

/// Configuração específica de sincronização para ReceitaAgro
class ReceitaAgroSyncConfig {
  static final List<BoxSyncConfig> configs = [
    // ===== BOXES SOMENTE LOCAIS (CONTEÚDO ESTÁTICO) =====
    
    /// Dados de pragas incluídos na versão do app
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_pragas_static',
      description: 'Base de dados de pragas versionada com o app',
    ),
    
    /// Dados de defensivos incluídos na versão do app
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_defensivos_static',
      description: 'Base de dados de defensivos versionada com o app',
    ),
    
    /// Dados de diagnósticos incluídos na versão do app
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_diagnosticos_static',
      description: 'Base de dados de diagnósticos versionada com o app',
    ),
    
    /// Dados de culturas incluídos na versão do app
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_culturas_static',
      description: 'Base de dados de culturas versionada com o app',
    ),
    
    /// Associações praga-cultura incluídas na versão do app
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_praga_cultura_static',
      description: 'Relacionamentos praga-cultura versionados com o app',
    ),
    
    /// Receitas/formulações incluídas na versão do app
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_receitas_static',
      description: 'Receitas e formulações versionadas com o app',
    ),

    // ===== BOXES SINCRONIZÁVEIS (DADOS DO USUÁRIO) =====
    
    /// Favoritos do usuário
    BoxSyncConfig.syncable(
      boxName: 'receituagro_user_favorites',
      strategy: BoxSyncStrategy.automatic,
      description: 'Pragas, defensivos e diagnósticos favoritos do usuário',
    ),
    
    /// Comentários do usuário
    BoxSyncConfig.syncable(
      boxName: 'receituagro_user_comments',
      strategy: BoxSyncStrategy.automatic,
      description: 'Comentários e avaliações do usuário',
    ),
    
    /// Histórico de consultas
    BoxSyncConfig.syncable(
      boxName: 'receituagro_user_history',
      strategy: BoxSyncStrategy.periodic,
      description: 'Histórico de pragas, defensivos e diagnósticos consultados',
    ),
    
    /// Configurações personalizadas
    BoxSyncConfig.syncable(
      boxName: 'receituagro_user_settings',
      strategy: BoxSyncStrategy.periodic,
      description: 'Configurações e preferências do usuário',
    ),
    
    /// Dados de aplicações (se implementado futuramente)
    BoxSyncConfig.syncable(
      boxName: 'receituagro_user_applications',
      strategy: BoxSyncStrategy.automatic,
      description: 'Registro de aplicações de defensivos do usuário',
    ),

    // ===== BOXES DE CACHE =====
    
    /// Cache de dados temporários
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_temp_cache',
      description: 'Cache temporário de imagens e dados processados',
    ),
    
    /// Cache de busca
    BoxSyncConfig.localOnly(
      boxName: 'receituagro_search_cache',
      description: 'Cache de resultados de busca para melhor performance',
    ),
  ];
}

/// Serviço especializado para inicialização de dados estáticos do ReceitaAgro
class ReceitaAgroStaticDataService {
  const ReceitaAgroStaticDataService({
    required this.selectiveSync,
    required this.hiveStorage,
  });

  final SelectiveSyncService selectiveSync;
  final HiveStorageService hiveStorage;

  /// Inicializa todos os dados estáticos do ReceitaAgro
  Future<Either<Failure, void>> initializeAllStaticData({
    required String appVersion,
    required Map<String, Map<String, dynamic>> staticDataSets,
  }) async {
    try {
      final results = <Either<Failure, void>>[];

      // Inicializa cada conjunto de dados estáticos
      for (final entry in staticDataSets.entries) {
        final boxName = entry.key;
        final data = entry.value;
        
        final result = await selectiveSync.initializeStaticContent(
          boxName: boxName,
          staticData: data,
          appVersion: appVersion,
        );
        
        results.add(result);
      }

      // Verifica se houve algum erro
      for (final result in results) {
        if (result.isLeft()) {
          return result;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao inicializar dados estáticos: $e'));
    }
  }

  /// Inicializa dados de pragas
  Future<Either<Failure, void>> initializePragasData({
    required String appVersion,
    required List<Map<String, dynamic>> pragasData,
  }) async {
    final dataMap = <String, dynamic>{};
    
    for (int i = 0; i < pragasData.length; i++) {
      dataMap['praga_$i'] = pragasData[i];
    }
    
    return selectiveSync.initializeStaticContent(
      boxName: 'receituagro_pragas_static',
      staticData: dataMap,
      appVersion: appVersion,
    );
  }

  /// Inicializa dados de defensivos
  Future<Either<Failure, void>> initializeDefensivosData({
    required String appVersion,
    required List<Map<String, dynamic>> defensivosData,
  }) async {
    final dataMap = <String, dynamic>{};
    
    for (int i = 0; i < defensivosData.length; i++) {
      dataMap['defensivo_$i'] = defensivosData[i];
    }
    
    return selectiveSync.initializeStaticContent(
      boxName: 'receituagro_defensivos_static',
      staticData: dataMap,
      appVersion: appVersion,
    );
  }

  /// Inicializa dados de diagnósticos
  Future<Either<Failure, void>> initializeDiagnosticosData({
    required String appVersion,
    required List<Map<String, dynamic>> diagnosticosData,
  }) async {
    final dataMap = <String, dynamic>{};
    
    for (int i = 0; i < diagnosticosData.length; i++) {
      dataMap['diagnostico_$i'] = diagnosticosData[i];
    }
    
    return selectiveSync.initializeStaticContent(
      boxName: 'receituagro_diagnosticos_static',
      staticData: dataMap,
      appVersion: appVersion,
    );
  }

  /// Verifica se os dados estáticos estão atualizados
  Future<bool> isStaticDataUpToDate(String appVersion) async {
    final staticBoxes = [
      'receituagro_pragas_static',
      'receituagro_defensivos_static',
      'receituagro_diagnosticos_static',
      'receituagro_culturas_static',
    ];

    for (final boxName in staticBoxes) {
      final versionKey = '_app_version_$boxName';
      final storedVersionResult = await hiveStorage.get<String>(
        key: versionKey,
        box: boxName,
      );

      final storedVersion = storedVersionResult.fold(
        (failure) => null,
        (version) => version,
      );

      if (storedVersion != appVersion) {
        return false;
      }
    }

    return true;
  }
}

/// Exemplo de uso e configuração
class ReceitaAgroSyncExample {
  static Future<void> setupSync() async {
    final sl = GetIt.instance;
    
    // Obtém os serviços necessários
    final hiveStorage = sl<HiveStorageService>();
    
    // Cria o serviço de sincronização seletiva
    final selectiveSync = SelectiveSyncService(
      hiveStorage: hiveStorage,
    );
    
    // Registra as configurações específicas do ReceitaAgro
    selectiveSync.registerBoxConfigs(ReceitaAgroSyncConfig.configs);
    
    // Registra no DI
    sl.registerSingleton<SelectiveSyncService>(selectiveSync);
    
    // Cria o serviço de dados estáticos
    final staticDataService = ReceitaAgroStaticDataService(
      selectiveSync: selectiveSync,
      hiveStorage: hiveStorage,
    );
    
    sl.registerSingleton<ReceitaAgroStaticDataService>(staticDataService);
  }

  /// Exemplo de inicialização de dados estáticos
  static Future<void> initializeStaticData() async {
    final sl = GetIt.instance;
    final staticDataService = sl<ReceitaAgroStaticDataService>();
    const appVersion = '1.0.0'; // Versão atual do app
    
    // Dados mockados - substituir pelos dados reais dos JSONs
    final pragasData = [
      {'id': 1, 'nome': 'Lagarta-da-soja', 'descricao': 'Descrição da praga...'},
      {'id': 2, 'nome': 'Percevejo-marrom', 'descricao': 'Descrição da praga...'},
    ];
    
    final defensivosData = [
      {'id': 1, 'nome': 'Produto A', 'principio_ativo': 'Ativo A'},
      {'id': 2, 'nome': 'Produto B', 'principio_ativo': 'Ativo B'},
    ];
    
    // Inicializa os dados
    await staticDataService.initializePragasData(
      appVersion: appVersion,
      pragasData: pragasData,
    );
    
    await staticDataService.initializeDefensivosData(
      appVersion: appVersion,
      defensivosData: defensivosData,
    );
  }
}