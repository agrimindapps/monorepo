import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/animal.dart';

part 'animal_model.g.dart';

@HiveType(typeId: 11)
@JsonSerializable()
class AnimalModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(2)
  @JsonKey(name: 'species')
  final String species;

  @HiveField(3)
  @JsonKey(name: 'breed')
  final String breed;

  @HiveField(4)
  @JsonKey(name: 'birth_date')
  final DateTime birthDate;

  @HiveField(5)
  @JsonKey(name: 'gender')
  final String gender;

  @HiveField(6)
  @JsonKey(name: 'color')
  final String color;

  @HiveField(7)
  @JsonKey(name: 'current_weight')
  final double currentWeight;

  @HiveField(8)
  @JsonKey(name: 'photo')
  final String? photo;

  @HiveField(9)
  @JsonKey(name: 'notes')
  final String? notes;

  @HiveField(10)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(11)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(12)
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  AnimalModel({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.color,
    required this.currentWeight,
    this.photo,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory AnimalModel.fromEntity(Animal animal) {
    return AnimalModel(
      id: animal.id,
      name: animal.name,
      species: animal.species,
      breed: animal.breed,
      birthDate: animal.birthDate,
      gender: animal.gender,
      color: animal.color,
      currentWeight: animal.currentWeight,
      photo: animal.photo,
      notes: animal.notes,
      createdAt: animal.createdAt,
      updatedAt: animal.updatedAt,
      isDeleted: animal.isDeleted,
    );
  }

  factory AnimalModel.fromJson(Map<String, dynamic> json) =>
      _$AnimalModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnimalModelToJson(this);

  Animal toEntity() {
    return Animal(
      id: id,
      name: name,
      species: species,
      breed: breed,
      birthDate: birthDate,
      gender: gender,
      color: color,
      currentWeight: currentWeight,
      photo: photo,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  AnimalModel copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? gender,
    String? color,
    double? currentWeight,
    String? photo,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return AnimalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      currentWeight: currentWeight ?? this.currentWeight,
      photo: photo ?? this.photo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}