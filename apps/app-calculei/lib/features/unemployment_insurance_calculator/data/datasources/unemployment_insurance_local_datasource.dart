import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/unemployment_insurance_calculation_model.dart';

abstract class UnemploymentInsuranceLocalDataSource {
  Future<UnemploymentInsuranceCalculationModel> save(UnemploymentInsuranceCalculationModel model);
  Future<List<UnemploymentInsuranceCalculationModel>> getAll({int limit = 10});
  Future<UnemploymentInsuranceCalculationModel?> getById(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

@Injectable(as: UnemploymentInsuranceLocalDataSource)
class UnemploymentInsuranceLocalDataSourceImpl implements UnemploymentInsuranceLocalDataSource {
  static const String boxName = 'unemployment_insurance_calculations';
  final Box<UnemploymentInsuranceCalculationModel> _box;

  UnemploymentInsuranceLocalDataSourceImpl(this._box);

  @override
  Future<UnemploymentInsuranceCalculationModel> save(UnemploymentInsuranceCalculationModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<UnemploymentInsuranceCalculationModel>> getAll({int limit = 10}) async {
    try {
      final values = _box.values.toList();
      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
      return values.length > limit ? values.sublist(0, limit) : values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<UnemploymentInsuranceCalculationModel?> getById(String id) async {
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
abstract class UnemploymentInsuranceLocalDataSourceModule {
  @injectable
  Box<UnemploymentInsuranceCalculationModel> get unemploymentInsuranceBox {
    return Hive.box<UnemploymentInsuranceCalculationModel>(UnemploymentInsuranceLocalDataSourceImpl.boxName);
  }
}

extension UnemploymentInsuranceLocalDataSourceImplExtension on UnemploymentInsuranceLocalDataSourceImpl {
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(UnemploymentInsuranceCalculationModelAdapter());
    }
    if (!Hive.isBoxOpen(UnemploymentInsuranceLocalDataSourceImpl.boxName)) {
      await Hive.openBox<UnemploymentInsuranceCalculationModel>(UnemploymentInsuranceLocalDataSourceImpl.boxName);
    }
  }
}
