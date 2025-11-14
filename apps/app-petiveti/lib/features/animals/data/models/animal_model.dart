import 'package:core/core.dart' hide Column;

import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';

part 'animal_model.g.dart';

@JsonSerializable()
class AnimalModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'species')
  final AnimalSpecies species;

  @JsonKey(name: 'breed')
  final String? breed;

  @JsonKey(name: 'gender')
  final AnimalGender gender;

  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;

  @JsonKey(name: 'weight')
  final double? weight;

  @JsonKey(name: 'size')
  final AnimalSize? size;

  @JsonKey(name: 'color')
  final String? color;

  @JsonKey(name: 'microchip_number')
  final String? microchipNumber;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  AnimalModel({
    this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.breed,
    required this.gender,
    this.birthDate,
    this.weight,
    this.size,
    this.color,
    this.microchipNumber,
    this.notes,
    this.photoUrl,
    this.isActive = true,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory AnimalModel.fromEntity(Animal animal) {
    return AnimalModel(
      id: animal.id != null ? int.tryParse(animal.id!) : null,
      userId: animal.userId,
      name: animal.name,
      species: animal.species,
      breed: animal.breed,
      gender: animal.gender,
      birthDate: animal.birthDate,
      weight: animal.weight,
      size: animal.size,
      color: animal.color,
      microchipNumber: animal.microchipNumber,
      notes: animal.notes,
      photoUrl: animal.photoUrl,
      isActive: animal.isActive,
      createdAt: animal.createdAt,
      updatedAt: animal.updatedAt,
    );
  }

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      species:
          json['species'] is String
              ? AnimalSpeciesExtension.fromString(json['species'] as String)
              : AnimalSpecies.values[json['species'] as int],
      breed: json['breed'] as String?,
      gender:
          json['gender'] is String
              ? AnimalGenderExtension.fromString(json['gender'] as String)
              : AnimalGender.values[json['gender'] as int],
      birthDate:
          json['birth_date'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['birth_date'] as int)
              : null,
      weight: (json['weight'] as num?)?.toDouble(),
      size:
          json['size'] != null
              ? (json['size'] is String
                  ? AnimalSizeExtension.fromString(json['size'] as String)
                  : AnimalSize.values[json['size'] as int])
              : null,
      color: json['color'] as String?,
      microchipNumber: json['microchip_number'] as String?,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species.name,
      'breed': breed,
      'gender': gender.name,
      'birth_date': birthDate?.millisecondsSinceEpoch,
      'weight': weight,
      'size': size?.name,
      'color': color,
      'microchip_number': microchipNumber,
      'notes': notes,
      'photo_url': photoUrl,
      'is_active': isActive,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Animal toEntity() {
    return Animal(
      id: id?.toString(),
      userId: userId,
      name: name,
      species: species,
      breed: breed,
      gender: gender,
      birthDate: birthDate,
      weight: weight,
      size: size,
      color: color,
      microchipNumber: microchipNumber,
      notes: notes,
      photoUrl: photoUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  AnimalModel copyWith({
    int? id,
    String? userId,
    String? name,
    AnimalSpecies? species,
    String? breed,
    AnimalGender? gender,
    DateTime? birthDate,
    double? weight,
    AnimalSize? size,
    String? color,
    String? microchipNumber,
    String? notes,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      size: size ?? this.size,
      color: color ?? this.color,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  bool get isDeletedComputed => !isActive;
  static AnimalModel fromMap(Map<String, dynamic> map) {
    return AnimalModel.fromJson(map);
  }
  Map<String, dynamic> toMap() {
    return toJson();
  }
  AnimalModel copyWithDeleted({bool? isDeleted}) {
    return copyWith(isActive: isDeleted != null ? !isDeleted : null);
  }
}
