// Package imports:
import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import '../../../../core/error/exceptions.dart';
import '../models/thirteenth_salary_calculation_model.dart';

/// Abstract interface for 13th salary local data source
///
/// Follows Interface Segregation Principle (ISP):
/// - Specific interface for local storage operations
abstract class ThirteenthSalaryLocalDataSource {
  /// Saves a calculation to local storage
  Future<ThirteenthSalaryCalculationModel> save(
    ThirteenthSalaryCalculationModel model,
  );

  /// Retrieves all calculations from local storage
  ///
  /// Parameters:
  /// - [limit]: Maximum number of calculations to retrieve
  Future<List<ThirteenthSalaryCalculationModel>> getAll({int limit = 10});

  /// Retrieves a specific calculation by ID
  Future<ThirteenthSalaryCalculationModel?> getById(String id);

  /// Deletes a specific calculation
  Future<void> delete(String id);

  /// Clears all calculations
  Future<void> clearAll();
}

/// Hive implementation of 13th salary local data source
///
/// Follows Dependency Inversion Principle (DIP):
/// - Depends on Hive Box abstraction, not concrete implementation
@Injectable(as: ThirteenthSalaryLocalDataSource)
class ThirteenthSalaryLocalDataSourceImpl
    implements ThirteenthSalaryLocalDataSource {
  static const String boxName = 'thirteenth_salary_calculations';

  final Box<ThirteenthSalaryCalculationModel> _box;

  ThirteenthSalaryLocalDataSourceImpl(this._box);

  @override
  Future<ThirteenthSalaryCalculationModel> save(
    ThirteenthSalaryCalculationModel model,
  ) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<ThirteenthSalaryCalculationModel>> getAll({int limit = 10}) async {
    try {
      final values = _box.values.toList();

      // Sort by calculatedAt (most recent first)
      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

      // Apply limit
      if (values.length > limit) {
        return values.sublist(0, limit);
      }

      return values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<ThirteenthSalaryCalculationModel?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw CacheException('Erro ao recuperar cálculo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Erro ao deletar cálculo: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException('Erro ao limpar histórico: $e');
    }
  }
}

/// Provides Hive Box for 13th salary calculations
@module
abstract class ThirteenthSalaryLocalDataSourceModule {
  @injectable
  Box<ThirteenthSalaryCalculationModel> get thirteenthSalaryBox {
    return Hive.box<ThirteenthSalaryCalculationModel>(
      ThirteenthSalaryLocalDataSourceImpl.boxName,
    );
  }
}

/// Extension to add initialization method
extension ThirteenthSalaryLocalDataSourceImplExtension
    on ThirteenthSalaryLocalDataSourceImpl {
  /// Initializes Hive box for 13th salary calculations
  ///
  /// Must be called before using the datasource
  static Future<void> initialize() async {
    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ThirteenthSalaryCalculationModelAdapter());
    }

    // Open box if not already open
    if (!Hive.isBoxOpen(ThirteenthSalaryLocalDataSourceImpl.boxName)) {
      await Hive.openBox<ThirteenthSalaryCalculationModel>(
        ThirteenthSalaryLocalDataSourceImpl.boxName,
      );
    }
  }
}
