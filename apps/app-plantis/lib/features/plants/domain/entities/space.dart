import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class Space extends BaseSyncEntity {
  final String name;
  final String? description;
  final String? lightCondition; // 'low', 'medium', 'high'
  final double? humidity; // Percentual de umidade como double
  final double? averageTemperature;
  
  const Space({
    required super.id,
    required this.name,
    this.description,
    this.lightCondition,
    this.humidity,
    this.averageTemperature,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
  });
  
  String get displayName => name.trim().isEmpty ? 'Espaço sem nome' : name;
  
  String get displayDescription => description?.trim().isEmpty ?? true
      ? 'Sem descrição'
      : description!;

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'name': name,
      'description': description,
      'light_condition': lightCondition,
      'humidity': humidity,
      'average_temperature': averageTemperature,
    };
  }

  @override
  Space markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  Space markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  Space markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Space incrementVersion() {
    return copyWith(version: version + 1);
  }

  @override
  Space withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  Space withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }
  
  @override
  Space copyWith({
    String? id,
    String? name,
    String? description,
    String? lightCondition,
    double? humidity,
    double? averageTemperature,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      lightCondition: lightCondition ?? this.lightCondition,
      humidity: humidity ?? this.humidity,
      averageTemperature: averageTemperature ?? this.averageTemperature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }
  
  @override
  List<Object?> get props => [
    ...super.props,
    name,
    description,
    lightCondition,
    humidity,
    averageTemperature,
  ];
}