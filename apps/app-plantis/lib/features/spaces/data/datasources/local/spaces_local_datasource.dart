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
  final ILocalStorageRepository _storage;

  SpacesLocalDatasourceImpl({required ILocalStorageRepository storage}) : _storage = storage;

  @override
  Future<List<SpaceModel>> getSpaces() async {
    try {
      final result = await _storage.getValues<Map<String, dynamic>>(box: _boxName);
      
      return result.fold(
        (failure) => throw CacheFailure('Erro ao buscar espaços locais: ${failure.message}'),
        (spacesData) {
          return spacesData
              .map((data) => SpaceModel.fromJson(data))
              .toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        },
      );
    } catch (e) {
      throw CacheFailure('Erro ao buscar espaços locais: $e');
    }
  }

  @override
  Future<SpaceModel?> getSpaceById(String id) async {
    try {
      final result = await _storage.get<Map<String, dynamic>>(key: id, box: _boxName);
      
      return result.fold(
        (failure) => throw CacheFailure('Erro ao buscar espaço local: ${failure.message}'),
        (spaceData) => spaceData != null ? SpaceModel.fromJson(spaceData) : null,
      );
    } catch (e) {
      throw CacheFailure('Erro ao buscar espaço local: $e');
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
      final result = await _storage.save<Map<String, dynamic>>(
        key: space.id, 
        data: space.toJson(), 
        box: _boxName,
      );
      
      result.fold(
        (failure) => throw CacheFailure('Erro ao salvar espaço localmente: ${failure.message}'),
        (_) => null,
      );
    } catch (e) {
      throw CacheFailure('Erro ao salvar espaço localmente: $e');
    }
  }

  @override
  Future<void> cacheSpaces(List<SpaceModel> spaces) async {
    try {
      for (final space in spaces) {
        final result = await _storage.save<Map<String, dynamic>>(
          key: space.id, 
          data: space.toJson(), 
          box: _boxName,
        );
        
        result.fold(
          (failure) => throw CacheFailure('Erro ao salvar espaços localmente: ${failure.message}'),
          (_) => null,
        );
      }
    } catch (e) {
      throw CacheFailure('Erro ao salvar espaços localmente: $e');
    }
  }

  @override
  Future<void> removeSpace(String id) async {
    try {
      final result = await _storage.remove(key: id, box: _boxName);
      
      result.fold(
        (failure) => throw CacheFailure('Erro ao remover espaço local: ${failure.message}'),
        (_) => null,
      );
    } catch (e) {
      throw CacheFailure('Erro ao remover espaço local: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final result = await _storage.clear(box: _boxName);
      
      result.fold(
        (failure) => throw CacheFailure('Erro ao limpar cache de espaços: ${failure.message}'),
        (_) => null,
      );
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache de espaços: $e');
    }
  }
}