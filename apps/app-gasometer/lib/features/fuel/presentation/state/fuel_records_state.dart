import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';

part 'fuel_records_state.freezed.dart';

/// View states for fuel records feature
enum FuelRecordsViewState { initial, loading, loaded, error, empty }

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

    /// Filtro por mês específico
    DateTime? selectedMonth,

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
}
