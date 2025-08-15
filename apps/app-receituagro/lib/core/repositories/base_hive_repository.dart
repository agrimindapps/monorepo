import 'package:hive/hive.dart';
import '../contracts/i_static_data_repository.dart';

/// Repositório base para entidades Hive
/// Princípios: Single Responsibility + Template Method Pattern
abstract class BaseHiveRepository<T extends HiveObject> implements IStaticDataRepository<T> {
  final String _boxName;
  final String _versionKey = '_app_version';

  BaseHiveRepository(this._boxName);

  /// Template method - define o fluxo, subclasses implementam detalhes
  @override
  Future<bool> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String appVersion,
  ) async {
    try {
      if (isUpToDate(appVersion)) {
        return true; // Já atualizado
      }

      final box = await _getBox();
      await box.clear();

      for (final json in jsonData) {
        final entity = createFromJson(json); // Método abstrato
        final key = getKeyFromEntity(entity); // Método abstrato
        await box.put(key, entity);
      }

      await box.put(_versionKey, appVersion);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool isUpToDate(String appVersion) {
    try {
      final box = Hive.box<T>(_boxName);
      final storedVersion = box.get(_versionKey);
      return storedVersion == appVersion;
    } catch (e) {
      return false; // Box não aberta ou erro
    }
  }

  @override
  List<T> getAll() {
    try {
      final box = Hive.box<T>(_boxName);
      return box.values
          .where((item) => getKeyFromEntity(item) != _versionKey)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  T? getById(String id) {
    try {
      final box = Hive.box<T>(_boxName);
      return box.get(id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<T> findBy(bool Function(T item) predicate) {
    return getAll().where(predicate).toList();
  }

  @override
  Future<bool> clear() async {
    try {
      final box = await _getBox();
      await box.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  int get count => getAll().length;

  /// Métodos abstratos - subclasses devem implementar
  T createFromJson(Map<String, dynamic> json);
  String getKeyFromEntity(T entity);

  /// Métodos helper
  Future<Box<T>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<T>(_boxName);
    }
    return await Hive.openBox<T>(_boxName);
  }
}