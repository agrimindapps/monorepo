import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../models/maintenance_form_model.dart';
import 'maintenances_state.dart';

part 'maintenances_notifier.g.dart';

/// Notifier Riverpod para gerenciar manutenções
///
/// Features:
/// - CRUD de manutenções (load, add, update, delete)
/// - Filtros por veículo, tipo, status, período, busca de texto
/// - Ordenação por múltiplos campos (data, custo, tipo, odômetro)
/// - Cálculo de estatísticas (custos totais, médias, agrupamentos)
/// - Análise de manutenções similares e relatórios
/// - Detecção de manutenções vencidas/pendentes
@riverpod
class MaintenancesNotifier extends _$MaintenancesNotifier {
  // Services e repositories injetados via GetIt
  late final MaintenanceRepository _repository;
  late final MaintenanceFormatterService _formatter;
  late final GetVehicleById _getVehicleById;

  @override
  MaintenancesState build() {
    // Inicializa services via GetIt
    _repository = getIt<MaintenanceRepository>();
    _formatter = MaintenanceFormatterService();
    _getVehicleById = getIt<GetVehicleById>();

    // Inicializa repository se necessário
    _repository.initialize();

    // Carrega dados iniciais
    loadMaintenances();

    return const MaintenancesState();
  }

  // ==================== CRUD Operations ====================

  /// Carrega todas as manutenções
  Future<void> loadMaintenances() async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: () => null,
      );

      final maintenances = await _repository.getAllMaintenances();

      state = state.copyWith(
        maintenances: maintenances,
        isLoading: false,
      );

      // Aplica filtros e calcula estatísticas
      _applyFiltersAndStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao carregar manutenções: $e',
      );
    }
  }

  /// Carrega manutenções por veículo
  Future<void> loadMaintenancesByVehicle(String vehicleId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: () => null,
        selectedVehicleId: () => vehicleId,
      );

      final maintenances = await _repository.getMaintenancesByVehicle(vehicleId);

      state = state.copyWith(
        maintenances: maintenances,
        isLoading: false,
      );

      // Aplica filtros e calcula estatísticas
      _applyFiltersAndStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao carregar manutenções: $e',
      );
    }
  }

  /// Adiciona nova manutenção
  Future<bool> addMaintenance(MaintenanceFormModel formModel) async {
    try {
      state = state.clearError();

      // Validar dados completos
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          errorMessage: () => 'Dados inválidos: ${validationErrors.values.first}',
        );
        return false;
      }

      // Converter para entity
      final maintenance = formModel.toMaintenanceEntity();

      // Salvar no repositório
      final saved = await _repository.saveMaintenance(maintenance);

      if (saved != null) {
        // Atualizar lista local
        final updatedList = List<MaintenanceEntity>.from(state.maintenances);
        updatedList.add(saved);

        state = state.copyWith(
          maintenances: updatedList,
        );

        // Aplica filtros e calcula estatísticas
        _applyFiltersAndStats();

        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Erro ao salvar manutenção: $e',
      );
      return false;
    }
  }

  /// Atualiza manutenção existente
  Future<bool> updateMaintenance(MaintenanceFormModel formModel) async {
    try {
      state = state.clearError();

      if (!formModel.isEditing) {
        state = state.copyWith(
          errorMessage: () => 'Manutenção não existe para edição',
        );
        return false;
      }

      // Validar dados
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          errorMessage: () => 'Dados inválidos: ${validationErrors.values.first}',
        );
        return false;
      }

      // Converter para entity
      final maintenance = formModel.toMaintenanceEntity();

      // Atualizar no repositório
      final updated = await _repository.updateMaintenance(maintenance);

      if (updated != null) {
        // Atualizar lista local
        final updatedList = List<MaintenanceEntity>.from(state.maintenances);
        final index = updatedList.indexWhere((m) => m.id == maintenance.id);

        if (index >= 0) {
          updatedList[index] = updated;

          state = state.copyWith(
            maintenances: updatedList,
          );

          // Aplica filtros e calcula estatísticas
          _applyFiltersAndStats();
        }

        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Erro ao atualizar manutenção: $e',
      );
      return false;
    }
  }

  /// Remove manutenção
  Future<bool> removeMaintenance(String maintenanceId) async {
    try {
      state = state.clearError();

      final success = await _repository.deleteMaintenance(maintenanceId);

      if (success) {
        // Atualizar lista local
        final updatedList = List<MaintenanceEntity>.from(state.maintenances);
        updatedList.removeWhere((m) => m.id == maintenanceId);

        state = state.copyWith(
          maintenances: updatedList,
        );

        // Aplica filtros e calcula estatísticas
        _applyFiltersAndStats();

        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Erro ao remover manutenção: $e',
      );
      return false;
    }
  }

  // ==================== Queries ====================

  /// Busca manutenção por ID
  MaintenanceEntity? getMaintenanceById(String maintenanceId) {
    try {
      return state.maintenances.firstWhere((m) => m.id == maintenanceId);
    } catch (e) {
      return null;
    }
  }

  /// Carrega manutenções pendentes
  Future<List<MaintenanceEntity>> getUpcomingMaintenances() async {
    try {
      // Buscar odômetro atual do veículo selecionado ou usar 0
      double currentOdometer = 0;

      if (state.selectedVehicleId != null) {
        final vehicleResult = await _getVehicleById(
          GetVehicleByIdParams(vehicleId: state.selectedVehicleId!),
        );

        await vehicleResult.fold(
          (failure) async {
            // Ignora erro e usa 0
          },
          (vehicle) async {
            currentOdometer = vehicle.currentOdometer;
          },
        );
      }

      return await _repository.getUpcomingMaintenances(currentOdometer);
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Erro ao carregar manutenções pendentes: $e',
      );
      return [];
    }
  }

  /// Obtém manutenções por urgência
  List<MaintenanceEntity> getMaintenancesByUrgency(String urgencyLevel) {
    return state.filteredMaintenances
        .where((m) => m.urgencyLevel == urgencyLevel)
        .toList();
  }

  /// Obtém manutenções de alto custo
  List<MaintenanceEntity> getHighCostMaintenances({double threshold = 1000.0}) {
    return state.filteredMaintenances.where((m) => m.cost >= threshold).toList();
  }

  // ==================== Filters ====================

  /// Aplica filtro por veículo
  void filterByVehicle(String? vehicleId) {
    state = state.copyWith(
      selectedVehicleId: () => vehicleId,
    );
    _applyFiltersAndStats();
  }

  /// Aplica filtro por tipo
  void filterByType(MaintenanceType? type) {
    state = state.copyWith(
      selectedType: () => type,
    );
    _applyFiltersAndStats();
  }

  /// Aplica filtro por status
  void filterByStatus(MaintenanceStatus? status) {
    state = state.copyWith(
      selectedStatus: () => status,
    );
    _applyFiltersAndStats();
  }

  /// Aplica filtro por período
  void filterByPeriod(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: () => start,
      endDate: () => end,
    );
    _applyFiltersAndStats();
  }

  /// Aplica busca por texto
  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
    );
    _applyFiltersAndStats();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    state = state.clearFilters();
    _applyFiltersAndStats();
  }

  // ==================== Sorting ====================

  /// Ordena por campo específico
  void setSortBy(String field, {bool? ascending}) {
    state = state.copyWith(
      sortBy: field,
      sortAscending: ascending ?? (state.sortBy == field ? !state.sortAscending : false),
    );
    _applySort();
  }

  // ==================== Internal Methods ====================

  /// Aplica filtros à lista de manutenções
  void _applyFiltersAndStats() {
    final filtered = state.maintenances.where((maintenance) {
      // Filtro por veículo
      if (state.selectedVehicleId != null &&
          maintenance.vehicleId != state.selectedVehicleId) {
        return false;
      }

      // Filtro por tipo
      if (state.selectedType != null && maintenance.type != state.selectedType) {
        return false;
      }

      // Filtro por status
      if (state.selectedStatus != null &&
          maintenance.status != state.selectedStatus) {
        return false;
      }

      // Filtro por período
      if (state.startDate != null) {
        final startOfDay = DateTime(
          state.startDate!.year,
          state.startDate!.month,
          state.startDate!.day,
        );
        if (maintenance.serviceDate.isBefore(startOfDay)) return false;
      }

      if (state.endDate != null) {
        final endOfDay = DateTime(
          state.endDate!.year,
          state.endDate!.month,
          state.endDate!.day,
          23,
          59,
          59,
        );
        if (maintenance.serviceDate.isAfter(endOfDay)) return false;
      }

      // Filtro por busca de texto
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
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

    state = state.copyWith(
      filteredMaintenances: filtered,
    );

    _applySort();
    _calculateStats();
  }

  /// Aplica ordenação à lista filtrada
  void _applySort() {
    final sorted = List<MaintenanceEntity>.from(state.filteredMaintenances);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (state.sortBy) {
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

      return state.sortAscending ? comparison : -comparison;
    });

    state = state.copyWith(
      filteredMaintenances: sorted,
    );
  }

  /// Calcula estatísticas da lista filtrada
  void _calculateStats() {
    if (state.filteredMaintenances.isEmpty) {
      state = state.copyWith(stats: const {});
      return;
    }

    final totalCost = state.filteredMaintenances.fold<double>(
      0,
      (sum, m) => sum + m.cost,
    );
    final averageCost = totalCost / state.filteredMaintenances.length;

    // Agrupar por tipo
    final byType = <MaintenanceType, double>{};
    final countByType = <MaintenanceType, int>{};

    for (final maintenance in state.filteredMaintenances) {
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
    if (state.filteredMaintenances.length >= 2) {
      final sortedByDate = List<MaintenanceEntity>.from(state.filteredMaintenances)
        ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

      final firstDate = sortedByDate.first.serviceDate;
      final lastDate = sortedByDate.last.serviceDate;
      final monthsDiff =
          ((lastDate.year - firstDate.year) * 12 + lastDate.month - firstDate.month) +
              1;

      if (monthsDiff > 0) {
        monthlyCost = totalCost / monthsDiff;
      }
    }

    // Agrupar por status
    final byStatus = <MaintenanceStatus, int>{};
    for (final maintenance in state.filteredMaintenances) {
      byStatus[maintenance.status] = (byStatus[maintenance.status] ?? 0) + 1;
    }

    final stats = {
      'totalRecords': state.filteredMaintenances.length,
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
      'highestMaintenance': state.filteredMaintenances
          .reduce((a, b) => a.cost > b.cost ? a : b)
          .cost,
      'lowestMaintenance': state.filteredMaintenances
          .reduce((a, b) => a.cost < b.cost ? a : b)
          .cost,
      'completedCount': byStatus[MaintenanceStatus.completed] ?? 0,
      'pendingCount': byStatus[MaintenanceStatus.pending] ?? 0,
      'inProgressCount': byStatus[MaintenanceStatus.inProgress] ?? 0,
      'cancelledCount': byStatus[MaintenanceStatus.cancelled] ?? 0,
    };

    state = state.copyWith(stats: stats);
  }

  // ==================== Reports ====================

  /// Obtém relatório detalhado de uma manutenção
  Future<Map<String, dynamic>> getMaintenanceReport(String maintenanceId) async {
    final maintenance = getMaintenanceById(maintenanceId);
    if (maintenance == null) return {};

    VehicleEntity? vehicle;
    final vehicleResult = await _getVehicleById(
      GetVehicleByIdParams(vehicleId: maintenance.vehicleId),
    );

    await vehicleResult.fold(
      (failure) async {
        // Ignora erro
      },
      (v) async {
        vehicle = v;
      },
    );

    if (vehicle == null) return {};

    // Análise de manutenções similares
    final similarMaintenances = state.maintenances
        .where((m) => m.type == maintenance.type && m.id != maintenance.id)
        .toList();

    double? averageSimilar;
    if (similarMaintenances.isNotEmpty) {
      averageSimilar = similarMaintenances.fold<double>(0, (sum, m) => sum + m.cost) /
          similarMaintenances.length;
    }

    // Última manutenção do mesmo tipo
    final lastSimilar = similarMaintenances
        .where((m) => m.serviceDate.isBefore(maintenance.serviceDate))
        .fold<MaintenanceEntity?>(null, (latest, current) {
      return latest == null || current.serviceDate.isAfter(latest.serviceDate)
          ? current
          : latest;
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
        'isOverdue': maintenance.hasNextService &&
            maintenance.isNextServiceDue(vehicle!.currentOdometer),
        'urgencyLevel': maintenance.urgencyLevel,
      },
    };
  }

  /// Obtém estatísticas por período
  Map<String, dynamic> getStatsByPeriod(DateTime start, DateTime end) {
    final periodMaintenances = state.maintenances.where((m) {
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

  // ==================== Refresh ====================

  /// Recarrega dados
  Future<void> refresh() async {
    await loadMaintenances();
  }

  /// Limpa erro atual
  void clearError() {
    state = state.clearError();
  }
}
