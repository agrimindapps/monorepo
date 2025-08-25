import 'package:hive/hive.dart';

import '../../../../core/cache/cache_manager.dart';
import '../../domain/entities/odometer_entity.dart';
import '../models/odometer_model.dart';

/// Repository para persistência de leituras de odômetro usando Hive com cache strategy
class OdometerRepository with CachedRepository<OdometerEntity> {
  static const String _boxName = 'odometer';
  late Box<OdometerModel> _box;

  /// Inicializa o repositório
  Future<void> initialize() async {
    _box = await Hive.openBox<OdometerModel>(_boxName);
    
    // Inicializar cache com configurações otimizadas para odômetro
    initializeCache(
      maxSize: 100,
      defaultTtl: const Duration(minutes: 8), // TTL médio para leituras de odômetro
    );
  }

  /// Salva nova leitura de odômetro
  Future<OdometerEntity?> saveOdometerReading(OdometerEntity reading) async {
    try {
      final model = _entityToModel(reading);
      await _box.put(reading.id, model);
      return _modelToEntity(model);
    } catch (e) {
      throw Exception('Erro ao salvar leitura de odômetro: $e');
    }
  }

  /// Atualiza leitura de odômetro existente
  Future<OdometerEntity?> updateOdometerReading(OdometerEntity reading) async {
    try {
      if (!_box.containsKey(reading.id)) {
        throw Exception('Leitura de odômetro não encontrada');
      }
      
      final model = _entityToModel(reading);
      await _box.put(reading.id, model);
      return _modelToEntity(model);
    } catch (e) {
      throw Exception('Erro ao atualizar leitura de odômetro: $e');
    }
  }

  /// Remove leitura de odômetro por ID
  Future<bool> deleteOdometerReading(String readingId) async {
    try {
      await _box.delete(readingId);
      return true;
    } catch (e) {
      throw Exception('Erro ao remover leitura de odômetro: $e');
    }
  }

  /// Busca leitura de odômetro por ID
  Future<OdometerEntity?> getOdometerReadingById(String readingId) async {
    try {
      final model = _box.get(readingId);
      return model != null ? _modelToEntity(model) : null;
    } catch (e) {
      throw Exception('Erro ao buscar leitura de odômetro: $e');
    }
  }

  /// Carrega todas as leituras de odômetro
  Future<List<OdometerEntity>> getAllOdometerReadings() async {
    try {
      // Verificar cache primeiro
      const cacheKey = 'all_odometer_readings';
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      
      // Cache o resultado
      cacheList(cacheKey, entities);
      
      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar leituras de odômetro: $e');
    }
  }

  /// Carrega leituras de odômetro por veículo
  Future<List<OdometerEntity>> getOdometerReadingsByVehicle(String vehicleId) async {
    try {
      // Verificar cache primeiro
      final cacheKey = vehicleCacheKey(vehicleId, 'odometer_readings');
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final models = _box.values
          .where((model) => model.idVeiculo == vehicleId && !model.isDeleted)
          .toList();
      
      // Ordenar por data decrescente (mais recente primeiro)
      models.sort((a, b) => b.data.compareTo(a.data));
      
      final entities = models.map((model) => _modelToEntity(model)).toList();
      
      // Cache o resultado
      cacheList(cacheKey, entities);
      
      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar leituras do veículo: $e');
    }
  }

  /// Carrega leituras de odômetro por tipo
  Future<List<OdometerEntity>> getOdometerReadingsByType(OdometerType type) async {
    try {
      final typeString = _typeToString(type);
      final models = _box.values
          .where((model) => model.tipoRegistro == typeString && !model.isDeleted)
          .toList();
      
      // Ordenar por data decrescente
      models.sort((a, b) => b.data.compareTo(a.data));
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar leituras por tipo: $e');
    }
  }

  /// Carrega leituras de odômetro por período
  Future<List<OdometerEntity>> getOdometerReadingsByPeriod(DateTime start, DateTime end) async {
    try {
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      
      final models = _box.values.where((model) {
        return model.data >= startMs && 
               model.data <= endMs && 
               !model.isDeleted;
      }).toList();
      
      // Ordenar por data decrescente
      models.sort((a, b) => b.data.compareTo(a.data));
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar leituras por período: $e');
    }
  }

  /// Busca a última leitura de um veículo
  Future<OdometerEntity?> getLastOdometerReading(String vehicleId) async {
    try {
      final models = _box.values
          .where((model) => model.idVeiculo == vehicleId && !model.isDeleted)
          .toList();
      
      if (models.isEmpty) return null;
      
      // Encontrar o modelo com a maior data
      final latestModel = models.reduce((a, b) => 
          a.data > b.data ? a : b);
      
      return _modelToEntity(latestModel);
    } catch (e) {
      throw Exception('Erro ao buscar última leitura: $e');
    }
  }

  /// Busca leituras de odômetro por texto
  Future<List<OdometerEntity>> searchOdometerReadings(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final models = _box.values.where((model) {
        return !model.isDeleted && 
               model.descricao.toLowerCase().contains(lowerQuery);
      }).toList();
      
      // Ordenar por data decrescente
      models.sort((a, b) => b.data.compareTo(a.data));
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar leituras: $e');
    }
  }

  /// Carrega estatísticas básicas por veículo
  Future<Map<String, dynamic>> getVehicleStats(String vehicleId) async {
    try {
      final models = _box.values
          .where((model) => model.idVeiculo == vehicleId && !model.isDeleted)
          .toList();
      
      if (models.isEmpty) {
        return {
          'totalRecords': 0,
          'currentOdometer': 0.0,
          'firstReading': null,
          'lastReading': null,
          'totalDistance': 0.0,
        };
      }

      // Ordenar por data
      models.sort((a, b) => a.data.compareTo(b.data));
      
      final firstModel = models.first;
      final lastModel = models.last;
      final totalDistance = lastModel.odometro - firstModel.odometro;
      
      return {
        'totalRecords': models.length,
        'currentOdometer': lastModel.odometro,
        'firstReading': _modelToEntity(firstModel),
        'lastReading': _modelToEntity(lastModel),
        'totalDistance': totalDistance.abs(),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Verifica se há leituras duplicadas
  Future<List<OdometerEntity>> findDuplicates() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final duplicates = <OdometerModel>[];
      
      for (int i = 0; i < models.length; i++) {
        for (int j = i + 1; j < models.length; j++) {
          final model1 = models[i];
          final model2 = models[j];
          
          // Considera duplicata se mesmo veículo, valor próximo e data próxima
          final date1 = DateTime.fromMillisecondsSinceEpoch(model1.data);
          final date2 = DateTime.fromMillisecondsSinceEpoch(model2.data);
          final daysDiff = date1.difference(date2).inDays.abs();
          
          if (model1.idVeiculo == model2.idVeiculo &&
              (model1.odometro - model2.odometro).abs() < 1.0 &&
              daysDiff <= 1) {
            duplicates.add(model2);
          }
        }
      }
      
      return duplicates.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar duplicatas: $e');
    }
  }

  /// Limpa todas as leituras (apenas para debug/reset)
  Future<void> clearAllOdometerReadings() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Erro ao limpar leituras de odômetro: $e');
    }
  }

  /// Converte OdometerEntity para OdometerModel
  OdometerModel _entityToModel(OdometerEntity entity) {
    return OdometerModel.create(
      id: entity.id,
      userId: entity.userId,
      idVeiculo: entity.vehicleId,
      data: entity.registrationDate.millisecondsSinceEpoch,
      odometro: entity.value,
      descricao: entity.description,
      tipoRegistro: _typeToString(entity.type),
    );
  }

  /// Converte OdometerModel para OdometerEntity
  OdometerEntity _modelToEntity(OdometerModel model) {
    return OdometerEntity(
      id: model.id,
      vehicleId: model.idVeiculo,
      userId: model.userId ?? '',
      value: model.odometro,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(model.data),
      description: model.descricao,
      type: _stringToType(model.tipoRegistro ?? 'other'),
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: {
        'version': model.version,
        'isDirty': model.isDirty,
        'lastSync': model.lastSyncAt?.toIso8601String(),
      },
    );
  }

  /// Converte OdometerType para string
  String _typeToString(OdometerType type) {
    return type.name;
  }

  /// Converte string para OdometerType
  OdometerType _stringToType(String typeString) {
    return OdometerType.fromString(typeString);
  }

  /// Fecha o box (cleanup)
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      // Log error mas não trava
      print('Erro ao fechar box de odômetro: $e');
    }
  }
}