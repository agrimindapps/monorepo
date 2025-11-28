import 'package:core/core.dart' show Equatable;
import 'animal_enums.dart';
typedef PetEntity = Animal;
typedef Pet = Animal;
class PetImageEntity extends Equatable {
  final String id;
  final String petId;
  final String imageUrl;
  final String? description;
  final bool isProfile;
  final DateTime createdAt;

  const PetImageEntity({
    required this.id,
    required this.petId,
    required this.imageUrl,
    this.description,
    this.isProfile = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    petId,
    imageUrl,
    description,
    isProfile,
    createdAt,
  ];
}

class OwnerEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const OwnerEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone, address, createdAt];
}

class VetEntity extends Equatable {
  final String id;
  final String name;
  final String clinic;
  final String? phone;
  final String? email;
  final String? address;
  final String? specialty;
  final DateTime createdAt;

  const VetEntity({
    required this.id,
    required this.name,
    required this.clinic,
    this.phone,
    this.email,
    this.address,
    this.specialty,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    clinic,
    phone,
    email,
    address,
    specialty,
    createdAt,
  ];
}

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

  // New health fields
  final bool isCastrated;
  final List<String>? allergies;
  final String? bloodType;
  final String? preferredVeterinarian;
  final String? insuranceInfo;

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
    this.isCastrated = false,
    this.allergies,
    this.bloodType,
    this.preferredVeterinarian,
    this.insuranceInfo,
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
    bool? isCastrated,
    List<String>? allergies,
    String? bloodType,
    String? preferredVeterinarian,
    String? insuranceInfo,
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
      isCastrated: isCastrated ?? this.isCastrated,
      allergies: allergies ?? this.allergies,
      bloodType: bloodType ?? this.bloodType,
      preferredVeterinarian: preferredVeterinarian ?? this.preferredVeterinarian,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
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
    isCastrated,
    allergies,
    bloodType,
    preferredVeterinarian,
    insuranceInfo,
  ];
}
