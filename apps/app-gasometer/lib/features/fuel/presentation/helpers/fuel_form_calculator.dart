/// Calculator for fuel form operations
///
/// Responsibilities:
/// - Calculate total price from liters and price per liter
/// - Calculate fuel consumption
/// - Validate calculation consistency
class FuelFormCalculator {
  const FuelFormCalculator();

  /// Calculates total price from liters and price per liter
  double calculateTotalPrice(double liters, double pricePerLiter) {
    if (liters <= 0 || pricePerLiter <= 0) return 0.0;
    return liters * pricePerLiter;
  }

  /// Calculates fuel consumption in km/l
  double calculateConsumption(double distance, double liters) {
    if (distance <= 0 || liters <= 0) return 0.0;
    return distance / liters;
  }

  /// Calculates distance traveled between odometer readings
  double calculateDistance(double currentOdometer, double previousOdometer) {
    if (currentOdometer <= 0 || previousOdometer <= 0) return 0.0;
    if (currentOdometer < previousOdometer) return 0.0;
    return currentOdometer - previousOdometer;
  }

  /// Validates if calculated total matches expected value
  /// Returns null if valid, error message if not
  String? validateCalculatedTotal(
    double liters,
    double pricePerLiter,
    double totalPrice,
  ) {
    final calculated = calculateTotalPrice(liters, pricePerLiter);
    final difference = (calculated - totalPrice).abs();
    
    if (difference > 0.01) {
      return 'Valor total não confere com o cálculo';
    }
    return null;
  }

  /// Estimates range based on fuel and consumption
  double estimateRange(double liters, double averageConsumption) {
    if (liters <= 0 || averageConsumption <= 0) return 0.0;
    return liters * averageConsumption;
  }

  /// Calculates cost per kilometer
  double calculateCostPerKm(double totalPrice, double distance) {
    if (totalPrice <= 0 || distance <= 0) return 0.0;
    return totalPrice / distance;
  }
}
