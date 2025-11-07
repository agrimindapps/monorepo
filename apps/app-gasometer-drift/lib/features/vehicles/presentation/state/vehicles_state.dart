import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/vehicle_entity.dart';

part 'vehicles_state.freezed.dart';

/// View states for vehicles feature
enum VehiclesViewState { initial, loading, loaded, error, empty }

/// State imutável para gerenciamento de veículos
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
class VehiclesState with _$VehiclesState {
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
}
