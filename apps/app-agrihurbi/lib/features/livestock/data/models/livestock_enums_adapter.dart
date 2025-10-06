
import 'package:core/core.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';

/// Adapters para enums do sistema livestock
/// 
/// Registra todos os enums necessários para serialização Hive

/// Adapter para BovineAptitude
class BovineAptitudeAdapter extends TypeAdapter<BovineAptitude> {
  @override
  final int typeId = 100; // TypeId único para BovineAptitude

  @override
  BovineAptitude read(BinaryReader reader) {
    final index = reader.readByte();
    return BovineAptitude.values[index];
  }

  @override
  void write(BinaryWriter writer, BovineAptitude obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter para BreedingSystem
class BreedingSystemAdapter extends TypeAdapter<BreedingSystem> {
  @override
  final int typeId = 101; // TypeId único para BreedingSystem

  @override
  BreedingSystem read(BinaryReader reader) {
    final index = reader.readByte();
    return BreedingSystem.values[index];
  }

  @override
  void write(BinaryWriter writer, BreedingSystem obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter para EquineTemperament
class EquineTemperamentAdapter extends TypeAdapter<EquineTemperament> {
  @override
  final int typeId = 102; // TypeId único para EquineTemperament

  @override
  EquineTemperament read(BinaryReader reader) {
    final index = reader.readByte();
    return EquineTemperament.values[index];
  }

  @override
  void write(BinaryWriter writer, EquineTemperament obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter para CoatColor
class CoatColorAdapter extends TypeAdapter<CoatColor> {
  @override
  final int typeId = 103; // TypeId único para CoatColor

  @override
  CoatColor read(BinaryReader reader) {
    final index = reader.readByte();
    return CoatColor.values[index];
  }

  @override
  void write(BinaryWriter writer, CoatColor obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter para EquinePrimaryUse
class EquinePrimaryUseAdapter extends TypeAdapter<EquinePrimaryUse> {
  @override
  final int typeId = 104; // TypeId único para EquinePrimaryUse

  @override
  EquinePrimaryUse read(BinaryReader reader) {
    final index = reader.readByte();
    return EquinePrimaryUse.values[index];
  }

  @override
  void write(BinaryWriter writer, EquinePrimaryUse obj) {
    writer.writeByte(obj.index);
  }
}

/// Registra todos os adapters de enums para o Hive
void registerLivestockEnumAdapters() {
  Hive.registerAdapter(BovineAptitudeAdapter());
  Hive.registerAdapter(BreedingSystemAdapter());
  Hive.registerAdapter(EquineTemperamentAdapter());
  Hive.registerAdapter(CoatColorAdapter());
  Hive.registerAdapter(EquinePrimaryUseAdapter());
}
