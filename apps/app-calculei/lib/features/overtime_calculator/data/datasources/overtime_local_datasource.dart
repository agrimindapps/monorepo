import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/overtime_calculation_model.dart';

abstract class OvertimeLocalDataSource {
  Future<OvertimeCalculationModel> save(OvertimeCalculationModel model);
  Future<List<OvertimeCalculationModel>> getAll({int limit = 10});
  Future<OvertimeCalculationModel?> getById(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

@Injectable(as: OvertimeLocalDataSource)
class OvertimeLocalDataSourceImpl implements OvertimeLocalDataSource {
  static const String boxName = 'overtime_calculations';
  final Box<OvertimeCalculationModel> _box;
  OvertimeLocalDataSourceImpl(this._box);

  @override
  Future<OvertimeCalculationModel> save(OvertimeCalculationModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<OvertimeCalculationModel>> getAll({int limit = 10}) async {
    try {
      final values = _box.values.toList();
      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
      return values.length > limit ? values.sublist(0, limit) : values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<OvertimeCalculationModel?> getById(String id) async {
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
abstract class OvertimeLocalDataSourceModule {
  @injectable
  Box<OvertimeCalculationModel> get overtimeBox {
    return Hive.box<OvertimeCalculationModel>(OvertimeLocalDataSourceImpl.boxName);
  }
}

extension OvertimeLocalDataSourceImplExtension on OvertimeLocalDataSourceImpl {
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(OvertimeCalculationModelAdapter());
    }
    if (!Hive.isBoxOpen(OvertimeLocalDataSourceImpl.boxName)) {
      await Hive.openBox<OvertimeCalculationModel>(OvertimeLocalDataSourceImpl.boxName);
    }
  }
}
