import 'package:equatable/equatable.dart';
import 'animal_enums.dart';

class Animal extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AnimalSpecies species;
  final String? breed;
  final AnimalGender gender;
  final DateTime? birthDate;
  final double? weight;
  final AnimalSize? size;
  final String? color;
  final String? microchipNumber;
  final String? notes;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Animal({
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

  Animal copyWith({
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
    return Animal(
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

  int get ageInDays {
    if (birthDate == null) return 0;
    return DateTime.now().difference(birthDate!).inDays;
  }

  int get ageInMonths {
    return (ageInDays / 30.44).floor(); // Average days in a month
  }

  int get ageInYears {
    return (ageInMonths / 12).floor();
  }

  String get displayAge {
    if (birthDate == null) return 'Idade não informada';
    if (ageInYears > 0) {
      return '$ageInYears ${ageInYears == 1 ? 'ano' : 'anos'}';
    } else if (ageInMonths > 0) {
      return '$ageInMonths ${ageInMonths == 1 ? 'mês' : 'meses'}';
    } else {
      return '$ageInDays ${ageInDays == 1 ? 'dia' : 'dias'}';
    }
  }

  // Helper getter for backwards compatibility  
  double get currentWeight => weight ?? 0.0;
  String? get photo => photoUrl;
  bool get isDeleted => !isActive;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        size,
        color,
        microchipNumber,
        notes,
        photoUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}