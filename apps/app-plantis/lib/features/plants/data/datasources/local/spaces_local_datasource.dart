import 'dart:convert';

import 'package:core/core.dart';

import '../../models/space_model.dart';

abstract class SpacesLocalDatasource {
  Future<List<SpaceModel>> getSpaces();
  Future<SpaceModel?> getSpaceById(String id);
  Future<void> addSpace(SpaceModel space);
  Future<void> updateSpace(SpaceModel space);
  Future<void> deleteSpace(String id);
  Future<void> clearCache();
}

class SpacesLocalDatasourceImpl implements SpacesLocalDatasource {
  static const String _boxName = 'spaces';
  Box? _box; // Untyped to accept Box<dynamic> from UnifiedSyncManager

  Future<Box> get box async {
    if (_box != null) return _box!;

    // If box is already open (by UnifiedSync), reuse it
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box(_boxName);
      return _box!;
    }

    // Otherwise open it
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<List<SpaceModel>> getSpaces() async {
    try {
      final hiveBox = await box;
      final spaces = <SpaceModel>[];

      for (final key in hiveBox.keys) {
        final spaceJson = hiveBox.get(key) as String?;
        if (spaceJson != null) {
          final spaceData = jsonDecode(spaceJson) as Map<String, dynamic>;
          final space = SpaceModel.fromJson(spaceData);
          if (!space.isDeleted) {
            spaces.add(space);
          }
        }
      }

      // Sort by creation date (newest first)
      spaces.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

      return spaces;
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar espaços do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<SpaceModel?> getSpaceById(String id) async {
    try {
      final hiveBox = await box;
      final spaceJson = hiveBox.get(id) as String?;

      if (spaceJson == null) {
        return null;
      }

      final spaceData = jsonDecode(spaceJson) as Map<String, dynamic>;
      final space = SpaceModel.fromJson(spaceData);

      return space.isDeleted ? null : space;
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar espaço do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addSpace(SpaceModel space) async {
    try {
      final hiveBox = await box;
      final spaceJson = jsonEncode(space.toJson());
      await hiveBox.put(space.id, spaceJson);
    } catch (e) {
      throw CacheFailure(
        'Erro ao salvar espaço no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateSpace(SpaceModel space) async {
    try {
      final hiveBox = await box;
      final spaceJson = jsonEncode(space.toJson());
      await hiveBox.put(space.id, spaceJson);
    } catch (e) {
      throw CacheFailure(
        'Erro ao atualizar espaço no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteSpace(String id) async {
    try {
      final hiveBox = await box;

      // Get existing space first
      final spaceJson = hiveBox.get(id) as String?;
      if (spaceJson != null) {
        final spaceData = jsonDecode(spaceJson) as Map<String, dynamic>;
        final space = SpaceModel.fromJson(spaceData);

        // Soft delete - mark as deleted
        final deletedSpace = space.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        final updatedJson = jsonEncode(deletedSpace.toJson());
        await hiveBox.put(id, updatedJson);
      }
    } catch (e) {
      throw CacheFailure(
        'Erro ao deletar espaço do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final hiveBox = await box;
      await hiveBox.clear();
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache local: ${e.toString()}');
    }
  }
}
