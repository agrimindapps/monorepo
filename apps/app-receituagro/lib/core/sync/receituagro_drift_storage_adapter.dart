import 'dart:convert';

import 'package:core/core.dart' hide Column, OfflineData;
import 'package:core/src/domain/repositories/i_local_storage_repository.dart'
    show OfflineData;
import 'package:drift/drift.dart' hide JsonKey;

import '../../database/receituagro_database.dart';

/// Adapter para integrar tabelas Drift específicas do ReceitaAgro
/// com o sistema de sync do core package.
///
/// Este adapter implementa ILocalStorageRepository mas foca apenas nos métodos
/// essenciais para sync (save, get, remove, clear, getValues).
/// 
/// Traduz entre:
/// - Estrutura específica do Drift (Favoritos, Comentarios, AppSettings)
/// - Sistema de sync genérico esperado pelo UnifiedSyncManager
class ReceituagroDriftStorageAdapter implements ILocalStorageRepository {
  final ReceituagroDatabase _db;
  bool _isInitialized = false;

  ReceituagroDriftStorageAdapter(this._db);

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);
      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao inicializar adapter: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T data,
    String? box,
  }) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? 'key_value_storage';

      // Roteamento para tabelas específicas
      switch (tableName) {
        case 'favoritos':
          return await _saveFavorito(key, data);
        case 'comentarios':
          return await _saveComentario(key, data);
        case 'user_settings':
        case 'app_settings':
          return await _saveAppSettings(key, data);
        default:
          return Left(CacheFailure('Tabela não suportada: $tableName'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar: $e'));
    }
  }

  @override
  Future<Either<Failure, T?>> get<T>({
    required String key,
    String? box,
  }) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? 'key_value_storage';

      switch (tableName) {
        case 'favoritos':
          return await _getFavorito<T>(key);
        case 'comentarios':
          return await _getComentario<T>(key);
        case 'user_settings':
        case 'app_settings':
          return await _getAppSettings<T>(key);
        default:
          return Left(CacheFailure('Tabela não suportada: $tableName'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? 'key_value_storage';

      switch (tableName) {
        case 'favoritos':
          return await _getAllFavoritos<T>();
        case 'comentarios':
          return await _getAllComentarios<T>();
        case 'user_settings':
        case 'app_settings':
          return await _getAllAppSettings<T>();
        default:
          return Left(CacheFailure('Tabela não suportada: $tableName'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao obter todos os dados: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  }) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? 'key_value_storage';

      switch (tableName) {
        case 'favoritos':
          return await _deleteFavorito(key);
        case 'comentarios':
          return await _deleteComentario(key);
        case 'user_settings':
        case 'app_settings':
          return await _deleteAppSettings(key);
        default:
          return Left(CacheFailure('Tabela não suportada: $tableName'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clear({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? 'key_value_storage';

      switch (tableName) {
        case 'favoritos':
          await _db.delete(_db.favoritos).go();
          return const Right(null);
        case 'comentarios':
          await _db.delete(_db.comentarios).go();
          return const Right(null);
        case 'user_settings':
        case 'app_settings':
          await _db.delete(_db.appSettings).go();
          return const Right(null);
        default:
          return Left(CacheFailure('Tabela não suportada: $tableName'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar: $e'));
    }
  }

  // ========== IMPLEMENTAÇÕES STUB (não usadas pelo sync) ==========
  
  @override
  Future<Either<Failure, bool>> contains({required String key, String? box}) async {
    return const Left(CacheFailure('Método contains não implementado'));
  }

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async {
    return const Left(CacheFailure('Método getKeys não implementado'));
  }

  @override
  Future<Either<Failure, int>> length({String? box}) async {
    return const Left(CacheFailure('Método length não implementado'));
  }

  @override
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  }) async {
    return const Left(CacheFailure('Método saveList não implementado'));
  }

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  }) async {
    return const Left(CacheFailure('Método getList não implementado'));
  }

  @override
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    return const Left(CacheFailure('Método addToList não implementado'));
  }

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    return const Left(CacheFailure('Método removeFromList não implementado'));
  }

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  }) async {
    return const Left(CacheFailure('Método saveWithTTL não implementado'));
  }

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  }) async {
    return const Left(CacheFailure('Método getWithTTL não implementado'));
  }

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async {
    return const Left(CacheFailure('Método cleanExpiredData não implementado'));
  }

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async {
    return const Left(CacheFailure('Método saveUserSetting não implementado'));
  }

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    return const Left(CacheFailure('Método getUserSetting não implementado'));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async {
    return const Left(CacheFailure('Método getAllUserSettings não implementado'));
  }

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async {
    return const Left(CacheFailure('Método saveOfflineData não implementado'));
  }

  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async {
    return const Left(CacheFailure('Método getOfflineData não implementado'));
  }

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async {
    return const Left(CacheFailure('Método markAsSynced não implementado'));
  }

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async {
    return const Left(CacheFailure('Método getUnsyncedKeys não implementado'));
  }

  // ========== MÉTODOS PRIVADOS - FAVORITOS ==========

  Future<Either<Failure, void>> _saveFavorito(String key, dynamic data) async {
    try {
      final Map<String, dynamic> map = data is Map<String, dynamic>
          ? data
          : jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

      final companion = FavoritosCompanion(
        id: map['id'] != null ? Value(map['id'] as int) : const Value.absent(),
        firebaseId: Value(map['firebaseId'] as String?),
        userId: Value(map['userId'] as String),
        moduleName: Value(map['moduleName'] as String? ?? 'receituagro'),
        tipo: Value(map['tipo'] as String),
        itemId: Value(map['itemId'] as String),
        itemData: Value(map['itemData'] as String),
        isDirty: Value(map['isDirty'] as bool? ?? true),
        isDeleted: Value(map['isDeleted'] as bool? ?? false),
        version: Value(map['version'] as int? ?? 1),
        updatedAt: Value(DateTime.now()),
      );

      await _db.into(_db.favoritos).insertOnConflictUpdate(companion);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar favorito: $e'));
    }
  }

  Future<Either<Failure, T?>> _getFavorito<T>(String key) async {
    try {
      final query = _db.select(_db.favoritos)
        ..where((tbl) => tbl.firebaseId.equals(key));

      final favorito = await query.getSingleOrNull();
      if (favorito == null) return const Right(null);

      final map = _favoritoToMap(favorito);
      return Right(map as T);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter favorito: $e'));
    }
  }

  Future<Either<Failure, List<T>>> _getAllFavoritos<T>() async {
    try {
      final favoritos = await _db.select(_db.favoritos).get();
      final list = favoritos.map(_favoritoToMap).toList();
      return Right(list.cast<T>());
    } catch (e) {
      return Left(CacheFailure('Erro ao obter favoritos: $e'));
    }
  }

  Future<Either<Failure, void>> _deleteFavorito(String key) async {
    try {
      await (_db.delete(_db.favoritos)
            ..where((tbl) => tbl.firebaseId.equals(key)))
          .go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar favorito: $e'));
    }
  }

  Map<String, dynamic> _favoritoToMap(Favorito favorito) {
    return {
      'id': favorito.id,
      'firebaseId': favorito.firebaseId,
      'userId': favorito.userId,
      'moduleName': favorito.moduleName,
      'tipo': favorito.tipo,
      'itemId': favorito.itemId,
      'itemData': favorito.itemData,
      'createdAt': favorito.createdAt.toIso8601String(),
      'updatedAt': favorito.updatedAt?.toIso8601String(),
      'lastSyncAt': favorito.lastSyncAt?.toIso8601String(),
      'isDirty': favorito.isDirty,
      'isDeleted': favorito.isDeleted,
      'version': favorito.version,
    };
  }

  // ========== MÉTODOS PRIVADOS - COMENTARIOS ==========

  Future<Either<Failure, void>> _saveComentario(String key, dynamic data) async {
    try {
      final Map<String, dynamic> map = data is Map<String, dynamic>
          ? data
          : jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

      final companion = ComentariosCompanion(
        id: map['id'] != null ? Value(map['id'] as int) : const Value.absent(),
        firebaseId: Value(map['firebaseId'] as String?),
        userId: Value(map['userId'] as String),
        moduleName: Value(map['moduleName'] as String? ?? 'receituagro'),
        itemId: Value(map['itemId'] as String),
        texto: Value(map['texto'] as String),
        isDirty: Value(map['isDirty'] as bool? ?? true),
        isDeleted: Value(map['isDeleted'] as bool? ?? false),
        version: Value(map['version'] as int? ?? 1),
        updatedAt: Value(DateTime.now()),
      );

      await _db.into(_db.comentarios).insertOnConflictUpdate(companion);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar comentário: $e'));
    }
  }

  Future<Either<Failure, T?>> _getComentario<T>(String key) async {
    try {
      final query = _db.select(_db.comentarios)
        ..where((tbl) => tbl.firebaseId.equals(key));

      final comentario = await query.getSingleOrNull();
      if (comentario == null) return const Right(null);

      final map = _comentarioToMap(comentario);
      return Right(map as T);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter comentário: $e'));
    }
  }

  Future<Either<Failure, List<T>>> _getAllComentarios<T>() async {
    try {
      final comentarios = await _db.select(_db.comentarios).get();
      final list = comentarios.map(_comentarioToMap).toList();
      return Right(list.cast<T>());
    } catch (e) {
      return Left(CacheFailure('Erro ao obter comentários: $e'));
    }
  }

  Future<Either<Failure, void>> _deleteComentario(String key) async {
    try {
      await (_db.delete(_db.comentarios)
            ..where((tbl) => tbl.firebaseId.equals(key)))
          .go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar comentário: $e'));
    }
  }

  Map<String, dynamic> _comentarioToMap(Comentario comentario) {
    return {
      'id': comentario.id,
      'firebaseId': comentario.firebaseId,
      'userId': comentario.userId,
      'moduleName': comentario.moduleName,
      'itemId': comentario.itemId,
      'texto': comentario.texto,
      'createdAt': comentario.createdAt.toIso8601String(),
      'updatedAt': comentario.updatedAt?.toIso8601String(),
      'lastSyncAt': comentario.lastSyncAt?.toIso8601String(),
      'isDirty': comentario.isDirty,
      'isDeleted': comentario.isDeleted,
      'version': comentario.version,
    };
  }

  // ========== MÉTODOS PRIVADOS - APP SETTINGS ==========

  Future<Either<Failure, void>> _saveAppSettings(String key, dynamic data) async {
    try {
      final Map<String, dynamic> map = data is Map<String, dynamic>
          ? data
          : jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

      final companion = AppSettingsCompanion(
        id: map['id'] != null ? Value(map['id'] as int) : const Value.absent(),
        firebaseId: Value(map['firebaseId'] as String?),
        userId: Value(map['userId'] as String),
        moduleName: Value(map['moduleName'] as String? ?? 'receituagro'),
        theme: Value(map['theme'] as String? ?? 'system'),
        language: Value(map['language'] as String? ?? 'pt'),
        enableNotifications: Value(map['enableNotifications'] as bool? ?? true),
        enableSync: Value(map['enableSync'] as bool? ?? true),
        featureFlags: Value(map['featureFlags'] as String? ?? '{}'),
        isDirty: Value(map['isDirty'] as bool? ?? true),
        isDeleted: Value(map['isDeleted'] as bool? ?? false),
        version: Value(map['version'] as int? ?? 1),
        updatedAt: Value(DateTime.now()),
      );

      await _db.into(_db.appSettings).insertOnConflictUpdate(companion);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar settings: $e'));
    }
  }

  Future<Either<Failure, T?>> _getAppSettings<T>(String key) async {
    try {
      final query = _db.select(_db.appSettings)
        ..where((tbl) => tbl.firebaseId.equals(key));

      final settings = await query.getSingleOrNull();
      if (settings == null) return const Right(null);

      final map = _appSettingsToMap(settings);
      return Right(map as T);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter settings: $e'));
    }
  }

  Future<Either<Failure, List<T>>> _getAllAppSettings<T>() async {
    try {
      final settings = await _db.select(_db.appSettings).get();
      final list = settings.map(_appSettingsToMap).toList();
      return Right(list.cast<T>());
    } catch (e) {
      return Left(CacheFailure('Erro ao obter settings: $e'));
    }
  }

  Future<Either<Failure, void>> _deleteAppSettings(String key) async {
    try {
      await (_db.delete(_db.appSettings)
            ..where((tbl) => tbl.firebaseId.equals(key)))
          .go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar settings: $e'));
    }
  }

  Map<String, dynamic> _appSettingsToMap(AppSetting settings) {
    return {
      'id': settings.id,
      'firebaseId': settings.firebaseId,
      'userId': settings.userId,
      'moduleName': settings.moduleName,
      'theme': settings.theme,
      'language': settings.language,
      'enableNotifications': settings.enableNotifications,
      'enableSync': settings.enableSync,
      'featureFlags': settings.featureFlags,
      'createdAt': settings.createdAt.toIso8601String(),
      'updatedAt': settings.updatedAt?.toIso8601String(),
      'lastSyncAt': settings.lastSyncAt?.toIso8601String(),
      'isDirty': settings.isDirty,
      'isDeleted': settings.isDeleted,
      'version': settings.version,
    };
  }

  // ========== MÉTODOS AUXILIARES ==========

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final result = await initialize();
      result.fold(
        (failure) => throw Exception('Falha ao inicializar: ${failure.message}'),
        (_) => null,
      );
    }
  }

  Future<Either<Failure, void>> dispose() async {
    try {
      _isInitialized = false;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao fazer dispose: $e'));
    }
  }
}
