
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../entities/fuel_record_entity.dart';

/// Service especializado para filtros e ordenação de registros de combustível
/// Aplica SRP (Single Responsibility Principle) - responsável apenas por filtros

class FuelFilterService {
  /// Filtra registros por veículo
  List<FuelRecordEntity> filterByVehicle(
    List<FuelRecordEntity> records,
    String vehicleId,
  ) {
    if (vehicleId.isEmpty) return records;
    return records.where((record) => record.vehicleId == vehicleId).toList();
  }

  /// Filtra registros por tipo de combustível
  List<FuelRecordEntity> filterByFuelType(
    List<FuelRecordEntity> records,
    FuelType fuelType,
  ) {
    return records.where((record) => record.fuelType == fuelType).toList();
  }

  /// Filtra registros por período de datas
  List<FuelRecordEntity> filterByDateRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
  }

  /// Filtra registros por query de busca (texto livre)
  /// Busca em: nome do posto, marca do posto, tipo de combustível e notas
  List<FuelRecordEntity> filterBySearchQuery(
    List<FuelRecordEntity> records,
    String query,
  ) {
    if (query.isEmpty) return records;

    final normalizedQuery = query.toLowerCase().trim();

    return records.where((record) {
      return record.gasStationName?.toLowerCase().contains(normalizedQuery) ==
              true ||
          record.gasStationBrand?.toLowerCase().contains(normalizedQuery) ==
              true ||
          record.notes?.toLowerCase().contains(normalizedQuery) == true ||
          record.fuelType.displayName.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  /// Filtra apenas registros com tanque cheio
  List<FuelRecordEntity> filterFullTankOnly(List<FuelRecordEntity> records) {
    return records.where((record) => record.fullTank).toList();
  }

  /// Filtra registros com consumo calculado
  List<FuelRecordEntity> filterWithConsumption(
    List<FuelRecordEntity> records,
  ) {
    return records
        .where((record) => record.consumption != null && record.consumption! > 0)
        .toList();
  }

  /// Filtra registros acima de um valor mínimo
  List<FuelRecordEntity> filterByMinimumCost(
    List<FuelRecordEntity> records,
    double minimumCost,
  ) {
    return records.where((record) => record.totalPrice >= minimumCost).toList();
  }

  /// Filtra registros abaixo de um valor máximo
  List<FuelRecordEntity> filterByMaximumCost(
    List<FuelRecordEntity> records,
    double maximumCost,
  ) {
    return records.where((record) => record.totalPrice <= maximumCost).toList();
  }

  /// Ordena registros por data (mais recentes primeiro por padrão)
  List<FuelRecordEntity> sortByDate(
    List<FuelRecordEntity> records, {
    bool descending = true,
  }) {
    final sortedRecords = List<FuelRecordEntity>.from(records);
    sortedRecords.sort((a, b) {
      return descending
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date);
    });
    return sortedRecords;
  }

  /// Ordena registros por valor total
  List<FuelRecordEntity> sortByTotalPrice(
    List<FuelRecordEntity> records, {
    bool descending = true,
  }) {
    final sortedRecords = List<FuelRecordEntity>.from(records);
    sortedRecords.sort((a, b) {
      return descending
          ? b.totalPrice.compareTo(a.totalPrice)
          : a.totalPrice.compareTo(b.totalPrice);
    });
    return sortedRecords;
  }

  /// Ordena registros por preço por litro
  List<FuelRecordEntity> sortByPricePerLiter(
    List<FuelRecordEntity> records, {
    bool descending = true,
  }) {
    final sortedRecords = List<FuelRecordEntity>.from(records);
    sortedRecords.sort((a, b) {
      return descending
          ? b.pricePerLiter.compareTo(a.pricePerLiter)
          : a.pricePerLiter.compareTo(b.pricePerLiter);
    });
    return sortedRecords;
  }

  /// Ordena registros por odômetro
  List<FuelRecordEntity> sortByOdometer(
    List<FuelRecordEntity> records, {
    bool descending = true,
  }) {
    final sortedRecords = List<FuelRecordEntity>.from(records);
    sortedRecords.sort((a, b) {
      return descending
          ? b.odometer.compareTo(a.odometer)
          : a.odometer.compareTo(b.odometer);
    });
    return sortedRecords;
  }

  /// Ordena registros por consumo (quando disponível)
  List<FuelRecordEntity> sortByConsumption(
    List<FuelRecordEntity> records, {
    bool descending = true,
  }) {
    final recordsWithConsumption = filterWithConsumption(records);

    recordsWithConsumption.sort((a, b) {
      final aConsumption = a.consumption ?? 0;
      final bConsumption = b.consumption ?? 0;

      return descending
          ? bConsumption.compareTo(aConsumption)
          : aConsumption.compareTo(bConsumption);
    });

    return recordsWithConsumption;
  }

  /// Obtém registros mais recentes (limit)
  List<FuelRecordEntity> getRecentRecords(
    List<FuelRecordEntity> records,
    int limit,
  ) {
    final sortedRecords = sortByDate(records, descending: true);
    return sortedRecords.take(limit).toList();
  }

  /// Obtém registros mais antigos (limit)
  List<FuelRecordEntity> getOldestRecords(
    List<FuelRecordEntity> records,
    int limit,
  ) {
    final sortedRecords = sortByDate(records, descending: false);
    return sortedRecords.take(limit).toList();
  }

  /// Aplica múltiplos filtros de uma vez
  List<FuelRecordEntity> applyFilters(
    List<FuelRecordEntity> records, {
    String? vehicleId,
    FuelType? fuelType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool? fullTankOnly,
    double? minimumCost,
    double? maximumCost,
  }) {
    var filteredRecords = records;

    if (vehicleId != null && vehicleId.isNotEmpty) {
      filteredRecords = filterByVehicle(filteredRecords, vehicleId);
    }

    if (fuelType != null) {
      filteredRecords = filterByFuelType(filteredRecords, fuelType);
    }

    if (startDate != null && endDate != null) {
      filteredRecords = filterByDateRange(filteredRecords, startDate, endDate);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredRecords = filterBySearchQuery(filteredRecords, searchQuery);
    }

    if (fullTankOnly == true) {
      filteredRecords = filterFullTankOnly(filteredRecords);
    }

    if (minimumCost != null) {
      filteredRecords = filterByMinimumCost(filteredRecords, minimumCost);
    }

    if (maximumCost != null) {
      filteredRecords = filterByMaximumCost(filteredRecords, maximumCost);
    }

    return filteredRecords;
  }

  /// Agrupa registros por veículo
  Map<String, List<FuelRecordEntity>> groupByVehicle(
    List<FuelRecordEntity> records,
  ) {
    final grouped = <String, List<FuelRecordEntity>>{};

    for (final record in records) {
      grouped.putIfAbsent(record.vehicleId, () => []).add(record);
    }

    return grouped;
  }

  /// Agrupa registros por mês
  Map<String, List<FuelRecordEntity>> groupByMonth(
    List<FuelRecordEntity> records,
  ) {
    final grouped = <String, List<FuelRecordEntity>>{};

    for (final record in records) {
      final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(monthKey, () => []).add(record);
    }

    return grouped;
  }

  /// Agrupa registros por tipo de combustível
  Map<FuelType, List<FuelRecordEntity>> groupByFuelType(
    List<FuelRecordEntity> records,
  ) {
    final grouped = <FuelType, List<FuelRecordEntity>>{};

    for (final record in records) {
      grouped.putIfAbsent(record.fuelType, () => []).add(record);
    }

    return grouped;
  }
}
