import 'package:equatable/equatable.dart';

class Space extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageBase64;
  final SpaceType type;
  final SpaceConfig? config;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;

  const Space({
    required this.id,
    required this.name,
    this.description,
    this.imageBase64,
    required this.type,
    this.config,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = false,
  });

  Space copyWith({
    String? id,
    String? name,
    String? description,
    String? imageBase64,
    SpaceType? type,
    SpaceConfig? config,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      type: type ?? this.type,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageBase64,
        type,
        config,
        createdAt,
        updatedAt,
        isDirty,
      ];
}

enum SpaceType {
  indoor('indoor', 'Interior'),
  outdoor('outdoor', 'Exterior'),
  greenhouse('greenhouse', 'Estufa'),
  balcony('balcony', 'Varanda'),
  garden('garden', 'Jardim'),
  room('room', 'Quarto'),
  kitchen('kitchen', 'Cozinha'),
  bathroom('bathroom', 'Banheiro'),
  office('office', 'Escritório');

  const SpaceType(this.value, this.displayName);

  final String value;
  final String displayName;

  static SpaceType fromString(String value) {
    return SpaceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SpaceType.room,
    );
  }
}

class SpaceConfig extends Equatable {
  final double? temperature;
  final double? humidity;
  final String? lightLevel; // 'low', 'medium', 'high'
  final bool? hasDirectSunlight;
  final bool? hasAirConditioning;
  final String? ventilation; // 'poor', 'good', 'excellent'
  final int? maxPlants;

  const SpaceConfig({
    this.temperature,
    this.humidity,
    this.lightLevel,
    this.hasDirectSunlight,
    this.hasAirConditioning,
    this.ventilation,
    this.maxPlants,
  });

  SpaceConfig copyWith({
    double? temperature,
    double? humidity,
    String? lightLevel,
    bool? hasDirectSunlight,
    bool? hasAirConditioning,
    String? ventilation,
    int? maxPlants,
  }) {
    return SpaceConfig(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lightLevel: lightLevel ?? this.lightLevel,
      hasDirectSunlight: hasDirectSunlight ?? this.hasDirectSunlight,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      ventilation: ventilation ?? this.ventilation,
      maxPlants: maxPlants ?? this.maxPlants,
    );
  }

  @override
  List<Object?> get props => [
        temperature,
        humidity,
        lightLevel,
        hasDirectSunlight,
        hasAirConditioning,
        ventilation,
        maxPlants,
      ];
}