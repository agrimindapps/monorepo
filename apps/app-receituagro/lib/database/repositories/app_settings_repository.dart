import 'package:core/core.dart';

import '../../core/models/app_settings.dart' as models;
import '../receituagro_database.dart';
import '../tables/receituagro_tables.dart' as tables;

/// Repositório de Configurações do App usando Drift
///
/// Gerencia todas as operações de CRUD e queries relacionadas às configurações
/// do aplicativo 
@lazySingleton
class AppSettingsRepository
    extends BaseDriftRepositoryImpl<models.AppSettings, AppSetting> {
  AppSettingsRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<tables.AppSettings, AppSetting> get table => _db.appSettings;

  @override
  GeneratedDatabase get database => _db;

  @override
  models.AppSettings fromData(AppSetting data) {
    return models.AppSettings(
      id: data.id,
      firebaseId: data.firebaseId,
      userId: data.userId,
      moduleName: data.moduleName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      theme: data.theme,
      language: data.language,
      enableNotifications: data.enableNotifications,
      enableSync: data.enableSync,
      featureFlags: data.featureFlags,
    );
  }

  @override
  Insertable<AppSetting> toCompanion(models.AppSettings entity) {
    return AppSettingsCompanion(
      id: Value(entity.id),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId),
      moduleName: Value(entity.moduleName),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      theme: Value(entity.theme),
      language: Value(entity.language),
      enableNotifications: Value(entity.enableNotifications),
      enableSync: Value(entity.enableSync),
      featureFlags: Value(entity.featureFlags),
    );
  }

  @override
  Expression<int> idColumn(covariant tables.AppSettings tbl) => tbl.id;

  /// Busca configurações do app para um usuário específico
  Future<models.AppSettings?> getAppSettings(String userId) async {
    final data =
        await (_db.select(_db.appSettings)..where(
              (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
            ))
            .getSingleOrNull();

    return data != null ? fromData(data) : null;
  }

  /// Salva ou atualiza configurações do app
  Future<models.AppSettings> saveAppSettings(
    models.AppSettings settings,
  ) async {
    final companion = toCompanion(settings);
    final id = await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(companion);

    // Busca o registro atualizado para retornar
    final updatedData = await (_db.select(
      _db.appSettings,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return fromData(updatedData);
  }

  /// Cria configurações padrão para um usuário
  Future<models.AppSettings> createDefaultSettings(String userId) async {
    final defaultSettings = models.AppSettings(
      id: 0, // Será gerado automaticamente
      userId: userId,
      createdAt: DateTime.now(),
    );

    return await saveAppSettings(defaultSettings);
  }

  /// Atualiza configurações específicas
  Future<models.AppSettings?> updateSettings(
    String userId, {
    String? theme,
    String? language,
    bool? enableNotifications,
    bool? enableSync,
    String? featureFlags,
  }) async {
    final currentSettings = await getAppSettings(userId);
    if (currentSettings == null) return null;

    final updatedSettings = currentSettings.copyWith(
      theme: theme ?? currentSettings.theme,
      language: language ?? currentSettings.language,
      enableNotifications:
          enableNotifications ?? currentSettings.enableNotifications,
      enableSync: enableSync ?? currentSettings.enableSync,
      featureFlags: featureFlags ?? currentSettings.featureFlags,
      updatedAt: DateTime.now(),
      isDirty: true,
    );

    return await saveAppSettings(updatedSettings);
  }

  /// Remove configurações do app (soft delete)
  Future<bool> deleteAppSettings(String userId) async {
    final count =
        await (_db.update(
          _db.appSettings,
        )..where((tbl) => tbl.userId.equals(userId))).write(
          AppSettingsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );

    return count > 0;
  }

  /// Busca todas as configurações para sincronização
  Future<List<models.AppSettings>> getAllForSync() async {
    final dataList =
        await (_db.select(_db.appSettings)..where(
              (tbl) => tbl.isDirty.equals(true) | tbl.isDeleted.equals(true),
            ))
            .get();

    return dataList.map(fromData).toList();
  }

  /// Marca configurações como sincronizadas
  Future<bool> markAsSynced(int id) async {
    final count =
        await (_db.update(
          _db.appSettings,
        )..where((tbl) => tbl.id.equals(id))).write(
          AppSettingsCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );

    return count > 0;
  }

  /// Obtém estatísticas das configurações
  Future<Map<String, dynamic>> getStats() async {
    final total =
        await (_db.select(_db.appSettings)
              ..where((tbl) => tbl.isDeleted.equals(false)))
            .get()
            .then((list) => list.length);
    final dirty =
        await (_db.select(_db.appSettings)
              ..where((tbl) => tbl.isDirty.equals(true)))
            .get()
            .then((list) => list.length);

    return {
      'total_settings': total,
      'dirty_settings': dirty,
      'sync_pending': dirty > 0,
    };
  }
}
