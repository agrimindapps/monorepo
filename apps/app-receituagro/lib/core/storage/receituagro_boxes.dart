import 'package:core/core.dart';

/// Definições de boxes específicas do app ReceitaAgro
/// Cada app gerencia suas próprias boxes para evitar contaminação cross-app
class ReceitaAgroBoxes {
  // Private constructor para classe utilitária (apenas membros estáticos)
  ReceitaAgroBoxes._();

  static const String receituagro = 'receituagro';
  static const String cache = 'receituagro_cache';
  static const String favoritos = 'receituagro_favoritos';
  static const String settings = 'receituagro_settings';
  static const String offline = 'receituagro_offline';

  /// Obtém todas as configurações de boxes do ReceitaAgro
  /// Cada box é configurada com o appId correto para isolamento
  static List<BoxConfiguration> getConfigurations() => [
    BoxConfiguration.basic(
      name: receituagro,
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      metadata: {
        'description': 'Box principal para dados estáticos do ReceitaAgro',
        'contains': ['plantas', 'pragas', 'doencas', 'receitas'],
      },
    ),

    BoxConfiguration.basic(
      name: cache,
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      metadata: {
        'description': 'Cache de dados temporários do ReceitaAgro',
        'contains': ['search_cache', 'image_cache'],
      },
    ),

    BoxConfiguration.basic(
      name: favoritos,
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      metadata: {
        'description': 'Favoritos e bookmarks do usuário',
        'contains': ['favorite_plantas', 'favorite_receitas'],
      },
    ),

    BoxConfiguration.basic(
      name: settings,
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      metadata: {
        'description': 'Configurações específicas do ReceitaAgro',
        'contains': ['app_preferences', 'user_settings'],
      },
    ),

    BoxConfiguration.basic(
      name: offline,
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      metadata: {
        'description': 'Dados para uso offline',
        'contains': ['sync_data', 'offline_content'],
      },
    ),

    // ========================================================================
    // BOXES PARA SYNC EM TEMPO REAL - UnifiedSyncManager
    // ========================================================================
    // IMPORTANTE: Estes nomes devem corresponder aos usados no
    // UnifiedSyncManager (favoritos, comentarios, user_settings, etc.)
    // sem prefixo receituagro_
    //
    // ⚠️ CRÍTICO: Marcadas como persistent:false porque:
    // 1. BoxRegistryService abre como Box<dynamic>
    // 2. HiveManager precisa de Box<T> específico (Box<ComentarioHive>, etc.)
    // 3. Cast Box<dynamic> → Box<T> é IMPOSSÍVEL em Dart (generics invariantes)
    // 4. HiveManager abrirá com tipo correto quando BaseHiveRepository precisar

    BoxConfiguration.basic(
      name: 'favoritos',  // Nome usado pelo UnifiedSyncManager
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      persistent: false,  // ⚠️ HiveManager abrirá com tipo correto
      metadata: {
        'description': 'Favoritos sincronizados (defensivos, pragas, diagnósticos, culturas)',
        'sync_enabled': true,
        'realtime': true,
      },
    ),

    BoxConfiguration.basic(
      name: 'comentarios',  // Nome usado pelo UnifiedSyncManager
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      persistent: false,  // ⚠️ HiveManager abrirá com tipo correto
      metadata: {
        'description': 'Comentários do usuário sincronizados',
        'sync_enabled': true,
        'realtime': true,
      },
    ),

    BoxConfiguration.basic(
      name: 'user_settings',  // Nome usado pelo UnifiedSyncManager
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      persistent: false,  // ⚠️ HiveManager abrirá com tipo correto
      metadata: {
        'description': 'Configurações do usuário sincronizadas',
        'sync_enabled': true,
        'realtime': true,
      },
    ),

    BoxConfiguration.basic(
      name: 'user_history',  // Nome usado pelo UnifiedSyncManager
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      persistent: false,  // ⚠️ HiveManager abrirá com tipo correto
      metadata: {
        'description': 'Histórico de ações do usuário',
        'sync_enabled': true,
        'realtime': true,
      },
    ),

    BoxConfiguration.basic(
      name: 'subscriptions',  // Nome usado pelo UnifiedSyncManager
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      persistent: false,  // ⚠️ HiveManager abrirá com tipo correto
      metadata: {
        'description': 'Dados de assinatura premium sincronizados',
        'sync_enabled': true,
        'realtime': true,
      },
    ),

    BoxConfiguration.basic(
      name: 'users',  // Nome usado pelo UnifiedSyncManager
      appId: 'receituagro',
    ).copyWith(
      version: 1,
      persistent: false,  // ⚠️ HiveManager abrirá com tipo correto
      metadata: {
        'description': 'Dados do usuário sincronizados',
        'sync_enabled': true,
        'realtime': true,
      },
    ),
  ];

}

/// Storage keys específicos para o ReceitaAgro
/// Estes substituem os keys que estavam no core package
class ReceitaAgroStorageKeys {
    static const String userPreferences = 'receituagro_user_preferences';
    static const String appVersion = 'receituagro_app_version';
    static const String lastSyncDate = 'receituagro_last_sync_date';
    static const String cachedPlantas = 'receituagro_cached_plantas';
    static const String cachedPragas = 'receituagro_cached_pragas';
    static const String cachedDoencas = 'receituagro_cached_doencas';
    static const String cachedReceitas = 'receituagro_cached_receitas';
    static const String favoritePlants = 'receituagro_favorite_plants';
    static const String favoriteRecipes = 'receituagro_favorite_recipes';
    static const String favoriteCategories = 'receituagro_favorite_categories';
    static const String offlinePlants = 'receituagro_offline_plants';
    static const String offlineRecipes = 'receituagro_offline_recipes';
    static const String syncStatus = 'receituagro_sync_status';
  }
