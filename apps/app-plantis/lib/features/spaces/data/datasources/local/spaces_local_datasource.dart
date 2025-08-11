import 'package:core/core.dart';
import '../../models/space_model.dart';

abstract class SpacesLocalDatasource {
  Future<List<SpaceModel>> getSpaces();
  Future<SpaceModel?> getSpaceById(String id);
  Future<List<SpaceModel>> searchSpaces(String query);
  Future<void> cacheSpace(SpaceModel space);
  Future<void> cacheSpaces(List<SpaceModel> spaces);
  Future<void> removeSpace(String id);
  Future<void> clearCache();
}

class SpacesLocalDatasourceImpl implements SpacesLocalDatasource {
  static const String _boxName = 'spaces';
  late final HiveStorageService _storage;

  SpacesLocalDatasourceImpl() {
    _storage = HiveStorageService();
  }

  @override
  Future<List<SpaceModel>> getSpaces() async {
    try {
      await _storage.init();
      final spacesData = await _storage.getAll<Map<String, dynamic>>(_boxName);
      
      return spacesData.map((data) => SpaceModel.fromJson(data)).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      throw const CacheFailure('Erro ao buscar espaços locais');
    }
  }

  @override
  Future<SpaceModel?> getSpaceById(String id) async {
    try {
      await _storage.init();
      final spaceData = await _storage.get<Map<String, dynamic>>(_boxName, id);
      
      return spaceData != null ? SpaceModel.fromJson(spaceData) : null;
    } catch (e) {
      throw const CacheFailure('Erro ao buscar espaço local');
    }
  }

  @override
  Future<List<SpaceModel>> searchSpaces(String query) async {
    try {
      final spaces = await getSpaces();
      final queryLower = query.toLowerCase();
      
      return spaces.where((space) {
        return space.name.toLowerCase().contains(queryLower) ||
               (space.description?.toLowerCase().contains(queryLower) ?? false) ||
               space.type.displayName.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw const CacheFailure('Erro ao buscar espaços');
    }
  }

  @override
  Future<void> cacheSpace(SpaceModel space) async {
    try {
      await _storage.init();
      await _storage.put(_boxName, space.id, space.toJson());
    } catch (e) {
      throw const CacheFailure('Erro ao salvar espaço localmente');
    }
  }

  @override
  Future<void> cacheSpaces(List<SpaceModel> spaces) async {
    try {
      await _storage.init();
      for (final space in spaces) {
        await _storage.put(_boxName, space.id, space.toJson());
      }
    } catch (e) {
      throw const CacheFailure('Erro ao salvar espaços localmente');
    }
  }

  @override
  Future<void> removeSpace(String id) async {
    try {
      await _storage.init();
      await _storage.delete(_boxName, id);
    } catch (e) {
      throw const CacheFailure('Erro ao remover espaço local');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _storage.init();
      await _storage.clear(_boxName);
    } catch (e) {
      throw const CacheFailure('Erro ao limpar cache de espaços');
    }
  }
}