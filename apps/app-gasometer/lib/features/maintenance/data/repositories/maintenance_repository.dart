import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../models/maintenance_model.dart';

/// Repository para persistência de manutenções usando Hive
class MaintenanceRepository {
  static const String _boxName = 'maintenance';
  late Box<MaintenanceModel> _box;

  /// Inicializa o repositório
  Future<void> initialize() async {
    _box = await Hive.openBox<MaintenanceModel>(_boxName);
  }

  /// Salva nova manutenção
  Future<MaintenanceEntity?> saveMaintenance(MaintenanceEntity maintenance) async {
    try {
      final model = _entityToModel(maintenance);
      await _box.put(maintenance.id, model);
      return _modelToEntity(model);
    } catch (e) {
      throw Exception('Erro ao salvar manutenção: $e');
    }
  }

  /// Atualiza manutenção existente
  Future<MaintenanceEntity?> updateMaintenance(MaintenanceEntity maintenance) async {
    try {
      if (!_box.containsKey(maintenance.id)) {
        throw Exception('Manutenção não encontrada');
      }
      
      final model = _entityToModel(maintenance);
      await _box.put(maintenance.id, model);
      return _modelToEntity(model);
    } catch (e) {
      throw Exception('Erro ao atualizar manutenção: $e');
    }
  }

  /// Remove manutenção por ID
  Future<bool> deleteMaintenance(String maintenanceId) async {
    try {
      await _box.delete(maintenanceId);
      return true;
    } catch (e) {
      throw Exception('Erro ao remover manutenção: $e');
    }
  }

  /// Busca manutenção por ID
  Future<MaintenanceEntity?> getMaintenanceById(String maintenanceId) async {
    try {
      final model = _box.get(maintenanceId);
      return model != null ? _modelToEntity(model) : null;
    } catch (e) {
      throw Exception('Erro ao buscar manutenção: $e');
    }
  }

  /// Carrega todas as manutenções
  Future<List<MaintenanceEntity>> getAllMaintenances() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar manutenções: $e');
    }
  }

  /// Carrega manutenções por veículo
  Future<List<MaintenanceEntity>> getMaintenancesByVehicle(String vehicleId) async {
    try {
      final models = _box.values
          .where((model) => model.veiculoId == vehicleId && !model.isDeleted)
          .toList();
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar manutenções do veículo: $e');
    }
  }

  /// Carrega manutenções por tipo
  Future<List<MaintenanceEntity>> getMaintenancesByType(MaintenanceType type) async {
    try {
      final typeString = _typeToString(type);
      final models = _box.values
          .where((model) => model.tipo == typeString && !model.isDeleted)
          .toList();
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar manutenções por tipo: $e');
    }
  }

  /// Carrega manutenções por status
  Future<List<MaintenanceEntity>> getMaintenancesByStatus(MaintenanceStatus status) async {
    try {
      final models = _box.values
          .where((model) => !model.isDeleted)
          .toList();
      
      // Como o modelo atual não tem status separado, vamos considerar todas como 'completed'
      // se foram salvas, ou filtrar de outra forma
      final filteredModels = models.where((model) {
        if (status == MaintenanceStatus.completed) {
          return model.concluida;
        } else if (status == MaintenanceStatus.pending) {
          return !model.concluida;
        }
        return false; // Para inProgress e cancelled, retorna vazio por enquanto
      }).toList();
      
      return filteredModels.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar manutenções por status: $e');
    }
  }

  /// Carrega manutenções por período
  Future<List<MaintenanceEntity>> getMaintenancesByPeriod(DateTime start, DateTime end) async {
    try {
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      
      final models = _box.values.where((model) {
        return model.data >= startMs && 
               model.data <= endMs && 
               !model.isDeleted;
      }).toList();
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar manutenções por período: $e');
    }
  }

  /// Carrega manutenções pendentes (próximas revisões vencidas)
  Future<List<MaintenanceEntity>> getUpcomingMaintenances(double currentOdometer) async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final maintenances = models.map((model) => _modelToEntity(model)).toList();
      
      return maintenances.where((maintenance) {
        return maintenance.isNextServiceDue(currentOdometer);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar manutenções pendentes: $e');
    }
  }

  /// Busca manutenções por texto
  Future<List<MaintenanceEntity>> searchMaintenances(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final models = _box.values.where((model) {
        return !model.isDeleted && 
               model.descricao.toLowerCase().contains(lowerQuery);
      }).toList();
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar manutenções: $e');
    }
  }

  /// Carrega estatísticas básicas
  Future<Map<String, dynamic>> getStats() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      
      if (models.isEmpty) {
        return {
          'totalRecords': 0,
          'totalCost': 0.0,
          'averageCost': 0.0,
        };
      }

      final totalCost = models.fold<double>(0, (sum, model) => sum + model.valor);
      
      return {
        'totalRecords': models.length,
        'totalCost': totalCost,
        'averageCost': totalCost / models.length,
        'lastMaintenance': _modelToEntity(models.reduce((a, b) => 
            a.data > b.data ? a : b)),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Verifica se há manutenções duplicadas
  Future<List<MaintenanceEntity>> findDuplicates() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final duplicates = <MaintenanceModel>[];
      
      for (int i = 0; i < models.length; i++) {
        for (int j = i + 1; j < models.length; j++) {
          final model1 = models[i];
          final model2 = models[j];
          
          // Considera duplicata se mesmo veículo, tipo, data (mesmo dia) e valor muito próximo
          final date1 = DateTime.fromMillisecondsSinceEpoch(model1.data);
          final date2 = DateTime.fromMillisecondsSinceEpoch(model2.data);
          
          if (model1.veiculoId == model2.veiculoId &&
              model1.tipo == model2.tipo &&
              date1.day == date2.day &&
              date1.month == date2.month &&
              date1.year == date2.year &&
              (model1.valor - model2.valor).abs() < 0.01) {
            duplicates.add(model2);
          }
        }
      }
      
      return duplicates.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar duplicatas: $e');
    }
  }

  /// Limpa todas as manutenções (apenas para debug/reset)
  Future<void> clearAllMaintenances() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Erro ao limpar manutenções: $e');
    }
  }

  /// Converte MaintenanceEntity para MaintenanceModel
  MaintenanceModel _entityToModel(MaintenanceEntity entity) {
    return MaintenanceModel.create(
      id: entity.id,
      userId: entity.userId,
      veiculoId: entity.vehicleId,
      tipo: _typeToString(entity.type),
      descricao: '${entity.title} - ${entity.description}', // Combina título e descrição
      valor: entity.cost,
      data: entity.serviceDate.millisecondsSinceEpoch,
      odometro: entity.odometer.round(),
      proximaRevisao: entity.nextServiceDate?.millisecondsSinceEpoch,
      concluida: entity.status == MaintenanceStatus.completed,
    );
  }

  /// Converte MaintenanceModel para MaintenanceEntity
  MaintenanceEntity _modelToEntity(MaintenanceModel model) {
    // Separar título e descrição se possível (formato: "Título - Descrição")
    final parts = model.descricao.split(' - ');
    final title = parts.isNotEmpty ? parts.first : model.descricao;
    final description = parts.length > 1 ? parts.skip(1).join(' - ') : model.descricao;
    
    return MaintenanceEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.veiculoId,
      type: _stringToType(model.tipo),
      status: model.concluida ? MaintenanceStatus.completed : MaintenanceStatus.pending,
      title: title,
      description: description,
      cost: model.valor,
      serviceDate: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro.toDouble(),
      workshopName: null, // Não disponível no modelo atual
      workshopPhone: null, // Não disponível no modelo atual
      workshopAddress: null, // Não disponível no modelo atual
      nextServiceDate: model.proximaRevisao != null 
          ? DateTime.fromMillisecondsSinceEpoch(model.proximaRevisao!)
          : null,
      nextServiceOdometer: null, // Não disponível no modelo atual
      photosPaths: const [], // Não disponível no modelo atual
      invoicesPaths: const [], // Não disponível no modelo atual
      parts: const {}, // Não disponível no modelo atual
      notes: null, // Não disponível no modelo atual
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: const {},
    );
  }

  /// Converte MaintenanceType para string
  String _typeToString(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventiva';
      case MaintenanceType.corrective:
        return 'Corretiva';
      case MaintenanceType.inspection:
        return 'Revisão';
      case MaintenanceType.emergency:
        return 'Emergencial';
    }
  }

  /// Converte string para MaintenanceType
  MaintenanceType _stringToType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'preventiva':
        return MaintenanceType.preventive;
      case 'corretiva':
        return MaintenanceType.corrective;
      case 'revisão':
      case 'revisao':
        return MaintenanceType.inspection;
      case 'emergencial':
        return MaintenanceType.emergency;
      default:
        return MaintenanceType.preventive;
    }
  }

  /// Converte MaintenanceStatus para string
  String _statusToString(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Pendente';
      case MaintenanceStatus.inProgress:
        return 'Em Andamento';
      case MaintenanceStatus.completed:
        return 'Concluída';
      case MaintenanceStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Fecha o box (cleanup)
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      // Log error mas não trava
      if (kDebugMode) {
        print('Erro ao fechar box de manutenções: $e');
      }
    }
  }
}