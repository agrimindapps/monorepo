import 'package:hive/hive.dart';

import '../../../../../core/config/app_config.dart.template';
import '../../models/example_model.dart';

/// Local data source for examples using Hive
/// Handles all local storage operations
class ExampleLocalDataSource {
  ExampleLocalDataSource();

  /// Get Hive box for examples
  Box<ExampleModel> get _box {
    return Hive.box<ExampleModel>(AppConfig.exampleBoxName);
  }

  /// Get all examples from local storage
  Future<List<ExampleModel>> getAll() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw Exception('Failed to load examples from local storage: $e');
    }
  }

  /// Get example by ID from local storage
  Future<ExampleModel?> getById(String id) async {
    try {
      return _box.values.firstWhere(
        (model) => model.id == id,
        orElse: () => throw Exception('Example not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Add example to local storage
  Future<ExampleModel> add(ExampleModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw Exception('Failed to add example to local storage: $e');
    }
  }

  /// Update example in local storage
  Future<ExampleModel> update(ExampleModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw Exception('Failed to update example in local storage: $e');
    }
  }

  /// Delete example from local storage
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete example from local storage: $e');
    }
  }

  /// Clear all examples from local storage
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to clear examples from local storage: $e');
    }
  }

  /// Get examples that need sync (isDirty = true)
  Future<List<ExampleModel>> getDirty() async {
    try {
      return _box.values.where((model) => model.isDirty).toList();
    } catch (e) {
      throw Exception('Failed to load dirty examples: $e');
    }
  }

  /// Save multiple examples (batch operation)
  Future<void> saveAll(List<ExampleModel> models) async {
    try {
      final entries = {for (final model in models) model.id: model};
      await _box.putAll(entries);
    } catch (e) {
      throw Exception('Failed to save examples to local storage: $e');
    }
  }
}
