import 'package:core/core.dart';

/// Represents an odometer reading record
class OdometerEntity extends BaseSyncEntity {
  const OdometerEntity({
    required super.id,
    required this.vehicleId,
    required this.value,
    required this.registrationDate,
    required this.description,
    required this.type,
    this.metadata = const {},
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
  });

  /// Creates an entity from a map
  factory OdometerEntity.fromMap(Map<String, dynamic> map) {
    return OdometerEntity(
      id: map['id']?.toString() ?? '',
      vehicleId: map['vehicleId']?.toString() ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(
        (map['registrationDate'] as int?) ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      description: map['description']?.toString() ?? '',
      type: OdometerType.fromString(map['type']?.toString() ?? 'other'),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncAt'] as int)
          : null,
      isDirty: map['isDirty'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      userId: map['userId']?.toString(),
      moduleName: map['moduleName']?.toString(),
    );
  }

  /// Creates an entity from Firebase map
  factory OdometerEntity.fromFirebaseMap(Map<String, dynamic> map) {
    return OdometerEntity(
      id: map['id']?.toString() ?? '',
      vehicleId: map['vehicleId']?.toString() ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(
        (map['registrationDate'] as int?) ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      description: map['description']?.toString() ?? '',
      type: OdometerType.fromString(map['type']?.toString() ?? 'other'),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
      isDirty: map['is_dirty'] as bool? ?? false,
      isDeleted: map['is_deleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      userId: map['user_id']?.toString(),
      moduleName: map['module_name']?.toString(),
    );
  }

  final String vehicleId;
  final double value;
  final DateTime registrationDate;
  final String description;
  final OdometerType type;
  final Map<String, dynamic> metadata;

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'vehicleId': vehicleId,
      'value': value,
      'registrationDate': registrationDate.millisecondsSinceEpoch,
      'description': description,
      'type': type.name,
      'metadata': metadata,
    };
  }

  @override
  BaseSyncEntity markAsDirty() {
    return copyWith(isDirty: true, version: version + 1);
  }

  @override
  BaseSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  BaseSyncEntity markAsDeleted() {
    return copyWith(isDeleted: true, version: version + 1);
  }

  @override
  BaseSyncEntity incrementVersion() {
    return copyWith(version: version + 1);
  }

  @override
  BaseSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  BaseSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Creates a copy of this entity with the given fields replaced
  @override
  OdometerEntity copyWith({
    String? id,
    String? vehicleId,
    double? value,
    DateTime? registrationDate,
    String? description,
    OdometerType? type,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return OdometerEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      value: value ?? this.value,
      registrationDate: registrationDate ?? this.registrationDate,
      description: description ?? this.description,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
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

  /// Converts the entity to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'value': value,
      'registrationDate': registrationDate.millisecondsSinceEpoch,
      'description': description,
      'type': type.name,
      'metadata': metadata,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
    };
  }

  @override
  List<Object?> get props => [
    ...super.props,
    vehicleId,
    value,
    registrationDate,
    description,
    type,
    metadata,
  ];

  @override
  String toString() {
    return 'OdometerEntity('
        'id: $id, '
        'vehicleId: $vehicleId, '
        'value: $value, '
        'type: $type, '
        'registrationDate: $registrationDate'
        ')';
  }
}

/// Types of odometer registration
enum OdometerType {
  trip('Viagem', 'Registro de viagem ou deslocamento'),
  leisure('Passeio', 'Registro de passeio ou lazer'),
  maintenance('Manutenção', 'Registro relacionado à manutenção'),
  fueling('Abastecimento', 'Registro durante abastecimento'),
  other('Outros', 'Outros tipos de registro');

  const OdometerType(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Creates an OdometerType from string value
  static OdometerType fromString(String value) {
    return OdometerType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => OdometerType.other,
    );
  }

  /// Gets all available types as a list
  static List<OdometerType> get allTypes => OdometerType.values;

  /// Gets display names for all types
  static List<String> get displayNames =>
      OdometerType.values.map((type) => type.displayName).toList();
}
