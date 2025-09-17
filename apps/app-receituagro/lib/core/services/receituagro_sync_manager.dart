import 'package:core/core.dart' as core;
import 'package:get_it/get_it.dart';

// Import the simplified implementations from selective sync service
import 'receituagro_selective_sync_service.dart' as local;

/// Gerenciador de sincronização específico para o ReceitaAgro
class ReceitaAgroSyncManager {
  ReceitaAgroSyncManager({
    required this.hiveStorage,
    required this.selectiveSync,
  });

  final local.HiveStorageService hiveStorage;
  final local.SelectiveSyncService selectiveSync;

  /// Configurações específicas do ReceitaAgro
  static final List<local.BoxSyncConfig> _configs = [
    // BOXES ESTÁTICAS (não sincronizam - dados do JSON versionado)
    local.BoxSyncConfig.localOnly(
      boxName: 'receituagro_pragas_static',
      description: 'Dados de pragas incluídos na versão do app',
    ),
    local.BoxSyncConfig.localOnly(
      boxName: 'receituagro_defensivos_static',
      description: 'Dados de defensivos incluídos na versão do app',
    ),
    local.BoxSyncConfig.localOnly(
      boxName: 'receituagro_diagnosticos_static',
      description: 'Dados de diagnósticos incluídos na versão do app',
    ),
    local.BoxSyncConfig.localOnly(
      boxName: 'receituagro_culturas_static',
      description: 'Dados de culturas incluídos na versão do app',
    ),

    // BOXES DO USUÁRIO (sincronizam com Firebase)
    local.BoxSyncConfig.syncable(
      boxName: 'receituagro_user_favorites',
      strategy: local.BoxSyncStrategy.automatic,
      description: 'Favoritos do usuário',
    ),
    local.BoxSyncConfig.syncable(
      boxName: 'receituagro_user_comments',
      strategy: local.BoxSyncStrategy.automatic,
      description: 'Comentários do usuário',
    ),
    local.BoxSyncConfig.syncable(
      boxName: 'receituagro_user_settings',
      strategy: local.BoxSyncStrategy.periodic,
      description: 'Configurações do usuário',
    ),
  ];

  /// Inicializa o sistema de sincronização
  void initialize() {
    selectiveSync.registerBoxConfigs(_configs);
  }

  /// Carrega dados estáticos dos JSONs (chamado uma vez por versão)
  Future<void> loadStaticDataFromAssets({
    required String appVersion,
    required Map<String, dynamic> pragasJson,
    required Map<String, dynamic> defensivosJson,
    required Map<String, dynamic> diagnosticosJson,
    required Map<String, dynamic> culturasJson,
  }) async {
    // Carrega pragas
    await selectiveSync.initializeStaticContent(
      boxName: 'receituagro_pragas_static',
      staticData: pragasJson,
      appVersion: appVersion,
    );

    // Carrega defensivos
    await selectiveSync.initializeStaticContent(
      boxName: 'receituagro_defensivos_static',
      staticData: defensivosJson,
      appVersion: appVersion,
    );

    // Carrega diagnósticos
    await selectiveSync.initializeStaticContent(
      boxName: 'receituagro_diagnosticos_static',
      staticData: diagnosticosJson,
      appVersion: appVersion,
    );

    // Carrega culturas
    await selectiveSync.initializeStaticContent(
      boxName: 'receituagro_culturas_static',
      staticData: culturasJson,
      appVersion: appVersion,
    );
  }

  /// Verifica se precisa recarregar dados estáticos
  Future<bool> needsStaticDataReload(String currentAppVersion) async {
    const boxes = [
      'receituagro_pragas_static',
      'receituagro_defensivos_static', 
      'receituagro_diagnosticos_static',
      'receituagro_culturas_static',
    ];

    for (final boxName in boxes) {
      final versionKey = '_app_version_$boxName';
      final result = await hiveStorage.get<String>(
        key: versionKey,
        box: boxName,
      );

      final storedVersion = result.fold(
        (core.Failure failure) => null,
        (String? version) => version,
      );

      if (storedVersion != currentAppVersion) {
        return true;
      }
    }

    return false;
  }

  /// Obtém dados de pragas (sempre local)
  Future<List<Map<String, dynamic>>> getPragas() async {
    final result = await hiveStorage.getValues<Map<String, dynamic>>(
      box: 'receituagro_pragas_static',
    );

    return result.fold(
      (core.Failure failure) => <Map<String, dynamic>>[],
      (List<Map<String, dynamic>> values) => values.where((Map<String, dynamic> v) => !v.containsKey('_app_version')).toList(),
    );
  }

  /// Obtém dados de defensivos (sempre local)
  Future<List<Map<String, dynamic>>> getDefensivos() async {
    final result = await hiveStorage.getValues<Map<String, dynamic>>(
      box: 'receituagro_defensivos_static',
    );

    return result.fold(
      (core.Failure failure) => <Map<String, dynamic>>[],
      (List<Map<String, dynamic>> values) => values.where((Map<String, dynamic> v) => !v.containsKey('_app_version')).toList(),
    );
  }

  /// Salva favorito do usuário (sincroniza automaticamente)
  Future<void> addFavorite({
    required String type, // 'praga', 'defensivo', 'diagnostico'
    required String itemId,
    required Map<String, dynamic> favoriteData,
  }) async {
    final key = '${type}_$itemId';
    await hiveStorage.save(
      key: key,
      data: favoriteData,
      box: 'receituagro_user_favorites',
    );
    
    // O sincronismo acontece automaticamente pois a box está configurada
    // como BoxSyncStrategy.automatic
  }

  /// Obtém favoritos do usuário
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final result = await hiveStorage.getValues<Map<String, dynamic>>(
      box: 'receituagro_user_favorites',
    );

    return result.fold(
      (core.Failure failure) => <Map<String, dynamic>>[],
      (List<Map<String, dynamic>> values) => values,
    );
  }

  /// Força sincronização manual dos dados do usuário
  Future<void> syncUserData() async {
    await selectiveSync.syncAllSyncableBoxes();
  }

  /// Obtém estatísticas de sincronização
  Map<String, dynamic> getSyncStats() {
    return selectiveSync.getSyncStats();
  }
}

/// Configuração e inicialização no DI
class ReceitaAgroSyncSetup {
  static Future<void> setup() async {
    final sl = GetIt.instance;
    
    // Assume que os serviços base já estão registrados
    final hiveStorage = local.HiveStorageService();

    // Cria o serviço de sincronização seletiva
    final selectiveSync = local.SelectiveSyncService(
      hiveStorage: hiveStorage,
    );
    
    // Cria o gerenciador específico do ReceitaAgro
    final syncManager = ReceitaAgroSyncManager(
      hiveStorage: hiveStorage,
      selectiveSync: selectiveSync,
    );
    
    // Inicializa as configurações
    syncManager.initialize();
    
    // Registra no DI
    sl.registerSingleton<ReceitaAgroSyncManager>(syncManager);
  }
}

/// Exemplo de uso prático
class ReceitaAgroSyncUsageExample {
  late final ReceitaAgroSyncManager syncManager;

  ReceitaAgroSyncUsageExample() {
    syncManager = GetIt.instance<ReceitaAgroSyncManager>();
  }

  /// Inicialização no startup do app
  Future<void> initializeAppData() async {
    const currentVersion = '1.0.0';
    
    // Verifica se precisa recarregar dados estáticos
    final needsReload = await syncManager.needsStaticDataReload(currentVersion);
    
    if (needsReload) {
      // Carregaria os JSONs dos assets aqui
      final pragasJson = <String, dynamic>{}; // loadPragasFromAssets();
      final defensivosJson = <String, dynamic>{}; // loadDefensivosFromAssets();
      final diagnosticosJson = <String, dynamic>{}; // loadDiagnosticosFromAssets();
      final culturasJson = <String, dynamic>{}; // loadCulturasFromAssets();
      
      await syncManager.loadStaticDataFromAssets(
        appVersion: currentVersion,
        pragasJson: pragasJson,
        defensivosJson: defensivosJson,
        diagnosticosJson: diagnosticosJson,
        culturasJson: culturasJson,
      );
    }
  }

  /// Exemplo: usuário favorita uma praga
  Future<void> favoriteAPraga(String pragaId) async {
    await syncManager.addFavorite(
      type: 'praga',
      itemId: pragaId,
      favoriteData: {
        'id': pragaId,
        'type': 'praga',
        'favorited_at': DateTime.now().toIso8601String(),
      },
    );
    // Sincronização com Firebase acontece automaticamente!
  }

  /// Exemplo: listar pragas disponíveis
  Future<List<Map<String, dynamic>>> listAvailablePragas() async {
    return syncManager.getPragas(); // Sempre local, nunca sincroniza
  }
}