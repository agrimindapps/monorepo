import 'package:equatable/equatable.dart';

class Animal extends Equatable {
  final String id;
  final String name;
  final String species; // Dog or Cat
  final String breed;
  final DateTime birthDate;
  final String gender; // Male or Female
  final String color;
  final double currentWeight;
  final String? photo;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Animal({
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

  Animal copyWith({
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
    return Animal(
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

  int get ageInDays {
    return DateTime.now().difference(birthDate).inDays;
  }

  int get ageInMonths {
    return (ageInDays / 30.44).floor(); // Average days in a month
  }

  int get ageInYears {
    return (ageInMonths / 12).floor();
  }

  String get displayAge {
    if (ageInYears > 0) {
      return '$ageInYears ${ageInYears == 1 ? 'ano' : 'anos'}';
    } else if (ageInMonths > 0) {
      return '$ageInMonths ${ageInMonths == 1 ? 'mês' : 'meses'}';
    } else {
      return '$ageInDays ${ageInDays == 1 ? 'dia' : 'dias'}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        breed,
        birthDate,
        gender,
        color,
        currentWeight,
        photo,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}