import '../../data/models/fuel_supply_model.dart';

/// Service responsible for fuel supply business logic operations
/// Extracted from FuelSupplyModel to follow Single Responsibility Principle
class FuelBusinessService {
  /// Calculate fuel consumption in km/L with previous odometer
  static double calculateConsumption(
    FuelSupplyModel fuelSupply,
    double previousOdometer,
  ) {
    if (fuelSupply.liters <= 0) return 0.0;

    final distanceTraveled = fuelSupply.odometer - previousOdometer;
    if (distanceTraveled <= 0) return 0.0;

    return distanceTraveled / fuelSupply.liters;
  }
  
  /// Calculate consumption in L/100km (European standard)
  static double calculateConsumptionL100km(
    FuelSupplyModel fuelSupply,
    double previousOdometer,
  ) {
    final consumptionKmL = calculateConsumption(fuelSupply, previousOdometer);
    if (consumptionKmL <= 0) return 0.0;
    
    return 100 / consumptionKmL;
  }

  /// Calculate price per liter from total value and liters
  static double calculatePricePerLiter(FuelSupplyModel fuelSupply) {
    return fuelSupply.liters > 0 ? fuelSupply.totalPrice / fuelSupply.liters : 0.0;
  }

  /// Calculate total value from price per liter and liters
  static double calculateTotalValue(double pricePerLiter, double liters) {
    return pricePerLiter * liters;
  }

  /// Calculate average consumption from a list of fuel supplies
  static double calculateAverageConsumption(
    List<FuelSupplyModel> fuelSupplies,
    List<double> previousOdometers,
  ) {
    if (fuelSupplies.isEmpty || fuelSupplies.length != previousOdometers.length) {
      return 0.0;
    }

    final consumptions = <double>[];
    for (int i = 0; i < fuelSupplies.length; i++) {
      final consumption = calculateConsumption(fuelSupplies[i], previousOdometers[i]);
      if (consumption > 0) {
        consumptions.add(consumption);
      }
    }

    if (consumptions.isEmpty) return 0.0;
    return consumptions.reduce((a, b) => a + b) / consumptions.length;
  }

  /// Calculate total fuel cost from a list of fuel supplies
  static double calculateTotalFuelCost(List<FuelSupplyModel> fuelSupplies) {
    return fuelSupplies.fold(0.0, (total, supply) => total + supply.totalPrice);
  }

  /// Calculate total liters from a list of fuel supplies
  static double calculateTotalLiters(List<FuelSupplyModel> fuelSupplies) {
    return fuelSupplies.fold(0.0, (total, supply) => total + supply.liters);
  }

  /// Calculate average price per liter from a list of fuel supplies
  static double calculateAveragePricePerLiter(List<FuelSupplyModel> fuelSupplies) {
    if (fuelSupplies.isEmpty) return 0.0;
    
    final totalValue = calculateTotalFuelCost(fuelSupplies);
    final totalLiters = calculateTotalLiters(fuelSupplies);
    
    return totalLiters > 0 ? totalValue / totalLiters : 0.0;
  }

  /// Filter fuel supplies by vehicle
  static List<FuelSupplyModel> filterByVehicle(
    List<FuelSupplyModel> fuelSupplies,
    String vehicleId,
  ) {
    return fuelSupplies
        .where((supply) => supply.vehicleId == vehicleId)
        .toList();
  }

  /// Filter fuel supplies by date range
  static List<FuelSupplyModel> filterByDateRange(
    List<FuelSupplyModel> fuelSupplies,
    DateTime startDate,
    DateTime endDate,
  ) {
    return fuelSupplies.where((supply) {
      final supplyDate = DateTime.fromMillisecondsSinceEpoch(supply.date);
      return supplyDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             supplyDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filter fuel supplies by fuel type
  static List<FuelSupplyModel> filterByFuelType(
    List<FuelSupplyModel> fuelSupplies,
    int fuelType,
  ) {
    return fuelSupplies
        .where((supply) => supply.fuelType == fuelType)
        .toList();
  }

  /// Filter fuel supplies by gas station
  static List<FuelSupplyModel> filterByGasStation(
    List<FuelSupplyModel> fuelSupplies,
    String gasStation,
  ) {
    return fuelSupplies
        .where((supply) => supply.gasStationName?.toLowerCase().contains(gasStation.toLowerCase()) ?? false)
        .toList();
  }

  /// Sort fuel supplies by date (most recent first)
  static List<FuelSupplyModel> sortByDateDescending(List<FuelSupplyModel> fuelSupplies) {
    final sortedList = List<FuelSupplyModel>.from(fuelSupplies);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }

  /// Sort fuel supplies by odometer (highest first)
  static List<FuelSupplyModel> sortByOdometerDescending(List<FuelSupplyModel> fuelSupplies) {
    final sortedList = List<FuelSupplyModel>.from(fuelSupplies);
    sortedList.sort((a, b) => b.odometer.compareTo(a.odometer));
    return sortedList;
  }

  /// Group fuel supplies by month
  static Map<String, List<FuelSupplyModel>> groupByMonth(List<FuelSupplyModel> fuelSupplies) {
    final Map<String, List<FuelSupplyModel>> grouped = {};
    
    for (final supply in fuelSupplies) {
      final date = DateTime.fromMillisecondsSinceEpoch(supply.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      grouped.putIfAbsent(monthKey, () => <FuelSupplyModel>[]);
      grouped[monthKey]!.add(supply);
    }
    
    return grouped;
  }

  /// Group fuel supplies by fuel type
  static Map<int, List<FuelSupplyModel>> groupByFuelType(List<FuelSupplyModel> fuelSupplies) {
    final Map<int, List<FuelSupplyModel>> grouped = {};
    
    for (final supply in fuelSupplies) {
      grouped.putIfAbsent(supply.fuelType, () => <FuelSupplyModel>[]);
      grouped[supply.fuelType]!.add(supply);
    }
    
    return grouped;
  }

  /// Validate fuel supply basic fields
  static bool isValidFuelSupply(FuelSupplyModel fuelSupply) {
    return fuelSupply.vehicleId.isNotEmpty &&
           fuelSupply.date > 0 &&
           fuelSupply.liters > 0 &&
           fuelSupply.totalPrice > 0 &&
           fuelSupply.odometer > 0 &&
           fuelSupply.pricePerLiter > 0;
  }
  
  /// Validate financial consistency (total value vs price per liter)
  static bool isFinanciallyConsistent(
    FuelSupplyModel fuelSupply, {
    double tolerancePercentage = 5.0,
  }) {
    if (fuelSupply.liters <= 0 || fuelSupply.pricePerLiter <= 0) return false;

    final calculatedValue = fuelSupply.pricePerLiter * fuelSupply.liters;
    final difference = (fuelSupply.totalPrice - calculatedValue).abs();
    final percentageDifference = (difference / fuelSupply.totalPrice) * 100;
    
    return percentageDifference <= tolerancePercentage;
  }

  /// Check if odometer reading is logical (not decreasing)
  static bool isOdometerReadingValid(
    FuelSupplyModel currentSupply,
    FuelSupplyModel? previousSupply,
  ) {
    if (previousSupply == null) return true;
    return currentSupply.odometer >= previousSupply.odometer;
  }

  /// Check if fuel supply belongs to specific vehicle
  static bool belongsToVehicle(FuelSupplyModel fuelSupply, String vehicleId) {
    return fuelSupply.vehicleId == vehicleId;
  }

  /// Calculate monthly statistics
  static Map<String, double> calculateMonthlyStatistics(List<FuelSupplyModel> fuelSupplies) {
    final grouped = groupByMonth(fuelSupplies);
    final Map<String, double> statistics = {};
    
    grouped.forEach((month, supplies) {
      statistics['${month}_total_cost'] = calculateTotalFuelCost(supplies);
      statistics['${month}_total_liters'] = calculateTotalLiters(supplies);
      statistics['${month}_avg_price'] = calculateAveragePricePerLiter(supplies);
      statistics['${month}_count'] = supplies.length.toDouble();
    });
    
    return statistics;
  }

  /// Find the most economical fuel supply (best price per liter)
  static FuelSupplyModel? findMostEconomicalSupply(List<FuelSupplyModel> fuelSupplies) {
    if (fuelSupplies.isEmpty) return null;
    return fuelSupplies.reduce((current, next) => 
        current.pricePerLiter < next.pricePerLiter ? current : next);
  }

  /// Find the most expensive fuel supply (worst price per liter)
  static FuelSupplyModel? findMostExpensiveSupply(List<FuelSupplyModel> fuelSupplies) {
    if (fuelSupplies.isEmpty) return null;
    return fuelSupplies.reduce((current, next) => 
        current.pricePerLiter > next.pricePerLiter ? current : next);
  }
}
