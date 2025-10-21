import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../models/vacation_calculation_model.dart';

/// Local data source for vacation calculations using Hive
abstract class VacationLocalDataSource {
  /// Save calculation to local storage
  Future<void> saveCalculation(VacationCalculationModel calculation);

  /// Get all calculations from local storage
  Future<List<VacationCalculationModel>> getCalculations({int? limit});

  /// Get calculation by ID
  Future<VacationCalculationModel?> getCalculationById(String id);

  /// Delete calculation
  Future<void> deleteCalculation(String id);

  /// Clear all calculations
  Future<void> clearAll();
}

@Injectable(as: VacationLocalDataSource)
class VacationLocalDataSourceImpl implements VacationLocalDataSource {
  static const String _boxName = 'vacation_calculations';

  Box<VacationCalculationModel> get _box =>
      Hive.box<VacationCalculationModel>(_boxName);

  /// Initialize Hive box (call this during app startup)
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(VacationCalculationModelAdapter());
    }
    await Hive.openBox<VacationCalculationModel>(_boxName);
  }

  @override
  Future<void> saveCalculation(VacationCalculationModel calculation) async {
    await _box.put(calculation.id, calculation);
  }

  @override
  Future<List<VacationCalculationModel>> getCalculations({
    int? limit,
  }) async {
    final calculations = _box.values.toList();

    // Sort by calculatedAt (most recent first)
    calculations.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

    if (limit != null && limit > 0) {
      return calculations.take(limit).toList();
    }

    return calculations;
  }

  @override
  Future<VacationCalculationModel?> getCalculationById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> deleteCalculation(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}
