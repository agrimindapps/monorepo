import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/sync_repository_impl.dart';
import '../repositories/user_profile_repository_impl.dart';

part 'sync_provider.g.dart';

/// Estado de sincronização
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncState {
  final SyncStatus status;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const SyncState({
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.lastSyncTime,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Provider para gerenciar sincronização
@riverpod
class SyncManager extends _$SyncManager {
  @override
  SyncState build() {
    // Inicia listener de mudanças do Firebase
    _watchCloudChanges();
    return const SyncState();
  }

  /// Sincroniza configurações para a nuvem
  Future<void> syncSettingsToCloud() async {
    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final settings = await ref.read(settingsProvider.future);
      await ref.read(syncRepositoryProvider).syncSettingsToCloud(settings);

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sincroniza perfil para a nuvem
  Future<void> syncProfileToCloud() async {
    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final profile = await ref.read(userProfileProvider.future);
      await ref.read(syncRepositoryProvider).syncProfileToCloud(profile);

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sincroniza todos os dados para a nuvem
  Future<void> syncAllToCloud() async {
    await syncSettingsToCloud();
    await syncProfileToCloud();
  }

  /// Sincroniza configurações da nuvem para local
  Future<void> syncSettingsFromCloud() async {
    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final remoteSettings = await ref.read(syncRepositoryProvider).syncSettingsFromCloud();
      
      if (remoteSettings != null) {
        // Força reload do provider
        ref.invalidate(settingsProvider);
      }

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sincroniza perfil da nuvem para local
  Future<void> syncProfileFromCloud() async {
    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final remoteProfile = await ref.read(syncRepositoryProvider).syncProfileFromCloud();
      
      if (remoteProfile != null) {
        // Força reload do provider
        ref.invalidate(userProfileProvider);
      }

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sincroniza todos os dados da nuvem para local
  Future<void> syncAllFromCloud() async {
    await syncSettingsFromCloud();
    await syncProfileFromCloud();
  }

  /// Observa mudanças na nuvem
  void _watchCloudChanges() {
    // Observa mudanças nas configurações
    ref.listen(
      cloudSettingsProvider,
      (previous, next) {
        next.whenData((remoteSettings) {
          if (remoteSettings != null) {
            state = state.copyWith(
              lastSyncTime: DateTime.now(),
              status: SyncStatus.success,
            );
          }
        });
      },
    );

    // Observa mudanças no perfil
    ref.listen(
      cloudProfileProvider,
      (previous, next) {
        next.whenData((remoteProfile) {
          if (remoteProfile != null) {
            state = state.copyWith(
              lastSyncTime: DateTime.now(),
              status: SyncStatus.success,
            );
          }
        });
      },
    );
  }

  /// Reseta status de erro
  void clearError() {
    state = state.copyWith(
      status: SyncStatus.idle,
      errorMessage: null,
    );
  }
}

/// Provider que observa configurações na nuvem
@riverpod
Stream<SettingsEntity?> cloudSettings(CloudSettingsRef ref) {
  return ref.watch(syncRepositoryProvider).watchCloudSettings();
}

/// Provider que observa perfil na nuvem
@riverpod
Stream<UserProfileEntity?> cloudProfile(CloudProfileRef ref) {
  return ref.watch(syncRepositoryProvider).watchCloudProfile();
}

/// Provider de auto-sync: sincroniza automaticamente quando há mudanças locais
@riverpod
class AutoSync extends _$AutoSync {
  @override
  bool build() {
    // Observa mudanças nas configurações locais
    ref.listen(settingsProvider, (previous, next) {
      next.whenData((_) {
        // Sincroniza automaticamente para a nuvem
        ref.read(syncManagerProvider.notifier).syncSettingsToCloud();
      });
    });

    // Observa mudanças no perfil local
    ref.listen(userProfileProvider, (previous, next) {
      next.whenData((_) {
        // Sincroniza automaticamente para a nuvem
        ref.read(syncManagerProvider.notifier).syncProfileToCloud();
      });
    });
    
    return true;
  }

  void enable() => state = true;
  void disable() => state = false;
}
