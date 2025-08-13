// Project imports:
import '../../../../core/services/localstorage_service.dart';
import '../interfaces/i_local_storage_service.dart';

/// Implementação do serviço de armazenamento local
class LocalStorageServiceImpl implements ILocalStorageService {
  final LocalStorageService _localStorageService;

  LocalStorageServiceImpl(this._localStorageService);

  @override
  Future<bool> isFavorite(String boxName, String id) async {
    return _localStorageService.isFavorite(boxName, id);
  }

  @override
  Future<bool> setFavorite(String boxName, String id) async {
    return _localStorageService.setFavorite(boxName, id);
  }

  @override
  Future<List<String>> getFavorites(String boxName) async {
    return _localStorageService.getFavorites(boxName);
  }
}
