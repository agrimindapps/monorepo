import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Providers comuns reutilizáveis entre todos os apps do monorepo
/// Centraliza o state management para consistência arquitetural

/// Provider para SharedPreferences - singleton global
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app startup');
});

/// Provider para Connectivity - stream de status de conexão
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider para status de conectividade atual (boolean simplificado)
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.when(
    data: (connectivity) => connectivity.any((c) => c != ConnectivityResult.none),
    loading: () => true, // Assume conectado durante loading
    error: (_, stackTrace) => false,
  );
});

/// Provider para configurações globais do app
final appConfigProvider = StateProvider<Map<String, dynamic>>((ref) {
  return <String, dynamic>{};
});

/// Provider para tema atual (dark/light mode)
final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Provider para locale/idioma atual
final localeProvider = StateProvider<String>((ref) {
  return 'pt_BR';
});

/// Provider para loading states globais
final globalLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider para mensagens de erro globais
final globalErrorProvider = StateProvider<String?>((ref) {
  return null;
});

/// Provider para notificações/snackbars globais
final globalNotificationProvider = StateProvider<String?>((ref) {
  return null;
});

/// Provider base para estado de autenticação
/// Apps devem override este provider com sua implementação específica
final authStateProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider para usuário atual
/// Apps devem override com sua implementação específica
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});

/// Provider para timestamp atual (auto-refresh)
final timestampProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

/// Provider para UUID generator
final uuidProvider = Provider<String>((ref) {
  return DateTime.now().millisecondsSinceEpoch.toString();
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

/// Provider para logs de debug
final debugLogsProvider = StateNotifierProvider<DebugLogsNotifier, List<String>>((ref) {
  return DebugLogsNotifier();
});

/// Notifier para gerenciar logs de debug
class DebugLogsNotifier extends StateNotifier<List<String>> {
  DebugLogsNotifier() : super([]);
  
  void addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    state = [...state, '[$timestamp] $message'];
    if (state.length > 100) {
      state = state.sublist(state.length - 100);
    }
  }
  
  void clearLogs() {
    state = [];
  }
}

/// Provider para métricas de performance
final performanceMetricsProvider = StateProvider<Map<String, dynamic>>((ref) {
  return <String, dynamic>{
    'app_startup_time': 0,
    'last_sync_duration': 0,
    'memory_usage': 0,
  };
});

/// Provider para cache global de dados
final globalCacheProvider = StateProvider<Map<String, dynamic>>((ref) {
  return <String, dynamic>{};
});

/// Provider para estado de sincronização global
final syncStateProvider = StateProvider<SyncState>((ref) {
  return SyncState.idle;
});

/// Estados possíveis de sincronização
enum SyncState {
  idle,
  syncing,
  completed,
  error,
}

/// Provider para progresso de sincronização (0.0 a 1.0)
final syncProgressProvider = StateProvider<double>((ref) {
  return 0.0;
});

/// Provider para última sincronização
final lastSyncProvider = StateProvider<DateTime?>((ref) {
  return null;
});

/// Family provider para cache por chave
final cacheByKeyProvider = StateProvider.family<dynamic, String>((ref, key) {
  return null;
});

/// Family provider para loading state por feature
final loadingByFeatureProvider = StateProvider.family<bool, String>((ref, feature) {
  return false;
});

/// Family provider para erro por feature
final errorByFeatureProvider = StateProvider.family<String?, String>((ref, feature) {
  return null;
});

/// Provider derivado que combina estado de conectividade e sincronização
final canSyncProvider = Provider<bool>((ref) {
  final isConnected = ref.watch(isConnectedProvider);
  final syncState = ref.watch(syncStateProvider);
  
  return isConnected && syncState != SyncState.syncing;
});

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

/// Estados possíveis do app
enum AppStatus {
  loading,
  ready,
  error,
  offline,
  unauthenticated,
}
