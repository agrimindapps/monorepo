import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/odometer_entity.dart';
import '../../domain/usecases/add_odometer_reading.dart';
import '../../domain/usecases/delete_odometer_reading.dart';
import '../../domain/usecases/get_last_odometer_reading.dart';
import '../../domain/usecases/get_odometer_readings_by_vehicle.dart';
import 'odometer_providers.dart';
import 'odometer_state.dart';

part 'odometer_notifier.g.dart';

@riverpod
class OdometerNotifier extends _$OdometerNotifier {
  late final GetOdometerReadingsByVehicleUseCase _getReadingsUseCase;
  late final GetLastOdometerReadingUseCase _getLastReadingUseCase;
  late final DeleteOdometerReadingUseCase _deleteReadingUseCase;
  late final AddOdometerReadingUseCase _addReadingUseCase;
  
  /// Cache para restauração (undo)
  final Map<String, OdometerEntity> _deletedCache = {};

  @override
  OdometerState build() {
    _getReadingsUseCase = ref.watch(getOdometerReadingsByVehicleProvider);
    _getLastReadingUseCase = ref.watch(getLastOdometerReadingProvider);
    _deleteReadingUseCase = ref.watch(deleteOdometerReadingProvider);
    _addReadingUseCase = ref.watch(addOdometerReadingProvider);
    return const OdometerState();
  }

  /// Carrega leituras de odômetro por veículo
  Future<void> loadByVehicle(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) {
        state = state.copyWith(readings: [], filteredReadings: []);
        return;
      }

      state = state.copyWith(isLoading: true, selectedVehicleId: vehicleId);

      final result = await _getReadingsUseCase(vehicleId);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (readings) {
          state = state.copyWith(
            readings: readings,
            isLoading: false,
            errorMessage: null,
          );
          _applyFilters();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Seleciona mês para filtro
  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: month);
    _applyFilters();
  }

  /// Limpa filtro de mês
  void clearMonthFilter() {
    state = state.copyWith(clearMonth: true);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.readings;

    if (state.selectedMonth != null) {
      filtered = filtered.where((r) {
        return r.registrationDate.year == state.selectedMonth!.year &&
            r.registrationDate.month == state.selectedMonth!.month;
      }).toList();
    }

    state = state.copyWith(filteredReadings: filtered);
  }

  /// Obtém última leitura de odômetro
  Future<OdometerEntity?> getLatestReading(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) return null;

      final result = await _getLastReadingUseCase(vehicleId);
      
      return result.fold(
        (failure) => null,
        (reading) => reading,
      );
    } catch (e) {
      return null;
    }
  }

  /// Remove leitura otimisticamente (para undo)
  Future<void> deleteOptimistic(String readingId) async {
    // Encontra o item a ser removido
    final itemToDelete = state.readings.firstWhere(
      (r) => r.id == readingId,
      orElse: () => throw Exception('Item não encontrado'),
    );
    
    // Guarda no cache para possível restauração
    _deletedCache[readingId] = itemToDelete;
    
    // Remove otimisticamente da UI
    final newReadings = state.readings.where((r) => r.id != readingId).toList();
    state = state.copyWith(readings: newReadings);
    _applyFilters();
    
    // Executa delete no backend
    final result = await _deleteReadingUseCase(readingId);
    
    result.fold(
      (failure) {
        // Se falhou, restaura o item
        _restoreFromCache(readingId);
      },
      (_) {
        // Sucesso - remove do cache após timeout do undo
        Future.delayed(const Duration(seconds: 6), () {
          _deletedCache.remove(readingId);
        });
      },
    );
  }

  /// Restaura item deletado (undo)
  Future<void> restoreDeleted(String readingId) async {
    final cachedItem = _deletedCache[readingId];
    if (cachedItem == null) return;
    
    // Restaura na UI primeiro
    _restoreFromCache(readingId);
    
    // Re-adiciona no backend
    await _addReadingUseCase(cachedItem);
    
    // Remove do cache
    _deletedCache.remove(readingId);
  }

  void _restoreFromCache(String readingId) {
    final cachedItem = _deletedCache[readingId];
    if (cachedItem == null) return;
    
    final newReadings = [...state.readings, cachedItem]
      ..sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    
    state = state.copyWith(readings: newReadings);
    _applyFilters();
  }

  /// Obtém uma leitura por ID
  OdometerEntity? getReadingById(String id) {
    try {
      return state.readings.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
