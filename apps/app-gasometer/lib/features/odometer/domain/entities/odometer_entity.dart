import 'package:core/core.dart' show Equatable;

/// Represents an odometer reading record
class OdometerEntity extends Equatable {
  const OdometerEntity({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.value,
    required this.registrationDate,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Creates an entity from a map
  factory OdometerEntity.fromMap(Map<String, dynamic> map) {
    return OdometerEntity(
      id: map['id']?.toString() ?? '',
      vehicleId: map['vehicleId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(
        (map['registrationDate'] as int?) ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      description: map['description']?.toString() ?? '',
      type: OdometerType.fromString(map['type']?.toString() ?? 'other'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
  final String id;
  final String vehicleId;
  final String userId;
  final double value;
  final DateTime registrationDate;
  final String description;
  final OdometerType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  /// Creates a copy of this entity with the given fields replaced
  OdometerEntity copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    double? value,
    DateTime? registrationDate,
    String? description,
    OdometerType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return OdometerEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      value: value ?? this.value,
      registrationDate: registrationDate ?? this.registrationDate,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts the entity to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'value': value,
      'registrationDate': registrationDate.millisecondsSinceEpoch,
      'description': description,
      'type': type.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    userId,
    value,
    registrationDate,
    description,
    type,
    createdAt,
    updatedAt,
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
