import 'package:drift/drift.dart';
import '../../features/livestock/domain/entities/bovine_entity.dart';
import '../../features/livestock/domain/entities/equine_entity.dart';

/// Conversor para BovineAptitude (enum)
/// Mapeia entre int (banco de dados) e BovineAptitude (domínio)
class BovineAptitudeConverter extends TypeConverter<BovineAptitude, int> {
  const BovineAptitudeConverter();

  @override
  BovineAptitude fromSql(int fromDb) {
    return BovineAptitude.values[fromDb];
  }

  @override
  int toSql(BovineAptitude value) {
    return value.index;
  }
}

/// Conversor para BreedingSystem (enum)
/// Mapeia entre int (banco de dados) e BreedingSystem (domínio)
class BreedingSystemConverter extends TypeConverter<BreedingSystem, int> {
  const BreedingSystemConverter();

  @override
  BreedingSystem fromSql(int fromDb) {
    return BreedingSystem.values[fromDb];
  }

  @override
  int toSql(BreedingSystem value) {
    return value.index;
  }
}

/// Conversor para EquineTemperament (enum)
/// Mapeia entre int (banco de dados) e EquineTemperament (domínio)
class EquineTemperamentConverter extends TypeConverter<EquineTemperament, int> {
  const EquineTemperamentConverter();

  @override
  EquineTemperament fromSql(int fromDb) {
    return EquineTemperament.values[fromDb];
  }

  @override
  int toSql(EquineTemperament value) {
    return value.index;
  }
}

/// Conversor para CoatColor (enum)
/// Mapeia entre int (banco de dados) e CoatColor (domínio)
class CoatColorConverter extends TypeConverter<CoatColor, int> {
  const CoatColorConverter();

  @override
  CoatColor fromSql(int fromDb) {
    return CoatColor.values[fromDb];
  }

  @override
  int toSql(CoatColor value) {
    return value.index;
  }
}

/// Conversor para EquinePrimaryUse (enum)
/// Mapeia entre int (banco de dados) e EquinePrimaryUse (domínio)
class EquinePrimaryUseConverter extends TypeConverter<EquinePrimaryUse, int> {
  const EquinePrimaryUseConverter();

  @override
  EquinePrimaryUse fromSql(int fromDb) {
    return EquinePrimaryUse.values[fromDb];
  }

  @override
  int toSql(EquinePrimaryUse value) {
    return value.index;
  }
}

/// Conversor para List<String> (array/tags/imageUrls)
/// Mapeia entre String JSON (banco de dados) e List<String> (domínio)
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '[]') {
      return [];
    }
    try {
      // Parse JSON array string: ["item1", "item2"]
      final list = fromDb
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .where((item) => item.isNotEmpty)
          .map((item) => item.trim())
          .toList();
      return list;
    } catch (e) {
      // Se falhar no parse, retorna lista vazia
      return [];
    }
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) {
      return '[]';
    }
    // Converte lista em JSON array string: ["item1", "item2"]
    final jsonArray = value.map((item) => '"$item"').join(',');
    return '[$jsonArray]';
  }
}
