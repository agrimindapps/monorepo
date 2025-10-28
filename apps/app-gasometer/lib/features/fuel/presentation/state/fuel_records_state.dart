import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';

part 'fuel_records_state.freezed.dart';

/// View states for fuel records feature
enum FuelRecordsViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Filtro de período para registros de combustível
enum FuelRecordsPeriod {
  all('Todos'),
  week('Última Semana'),
  month('Último Mês'),
  threeMonths('3 Meses'),
  sixMonths('6 Meses'),
  year('Último Ano');

  const FuelRecordsPeriod(this.displayName);
  final String displayName;
}

/// State imutável para gerenciamento de registros de combustível
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
class FuelRecordsState with _$FuelRecordsState {
  const FuelRecordsState._();

  const factory FuelRecordsState({
    /// Lista de registros de abastecimento
    @Default([]) List<FuelRecordEntity> records,

    /// Registro selecionado
    FuelRecordEntity? selectedRecord,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Filtro por veículo
    String? selectedVehicleId,

    /// Filtro por tipo de combustível
    FuelType? selectedFuelType,

    /// Filtro de período
    @Default(FuelRecordsPeriod.all) FuelRecordsPeriod period,

    /// Ordenação (date, price, liters, odometer)
    @Default('date') String sortBy,

    /// Ordem descendente (mais recente primeiro)
    @Default(true) bool isDescending,

    /// Analytics - Consumo médio (km/l)
    double? averageConsumption,

    /// Analytics - Preço médio por litro
    double? averagePricePerLiter,

    /// Analytics - Total gasto no período
    double? totalSpent,

    /// Analytics - Total de litros
    double? totalLiters,

    /// Analytics - Distância total percorrida
    double? totalDistance,
  }) = _FuelRecordsState;

  /// Factory para estado inicial
  factory FuelRecordsState.initial() => const FuelRecordsState();

  // ========== Computed Properties ==========

  /// Registros filtrados
  List<FuelRecordEntity> get filteredRecords {
    var filtered = records;

    // Filtrar por veículo
    if (selectedVehicleId != null) {
      filtered = filtered.where((r) => r.vehicleId == selectedVehicleId).toList();
    }

    // Filtrar por tipo de combustível
    if (selectedFuelType != null) {
      filtered = filtered.where((r) => r.fuelType == selectedFuelType).toList();
    }

    // Filtrar por período
    if (period != FuelRecordsPeriod.all) {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case FuelRecordsPeriod.week:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case FuelRecordsPeriod.month:
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case FuelRecordsPeriod.threeMonths:
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case FuelRecordsPeriod.sixMonths:
          startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case FuelRecordsPeriod.year:
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        case FuelRecordsPeriod.all:
          startDate = DateTime(1900);
          break;
      }

      filtered = filtered.where((r) => r.date.isAfter(startDate)).toList();
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'price':
          comparison = a.totalPrice.compareTo(b.totalPrice);
          break;
        case 'liters':
          comparison = a.liters.compareTo(b.liters);
          break;
        case 'odometer':
          comparison = a.odometer.compareTo(b.odometer);
          break;
        default:
          comparison = a.date.compareTo(b.date);
      }
      return isDescending ? -comparison : comparison;
    });

    return filtered;
  }

  /// Conta total de registros
  int get totalRecords => records.length;

  /// Conta de registros filtrados
  int get filteredCount => filteredRecords.length;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se lista está vazia
  bool get isEmpty => records.isEmpty;

  /// Verifica se há registros filtrados
  bool get hasFilteredRecords => filteredRecords.isNotEmpty;

  /// Verifica se há filtros ativos
  bool get hasActiveFilters =>
      selectedVehicleId != null ||
      selectedFuelType != null ||
      period != FuelRecordsPeriod.all;

  /// Estado da view baseado nos dados
  FuelRecordsViewState get viewState {
    if (isLoading) return FuelRecordsViewState.loading;
    if (hasError) return FuelRecordsViewState.error;
    if (isEmpty) return FuelRecordsViewState.empty;
    if (hasFilteredRecords) return FuelRecordsViewState.loaded;
    return FuelRecordsViewState.initial;
  }

  /// Verifica se há registro selecionado
  bool get hasSelectedRecord => selectedRecord != null;

  /// Verifica se há analytics calculadas
  bool get hasAnalytics =>
      averageConsumption != null ||
      averagePricePerLiter != null ||
      totalSpent != null;
}

/// Extension para métodos de transformação do state
extension FuelRecordsStateX on FuelRecordsState {
  /// Limpa mensagem de erro
  FuelRecordsState clearError() => copyWith(error: null);

  /// Limpa seleção
  FuelRecordsState clearSelection() => copyWith(selectedRecord: null);

  /// Reseta filtros
  FuelRecordsState resetFilters() => copyWith(
        selectedVehicleId: null,
        selectedFuelType: null,
        period: FuelRecordsPeriod.all,
        sortBy: 'date',
        isDescending: true,
      );

  /// Limpa analytics
  FuelRecordsState clearAnalytics() => copyWith(
        averageConsumption: null,
        averagePricePerLiter: null,
        totalSpent: null,
        totalLiters: null,
        totalDistance: null,
      );
}
