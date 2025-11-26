import 'package:core/core.dart'
    hide
        NotificationSettings,
        SubscriptionEntity,
        SubscriptionTier,
        Provider,
        Consumer,
        ProviderContainer,
        PrivacySettings;
import 'package:flutter_riverpod/legacy.dart';

// import '../../core/di/injection_container.dart' as di; // Commented out - migrating to Riverpod
import '../../features/markets/domain/entities/market_entity.dart';
import '../../features/markets/domain/entities/market_filter_entity.dart';
import '../../features/markets/domain/repositories/market_repository.dart';
import '../../features/markets/domain/usecases/get_market_summary.dart'
    as market_summary;
import '../../features/markets/domain/usecases/get_markets.dart';
import '../../features/news/domain/entities/commodity_price_entity.dart';
import '../../features/news/domain/entities/news_article_entity.dart';
import '../../features/news/domain/usecases/get_commodity_prices.dart';
import '../../features/news/domain/usecases/get_news.dart';
import '../../features/settings/domain/entities/settings_entity.dart';
import '../../features/settings/domain/usecases/manage_settings.dart';

/// State para gerenciamento de configurações
class SettingsState {
  const SettingsState({
    this.settings,
    this.isLoadingSettings = false,
    this.isSavingSettings = false,
    this.errorMessage,
    this.successMessage,
  });

  final SettingsEntity? settings;
  final bool isLoadingSettings;
  final bool isSavingSettings;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isInitialized => settings != null;
  AppTheme get theme => settings?.theme ?? AppTheme.system;
  String get language => settings?.language ?? 'pt_BR';
  NotificationSettings get notifications =>
      settings?.notifications ?? const NotificationSettings();
  bool get pushNotificationsEnabled => notifications.pushNotifications;
  bool get newsNotificationsEnabled => notifications.newsNotifications;
  bool get marketAlertsEnabled => notifications.marketAlerts;
  bool get weatherAlertsEnabled => notifications.weatherAlerts;
  DataSettings get dataSettings =>
      settings?.dataSettings ?? const DataSettings();
  bool get autoSyncEnabled => dataSettings.autoSync;
  bool get wifiOnlySyncEnabled => dataSettings.wifiOnlySync;
  bool get cacheImagesEnabled => dataSettings.cacheImages;
  DataExportFormat get exportFormat => dataSettings.exportFormat;
  PrivacySettings get privacy => settings?.privacy ?? const PrivacySettings();
  bool get analyticsEnabled => privacy.analyticsEnabled;
  bool get crashReportingEnabled => privacy.crashReportingEnabled;
  bool get shareUsageDataEnabled => privacy.shareUsageData;
  DisplaySettings get display => settings?.display ?? const DisplaySettings();
  double get fontSize => display.fontSize;
  bool get highContrastEnabled => display.highContrast;
  bool get animationsEnabled => display.animations;
  String get dateFormat => display.dateFormat;
  String get currency => display.currency;
  String get unitSystem => display.unitSystem;
  SecuritySettings get security =>
      settings?.security ?? const SecuritySettings();
  bool get biometricAuthEnabled => security.biometricAuth;
  bool get requireAuthOnOpenEnabled => security.requireAuthOnOpen;
  int get autoLockMinutes => security.autoLockMinutes;
  BackupSettings get backup => settings?.backup ?? const BackupSettings();
  bool get autoBackupEnabled => backup.autoBackup;
  BackupFrequency get backupFrequency => backup.frequency;
  bool get includeImagesInBackup => backup.includeImages;
  BackupStorage get backupStorage => backup.storage;

  SettingsState copyWith({
    SettingsEntity? settings,
    bool? isLoadingSettings,
    bool? isSavingSettings,
    String? errorMessage,
    String? successMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoadingSettings: isLoadingSettings ?? this.isLoadingSettings,
      isSavingSettings: isSavingSettings ?? this.isSavingSettings,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// State para gerenciamento de mercados
class MarketState {
  const MarketState({
    this.markets = const [],
    this.favoriteMarkets = const [],
    this.searchResults = const [],
    this.topGainers = const [],
    this.topLosers = const [],
    this.mostActive = const [],
    this.marketSummary,
    this.isLoadingMarkets = false,
    this.isLoadingSummary = false,
    this.isLoadingFavorites = false,
    this.isLoadingSearch = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.currentFilter = const MarketFilter(),
    this.currentSearchQuery = '',
    this.lastUpdate,
    this.searchHistory = const [],
  });

  final List<MarketEntity> markets;
  final List<MarketEntity> favoriteMarkets;
  final List<MarketEntity> searchResults;
  final List<MarketEntity> topGainers;
  final List<MarketEntity> topLosers;
  final List<MarketEntity> mostActive;
  final dynamic marketSummary;
  final bool isLoadingMarkets;
  final bool isLoadingSummary;
  final bool isLoadingFavorites;
  final bool isLoadingSearch;
  final bool isRefreshing;
  final String? errorMessage;
  final MarketFilter currentFilter;
  final String currentSearchQuery;
  final DateTime? lastUpdate;
  final List<String> searchHistory;

  bool get hasError => errorMessage != null;
  bool get hasData => markets.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;

  MarketState copyWith({
    List<MarketEntity>? markets,
    List<MarketEntity>? favoriteMarkets,
    List<MarketEntity>? searchResults,
    List<MarketEntity>? topGainers,
    List<MarketEntity>? topLosers,
    List<MarketEntity>? mostActive,
    dynamic marketSummary,
    bool? isLoadingMarkets,
    bool? isLoadingSummary,
    bool? isLoadingFavorites,
    bool? isLoadingSearch,
    bool? isRefreshing,
    String? errorMessage,
    MarketFilter? currentFilter,
    String? currentSearchQuery,
    DateTime? lastUpdate,
    List<String>? searchHistory,
  }) {
    return MarketState(
      markets: markets ?? this.markets,
      favoriteMarkets: favoriteMarkets ?? this.favoriteMarkets,
      searchResults: searchResults ?? this.searchResults,
      topGainers: topGainers ?? this.topGainers,
      topLosers: topLosers ?? this.topLosers,
      mostActive: mostActive ?? this.mostActive,
      marketSummary: marketSummary ?? this.marketSummary,
      isLoadingMarkets: isLoadingMarkets ?? this.isLoadingMarkets,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage ?? this.errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}

/// State para gerenciamento de notícias
class NewsState {
  const NewsState({
    this.articles = const [],
    this.premiumArticles = const [],
    this.favoriteArticles = const [],
    this.searchResults = const [],
    this.commodityPrices = const [],
    this.marketSummary,
    this.isLoadingNews = false,
    this.isLoadingPremium = false,
    this.isLoadingCommodities = false,
    this.isRefreshing = false,
    this.isSearching = false,
    this.errorMessage,
    this.currentCategory = NewsCategory.crops,
    this.currentSearchQuery = '',
    this.lastUpdate,
    this.searchHistory = const [],
  });

  final List<NewsArticleEntity> articles;
  final List<NewsArticleEntity> premiumArticles;
  final List<NewsArticleEntity> favoriteArticles;
  final List<NewsArticleEntity> searchResults;
  final List<CommodityPriceEntity> commodityPrices;
  final dynamic marketSummary;
  final bool isLoadingNews;
  final bool isLoadingPremium;
  final bool isLoadingCommodities;
  final bool isRefreshing;
  final bool isSearching;
  final String? errorMessage;
  final NewsCategory currentCategory;
  final String currentSearchQuery;
  final DateTime? lastUpdate;
  final List<String> searchHistory;

  bool get hasError => errorMessage != null;
  bool get hasArticles => articles.isNotEmpty;
  bool get hasPremiumArticles => premiumArticles.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;
  bool get hasCommodityPrices => commodityPrices.isNotEmpty;

  NewsState copyWith({
    List<NewsArticleEntity>? articles,
    List<NewsArticleEntity>? premiumArticles,
    List<NewsArticleEntity>? favoriteArticles,
    List<NewsArticleEntity>? searchResults,
    List<CommodityPriceEntity>? commodityPrices,
    dynamic marketSummary,
    bool? isLoadingNews,
    bool? isLoadingPremium,
    bool? isLoadingCommodities,
    bool? isRefreshing,
    bool? isSearching,
    String? errorMessage,
    NewsCategory? currentCategory,
    String? currentSearchQuery,
    DateTime? lastUpdate,
    List<String>? searchHistory,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      premiumArticles: premiumArticles ?? this.premiumArticles,
      favoriteArticles: favoriteArticles ?? this.favoriteArticles,
      searchResults: searchResults ?? this.searchResults,
      commodityPrices: commodityPrices ?? this.commodityPrices,
      marketSummary: marketSummary ?? this.marketSummary,
      isLoadingNews: isLoadingNews ?? this.isLoadingNews,
      isLoadingPremium: isLoadingPremium ?? this.isLoadingPremium,
      isLoadingCommodities: isLoadingCommodities ?? this.isLoadingCommodities,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
      currentCategory: currentCategory ?? this.currentCategory,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}
/*
/// State para gerenciamento de assinaturas
class SubscriptionState {
  const SubscriptionState({
    this.currentSubscription,
    this.availableTiers = const [],
    this.paymentMethods = const [],
    this.isLoadingSubscription = false,
    this.isProcessingPayment = false,
    this.isUpdatingSubscription = false,
    this.errorMessage,
    this.successMessage,
  });

  final SubscriptionEntity? currentSubscription;
  final List<SubscriptionTier> availableTiers;
  final List<PaymentMethod> paymentMethods;
  final bool isLoadingSubscription;
  final bool isProcessingPayment;
  final bool isUpdatingSubscription;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasActiveSubscription => currentSubscription?.isActive ?? false;
  bool get isPremiumUser => currentSubscription?.tier != null;
  bool get isAnyOperationInProgress => isLoadingSubscription || isProcessingPayment || isUpdatingSubscription;

  SubscriptionState copyWith({
    SubscriptionEntity? currentSubscription,
    List<SubscriptionTier>? availableTiers,
    List<PaymentMethod>? paymentMethods,
    bool? isLoadingSubscription,
    bool? isProcessingPayment,
    bool? isUpdatingSubscription,
    String? errorMessage,
    String? successMessage,
  }) {
    return SubscriptionState(
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availableTiers: availableTiers ?? this.availableTiers,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoadingSubscription: isLoadingSubscription ?? this.isLoadingSubscription,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      isUpdatingSubscription: isUpdatingSubscription ?? this.isUpdatingSubscription,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
*/

/// StateNotifier para gerenciamento de configurações
class SettingsStateNotifier extends StateNotifier<SettingsState> {
  SettingsStateNotifier(this._manageSettings) : super(const SettingsState());

  final ManageSettings _manageSettings;

  /// Carrega configurações
  Future<void> loadSettings() async {
    state = state.copyWith(isLoadingSettings: true, errorMessage: null);

    final result = await _manageSettings.getSettings();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingSettings: false,
        errorMessage: 'Erro ao carregar configurações: ${failure.message}',
      ),
      (settings) =>
          state = state.copyWith(isLoadingSettings: false, settings: settings),
    );
  }

  /// Salva configurações
  Future<bool> saveSettings(SettingsEntity newSettings) async {
    state = state.copyWith(isSavingSettings: true, errorMessage: null);

    final result = await _manageSettings.updateSettings(newSettings);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSavingSettings: false,
          errorMessage: 'Erro ao salvar configurações: ${failure.message}',
        );
        return false;
      },
      (settings) {
        state = state.copyWith(
          isSavingSettings: false,
          settings: settings,
          successMessage: 'Configurações salvas com sucesso!',
        );
        return true;
      },
    );
  }

  /// Reset para configurações padrão
  Future<bool> resetToDefaults() async {
    state = state.copyWith(isSavingSettings: true, errorMessage: null);

    final result = await _manageSettings.resetToDefaults();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSavingSettings: false,
          errorMessage: 'Erro ao resetar configurações: ${failure.message}',
        );
        return false;
      },
      (settings) {
        state = state.copyWith(
          isSavingSettings: false,
          settings: settings,
          successMessage: 'Configurações resetadas para o padrão',
        );
        return true;
      },
    );
  }

  /// Atualiza tema
  Future<bool> updateTheme(AppTheme newTheme) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      theme: newTheme,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Atualiza idioma
  Future<bool> updateLanguage(String newLanguage) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      language: newLanguage,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Atualiza configurações de notificação
  Future<bool> updateNotificationSettings(
    NotificationSettings newNotifications,
  ) async {
    if (state.settings == null) return false;

    final updatedSettings = state.settings!.copyWith(
      notifications: newNotifications,
      lastUpdated: DateTime.now(),
    );

    return await saveSettings(updatedSettings);
  }

  /// Inicializa provider
  Future<void> initialize() async {
    await loadSettings();
  }

  /// Limpa mensagens
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// StateNotifier para gerenciamento de mercados
class MarketStateNotifier extends StateNotifier<MarketState> {
  MarketStateNotifier(
    this._getMarkets,
    this._getMarketSummary,
    this._repository,
  ) : super(const MarketState());

  final GetMarkets _getMarkets;
  final market_summary.GetMarketSummary _getMarketSummary;
  final MarketRepository _repository;

  /// Carrega mercados
  Future<void> loadMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
    bool refresh = false,
  }) async {
    if (state.isLoadingMarkets && !refresh) return;

    state = state.copyWith(isLoadingMarkets: true, errorMessage: null);

    final result = await _getMarkets(
      filter: filter,
      limit: limit,
      offset: offset,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMarkets: false,
        errorMessage: failure.message,
      ),
      (markets) => state = state.copyWith(
        isLoadingMarkets: false,
        markets: markets,
        currentFilter: filter ?? state.currentFilter,
        lastUpdate: DateTime.now(),
      ),
    );
  }

  /// Carrega resumo do mercado
  Future<void> loadMarketSummary() async {
    state = state.copyWith(isLoadingSummary: true);

    final result = await _getMarketSummary();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingSummary: false,
        errorMessage: failure.message,
      ),
      (summary) => state = state.copyWith(
        isLoadingSummary: false,
        marketSummary: summary,
      ),
    );
  }

  /// Busca mercados
  Future<void> searchMarkets(String query) async {
    state = state.copyWith(isLoadingSearch: true, currentSearchQuery: query);

    final result = await _repository.searchMarkets(query: query);

    result.fold(
      (Failure failure) => state = state.copyWith(
        isLoadingSearch: false,
        errorMessage: failure.message,
      ),
      (List<MarketEntity> results) {
        final updatedHistory = List<String>.from(state.searchHistory);
        if (!updatedHistory.contains(query)) {
          updatedHistory.insert(0, query);
          if (updatedHistory.length > 10) {
            updatedHistory.removeLast();
          }
        }

        state = state.copyWith(
          isLoadingSearch: false,
          searchResults: results,
          searchHistory: updatedHistory,
        );
      },
    );
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// StateNotifier para gerenciamento de notícias
class NewsStateNotifier extends StateNotifier<NewsState> {
  NewsStateNotifier(this._getNews, this._getCommodityPrices)
      : super(const NewsState());

  final GetNews _getNews;
  final GetCommodityPrices _getCommodityPrices;

  /// Carrega notícias
  Future<void> loadNews({
    NewsCategory category = NewsCategory.crops,
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async {
    if (state.isLoadingNews && !refresh) return;

    state = state.copyWith(isLoadingNews: true, errorMessage: null);

    final result = await _getNews(
      filter: NewsFilter(categories: [category]),
      limit: limit,
      offset: offset,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingNews: false,
        errorMessage: failure.message,
      ),
      (articles) => state = state.copyWith(
        isLoadingNews: false,
        articles: articles,
        currentCategory: category,
        lastUpdate: DateTime.now(),
      ),
    );
  }

  /// Carrega preços de commodities
  Future<void> loadCommodityPrices() async {
    state = state.copyWith(isLoadingCommodities: true);

    final result = await _getCommodityPrices();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingCommodities: false,
        errorMessage: failure.message,
      ),
      (prices) => state = state.copyWith(
        isLoadingCommodities: false,
        commodityPrices: prices,
      ),
    );
  }

  /// Busca artigos
  Future<void> searchArticles(String query) async {
    state = state.copyWith(isSearching: true, currentSearchQuery: query);
    final updatedHistory = List<String>.from(state.searchHistory);
    if (!updatedHistory.contains(query)) {
      updatedHistory.insert(0, query);
      if (updatedHistory.length > 10) {
        updatedHistory.removeLast();
      }
    }

    state = state.copyWith(
      isSearching: false,
      searchResults: [],
      searchHistory: updatedHistory,
    );
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
/*
/// StateNotifier para gerenciamento de assinaturas
class SubscriptionStateNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionStateNotifier(
    this._manageSubscription,
  ) : super(const SubscriptionState());

  final ManageSubscription _manageSubscription;

  /// Carrega assinatura atual
  Future<void> loadCurrentSubscription() async {
    state = state.copyWith(isLoadingSubscription: true, errorMessage: null);

    final result = await _manageSubscription.getCurrentSubscription();

    result.fold(
      (dynamic failure) => state = state.copyWith(
        isLoadingSubscription: false,
        errorMessage: failure.message,
      ),
      (dynamic subscription) => state = state.copyWith(
        isLoadingSubscription: false,
        currentSubscription: subscription,
      ),
    );
  }

  /// Carrega métodos de pagamento
  Future<void> loadPaymentMethods() async {
    state = state.copyWith(paymentMethods: []);
  }

  /// Processa pagamento
  Future<bool> processPayment(String paymentMethodId, SubscriptionTier tier) async {
    state = state.copyWith(isProcessingPayment: true, errorMessage: null);

    final result = await _manageSubscription.purchaseSubscription(
      tier: tier,
      paymentMethodId: paymentMethodId,
    );

    return result.fold(
      (dynamic failure) {
        state = state.copyWith(
          isProcessingPayment: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (dynamic subscription) {
        state = state.copyWith(
          isProcessingPayment: false,
          currentSubscription: subscription,
          successMessage: 'Assinatura ativada com sucesso!',
        );
        return true;
      },
    );
  }

  /// Cancela assinatura
  Future<bool> cancelSubscription() async {
    state = state.copyWith(isUpdatingSubscription: true, errorMessage: null);

    final result = await _manageSubscription.cancelSubscription();

    return result.fold(
      (dynamic failure) {
        state = state.copyWith(
          isUpdatingSubscription: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isUpdatingSubscription: false,
          currentSubscription: null,
          successMessage: 'Assinatura cancelada com sucesso',
        );
        return true;
      },
    );
  }

  /// Limpa mensagens
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
*/

/// Provider para gerenciamento de configurações
// TODO: Replace getIt calls with Riverpod providers - commented out temporarily
/*
final settingsProvider =
    StateNotifierProvider<SettingsStateNotifier, SettingsState>((ref) {
      return SettingsStateNotifier(null); // Temporarily pass null
    });

/// Provider para gerenciamento de mercados
final marketProvider = StateNotifierProvider<MarketStateNotifier, MarketState>((
  ref,
) {
  return MarketStateNotifier(
    null, // Temporarily pass null
    null, // Temporarily pass null
  );
});

/// Provider para gerenciamento de notícias
final newsProvider = StateNotifierProvider<NewsStateNotifier, NewsState>((ref) {
  return NewsStateNotifier(null, null); // Temporarily pass null
});
*/
/*
/// Provider para gerenciamento de assinaturas
final subscriptionProvider = StateNotifierProvider<SubscriptionStateNotifier, SubscriptionState>((ref) {
  return SubscriptionStateNotifier(
    di.getIt<ManageSubscription>(),
  );
});
*/

/*
/// Provider para configurações atuais
final currentSettingsProvider = Provider<SettingsEntity?>((ref) {
  final state = ref.watch(settingsProvider);
  return state.settings;
});

/// Provider para tema atual
final currentThemeProvider = Provider<AppTheme>((ref) {
  final state = ref.watch(settingsProvider);
  return state.theme;
});

/// Provider para mercados carregados
final loadedMarketsProvider = Provider<List<MarketEntity>>((ref) {
  final state = ref.watch(marketProvider);
  return state.markets;
});

/// Provider para artigos carregados
final loadedArticlesProvider = Provider<List<NewsArticleEntity>>((ref) {
  final state = ref.watch(newsProvider);
  return state.articles;
});
*/
/*
/// Provider para assinatura ativa
final activeSubscriptionProvider = Provider<SubscriptionEntity?>((ref) {
  final state = ref.watch(subscriptionProvider);
  return state.currentSubscription;
});

/// Provider para status premium
final isPremiumUserProvider = Provider<bool>((ref) {
  final state = ref.watch(subscriptionProvider);
  return state.isPremiumUser;
});
*/
