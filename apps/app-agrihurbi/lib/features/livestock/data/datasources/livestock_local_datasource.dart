import 'package:core/core.dart';

import '../models/bovine_model.dart';
import '../models/equine_model.dart';

/// Interface para data source local de livestock
abstract class LivestockLocalDataSource {
  Future<List<BovineModel>> getAllBovines();
  Future<BovineModel?> getBovineById(String id);
  Future<void> saveBovine(BovineModel bovine);
  Future<void> deleteBovine(String id);
  Future<List<BovineModel>> searchBovines({
    String? breed,
    String? aptitude,
    String? purpose,
    List<String>? tags,
  });
  Future<List<EquineModel>> getAllEquines();
  Future<EquineModel?> getEquineById(String id);
  Future<void> saveEquine(EquineModel equine);
  Future<void> deleteEquine(String id);
  Future<List<EquineModel>> searchEquines({
    String? temperament,
    String? coat,
    String? primaryUse,
    String? geneticInfluences,
  });
  Future<String> exportData();
  Future<void> importData(String backupData);
}

/// Implementação do data source local
@LazySingleton(as: LivestockLocalDataSource)
class LivestockLocalDataSourceImpl implements LivestockLocalDataSource {
  LivestockLocalDataSourceImpl();

  @override
  Future<List<BovineModel>> getAllBovines() async {
    throw UnimplementedError('getAllBovines has not been implemented');
  }

  @override
  Future<BovineModel?> getBovineById(String id) async {
    throw UnimplementedError('getBovineById has not been implemented');
  }

  @override
  Future<void> saveBovine(BovineModel bovine) async {
    throw UnimplementedError('saveBovine has not been implemented');
  }

  @override
  Future<void> deleteBovine(String id) async {
    throw UnimplementedError('deleteBovine has not been implemented');
  }

  @override
  Future<List<BovineModel>> searchBovines({
    String? breed,
    String? aptitude,
    String? purpose,
    List<String>? tags,
  }) async {
    throw UnimplementedError('searchBovines has not been implemented');
  }

  @override
  Future<List<EquineModel>> getAllEquines() async {
    throw UnimplementedError('getAllEquines has not been implemented');
  }

  @override
  Future<EquineModel?> getEquineById(String id) async {
    throw UnimplementedError('getEquineById has not been implemented');
  }

  @override
  Future<void> saveEquine(EquineModel equine) async {
    throw UnimplementedError('saveEquine has not been implemented');
  }

  @override
  Future<void> deleteEquine(String id) async {
    throw UnimplementedError('deleteEquine has not been implemented');
  }

  @override
  Future<List<EquineModel>> searchEquines({
    String? temperament,
    String? coat,
    String? primaryUse,
    String? geneticInfluences,
  }) async {
    throw UnimplementedError('searchEquines has not been implemented');
  }

  @override
  Future<String> exportData() async {
    throw UnimplementedError('exportData has not been implemented');
  }

  @override
  Future<void> importData(String backupData) async {
    throw UnimplementedError('importData has not been implemented');
  }
}


