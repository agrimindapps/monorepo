import 'package:core/core.dart';

import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';

part 'animal_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class AnimalModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'user_id')
  final String userId;

  @HiveField(2)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(3)
  @JsonKey(name: 'species')
  final AnimalSpecies species;

  @HiveField(4)
  @JsonKey(name: 'breed')
  final String? breed;

  @HiveField(5)
  @JsonKey(name: 'gender')
  final AnimalGender gender;

  @HiveField(6)
  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;

  @HiveField(7)
  @JsonKey(name: 'weight')
  final double? weight;

  @HiveField(8)
  @JsonKey(name: 'size')
  final AnimalSize? size;

  @HiveField(9)
  @JsonKey(name: 'color')
  final String? color;

  @HiveField(10)
  @JsonKey(name: 'microchip_number')
  final String? microchipNumber;

  @HiveField(11)
  @JsonKey(name: 'notes')
  final String? notes;

  @HiveField(12)
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @HiveField(13)
  @JsonKey(name: 'is_active')
  final bool isActive;

  @HiveField(14)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(15)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  AnimalModel({
    required this.id,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnimalModel.fromEntity(Animal animal) {
    return AnimalModel(
      id: animal.id,
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
      id: json['id'] as String,
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
      id: id,
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
    String? id,
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
  bool get isDeleted => !isActive;
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
