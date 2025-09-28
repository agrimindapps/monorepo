import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../models/maintenance_form_model.dart';

/// Provider principal para gerenciar estado e operações de manutenções
class MaintenancesProvider extends ChangeNotifier {

  MaintenancesProvider(
    this._repository,
    this._vehiclesProvider,
  ) {
    _initialize();
  }
  final MaintenanceRepository _repository;
  final VehiclesProvider _vehiclesProvider;
  final MaintenanceFormatterService _formatter = MaintenanceFormatterService();

  // Estado da listagem de manutenções
  List<MaintenanceEntity> _maintenances = [];
  List<MaintenanceEntity> _filteredMaintenances = [];
  bool _isLoading = false;
  String? _error;
  
  // Filtros aplicados
  String? _selectedVehicleId;
  MaintenanceType? _selectedType;
  MaintenanceStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  
  // Ordenação
  String _sortBy = 'serviceDate'; // 'serviceDate', 'cost', 'type', 'odometer'
  bool _sortAscending = false;
  
  // Estado de estatísticas
  Map<String, dynamic> _stats = {};

  // Getters públicos
  List<MaintenanceEntity> get maintenances => _filteredMaintenances;
  List<MaintenanceEntity> get allMaintenances => _maintenances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedVehicleId => _selectedVehicleId;
  MaintenanceType? get selectedType => _selectedType;
  MaintenanceStatus? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  Map<String, dynamic> get stats => _stats;

  /// Inicialização do provider
  Future<void> _initialize() async {
    await loadMaintenances();
  }

  /// Carrega todas as manutenções
  Future<void> loadMaintenances() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _maintenances = await _repository.getAllMaintenances();
      _applyFilters();
      _calculateStats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar manutenções: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega manutenções por veículo
  Future<void> loadMaintenancesByVehicle(String vehicleId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _maintenances = await _repository.getMaintenancesByVehicle(vehicleId);
      _selectedVehicleId = vehicleId;
      
      _applyFilters();
      _calculateStats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar manutenções: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona nova manutenção
  Future<bool> addMaintenance(MaintenanceFormModel formModel) async {
    try {
      _error = null;

      // Validar dados completos
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        _error = 'Dados inválidos: ${validationErrors.values.first}';
        notifyListeners();
        return false;
      }

      // Converter para entity
      final maintenance = formModel.toMaintenanceEntity();

      // Salvar no repositório
      final saved = await _repository.saveMaintenance(maintenance);
      
      if (saved != null) {
        // Atualizar lista local
        _maintenances.add(saved);
        _applyFilters();
        _calculateStats();

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Erro ao salvar manutenção: $e';
      notifyListeners();
      return false;
    }
  }

  /// Atualiza manutenção existente
  Future<bool> updateMaintenance(MaintenanceFormModel formModel) async {
    try {
      _error = null;

      if (!formModel.isEditing) {
        _error = 'Manutenção não existe para edição';
        notifyListeners();
        return false;
      }

      // Validar dados
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        _error = 'Dados inválidos: ${validationErrors.values.first}';
        notifyListeners();
        return false;
      }

      // Converter para entity
      final maintenance = formModel.toMaintenanceEntity();

      // Atualizar no repositório
      final updated = await _repository.updateMaintenance(maintenance);
      
      if (updated != null) {
        // Atualizar lista local
        final index = _maintenances.indexWhere((m) => m.id == maintenance.id);
        if (index >= 0) {
          _maintenances[index] = updated;
          _applyFilters();
          _calculateStats();

          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Erro ao atualizar manutenção: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove manutenção
  Future<bool> removeMaintenance(String maintenanceId) async {
    try {
      _error = null;

      final success = await _repository.deleteMaintenance(maintenanceId);
      
      if (success) {
        _maintenances.removeWhere((m) => m.id == maintenanceId);
        _applyFilters();
        _calculateStats();

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Erro ao remover manutenção: $e';
      notifyListeners();
      return false;
    }
  }

  /// Busca manutenção por ID
  MaintenanceEntity? getMaintenanceById(String maintenanceId) {
    try {
      return _maintenances.firstWhere((m) => m.id == maintenanceId);
    } catch (e) {
      return null;
    }
  }

  /// Carrega manutenções pendentes
  Future<List<MaintenanceEntity>> getUpcomingMaintenances() async {
    try {
      // Buscar odômetro atual do veículo selecionado ou usar 0
      double currentOdometer = 0;
      if (_selectedVehicleId != null) {
        final vehicle = await _vehiclesProvider.getVehicleById(_selectedVehicleId!);
        currentOdometer = vehicle?.currentOdometer ?? 0;
      }

      return await _repository.getUpcomingMaintenances(currentOdometer);
    } catch (e) {
      _error = 'Erro ao carregar manutenções pendentes: $e';
      notifyListeners();
      return [];
    }
  }

  // Métodos de filtragem

  /// Aplica filtro por veículo
  void filterByVehicle(String? vehicleId) {
    _selectedVehicleId = vehicleId;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica filtro por tipo
  void filterByType(MaintenanceType? type) {
    _selectedType = type;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica filtro por status
  void filterByStatus(MaintenanceStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica filtro por período
  void filterByPeriod(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica busca por texto
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _selectedVehicleId = null;
    _selectedType = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  // Métodos de ordenação

  /// Ordena por campo específico
  void setSortBy(String field, {bool? ascending}) {
    _sortBy = field;
    _sortAscending = ascending ?? (_sortBy == field ? !_sortAscending : false);
    _applySort();
    notifyListeners();
  }

  /// Aplica filtros à lista de manutenções
  void _applyFilters() {
    _filteredMaintenances = _maintenances.where((maintenance) {
      // Filtro por veículo
      if (_selectedVehicleId != null && maintenance.vehicleId != _selectedVehicleId) {
        return false;
      }

      // Filtro por tipo
      if (_selectedType != null && maintenance.type != _selectedType) {
        return false;
      }

      // Filtro por status
      if (_selectedStatus != null && maintenance.status != _selectedStatus) {
        return false;
      }

      // Filtro por período
      if (_startDate != null) {
        final startOfDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        if (maintenance.serviceDate.isBefore(startOfDay)) return false;
      }
      
      if (_endDate != null) {
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (maintenance.serviceDate.isAfter(endOfDay)) return false;
      }

      // Filtro por busca de texto
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!maintenance.title.toLowerCase().contains(query) &&
            !maintenance.description.toLowerCase().contains(query) &&
            !maintenance.type.displayName.toLowerCase().contains(query) &&
            (maintenance.workshopName?.toLowerCase().contains(query) != true) &&
            (maintenance.notes?.toLowerCase().contains(query) != true)) {
          return false;
        }
      }

      return true;
    }).toList();

    _applySort();
  }

  /// Aplica ordenação à lista filtrada
  void _applySort() {
    _filteredMaintenances.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'serviceDate':
          comparison = a.serviceDate.compareTo(b.serviceDate);
          break;
        case 'cost':
          comparison = a.cost.compareTo(b.cost);
          break;
        case 'type':
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        case 'odometer':
          comparison = a.odometer.compareTo(b.odometer);
          break;
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'status':
          comparison = a.status.displayName.compareTo(b.status.displayName);
          break;
        default:
          comparison = a.serviceDate.compareTo(b.serviceDate);
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  /// Calcula estatísticas da lista filtrada
  void _calculateStats() {
    if (_filteredMaintenances.isEmpty) {
      _stats = {};
      return;
    }

    final totalCost = _filteredMaintenances.fold<double>(0, (sum, m) => sum + m.cost);
    final averageCost = totalCost / _filteredMaintenances.length;
    
    // Agrupar por tipo
    final byType = <MaintenanceType, double>{};
    final countByType = <MaintenanceType, int>{};
    
    for (final maintenance in _filteredMaintenances) {
      byType[maintenance.type] = (byType[maintenance.type] ?? 0) + maintenance.cost;
      countByType[maintenance.type] = (countByType[maintenance.type] ?? 0) + 1;
    }

    // Encontrar tipo mais caro
    MaintenanceType? mostExpensiveType;
    double maxTypeCost = 0;
    byType.forEach((type, cost) {
      if (cost > maxTypeCost) {
        maxTypeCost = cost;
        mostExpensiveType = type;
      }
    });

    // Calcular médias mensais se tiver dados suficientes
    double monthlyCost = 0;
    if (_filteredMaintenances.length >= 2) {
      final sortedByDate = List<MaintenanceEntity>.from(_filteredMaintenances)
        ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));
      
      final firstDate = sortedByDate.first.serviceDate;
      final lastDate = sortedByDate.last.serviceDate;
      final monthsDiff = ((lastDate.year - firstDate.year) * 12 + lastDate.month - firstDate.month) + 1;
      
      if (monthsDiff > 0) {
        monthlyCost = totalCost / monthsDiff;
      }
    }

    // Agrupar por status
    final byStatus = <MaintenanceStatus, int>{};
    for (final maintenance in _filteredMaintenances) {
      byStatus[maintenance.status] = (byStatus[maintenance.status] ?? 0) + 1;
    }

    _stats = {
      'totalRecords': _filteredMaintenances.length,
      'totalCost': totalCost,
      'totalCostFormatted': _formatter.formatAmount(totalCost),
      'averageCost': averageCost,
      'averageCostFormatted': _formatter.formatAmount(averageCost),
      'monthlyCost': monthlyCost,
      'monthlyCostFormatted': _formatter.formatAmount(monthlyCost),
      'byType': byType.map((k, v) => MapEntry(k.displayName, v)),
      'countByType': countByType.map((k, v) => MapEntry(k.displayName, v)),
      'byStatus': byStatus.map((k, v) => MapEntry(k.displayName, v)),
      'mostExpensiveType': mostExpensiveType?.displayName,
      'mostExpensiveTypeCost': maxTypeCost,
      'mostExpensiveTypeCostFormatted': _formatter.formatAmount(maxTypeCost),
      'highestMaintenance': _filteredMaintenances.reduce((a, b) => a.cost > b.cost ? a : b).cost,
      'lowestMaintenance': _filteredMaintenances.reduce((a, b) => a.cost < b.cost ? a : b).cost,
      'completedCount': byStatus[MaintenanceStatus.completed] ?? 0,
      'pendingCount': byStatus[MaintenanceStatus.pending] ?? 0,
      'inProgressCount': byStatus[MaintenanceStatus.inProgress] ?? 0,
      'cancelledCount': byStatus[MaintenanceStatus.cancelled] ?? 0,
    };
  }

  /// Recarrega dados
  Future<void> refresh() async {
    await loadMaintenances();
  }

  /// Limpa erro atual
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Obtém relatório detalhado de uma manutenção
  Future<Map<String, dynamic>> getMaintenanceReport(String maintenanceId) async {
    final maintenance = getMaintenanceById(maintenanceId);
    if (maintenance == null) return {};

    final vehicle = await _vehiclesProvider.getVehicleById(maintenance.vehicleId);
    if (vehicle == null) return {};

    // Análise de manutenções similares
    final similarMaintenances = _maintenances
        .where((m) => m.type == maintenance.type && m.id != maintenance.id)
        .toList();

    double? averageSimilar;
    if (similarMaintenances.isNotEmpty) {
      averageSimilar = similarMaintenances.fold<double>(0, (sum, m) => sum + m.cost) / similarMaintenances.length;
    }

    // Última manutenção do mesmo tipo
    final lastSimilar = similarMaintenances
        .where((m) => m.serviceDate.isBefore(maintenance.serviceDate))
        .fold<MaintenanceEntity?>(null, (latest, current) {
          return latest == null || current.serviceDate.isAfter(latest.serviceDate) ? current : latest;
        });

    return {
      'maintenance': maintenance,
      'vehicle': vehicle,
      'analysis': {
        'totalSimilar': similarMaintenances.length,
        'averageSimilar': averageSimilar,
        'deviationFromAverage': averageSimilar != null 
            ? ((maintenance.cost - averageSimilar) / averageSimilar * 100) 
            : null,
        'lastSimilar': lastSimilar,
        'daysSinceLastSimilar': lastSimilar != null
            ? maintenance.serviceDate.difference(lastSimilar.serviceDate).inDays
            : null,
        'isOverdue': maintenance.hasNextService && maintenance.isNextServiceDue(vehicle.currentOdometer),
        'urgencyLevel': maintenance.urgencyLevel,
      },
    };
  }

  /// Obtém manutenções por urgência
  List<MaintenanceEntity> getMaintenancesByUrgency(String urgencyLevel) {
    return _filteredMaintenances.where((m) => m.urgencyLevel == urgencyLevel).toList();
  }

  /// Obtém manutenções de alto custo
  List<MaintenanceEntity> getHighCostMaintenances({double threshold = 1000.0}) {
    return _filteredMaintenances.where((m) => m.cost >= threshold).toList();
  }

  /// Obtém estatísticas por período
  Map<String, dynamic> getStatsByPeriod(DateTime start, DateTime end) {
    final periodMaintenances = _maintenances.where((m) {
      return m.serviceDate.isAfter(start.subtract(const Duration(days: 1))) &&
             m.serviceDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    if (periodMaintenances.isEmpty) return {};

    final totalCost = periodMaintenances.fold<double>(0, (sum, m) => sum + m.cost);
    final days = end.difference(start).inDays + 1;
    
    return {
      'totalRecords': periodMaintenances.length,
      'totalCost': totalCost,
      'totalCostFormatted': _formatter.formatAmount(totalCost),
      'averageDailyCost': totalCost / days,
      'averageDailyCostFormatted': _formatter.formatAmount(totalCost / days),
      'period': _formatter.formatServiceInterval(start, end),
    };
  }
}