import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Providers comuns reutilizáveis entre todos os apps do monorepo
/// Centraliza o state management para consistência arquitetural
/// Migrado para Riverpod 3.0 - sem StateNotifier/StateProvider (legacy)

/// Provider para SharedPreferences - singleton global
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be overridden at app startup');
});

/// Provider para Connectivity - stream de status de conexão
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider para status de conectividade atual (boolean simplificado)
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.when(
    data: (connectivity) =>
        connectivity.any((c) => c != ConnectivityResult.none),
    loading: () => true, // Assume conectado durante loading
    error: (_, stackTrace) => false,
  );
});

// ============================================================================
// Notifiers para estados mutáveis - Riverpod 3.0 API
// ============================================================================

/// Notifier para configurações globais do app
class AppConfigNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => <String, dynamic>{};

  void update(Map<String, dynamic> config) => state = {...state, ...config};
  void set(String key, dynamic value) => state = {...state, key: value};
  void remove(String key) {
    final newState = Map<String, dynamic>.from(state);
    newState.remove(key);
    state = newState;
  }

  void clear() => state = <String, dynamic>{};
}

final appConfigProvider =
    NotifierProvider<AppConfigNotifier, Map<String, dynamic>>(
  AppConfigNotifier.new,
);

/// Notifier para tema atual (dark/light mode)
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

/// Notifier para locale/idioma atual
class LocaleNotifier extends Notifier<String> {
  @override
  String build() => 'pt_BR';

  void setLocale(String locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);

/// Notifier para loading states globais
class GlobalLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool loading) => state = loading;
  void startLoading() => state = true;
  void stopLoading() => state = false;
}

final globalLoadingProvider = NotifierProvider<GlobalLoadingNotifier, bool>(
  GlobalLoadingNotifier.new,
);

/// Notifier para mensagens de erro globais
class GlobalErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setError(String? error) => state = error;
  void clearError() => state = null;
}

final globalErrorProvider = NotifierProvider<GlobalErrorNotifier, String?>(
  GlobalErrorNotifier.new,
);

/// Notifier para notificações/snackbars globais
class GlobalNotificationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void notify(String message) => state = message;
  void clearNotification() => state = null;
}

final globalNotificationProvider =
    NotifierProvider<GlobalNotificationNotifier, String?>(
  GlobalNotificationNotifier.new,
);

/// Notifier para estado de autenticação
class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setAuthenticated(bool authenticated) => state = authenticated;
  void login() => state = true;
  void logout() => state = false;
}

final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);

/// Notifier para usuário atual
class CurrentUserNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void setUser(Map<String, dynamic>? user) => state = user;
  void updateUser(Map<String, dynamic> updates) {
    if (state != null) {
      state = {...state!, ...updates};
    }
  }

  void clearUser() => state = null;
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, Map<String, dynamic>?>(
  CurrentUserNotifier.new,
);

/// Provider para timestamp atual (auto-refresh)
final timestampProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

/// Provider para mode debug (apenas em desenvolvimento)
final debugModeProvider = Provider<bool>((ref) {
  bool debugMode = false;
  assert(() {
    debugMode = true;
    return true;
  }());
  return debugMode;
});

/// Notifier para logs de debug
class DebugLogsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    state = [...state, '[$timestamp] $message'];
    if (state.length > 100) {
      state = state.sublist(state.length - 100);
    }
  }

  void clearLogs() => state = [];
}

final debugLogsProvider = NotifierProvider<DebugLogsNotifier, List<String>>(
  DebugLogsNotifier.new,
);

/// Notifier para métricas de performance
class PerformanceMetricsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => <String, dynamic>{
        'app_startup_time': 0,
        'last_sync_duration': 0,
        'memory_usage': 0,
      };

  void updateMetric(String key, dynamic value) =>
      state = {...state, key: value};
  void updateMetrics(Map<String, dynamic> metrics) =>
      state = {...state, ...metrics};
}

final performanceMetricsProvider =
    NotifierProvider<PerformanceMetricsNotifier, Map<String, dynamic>>(
  PerformanceMetricsNotifier.new,
);

/// Notifier para cache global de dados
class GlobalCacheNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => <String, dynamic>{};

  void put(String key, dynamic value) => state = {...state, key: value};
  dynamic get(String key) => state[key];
  void remove(String key) {
    final newState = Map<String, dynamic>.from(state);
    newState.remove(key);
    state = newState;
  }

  void clear() => state = <String, dynamic>{};
  bool has(String key) => state.containsKey(key);
}

final globalCacheProvider =
    NotifierProvider<GlobalCacheNotifier, Map<String, dynamic>>(
  GlobalCacheNotifier.new,
);

/// Estados possíveis de sincronização
enum SyncState {
  idle,
  syncing,
  completed,
  error,
}

/// Notifier para estado de sincronização global
class SyncStateNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.idle;

  void setSyncState(SyncState syncState) => state = syncState;
  void startSyncing() => state = SyncState.syncing;
  void complete() => state = SyncState.completed;
  void fail() => state = SyncState.error;
  void reset() => state = SyncState.idle;
}

final syncStateProvider = NotifierProvider<SyncStateNotifier, SyncState>(
  SyncStateNotifier.new,
);

/// Notifier para progresso de sincronização (0.0 a 1.0)
class SyncProgressNotifier extends Notifier<double> {
  @override
  double build() => 0.0;

  void setProgress(double progress) => state = progress.clamp(0.0, 1.0);
  void reset() => state = 0.0;
}

final syncProgressProvider = NotifierProvider<SyncProgressNotifier, double>(
  SyncProgressNotifier.new,
);

/// Notifier para última sincronização
class LastSyncNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setLastSync(DateTime? timestamp) => state = timestamp;
  void updateNow() => state = DateTime.now();
  void clear() => state = null;
}

final lastSyncProvider = NotifierProvider<LastSyncNotifier, DateTime?>(
  LastSyncNotifier.new,
);

// ============================================================================
// Family providers para estados por chave/feature
// ============================================================================

/// Family provider para cache por chave
final cacheByKeyProvider = Provider.family<dynamic, String>((ref, key) {
  return ref.watch(globalCacheProvider)[key];
});

/// Family provider para loading state por feature
/// Uso: ref.watch(loadingByFeatureProvider('featureName'))
/// Para alterar: ref.read(loadingByFeatureNotifierProvider('featureName').notifier).setLoading(true)
class _LoadingByFeatureNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};

  void setLoading(String feature, bool loading) {
    state = {...state, feature: loading};
  }

  bool isLoading(String feature) => state[feature] ?? false;

  void start(String feature) => setLoading(feature, true);
  void stop(String feature) => setLoading(feature, false);
}

final _loadingByFeatureNotifierProvider =
    NotifierProvider<_LoadingByFeatureNotifier, Map<String, bool>>(
  _LoadingByFeatureNotifier.new,
);

/// Provider para verificar loading de uma feature específica
final loadingByFeatureProvider = Provider.family<bool, String>((ref, feature) {
  return ref.watch(_loadingByFeatureNotifierProvider)[feature] ?? false;
});

/// Family provider para erro por feature
class _ErrorByFeatureNotifier extends Notifier<Map<String, String?>> {
  @override
  Map<String, String?> build() => {};

  void setError(String feature, String? error) {
    state = {...state, feature: error};
  }

  String? getError(String feature) => state[feature];

  void clear(String feature) => setError(feature, null);
  void clearAll() => state = {};
}

final _errorByFeatureNotifierProvider =
    NotifierProvider<_ErrorByFeatureNotifier, Map<String, String?>>(
  _ErrorByFeatureNotifier.new,
);

/// Provider para verificar erro de uma feature específica
final errorByFeatureProvider = Provider.family<String?, String>((ref, feature) {
  return ref.watch(_errorByFeatureNotifierProvider)[feature];
});

// ============================================================================
// Providers derivados
// ============================================================================

/// Provider derivado que combina estado de conectividade e sincronização
final canSyncProvider = Provider<bool>((ref) {
  final isConnected = ref.watch(isConnectedProvider);
  final syncState = ref.watch(syncStateProvider);

  return isConnected && syncState != SyncState.syncing;
});

/// Estados possíveis do app
enum AppStatus {
  loading,
  ready,
  error,
  offline,
  unauthenticated,
}

/// Provider derivado para status geral do app
final appStatusProvider = Provider<AppStatus>((ref) {
  final isConnected = ref.watch(isConnectedProvider);
  final isLoading = ref.watch(globalLoadingProvider);
  final hasError = ref.watch(globalErrorProvider) != null;
  final isAuthenticated = ref.watch(authStateProvider);

  if (!isAuthenticated) return AppStatus.unauthenticated;
  if (hasError) return AppStatus.error;
  if (isLoading) return AppStatus.loading;
  if (!isConnected) return AppStatus.offline;

  return AppStatus.ready;
});
