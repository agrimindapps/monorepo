import '../../domain/entities/device_info.dart';

/// Model de DeviceInfo para serialização de dados
class DeviceInfoModel extends DeviceInfo {
  const DeviceInfoModel({
    required super.uuid,
    required super.name,
    required super.model,
    required super.platform,
    required super.systemVersion,
    required super.appVersion,
    required super.buildNumber,
    required super.identifier,
    required super.isPhysicalDevice,
    required super.manufacturer,
    required super.firstLoginAt,
    required super.lastActiveAt,
    required super.isActive,
    super.location,
    super.ipAddress,
  });

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'model': model,
      'platform': platform,
      'systemVersion': systemVersion,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'identifier': identifier,
      'isPhysicalDevice': isPhysicalDevice,
      'manufacturer': manufacturer,
      'firstLoginAt': firstLoginAt.millisecondsSinceEpoch,
      'lastActiveAt': lastActiveAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'location': location,
      'ipAddress': ipAddress,
    };
  }

  /// Cria instância a partir de Map
  factory DeviceInfoModel.fromMap(Map<String, dynamic> map) {
    return DeviceInfoModel(
      uuid: map['uuid'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown Device',
      model: map['model'] as String? ?? 'Unknown',
      platform: map['platform'] as String? ?? 'unknown',
      systemVersion: map['systemVersion'] as String? ?? 'Unknown',
      appVersion: map['appVersion'] as String? ?? '1.0.0',
      buildNumber: map['buildNumber'] as String? ?? '1',
      identifier: map['identifier'] as String? ?? 'unknown',
      isPhysicalDevice: map['isPhysicalDevice'] as bool? ?? true,
      manufacturer: map['manufacturer'] as String? ?? 'Unknown',
      firstLoginAt: DateTime.fromMillisecondsSinceEpoch(
        map['firstLoginAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
        map['lastActiveAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isActive: map['isActive'] as bool? ?? true,
      location: map['location'] as String?,
      ipAddress: map['ipAddress'] as String?,
    );
  }

  /// Cria instância a partir de JSON do Firestore
  factory DeviceInfoModel.fromFirestore(Map<String, dynamic> doc) {
    return DeviceInfoModel(
      uuid: doc['uuid'] as String? ?? '',
      name: doc['name'] as String? ?? 'Unknown Device',
      model: doc['model'] as String? ?? 'Unknown',
      platform: doc['platform'] as String? ?? 'unknown',
      systemVersion: doc['systemVersion'] as String? ?? 'Unknown',
      appVersion: doc['appVersion'] as String? ?? '1.0.0',
      buildNumber: doc['buildNumber'] as String? ?? '1',
      identifier: doc['identifier'] as String? ?? 'unknown',
      isPhysicalDevice: doc['isPhysicalDevice'] as bool? ?? true,
      manufacturer: doc['manufacturer'] as String? ?? 'Unknown',
      firstLoginAt: _parseDateTime(doc['firstLoginAt']),
      lastActiveAt: _parseDateTime(doc['lastActiveAt']),
      isActive: doc['isActive'] as bool? ?? true,
      location: doc['location'] as String?,
      ipAddress: doc['ipAddress'] as String?,
    );
  }

  /// Converte para Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uuid': uuid,
      'name': name,
      'model': model,
      'platform': platform,
      'systemVersion': systemVersion,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'identifier': identifier,
      'isPhysicalDevice': isPhysicalDevice,
      'manufacturer': manufacturer,
      'firstLoginAt': firstLoginAt,
      'lastActiveAt': lastActiveAt,
      'isActive': isActive,
      'location': location,
      'ipAddress': ipAddress,
    };
  }

  /// Converte entidade para model
  factory DeviceInfoModel.fromEntity(DeviceInfo entity) {
    return DeviceInfoModel(
      uuid: entity.uuid,
      name: entity.name,
      model: entity.model,
      platform: entity.platform,
      systemVersion: entity.systemVersion,
      appVersion: entity.appVersion,
      buildNumber: entity.buildNumber,
      identifier: entity.identifier,
      isPhysicalDevice: entity.isPhysicalDevice,
      manufacturer: entity.manufacturer,
      firstLoginAt: entity.firstLoginAt,
      lastActiveAt: entity.lastActiveAt,
      isActive: entity.isActive,
      location: entity.location,
      ipAddress: entity.ipAddress,
    );
  }

  /// Cria uma cópia com novos valores
  DeviceInfoModel copyWith({
    String? uuid,
    String? name,
    String? model,
    String? platform,
    String? systemVersion,
    String? appVersion,
    String? buildNumber,
    String? identifier,
    bool? isPhysicalDevice,
    String? manufacturer,
    DateTime? firstLoginAt,
    DateTime? lastActiveAt,
    bool? isActive,
    String? location,
    String? ipAddress,
  }) {
    return DeviceInfoModel(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      model: model ?? this.model,
      platform: platform ?? this.platform,
      systemVersion: systemVersion ?? this.systemVersion,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      identifier: identifier ?? this.identifier,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      manufacturer: manufacturer ?? this.manufacturer,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  /// Converte model para entidade
  DeviceInfo toEntity() => this;

  /// Helper para converter DateTime do Firestore
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Map && value.containsKey('_seconds')) {
      // Timestamp do Firestore
      final seconds = value['_seconds'] as int;
      final nanoseconds = value['_nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds / 1000000).round(),
      );
    }
    return DateTime.now();
  }
}
