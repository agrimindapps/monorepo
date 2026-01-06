import 'package:core/core.dart';

/// Providers unificados para sincronização e conectividade
/// Consolidam offline/online sync entre todos os apps do monorepo
/// Migrado para Riverpod 3.0 - sem legacy imports

/// Provider para stream de conectividade
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((list) => list.first);
});

/// Provider para status atual de conectividade
final connectivityStatusProvider = Provider<ConnectivityResult>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  return connectivityAsync.when(
    data: (status) => status,
    loading: () => ConnectivityResult.none,
    error: (_, __) => ConnectivityResult.none,
  );
});

/// Provider simplificado para verificar se está conectado
final isConnectedProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider);
  return status != ConnectivityResult.none;
});

/// Provider para tipo de conexão detalhado
final connectionTypeProvider = Provider<ConnectionType>((ref) {
  final status = ref.watch(connectivityStatusProvider);
  switch (status) {
    case ConnectivityResult.wifi:
      return ConnectionType.wifi;
    case ConnectivityResult.mobile:
      return ConnectionType.cellular;
    case ConnectivityResult.ethernet:
      return ConnectionType.ethernet;
    default:
      return ConnectionType.none;
  }
});

/// Provider principal para estado de sincronização - Riverpod 3.0
final syncStateProvider =
    NotifierProvider<OfflineSyncStateNotifier, OfflineSyncState>(
      OfflineSyncStateNotifier.new,
    );

/// Provider para verificar se está sincronizando
final isSyncingProvider = Provider<bool>((ref) {
  final syncState = ref.watch(syncStateProvider);
  return syncState.maybeWhen(
    syncing: (progress, message) => true,
    orElse: () => false,
  );
});

/// Provider para última sincronização
final lastSyncProvider = Provider<DateTime?>((ref) {
  final syncState = ref.watch(syncStateProvider);
  return syncState.maybeWhen(
    success: (info) => info.lastSync,
    partial: (info) => info.lastSync,
    orElse: () => null,
  );
});

/// Provider para contagem de itens pendentes
final pendingItemsCountProvider = Provider<int>((ref) {
  final syncState = ref.watch(syncStateProvider);
  return syncState.maybeWhen(
    partial: (info) => info.pendingItems,
    failed: (info) => info.pendingItems,
    orElse: () => 0,
  );
});

/// Provider para sincronização específica por app - Riverpod 3.0 usando Map interno
final _appSyncNotifierProvider =
    NotifierProvider<_AppSyncMapNotifier, Map<String, AppOfflineSyncState>>(
      _AppSyncMapNotifier.new,
    );

/// Provider derivado para estado de sync de um app específico
final appSyncProvider = Provider.family<AppOfflineSyncState, String>((ref, appId) {
  return ref.watch(_appSyncNotifierProvider)[appId] ?? const AppSyncIdle();
});

/// Provider para ações de sync de um app específico
final appSyncActionsProvider = Provider.family<AppSyncActions, String>((ref, appId) {
  final notifier = ref.read(_appSyncNotifierProvider.notifier);
  return AppSyncActions(
    startSync: () => notifier.startSync(appId),
    markNeedsSync: () => notifier.markNeedsSync(appId),
  );
});

/// Provider para verificar se app específico precisa sincronizar
final needsSyncProvider = Provider.family<bool, String>((ref, appId) {
  final isConnected = ref.watch(isConnectedProvider);
  final appSync = ref.watch(appSyncProvider(appId));
  final lastSync = ref.watch(lastSyncProvider);

  if (!isConnected) return false;

  return appSync.maybeWhen(
    needsSync: () => true,
    orElse: () => _shouldSync(lastSync),
  );
});

/// Provider para limitações de sync baseadas em premium
final syncLimitsProvider = Provider.family<SyncLimits, String>((ref, appId) {
  ref.watch(domainCurrentUserProvider);
  final isPremium = ref.watch(isPremiumProvider);

  return SyncLimits.forApp(appId, isPremium);
});

/// Provider para capacidades offline por app
final offlineCapabilitiesProvider =
    Provider.family<OfflineCapabilities, String>((ref, appId) {
      return OfflineCapabilities.forApp(appId);
    });

/// Provider para dados offline disponíveis
final offlineDataProvider = FutureProvider.family<OfflineData, String>((
  ref,
  appId,
) async {
  final capabilities = ref.watch(offlineCapabilitiesProvider(appId));
  if (!capabilities.hasOfflineSupport) {
    return OfflineData.empty();
  }
  return OfflineData.empty();
});

/// Provider para tamanho do cache offline
final offlineCacheSizeProvider = FutureProvider.family<int, String>((
  ref,
  appId,
) async {
  return 0;
});

/// Provider para ações de sincronização
final syncActionsProvider = Provider<SyncActions>((ref) {
  final syncNotifier = ref.read(syncStateProvider.notifier);

  return SyncActions(
    startSync: syncNotifier.startSync,
    stopSync: syncNotifier.stopSync,
    forcSync: syncNotifier.forceSync,
    clearOfflineData: syncNotifier.clearOfflineData,
    syncSpecificApp:
        (appId) => ref.read(appSyncActionsProvider(appId)).startSync(),
  );
});

/// Notifier para conflitos de sincronização - Riverpod 3.0
class SyncConflictsNotifier extends Notifier<List<SyncConflict>> {
  @override
  List<SyncConflict> build() => [];

  void addConflict(SyncConflict conflict) {
    state = [...state, conflict];
  }

  void removeConflict(String conflictId) {
    state = state.where((c) => c.id != conflictId).toList();
  }

  void clearAll() {
    state = [];
  }
}

final syncConflictsProvider =
    NotifierProvider<SyncConflictsNotifier, List<SyncConflict>>(
      SyncConflictsNotifier.new,
    );

/// Provider para verificar se há conflitos
final hasSyncConflictsProvider = Provider<bool>((ref) {
  final conflicts = ref.watch(syncConflictsProvider);
  return conflicts.isNotEmpty;
});

/// Provider para ações de resolução de conflitos
final conflictResolutionProvider = Provider<ConflictResolution>((ref) {
  return ConflictResolution(
    resolveWithLocal:
        (conflictId) =>
            _resolveConflict(ref, conflictId, ResolutionType.useLocal),
    resolveWithRemote:
        (conflictId) =>
            _resolveConflict(ref, conflictId, ResolutionType.useRemote),
    resolveWithMerge:
        (conflictId, mergedData) =>
            _resolveConflictWithMerge(ref, conflictId, mergedData),
    resolveAllWithLocal:
        () => _resolveAllConflicts(ref, ResolutionType.useLocal),
    resolveAllWithRemote:
        () => _resolveAllConflicts(ref, ResolutionType.useRemote),
  );
});

/// Notifier para configurações de bandwidth - Riverpod 3.0
class BandwidthConfigNotifier extends Notifier<BandwidthConfig> {
  @override
  BandwidthConfig build() {
    final connectionType = ref.watch(connectionTypeProvider);
    return BandwidthConfig.optimal(connectionType);
  }

  void setConfig(BandwidthConfig config) {
    state = config;
  }
}

final bandwidthConfigProvider =
    NotifierProvider<BandwidthConfigNotifier, BandwidthConfig>(
      BandwidthConfigNotifier.new,
    );

/// Provider para verificar se deve usar modo econômico
final dataEconomyModeProvider = Provider<bool>((ref) {
  final config = ref.watch(bandwidthConfigProvider);
  final connectionType = ref.watch(connectionTypeProvider);

  return config.useDataEconomy || connectionType == ConnectionType.cellular;
});

/// Estados de sincronização
abstract class OfflineSyncState {
  const OfflineSyncState();
}

class SyncIdle extends OfflineSyncState {
  const SyncIdle();
}

class SyncSyncing extends OfflineSyncState {
  final double progress;
  final String? currentItem;

  const SyncSyncing({this.progress = 0.0, this.currentItem});
}

class SyncSuccess extends OfflineSyncState {
  final SyncInfo info;
  const SyncSuccess(this.info);
}

class SyncPartial extends OfflineSyncState {
  final SyncInfo info;
  const SyncPartial(this.info);
}

class SyncFailed extends OfflineSyncState {
  final SyncInfo info;
  const SyncFailed(this.info);
}

extension OfflineSyncStateExtension on OfflineSyncState {
  T when<T>({
    required T Function() idle,
    required T Function(double progress, String? currentItem) syncing,
    required T Function(SyncInfo info) success,
    required T Function(SyncInfo info) partial,
    required T Function(SyncInfo info) failed,
  }) {
    if (this is SyncIdle) return idle();
    if (this is SyncSyncing) {
      final state = this as SyncSyncing;
      return syncing(state.progress, state.currentItem);
    }
    if (this is SyncSuccess) return success((this as SyncSuccess).info);
    if (this is SyncPartial) return partial((this as SyncPartial).info);
    if (this is SyncFailed) return failed((this as SyncFailed).info);
    throw StateError('Unknown state: \$this');
  }

  T maybeWhen<T>({
    T Function()? idle,
    T Function(double progress, String? currentItem)? syncing,
    T Function(SyncInfo info)? success,
    T Function(SyncInfo info)? partial,
    T Function(SyncInfo info)? failed,
    required T Function() orElse,
  }) {
    if (this is SyncIdle && idle != null) return idle();
    if (this is SyncSyncing && syncing != null) {
      final state = this as SyncSyncing;
      return syncing(state.progress, state.currentItem);
    }
    if (this is SyncSuccess && success != null) {
      return success((this as SyncSuccess).info);
    }
    if (this is SyncPartial && partial != null) {
      return partial((this as SyncPartial).info);
    }
    if (this is SyncFailed && failed != null) {
      return failed((this as SyncFailed).info);
    }
    return orElse();
  }
}

/// Estados de sincronização por app
abstract class AppOfflineSyncState {
  const AppOfflineSyncState();
}

class AppSyncIdle extends AppOfflineSyncState {
  const AppSyncIdle();
}

class AppSyncNeedsSync extends AppOfflineSyncState {
  const AppSyncNeedsSync();
}

class AppSyncSyncing extends AppOfflineSyncState {
  const AppSyncSyncing();
}

class AppSyncComplete extends AppOfflineSyncState {
  const AppSyncComplete();
}

extension AppOfflineSyncStateExtension on AppOfflineSyncState {
  T maybeWhen<T>({
    T Function()? idle,
    T Function()? needsSync,
    T Function()? syncing,
    T Function()? complete,
    required T Function() orElse,
  }) {
    if (this is AppSyncIdle && idle != null) return idle();
    if (this is AppSyncNeedsSync && needsSync != null) return needsSync();
    if (this is AppSyncSyncing && syncing != null) return syncing();
    if (this is AppSyncComplete && complete != null) return complete();
    return orElse();
  }
}

/// Informações de sincronização
class SyncInfo {
  final DateTime? lastSync;
  final int totalItems;
  final int syncedItems;
  final int failedItems;
  final int pendingItems;
  final List<String> errors;
  final Duration? syncDuration;

  const SyncInfo({
    this.lastSync,
    this.totalItems = 0,
    this.syncedItems = 0,
    this.failedItems = 0,
    this.pendingItems = 0,
    this.errors = const [],
    this.syncDuration,
  });

  double get progress => totalItems > 0 ? syncedItems / totalItems : 0.0;
  bool get hasErrors => errors.isNotEmpty;
  bool get isComplete => syncedItems == totalItems && failedItems == 0;
}

/// Tipos de conexão
enum ConnectionType { wifi, cellular, ethernet, none }

extension ConnectionTypeExtension on ConnectionType {
  static ConnectionType fromConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.cellular;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.none:
        return ConnectionType.none;
      default:
        return ConnectionType.none;
    }
  }

  bool get isHighBandwidth =>
      this == ConnectionType.wifi || this == ConnectionType.ethernet;
  bool get isLimitedBandwidth => this == ConnectionType.cellular;
}

/// Limitações de sincronização
class SyncLimits {
  final String appId;
  final bool isPremium;
  final int maxOfflineItems;
  final int maxSyncFrequencyMinutes;
  final bool allowBackgroundSync;
  final bool allowLargeFileSync;

  const SyncLimits({
    required this.appId,
    required this.isPremium,
    required this.maxOfflineItems,
    required this.maxSyncFrequencyMinutes,
    required this.allowBackgroundSync,
    required this.allowLargeFileSync,
  });

  factory SyncLimits.forApp(String appId, bool isPremium) {
    final config = SyncConfigRegistry.getSyncLimits(appId, isPremium);
    return SyncLimits(
      appId: config.appId,
      isPremium: isPremium,
      maxOfflineItems: config.maxOfflineItems,
      maxSyncFrequencyMinutes: config.maxSyncFrequencyMinutes,
      allowBackgroundSync: config.allowBackgroundSync,
      allowLargeFileSync: config.allowLargeFileSync,
    );
  }

  bool canSync(DateTime? lastSync) {
    if (lastSync == null) return true;
    final now = DateTime.now();
    final minutesSinceLastSync = now.difference(lastSync).inMinutes;
    return minutesSinceLastSync >= maxSyncFrequencyMinutes;
  }
}

/// Capacidades offline por app
class OfflineCapabilities {
  final String appId;
  final bool hasOfflineSupport;
  final bool canCreateOffline;
  final bool canEditOffline;
  final bool canDeleteOffline;
  final Set<String> offlineFeatures;

  const OfflineCapabilities({
    required this.appId,
    required this.hasOfflineSupport,
    required this.canCreateOffline,
    required this.canEditOffline,
    required this.canDeleteOffline,
    required this.offlineFeatures,
  });

  factory OfflineCapabilities.forApp(String appId) {
    final config = SyncConfigRegistry.getOfflineCapabilities(appId);
    return OfflineCapabilities(
      appId: config.appId,
      hasOfflineSupport: config.hasOfflineSupport,
      canCreateOffline: config.canCreateOffline,
      canEditOffline: config.canEditOffline,
      canDeleteOffline: config.canDeleteOffline,
      offlineFeatures: config.offlineFeatures,
    );
  }

  bool supportsFeature(String feature) => offlineFeatures.contains(feature);
}

/// Dados offline
class OfflineData {
  final String appId;
  final Map<String, dynamic> data;
  final DateTime lastUpdated;
  final int itemCount;

  const OfflineData({
    required this.appId,
    required this.data,
    required this.lastUpdated,
    required this.itemCount,
  });

  factory OfflineData.empty() {
    return OfflineData(
      appId: '',
      data: const {},
      lastUpdated: DateTime.now(),
      itemCount: 0,
    );
  }

  bool get isEmpty => itemCount == 0;
  bool get isStale => DateTime.now().difference(lastUpdated).inHours > 24;
}

/// Conflito de sincronização
class SyncConflict {
  final String id;
  final String itemType;
  final String itemId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime conflictTime;
  final ConflictReason reason;

  const SyncConflict({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.localData,
    required this.remoteData,
    required this.conflictTime,
    required this.reason,
  });
}

enum ConflictReason {
  concurrentModification,
  deletedRemotely,
  deletedLocally,
  schemaChange,
}

enum ResolutionType { useLocal, useRemote, merge }

/// Configuração de bandwidth
class BandwidthConfig {
  final bool useDataEconomy;
  final int maxImageQuality;
  final bool compressUploads;
  final bool limitConcurrentSyncs;
  final int maxConcurrentSyncs;

  const BandwidthConfig({
    required this.useDataEconomy,
    required this.maxImageQuality,
    required this.compressUploads,
    required this.limitConcurrentSyncs,
    required this.maxConcurrentSyncs,
  });

  factory BandwidthConfig.optimal(ConnectionType connectionType) {
    switch (connectionType) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return const BandwidthConfig(
          useDataEconomy: false,
          maxImageQuality: 100,
          compressUploads: false,
          limitConcurrentSyncs: false,
          maxConcurrentSyncs: 5,
        );
      case ConnectionType.cellular:
        return const BandwidthConfig(
          useDataEconomy: true,
          maxImageQuality: 60,
          compressUploads: true,
          limitConcurrentSyncs: true,
          maxConcurrentSyncs: 2,
        );
      case ConnectionType.none:
        return const BandwidthConfig(
          useDataEconomy: true,
          maxImageQuality: 30,
          compressUploads: true,
          limitConcurrentSyncs: true,
          maxConcurrentSyncs: 1,
        );
    }
  }
}

/// Ações de sincronização
class SyncActions {
  final Future<void> Function() startSync;
  final Future<void> Function() stopSync;
  final Future<void> Function() forcSync;
  final Future<void> Function(String appId) clearOfflineData;
  final Future<void> Function(String appId) syncSpecificApp;

  const SyncActions({
    required this.startSync,
    required this.stopSync,
    required this.forcSync,
    required this.clearOfflineData,
    required this.syncSpecificApp,
  });
}

/// Ações de sync por app
class AppSyncActions {
  final Future<void> Function() startSync;
  final void Function() markNeedsSync;

  const AppSyncActions({
    required this.startSync,
    required this.markNeedsSync,
  });
}

/// Resolução de conflitos
class ConflictResolution {
  final Future<void> Function(String conflictId) resolveWithLocal;
  final Future<void> Function(String conflictId) resolveWithRemote;
  final Future<void> Function(
    String conflictId,
    Map<String, dynamic> mergedData,
  )
  resolveWithMerge;
  final Future<void> Function() resolveAllWithLocal;
  final Future<void> Function() resolveAllWithRemote;

  const ConflictResolution({
    required this.resolveWithLocal,
    required this.resolveWithRemote,
    required this.resolveWithMerge,
    required this.resolveAllWithLocal,
    required this.resolveAllWithRemote,
  });
}

/// Notifier para estado de sincronização - Riverpod 3.0
class OfflineSyncStateNotifier extends Notifier<OfflineSyncState> {
  @override
  OfflineSyncState build() => const SyncIdle();

  Future<void> startSync() async {
    if (state is SyncSyncing) return;

    try {
      state = const SyncSyncing();
      for (int i = 0; i <= 100; i += 25) {
        state = SyncSyncing(
          progress: i.toDouble(),
          currentItem: 'Sincronizando item \$i%',
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      state = SyncSuccess(SyncInfo(lastSync: DateTime.now(), errors: []));
    } catch (e) {
      state = SyncFailed(
        SyncInfo(lastSync: DateTime.now(), errors: ['Erro inesperado: \$e']),
      );
    }
  }

  Future<void> stopSync() async {
    if (state is! SyncSyncing) return;
    state = const SyncIdle();
  }

  Future<void> forceSync() async {
    await startSync();
  }

  Future<void> clearOfflineData(String appId) async {
    // Placeholder: should clear app-specific offline data
  }
}

/// Notifier interno para gerenciar map de sincronização por app - Riverpod 3.0
class _AppSyncMapNotifier extends Notifier<Map<String, AppOfflineSyncState>> {
  @override
  Map<String, AppOfflineSyncState> build() => {};

  Future<void> startSync(String appId) async {
    if (state[appId] is AppSyncSyncing) return;

    state = {...state, appId: const AppSyncSyncing()};

    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      state = {...state, appId: const AppSyncComplete()};
    } catch (e) {
      state = {...state, appId: const AppSyncNeedsSync()};
    }
  }

  void markNeedsSync(String appId) {
    if (state[appId] is! AppSyncSyncing) {
      state = {...state, appId: const AppSyncNeedsSync()};
    }
  }
}

bool _shouldSync(DateTime? lastSync) {
  if (lastSync == null) return true;
  final now = DateTime.now();
  final hoursSinceLastSync = now.difference(lastSync).inHours;
  return hoursSinceLastSync >= 1;
}

Future<void> _resolveConflict(
  Ref ref,
  String conflictId,
  ResolutionType type,
) async {
  ref.read(syncConflictsProvider.notifier).removeConflict(conflictId);
}

Future<void> _resolveConflictWithMerge(
  Ref ref,
  String conflictId,
  Map<String, dynamic> mergedData,
) async {
  ref.read(syncConflictsProvider.notifier).removeConflict(conflictId);
}

Future<void> _resolveAllConflicts(Ref ref, ResolutionType type) async {
  ref.read(syncConflictsProvider.notifier).clearAll();
}
