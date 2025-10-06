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

/// Implementação do data source local usando Hive diretamente
@LazySingleton(as: LivestockLocalDataSource)
class LivestockLocalDataSourceImpl implements LivestockLocalDataSource {
  static const String _bovinesBoxName = 'bovines';
  static const String _equinesBoxName = 'equines';
  
  LivestockLocalDataSourceImpl();
  
  /// Getter para box de bovinos
  Box<BovineModel> get _bovinesBox => Hive.box<BovineModel>(_bovinesBoxName);
  
  /// Getter para box de equinos  
  Box<EquineModel> get _equinesBox => Hive.box<EquineModel>(_equinesBoxName);
  
  @override
  Future<List<BovineModel>> getAllBovines() async {
    try {
      return _bovinesBox.values.where((bovine) => bovine.isActive).toList();
    } catch (e) {
      throw CacheException('Erro ao buscar bovinos: $e');
    }
  }
  
  @override
  Future<BovineModel?> getBovineById(String id) async {
    try {
      return _bovinesBox.get(id);
    } catch (e) {
      throw CacheException('Erro ao buscar bovino por ID: $e');
    }
  }
  
  @override
  Future<void> saveBovine(BovineModel bovine) async {
    try {
      final now = DateTime.now();
      final updatedBovine = bovine.copyWith(
        updatedAt: now,
        createdAt: bovine.createdAt ?? now,
      );
      
      await _bovinesBox.put(updatedBovine.id, updatedBovine);
    } catch (e) {
      throw CacheException('Erro ao salvar bovino: $e');
    }
  }
  
  @override
  Future<void> deleteBovine(String id) async {
    try {
      final bovine = _bovinesBox.get(id);
      if (bovine != null) {
        final inactiveBovine = bovine.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await _bovinesBox.put(id, inactiveBovine);
      }
    } catch (e) {
      throw CacheException('Erro ao deletar bovino: $e');
    }
  }
  
  @override
  Future<List<BovineModel>> searchBovines({
    String? breed,
    String? aptitude,
    String? purpose,
    List<String>? tags,
  }) async {
    try {
      final allBovines = await getAllBovines();
      
      return allBovines.where((bovine) {
        bool matches = true;
        
        if (breed != null && breed.isNotEmpty) {
          matches = matches && bovine.breed.toLowerCase().contains(breed.toLowerCase());
        }
        
        if (aptitude != null && aptitude.isNotEmpty) {
          matches = matches && bovine.aptitude.displayName.toLowerCase().contains(aptitude.toLowerCase());
        }
        
        if (purpose != null && purpose.isNotEmpty) {
          matches = matches && bovine.purpose.toLowerCase().contains(purpose.toLowerCase());
        }
        
        if (tags != null && tags.isNotEmpty) {
          matches = matches && tags.any((tag) => 
            bovine.tags.any((bovineTag) => 
              bovineTag.toLowerCase().contains(tag.toLowerCase())
            )
          );
        }
        
        return matches;
      }).toList();
    } catch (e) {
      throw CacheException('Erro ao buscar bovinos com filtros: $e');
    }
  }
  
  @override
  Future<List<EquineModel>> getAllEquines() async {
    try {
      return _equinesBox.values.where((equine) => equine.isActive).toList();
    } catch (e) {
      throw CacheException('Erro ao buscar equinos: $e');
    }
  }
  
  @override
  Future<EquineModel?> getEquineById(String id) async {
    try {
      return _equinesBox.get(id);
    } catch (e) {
      throw CacheException('Erro ao buscar equino por ID: $e');
    }
  }
  
  @override
  Future<void> saveEquine(EquineModel equine) async {
    try {
      final now = DateTime.now();
      final updatedEquine = equine.copyWith(
        updatedAt: now,
        createdAt: equine.createdAt ?? now,
      );
      
      await _equinesBox.put(updatedEquine.id, updatedEquine);
    } catch (e) {
      throw CacheException('Erro ao salvar equino: $e');
    }
  }
  
  @override
  Future<void> deleteEquine(String id) async {
    try {
      final equine = _equinesBox.get(id);
      if (equine != null) {
        final inactiveEquine = equine.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await _equinesBox.put(id, inactiveEquine);
      }
    } catch (e) {
      throw CacheException('Erro ao deletar equino: $e');
    }
  }
  
  @override
  Future<List<EquineModel>> searchEquines({
    String? temperament,
    String? coat,
    String? primaryUse,
    String? geneticInfluences,
  }) async {
    try {
      final allEquines = await getAllEquines();
      
      return allEquines.where((equine) {
        bool matches = true;
        
        if (temperament != null && temperament.isNotEmpty) {
          matches = matches && equine.temperament.displayName.toLowerCase().contains(temperament.toLowerCase());
        }
        
        if (coat != null && coat.isNotEmpty) {
          matches = matches && equine.coat.displayName.toLowerCase().contains(coat.toLowerCase());
        }
        
        if (primaryUse != null && primaryUse.isNotEmpty) {
          matches = matches && equine.primaryUse.displayName.toLowerCase().contains(primaryUse.toLowerCase());
        }
        
        if (geneticInfluences != null && geneticInfluences.isNotEmpty) {
          matches = matches && equine.geneticInfluences.toLowerCase().contains(geneticInfluences.toLowerCase());
        }
        
        return matches;
      }).toList();
    } catch (e) {
      throw CacheException('Erro ao buscar equinos com filtros: $e');
    }
  }
  
  @override
  Future<String> exportData() async {
    try {
      final bovines = await getAllBovines();
      final equines = await getAllEquines();
      
      final exportData = {
        'bovines': bovines.map((b) => b.toJson()).toList(),
        'equines': equines.map((e) => e.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      return exportData.toString();
    } catch (e) {
      throw CacheException('Erro ao exportar dados: $e');
    }
  }
  
  @override
  Future<void> importData(String backupData) async {
    try {
      throw UnimplementedError('Import de dados não implementado ainda');
    } catch (e) {
      throw CacheException('Erro ao importar dados: $e');
    }
  }
  
  /// Método para inicializar boxes do Hive
  static Future<void> initializeBoxes() async {
    if (!Hive.isBoxOpen(_bovinesBoxName)) {
      await Hive.openBox<BovineModel>(_bovinesBoxName);
    }
    if (!Hive.isBoxOpen(_equinesBoxName)) {
      await Hive.openBox<EquineModel>(_equinesBoxName);
    }
  }
  
  /// Método para fechar boxes do Hive (cleanup)
  static Future<void> closeBoxes() async {
    if (Hive.isBoxOpen(_bovinesBoxName)) {
      await Hive.box<BovineModel>(_bovinesBoxName).close();
    }
    if (Hive.isBoxOpen(_equinesBoxName)) {
      await Hive.box<EquineModel>(_equinesBoxName).close();
    }
  }
}

/// Exceção específica para problemas de cache local
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}