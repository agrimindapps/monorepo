import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../datasources/firebase_sync_datasource.dart';
import '../datasources/local_settings_datasource.dart';
import '../datasources/local_user_profile_datasource.dart';
import '../models/settings_model.dart';
import '../models/user_profile_model.dart';

part 'sync_repository_impl.g.dart';

abstract class SyncRepository {
  /// Sincroniza configurações para a nuvem
  Future<void> syncSettingsToCloud(SettingsEntity settings);
  
  /// Sincroniza perfil para a nuvem
  Future<void> syncProfileToCloud(UserProfileEntity profile);
  
  /// Baixa configurações da nuvem
  Future<SettingsEntity?> syncSettingsFromCloud();
  
  /// Baixa perfil da nuvem
  Future<UserProfileEntity?> syncProfileFromCloud();
  
  /// Observa mudanças nas configurações na nuvem
  Stream<SettingsEntity?> watchCloudSettings();
  
  /// Observa mudanças no perfil na nuvem
  Stream<UserProfileEntity?> watchCloudProfile();
  
  /// Deleta todos os dados do usuário
  Future<void> deleteAllUserData();
}

class SyncRepositoryImpl implements SyncRepository {
  final FirebaseSyncDataSource _firebaseDataSource;
  final LocalSettingsDataSource _localSettingsDataSource;
  final LocalUserProfileDataSource _localProfileDataSource;

  SyncRepositoryImpl({
    required FirebaseSyncDataSource firebaseDataSource,
    required LocalSettingsDataSource localSettingsDataSource,
    required LocalUserProfileDataSource localProfileDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _localSettingsDataSource = localSettingsDataSource,
        _localProfileDataSource = localProfileDataSource;

  @override
  Future<void> syncSettingsToCloud(SettingsEntity settings) async {
    final model = SettingsModel.fromEntity(settings);
    await _firebaseDataSource.syncSettings(model);
  }

  @override
  Future<void> syncProfileToCloud(UserProfileEntity profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await _firebaseDataSource.syncUserProfile(model);
  }

  @override
  Future<SettingsEntity?> syncSettingsFromCloud() async {
    final remoteModel = await _firebaseDataSource.getSettings();
    if (remoteModel == null) return null;

    // Salva localmente
    await _localSettingsDataSource.saveSettings(remoteModel);
    
    return remoteModel;
  }

  @override
  Future<UserProfileEntity?> syncProfileFromCloud() async {
    final remoteModel = await _firebaseDataSource.getUserProfile();
    if (remoteModel == null) return null;

    // Salva localmente
    await _localProfileDataSource.saveProfile(remoteModel);
    
    return remoteModel;
  }

  @override
  Stream<SettingsEntity?> watchCloudSettings() {
    return _firebaseDataSource.watchSettings().asyncMap((remoteModel) async {
      if (remoteModel == null) return null;

      // Salva automaticamente quando recebe atualização
      await _localSettingsDataSource.saveSettings(remoteModel);
      
      return remoteModel as SettingsEntity;
    });
  }

  @override
  Stream<UserProfileEntity?> watchCloudProfile() {
    return _firebaseDataSource.watchUserProfile().asyncMap((remoteModel) async {
      if (remoteModel == null) return null;

      // Salva automaticamente quando recebe atualização
      await _localProfileDataSource.saveProfile(remoteModel);
      
      return remoteModel as UserProfileEntity;
    });
  }

  @override
  Future<void> deleteAllUserData() async {
    await _firebaseDataSource.deleteUserData();
    await _localSettingsDataSource.clearSettings();
    await _localProfileDataSource.clearProfile();
  }
}

@riverpod
SyncRepository syncRepository(SyncRepositoryRef ref) {
  return SyncRepositoryImpl(
    firebaseDataSource: ref.watch(firebaseSyncDataSourceProvider),
    localSettingsDataSource: ref.watch(localSettingsDataSourceProvider),
    localProfileDataSource: ref.watch(localUserProfileDataSourceProvider),
  );
}

@riverpod
FirebaseSyncDataSource firebaseSyncDataSource(FirebaseSyncDataSourceRef ref) {
  return FirebaseSyncDataSourceImpl();
}
