import 'vehicle_entity.dart';

/// Classe centralizada para mapeamento de combustíveis
/// Responsável por unificar as conversões entre strings, indices e FuelType enum
class FuelTypeMapper {
  /// Mapa de strings para FuelType (usado na interface)
  static const Map<String, FuelType> _stringToFuelType = {
    'Gasolina': FuelType.gasoline,
    'Etanol': FuelType.ethanol,
    'Diesel': FuelType.diesel,
    'Diesel S-10': FuelType.diesel, // Mapeado para diesel padrão
    'GNV': FuelType.gas,
    'Gás': FuelType.gas,
    'Energia Elétrica': FuelType.electric,
    'Elétrico': FuelType.electric,
    'Híbrido': FuelType.hybrid,
  };

  /// Mapa reverso de FuelType para string (usado na interface)
  static const Map<FuelType, String> _fuelTypeToString = {
    FuelType.gasoline: 'Gasolina',
    FuelType.ethanol: 'Etanol',
    FuelType.diesel: 'Diesel',
    FuelType.gas: 'GNV',
    FuelType.electric: 'Energia Elétrica',
    FuelType.hybrid: 'Híbrido',
  };

  /// Converte string do interface para FuelType
  static FuelType fromString(String fuelString) {
    return _stringToFuelType[fuelString] ?? FuelType.gasoline;
  }

  /// Converte FuelType para string do interface
  static String toStringFormat(FuelType fuelType) {
    return _fuelTypeToString[fuelType] ?? 'Gasolina';
  }

  /// Converte índice (usado no modelo) para FuelType
  static FuelType fromIndex(int index) {
    if (index >= 0 && index < FuelType.values.length) {
      return FuelType.values[index];
    }
    return FuelType.gasoline;
  }

  /// Converte FuelType para índice (usado no modelo)
  static int toIndex(FuelType fuelType) {
    return fuelType.index;
  }

  /// Lista de strings de combustível disponíveis para interface
  static List<String> get availableFuelStrings => _stringToFuelType.keys.toList();

  /// Lista de FuelTypes disponíveis
  static List<FuelType> get availableFuelTypes => FuelType.values;

  /// Verifica se uma string é um combustível válido
  static bool isValidFuelString(String fuelString) {
    return _stringToFuelType.containsKey(fuelString);
  }

  /// Obtém o nome display do enum (usando o método nativo do enum)
  static String getDisplayName(FuelType fuelType) {
    return fuelType.displayName;
  }
}