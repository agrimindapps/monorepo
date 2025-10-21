import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/emergency_reserve_calculation_model.dart';

abstract class EmergencyReserveLocalDataSource {
  Future<EmergencyReserveCalculationModel> save(EmergencyReserveCalculationModel model);
  Future<List<EmergencyReserveCalculationModel>> getAll({int limit = 10});
  Future<EmergencyReserveCalculationModel?> getById(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

@Injectable(as: EmergencyReserveLocalDataSource)
class EmergencyReserveLocalDataSourceImpl implements EmergencyReserveLocalDataSource {
  static const String boxName = 'emergency_reserve_calculations';
  final Box<EmergencyReserveCalculationModel> _box;

  EmergencyReserveLocalDataSourceImpl(this._box);

  @override
  Future<EmergencyReserveCalculationModel> save(EmergencyReserveCalculationModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<EmergencyReserveCalculationModel>> getAll({int limit = 10}) async {
    try {
      final values = _box.values.toList();
      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
      return values.length > limit ? values.sublist(0, limit) : values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<EmergencyReserveCalculationModel?> getById(String id) async {
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

@module
abstract class EmergencyReserveLocalDataSourceModule {
  @injectable
  Box<EmergencyReserveCalculationModel> get emergencyReserveBox {
    return Hive.box<EmergencyReserveCalculationModel>(EmergencyReserveLocalDataSourceImpl.boxName);
  }
}

extension EmergencyReserveLocalDataSourceImplExtension on EmergencyReserveLocalDataSourceImpl {
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(EmergencyReserveCalculationModelAdapter());
    }
    if (!Hive.isBoxOpen(EmergencyReserveLocalDataSourceImpl.boxName)) {
      await Hive.openBox<EmergencyReserveCalculationModel>(EmergencyReserveLocalDataSourceImpl.boxName);
    }
  }
}
