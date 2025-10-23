import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cash_vs_installment_calculation_model.dart';

abstract class CashVsInstallmentLocalDataSource {
  Future<CashVsInstallmentCalculationModel> save(CashVsInstallmentCalculationModel model);
  Future<List<CashVsInstallmentCalculationModel>> getAll({int limit = 10});
  Future<CashVsInstallmentCalculationModel?> getById(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

@Injectable(as: CashVsInstallmentLocalDataSource)
class CashVsInstallmentLocalDataSourceImpl implements CashVsInstallmentLocalDataSource {
  static const String boxName = 'cash_vs_installment_calculations';
  final Box<CashVsInstallmentCalculationModel> _box;

  CashVsInstallmentLocalDataSourceImpl(this._box);

  @override
  Future<CashVsInstallmentCalculationModel> save(CashVsInstallmentCalculationModel model) async {
    try {
      await _box.put(model.id, model);
      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<CashVsInstallmentCalculationModel>> getAll({int limit = 10}) async {
    try {
      final values = _box.values.toList();
      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
      return values.length > limit ? values.sublist(0, limit) : values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<CashVsInstallmentCalculationModel?> getById(String id) async {
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
abstract class CashVsInstallmentLocalDataSourceModule {
  @injectable
  Box<CashVsInstallmentCalculationModel> get cashVsInstallmentBox {
    return Hive.box<CashVsInstallmentCalculationModel>(CashVsInstallmentLocalDataSourceImpl.boxName);
  }
}

extension CashVsInstallmentLocalDataSourceImplExtension on CashVsInstallmentLocalDataSourceImpl {
  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(CashVsInstallmentCalculationModelAdapter());
    }
    if (!Hive.isBoxOpen(CashVsInstallmentLocalDataSourceImpl.boxName)) {
      await Hive.openBox<CashVsInstallmentCalculationModel>(CashVsInstallmentLocalDataSourceImpl.boxName);
    }
  }
}
