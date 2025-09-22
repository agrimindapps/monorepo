import 'package:core/core.dart';

import '../animal.dart';
import '../animal_enums.dart';

/// Entidade Animal para sincronização
/// Estende BaseSyncEntity com funcionalidades específicas de pet care:
/// - Single-user pet management (usuário único)
/// - Emergency data access para informações médicas críticas
/// - Offline-first para dados básicos do animal
class AnimalSyncEntity extends BaseSyncEntity {
  const AnimalSyncEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
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
    this.emergencyContact,
    this.veterinarianId,
    this.medicalNotes,
    this.allergies = const [],
    this.lastHealthCheckDate,
  });

  /// Informações básicas do animal
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

  /// Informações de emergência/médicas - CRÍTICAS para sync prioritário
  final String? emergencyContact;
  final String? veterinarianId;
  final String? medicalNotes;
  final List<String> allergies;
  final DateTime? lastHealthCheckDate;


  /// Getters computados para compatibilidade
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

  /// Helper getters para compatibilidade com código legado
  double get currentWeight => weight ?? 0.0;
  String? get photo => photoUrl;
  @override
  bool get isDeleted => !isActive || super.isDeleted;

  /// Verifica se há informações médicas críticas
  bool get hasEmergencyData {
    return emergencyContact != null ||
           medicalNotes != null ||
           allergies.isNotEmpty ||
           veterinarianId != null;
  }


  @override
  Map<String, dynamic> toFirebaseMap() {
    final Map<String, dynamic> map = {
      ...baseFirebaseFields,
      'name': name,
      'species': species.toLowerCase(),
      'breed': breed,
      'gender': gender.toLowerCase(),
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'size': size?.toString().split('.').last,
      'color': color,
      'microchip_number': microchipNumber,
      'notes': notes,
      'photo_url': photoUrl,
      'is_active': isActive,

      // Dados de emergência/médicos
      'emergency_contact': emergencyContact,
      'veterinarian_id': veterinarianId,
      'medical_notes': medicalNotes,
      'allergies': allergies,
      'last_health_check_date': lastHealthCheckDate?.toIso8601String(),

      // Metadados de pet care
      'has_emergency_data': hasEmergencyData,
      'age_in_days': ageInDays,
      'age_in_months': ageInMonths,
      'age_in_years': ageInYears,
    };

    // Remover valores nulos
    map.removeWhere((key, value) => value == null);
    return map;
  }

  static AnimalSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return AnimalSyncEntity(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: (baseFields['isDirty'] as bool?) ?? false,
      isDeleted: (baseFields['isDeleted'] as bool?) ?? false,
      version: (baseFields['version'] as int?) ?? 1,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,

      // Campos específicos do animal
      name: map['name'] as String,
      species: AnimalSpeciesExtension.fromString(map['species'] as String? ?? 'other'),
      breed: map['breed'] as String?,
      gender: AnimalGenderExtension.fromString(map['gender'] as String? ?? 'unknown'),
      birthDate: map['birth_date'] != null
        ? DateTime.parse(map['birth_date'] as String)
        : null,
      weight: (map['weight'] as num?)?.toDouble(),
      size: map['size'] != null
        ? AnimalSizeExtension.fromString(map['size'] as String)
        : null,
      color: map['color'] as String?,
      microchipNumber: map['microchip_number'] as String?,
      notes: map['notes'] as String?,
      photoUrl: map['photo_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,

      // Dados de emergência/médicos
      emergencyContact: map['emergency_contact'] as String?,
      veterinarianId: map['veterinarian_id'] as String?,
      medicalNotes: map['medical_notes'] as String?,
      allergies: (map['allergies'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      lastHealthCheckDate: map['last_health_check_date'] != null
        ? DateTime.parse(map['last_health_check_date'] as String)
        : null,

    );
  }

  @override
  AnimalSyncEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
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
    String? emergencyContact,
    String? veterinarianId,
    String? medicalNotes,
    List<String>? allergies,
    DateTime? lastHealthCheckDate,
  }) {
    return AnimalSyncEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
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
      emergencyContact: emergencyContact ?? this.emergencyContact,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      allergies: allergies ?? this.allergies,
      lastHealthCheckDate: lastHealthCheckDate ?? this.lastHealthCheckDate,
    );
  }

  @override
  AnimalSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  AnimalSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  AnimalSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isActive: false,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  AnimalSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  AnimalSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  AnimalSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }


  /// Atualiza informações médicas de emergência
  AnimalSyncEntity updateEmergencyInfo({
    String? emergencyContact,
    String? veterinarianId,
    String? medicalNotes,
    List<String>? allergies,
  }) {
    return copyWith(
      emergencyContact: emergencyContact ?? this.emergencyContact,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      allergies: allergies ?? this.allergies,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca última consulta de saúde
  AnimalSyncEntity markHealthCheck({DateTime? checkDate}) {
    return copyWith(
      lastHealthCheckDate: checkDate ?? DateTime.now(),
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Converte para entidade Animal legada (para compatibilidade)
  Animal toLegacyAnimal() {
    return Animal(
      id: id,
      userId: userId ?? '',
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
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Cria AnimalSyncEntity a partir de entidade Animal legada
  static AnimalSyncEntity fromLegacyAnimal(Animal animal, {
    String? userId,
    String? moduleName,
  }) {
    return AnimalSyncEntity(
      id: animal.id,
      createdAt: animal.createdAt,
      updatedAt: animal.updatedAt,
      userId: userId ?? animal.userId,
      moduleName: moduleName ?? 'petiveti',
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
      isDirty: true, // Marca como sujo para sync inicial
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
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
    emergencyContact,
    veterinarianId,
    medicalNotes,
    allergies,
    lastHealthCheckDate,
  ];
}

// Import removido para evitar circular dependency
// Use toLegacyAnimal() method for compatibility instead