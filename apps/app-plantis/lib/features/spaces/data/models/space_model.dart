import '../../domain/entities/space.dart';

class SpaceModel extends Space {
  const SpaceModel({
    required super.id,
    required super.name,
    super.description,
    super.imageBase64,
    required super.type,
    super.config,
    required super.createdAt,
    required super.updatedAt,
    super.isDirty,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageBase64: json['imageBase64'],
      type: SpaceType.fromString(json['type'] ?? 'room'),
      config: json['config'] != null 
          ? SpaceConfigModel.fromJson(json['config']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      isDirty: json['isDirty'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageBase64': imageBase64,
      'type': type.value,
      'config': config != null 
          ? SpaceConfigModel.fromEntity(config!).toJson() 
          : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDirty': isDirty,
    };
  }

  factory SpaceModel.fromEntity(Space space) {
    return SpaceModel(
      id: space.id,
      name: space.name,
      description: space.description,
      imageBase64: space.imageBase64,
      type: space.type,
      config: space.config,
      createdAt: space.createdAt,
      updatedAt: space.updatedAt,
      isDirty: space.isDirty,
    );
  }
}

class SpaceConfigModel extends SpaceConfig {
  const SpaceConfigModel({
    super.temperature,
    super.humidity,
    super.lightLevel,
    super.hasDirectSunlight,
    super.hasAirConditioning,
    super.ventilation,
    super.maxPlants,
  });

  factory SpaceConfigModel.fromJson(Map<String, dynamic> json) {
    return SpaceConfigModel(
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      lightLevel: json['lightLevel'],
      hasDirectSunlight: json['hasDirectSunlight'],
      hasAirConditioning: json['hasAirConditioning'],
      ventilation: json['ventilation'],
      maxPlants: json['maxPlants'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'lightLevel': lightLevel,
      'hasDirectSunlight': hasDirectSunlight,
      'hasAirConditioning': hasAirConditioning,
      'ventilation': ventilation,
      'maxPlants': maxPlants,
    };
  }

  factory SpaceConfigModel.fromEntity(SpaceConfig config) {
    return SpaceConfigModel(
      temperature: config.temperature,
      humidity: config.humidity,
      lightLevel: config.lightLevel,
      hasDirectSunlight: config.hasDirectSunlight,
      hasAirConditioning: config.hasAirConditioning,
      ventilation: config.ventilation,
      maxPlants: config.maxPlants,
    );
  }
}