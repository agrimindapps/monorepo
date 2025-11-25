import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/maintenance_entity.dart';

part 'maintenance_state.freezed.dart';

/// View states for maintenance feature
enum MaintenanceViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Status de manutenção
enum MaintenanceStatusFilter {
  all('Todas'),
  pending('Pendentes'),
  completed('Concluídas'),
  overdue('Atrasadas');

  const MaintenanceStatusFilter(this.displayName);
  final String displayName;
}

/// State imutável para gerenciamento de manutenções
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
sealed class MaintenanceState with _$MaintenanceState {
  const MaintenanceState._();

  const factory MaintenanceState({
    /// Lista de manutenções
    @Default([]) List<MaintenanceEntity> maintenances,

    /// Manutenção selecionada
    MaintenanceEntity? selectedMaintenance,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Filtro por veículo
    String? selectedVehicleId,

    /// Filtro por status
    @Default(MaintenanceStatusFilter.all) MaintenanceStatusFilter statusFilter,

    /// Filtro de busca
    @Default('') String searchQuery,

    /// Ordenação (date, cost, type)
    @Default('date') String sortBy,

    /// Ordem descendente
    @Default(true) bool isDescending,

    /// Total gasto em manutenções
    double? totalCost,

    /// Próxima manutenção agendada
    MaintenanceEntity? nextScheduled,
  }) = _MaintenanceState;

  /// Factory para estado inicial
  factory MaintenanceState.initial() => const MaintenanceState();

  // ========== Computed Properties ==========

  /// Manutenções filtradas
  List<MaintenanceEntity> get filteredMaintenances {
    var filtered = maintenances;

    // Filtrar por veículo
    if (selectedVehicleId != null) {
      filtered = filtered.where((m) => m.vehicleId == selectedVehicleId).toList();
    }

    // Filtrar por status
    switch (statusFilter) {
      case MaintenanceStatusFilter.pending:
        filtered = filtered.where((m) => m.status == MaintenanceStatus.pending).toList();
        break;
      case MaintenanceStatusFilter.completed:
        filtered = filtered.where((m) => m.status == MaintenanceStatus.completed).toList();
        break;
      case MaintenanceStatusFilter.overdue:
        filtered = filtered.where((m) {
          if (m.nextServiceDate == null) return false;
          return DateTime.now().isAfter(m.nextServiceDate!) &&
                 m.status != MaintenanceStatus.completed;
        }).toList();
        break;
      case MaintenanceStatusFilter.all:
        break;
    }

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((m) {
        return m.type.displayName.toLowerCase().contains(query) ||
            (m.description.toLowerCase().contains(query)) ||
            (m.workshopName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'date':
          comparison = a.serviceDate.compareTo(b.serviceDate);
          break;
        case 'cost':
          comparison = a.cost.compareTo(b.cost);
          break;
        case 'type':
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        default:
          comparison = a.serviceDate.compareTo(b.serviceDate);
      }
      return isDescending ? -comparison : comparison;
    });

    return filtered;
  }

  /// Manutenções pendentes
  List<MaintenanceEntity> get pendingMaintenances =>
      maintenances.where((m) => m.status == MaintenanceStatus.pending).toList();

  /// Manutenções atrasadas
  List<MaintenanceEntity> get overdueMaintenances =>
      maintenances.where((m) {
        if (m.nextServiceDate == null) return false;
        return DateTime.now().isAfter(m.nextServiceDate!) &&
               m.status != MaintenanceStatus.completed;
      }).toList();

  /// Manutenções concluídas
  List<MaintenanceEntity> get completedMaintenances =>
      maintenances.where((m) => m.status == MaintenanceStatus.completed).toList();

  /// Conta total de manutenções
  int get totalMaintenances => maintenances.length;

  /// Conta de manutenções filtradas
  int get filteredCount => filteredMaintenances.length;

  /// Conta de manutenções pendentes
  int get pendingCount => pendingMaintenances.length;

  /// Conta de manutenções atrasadas
  int get overdueCount => overdueMaintenances.length;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se lista está vazia
  bool get isEmpty => maintenances.isEmpty;

  /// Verifica se há manutenções filtradas
  bool get hasFilteredMaintenances => filteredMaintenances.isNotEmpty;

  /// Verifica se há busca ativa
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Verifica se há filtros ativos
  bool get hasActiveFilters =>
      selectedVehicleId != null ||
      statusFilter != MaintenanceStatusFilter.all ||
      hasSearchQuery;

  /// Estado da view baseado nos dados
  MaintenanceViewState get viewState {
    if (isLoading) return MaintenanceViewState.loading;
    if (hasError) return MaintenanceViewState.error;
    if (isEmpty) return MaintenanceViewState.empty;
    if (hasFilteredMaintenances) return MaintenanceViewState.loaded;
    return MaintenanceViewState.initial;
  }

  /// Verifica se há manutenção selecionada
  bool get hasSelectedMaintenance => selectedMaintenance != null;

  /// Verifica se há alertas (manutenções atrasadas)
  bool get hasAlerts => overdueCount > 0;
}

/// Extension para métodos de transformação do state
extension MaintenanceStateX on MaintenanceState {
  /// Limpa mensagem de erro
  MaintenanceState clearError() => copyWith(error: null);

  /// Limpa busca
  MaintenanceState clearSearch() => copyWith(searchQuery: '');

  /// Limpa seleção
  MaintenanceState clearSelection() => copyWith(selectedMaintenance: null);

  /// Reseta filtros
  MaintenanceState resetFilters() => copyWith(
        selectedVehicleId: null,
        statusFilter: MaintenanceStatusFilter.all,
        searchQuery: '',
        sortBy: 'date',
        isDescending: true,
      );
}
