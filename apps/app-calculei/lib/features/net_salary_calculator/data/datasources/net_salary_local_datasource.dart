import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/net_salary_calculation_model.dart';

abstract class NetSalaryLocalDataSource {
  Future<NetSalaryCalculationModel> save(NetSalaryCalculationModel model);
  Future<List<NetSalaryCalculationModel>> getAll({int limit = 10});
  Future<NetSalaryCalculationModel?> getById(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

@Injectable(as: NetSalaryLocalDataSource)
class NetSalaryLocalDataSourceImpl implements NetSalaryLocalDataSource {
  static const String boxName = 'net_salary_calculations';
  final Box<NetSalaryCalculationModel> _box;

  NetSalaryLocalDataSourceImpl(this._box);

  @override
  Future<NetSalaryCalculationModel> save(NetSalaryCalculationModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<NetSalaryCalculationModel>> getAll({int limit = 10}) async {
    try {
      final values = _box.values.toList();
      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
      return values.length > limit ? values.sublist(0, limit) : values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<NetSalaryCalculationModel?> getById(String id) async {
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
abstract class NetSalaryLocalDataSourceModule {
  @injectable
  Box<NetSalaryCalculationModel> get netSalaryBox {
    return Hive.box<NetSalaryCalculationModel>(NetSalaryLocalDataSourceImpl.boxName);
  }
}

extension NetSalaryLocalDataSourceImplExtension on NetSalaryLocalDataSourceImpl {
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(NetSalaryCalculationModelAdapter());
    }
    if (!Hive.isBoxOpen(NetSalaryLocalDataSourceImpl.boxName)) {
      await Hive.openBox<NetSalaryCalculationModel>(NetSalaryLocalDataSourceImpl.boxName);
    }
  }
}
