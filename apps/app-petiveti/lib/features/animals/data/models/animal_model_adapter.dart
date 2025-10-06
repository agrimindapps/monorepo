import 'package:core/core.dart' show BinaryReader, TypeAdapter, BinaryWriter;

import '../../domain/entities/animal_enums.dart';
import 'animal_model.dart';

class AnimalModelAdapter extends TypeAdapter<AnimalModel> {
  @override
  final int typeId = 0;

  @override
  AnimalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return AnimalModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      species: fields[3] as AnimalSpecies,
      breed: fields[4] as String?,
      gender: fields[5] as AnimalGender,
      birthDate: fields[6] as DateTime?,
      weight: fields[7] as double?,
      size: fields[8] as AnimalSize?,
      color: fields[9] as String?,
      microchipNumber: fields[10] as String?,
      notes: fields[11] as String?,
      photoUrl: fields[12] as String?,
      isActive: fields[13] as bool? ?? true,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AnimalModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.species)
      ..writeByte(4)
      ..write(obj.breed)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.birthDate)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.size)
      ..writeByte(9)
      ..write(obj.color)
      ..writeByte(10)
      ..write(obj.microchipNumber)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.photoUrl)
      ..writeByte(13)
      ..write(obj.isActive)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// Enum Adapters for Animal
class AnimalSpeciesAdapter extends TypeAdapter<AnimalSpecies> {
  @override
  final int typeId = 10;

  @override
  AnimalSpecies read(BinaryReader reader) {
    final index = reader.readByte();
    return AnimalSpecies.values[index];
  }

  @override
  void write(BinaryWriter writer, AnimalSpecies obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalSpeciesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimalGenderAdapter extends TypeAdapter<AnimalGender> {
  @override
  final int typeId = 11;

  @override
  AnimalGender read(BinaryReader reader) {
    final index = reader.readByte();
    return AnimalGender.values[index];
  }

  @override
  void write(BinaryWriter writer, AnimalGender obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalGenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnimalSizeAdapter extends TypeAdapter<AnimalSize> {
  @override
  final int typeId = 12;

  @override
  AnimalSize read(BinaryReader reader) {
    final index = reader.readByte();
    return AnimalSize.values[index];
  }

  @override
  void write(BinaryWriter writer, AnimalSize obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
