import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/vehicle_entity.dart';

part 'vehicles_state.freezed.dart';

/// View states for vehicles feature
enum VehiclesViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// State imutável para gerenciamento de veículos
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
class VehiclesState with _$VehiclesState {
  const VehiclesState._();

  const factory VehiclesState({
    /// Lista de veículos
    @Default([]) List<VehicleEntity> vehicles,

    /// Veículo selecionado
    VehicleEntity? selectedVehicle,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Filtro de busca
    @Default('') String searchQuery,

    /// Mostrar apenas veículos ativos
    @Default(true) bool showActiveOnly,

    /// Ordenação (brand, model, year)
    @Default('brand') String sortBy,

    /// Ordem ascendente
    @Default(true) bool isAscending,
  }) = _VehiclesState;

  /// Factory para estado inicial
  factory VehiclesState.initial() => const VehiclesState();

  // ========== Computed Properties ==========

  /// Veículos filtrados por busca e status
  List<VehicleEntity> get filteredVehicles {
    var filtered = vehicles;

    // Filtrar por status ativo
    if (showActiveOnly) {
      filtered = filtered.where((v) => v.isActive).toList();
    }

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((v) {
        return v.name.toLowerCase().contains(query) ||
            v.brand.toLowerCase().contains(query) ||
            v.model.toLowerCase().contains(query) ||
            v.licensePlate.toLowerCase().contains(query);
      }).toList();
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'brand':
          comparison = a.brand.compareTo(b.brand);
          break;
        case 'model':
          comparison = a.model.compareTo(b.model);
          break;
        case 'year':
          comparison = a.year.compareTo(b.year);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Conta total de veículos
  int get totalVehicles => vehicles.length;

  /// Conta de veículos ativos
  int get activeVehiclesCount => vehicles.where((v) => v.isActive).length;

  /// Conta de veículos filtrados
  int get filteredCount => filteredVehicles.length;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se lista está vazia
  bool get isEmpty => vehicles.isEmpty;

  /// Verifica se há veículos filtrados
  bool get hasFilteredVehicles => filteredVehicles.isNotEmpty;

  /// Verifica se há busca ativa
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Estado da view baseado nos dados
  VehiclesViewState get viewState {
    if (isLoading) return VehiclesViewState.loading;
    if (hasError) return VehiclesViewState.error;
    if (isEmpty) return VehiclesViewState.empty;
    if (filteredVehicles.isNotEmpty) return VehiclesViewState.loaded;
    return VehiclesViewState.initial;
  }

  /// Verifica se há veículo selecionado
  bool get hasSelectedVehicle => selectedVehicle != null;
}

/// Extension para métodos de transformação do state
extension VehiclesStateX on VehiclesState {
  /// Limpa mensagem de erro
  VehiclesState clearError() => copyWith(error: null);

  /// Limpa busca
  VehiclesState clearSearch() => copyWith(searchQuery: '');

  /// Limpa seleção
  VehiclesState clearSelection() => copyWith(selectedVehicle: null);

  /// Reseta filtros
  VehiclesState resetFilters() => copyWith(
        searchQuery: '',
        showActiveOnly: true,
        sortBy: 'brand',
        isAscending: true,
      );
}
