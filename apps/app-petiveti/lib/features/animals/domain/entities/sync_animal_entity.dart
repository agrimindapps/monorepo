import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Animals com Firebase
/// Contém todos os campos necessários para Drift + Firebase sync
class AnimalEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final String gender;
  final double? weight;
  final String? photo;
  final String? color;
  final String? microchipNumber;
  final String? notes;

  // Metadata
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  // Health fields
  final bool isCastrated;
  final String? allergies; // JSON string list
  final String? bloodType;
  final String? preferredVeterinarian;
  final String? insuranceInfo;

  // Sync fields
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const AnimalEntity({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    required this.gender,
    this.weight,
    this.photo,
    this.color,
    this.microchipNumber,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.isCastrated = false,
    this.allergies,
    this.bloodType,
    this.preferredVeterinarian,
    this.insuranceInfo,
    this.lastSyncAt,
    this.isDirty = false,
    this.version = 1,
  });

  @override
  List<Object?> get props => [
    id,
    firebaseId,
    userId,
    name,
    species,
    breed,
    birthDate,
    gender,
    weight,
    photo,
    color,
    microchipNumber,
    notes,
    isActive,
    createdAt,
    updatedAt,
    isDeleted,
    isCastrated,
    allergies,
    bloodType,
    preferredVeterinarian,
    insuranceInfo,
    lastSyncAt,
    isDirty,
    version,
  ];

  AnimalEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? gender,
    double? weight,
    String? photo,
    String? color,
    String? microchipNumber,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isCastrated,
    String? allergies,
    String? bloodType,
    String? preferredVeterinarian,
    String? insuranceInfo,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
  }) {
    return AnimalEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      photo: photo ?? this.photo,
      color: color ?? this.color,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isCastrated: isCastrated ?? this.isCastrated,
      allergies: allergies ?? this.allergies,
      bloodType: bloodType ?? this.bloodType,
      preferredVeterinarian:
          preferredVeterinarian ?? this.preferredVeterinarian,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
    );
  }

  /// Converte para Map (Firebase)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'birthDate': birthDate != null ? fs.Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'weight': weight,
      'photo': photo,
      'color': color,
      'microchipNumber': microchipNumber,
      'notes': notes,
      'isActive': isActive,
      'createdAt': fs.Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? fs.Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
      'isCastrated': isCastrated,
      'allergies': allergies,
      'bloodType': bloodType,
      'preferredVeterinarian': preferredVeterinarian,
      'insuranceInfo': insuranceInfo,
      'lastSyncAt': fs.Timestamp.now(),
      'version': version,
    };
  }

  /// Cria a partir de Firestore document
  factory AnimalEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return AnimalEntity(
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
      name: data['name'] as String,
      species: data['species'] as String,
      breed: data['breed'] as String?,
      birthDate: (data['birthDate'] as fs.Timestamp?)?.toDate(),
      gender: data['gender'] as String,
      weight: (data['weight'] as num?)?.toDouble(),
      photo: data['photo'] as String?,
      color: data['color'] as String?,
      microchipNumber: data['microchipNumber'] as String?,
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isCastrated: data['isCastrated'] as bool? ?? false,
      allergies: data['allergies'] as String?,
      bloodType: data['bloodType'] as String?,
      preferredVeterinarian: data['preferredVeterinarian'] as String?,
      insuranceInfo: data['insuranceInfo'] as String?,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
