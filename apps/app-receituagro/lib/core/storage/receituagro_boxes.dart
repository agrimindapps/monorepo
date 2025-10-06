import 'package:core/core.dart';

/// Definições de boxes específicas do app ReceitaAgro
/// Cada app gerencia suas próprias boxes para evitar contaminação cross-app
class ReceitaAgroBoxes {
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
