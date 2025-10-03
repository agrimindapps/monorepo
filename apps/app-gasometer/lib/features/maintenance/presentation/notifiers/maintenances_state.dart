import 'package:equatable/equatable.dart';

import '../../domain/entities/maintenance_entity.dart';

/// Estado imutável para o gerenciador de manutenções
///
/// Gerencia:
/// - Lista completa de manutenções
/// - Lista filtrada/ordenada
/// - Estados de loading/erro
/// - Filtros aplicados (veículo, tipo, status, período, busca)
/// - Ordenação (campo e direção)
/// - Estatísticas calculadas
class MaintenancesState extends Equatable {
  const MaintenancesState({
    this.maintenances = const [],
    this.filteredMaintenances = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedVehicleId,
    this.selectedType,
    this.selectedStatus,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
    this.sortBy = 'serviceDate',
    this.sortAscending = false,
    this.stats = const {},
  });

  // ==================== Data ====================

  /// Lista completa de manutenções (sem filtros)
  final List<MaintenanceEntity> maintenances;

  /// Lista filtrada/ordenada para exibição
  final List<MaintenanceEntity> filteredMaintenances;

  // ==================== UI State ====================

  /// Indica se está carregando dados
  final bool isLoading;

  /// Mensagem de erro atual (null se não houver)
  final String? errorMessage;

  // ==================== Filters ====================

  /// ID do veículo selecionado para filtro
  final String? selectedVehicleId;

  /// Tipo de manutenção selecionado para filtro
  final MaintenanceType? selectedType;

  /// Status selecionado para filtro
  final MaintenanceStatus? selectedStatus;

  /// Data inicial do período de filtro
  final DateTime? startDate;

  /// Data final do período de filtro
  final DateTime? endDate;

  /// Texto de busca para filtrar por título/descrição/oficina
  final String searchQuery;

  // ==================== Sorting ====================

  /// Campo usado para ordenação
  /// Valores válidos: 'serviceDate', 'cost', 'type', 'odometer', 'title', 'status'
  final String sortBy;

  /// Direção da ordenação (true = ascendente, false = descendente)
  final bool sortAscending;

  // ==================== Statistics ====================

  /// Estatísticas calculadas da lista filtrada
  /// Inclui: totalRecords, totalCost, averageCost, monthlyCost,
  ///         byType, countByType, byStatus, etc.
  final Map<String, dynamic> stats;

  // ==================== Computed Properties ====================

  /// Indica se há filtros ativos
  bool get hasActiveFilters =>
      selectedVehicleId != null ||
      selectedType != null ||
      selectedStatus != null ||
      startDate != null ||
      endDate != null ||
      searchQuery.isNotEmpty;

  /// Indica se há dados para exibir
  bool get hasData => filteredMaintenances.isNotEmpty;

  /// Indica se está em estado vazio (sem dados e sem loading)
  bool get isEmpty => !isLoading && !hasData;

  /// Indica se há erro
  bool get hasError => errorMessage != null;

  // ==================== CopyWith ====================

  MaintenancesState copyWith({
    List<MaintenanceEntity>? maintenances,
    List<MaintenanceEntity>? filteredMaintenances,
    bool? isLoading,
    String? Function()? errorMessage,
    String? Function()? selectedVehicleId,
    MaintenanceType? Function()? selectedType,
    MaintenanceStatus? Function()? selectedStatus,
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    Map<String, dynamic>? stats,
  }) {
    return MaintenancesState(
      maintenances: maintenances ?? this.maintenances,
      filteredMaintenances: filteredMaintenances ?? this.filteredMaintenances,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      selectedVehicleId: selectedVehicleId != null ? selectedVehicleId() : this.selectedVehicleId,
      selectedType: selectedType != null ? selectedType() : this.selectedType,
      selectedStatus: selectedStatus != null ? selectedStatus() : this.selectedStatus,
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      stats: stats ?? this.stats,
    );
  }

  /// Limpa mensagem de erro
  MaintenancesState clearError() {
    return copyWith(
      errorMessage: () => null,
    );
  }

  /// Limpa todos os filtros
  MaintenancesState clearFilters() {
    return copyWith(
      selectedVehicleId: () => null,
      selectedType: () => null,
      selectedStatus: () => null,
      startDate: () => null,
      endDate: () => null,
      searchQuery: '',
    );
  }

  // ==================== Equatable ====================

  @override
  List<Object?> get props => [
        maintenances,
        filteredMaintenances,
        isLoading,
        errorMessage,
        selectedVehicleId,
        selectedType,
        selectedStatus,
        startDate,
        endDate,
        searchQuery,
        sortBy,
        sortAscending,
        stats,
      ];
}
