import 'base_entity.dart';

/// Entidade que representa um dispositivo registrado no sistema
/// Contém informações sobre hardware, software e status do dispositivo
class DeviceEntity extends BaseEntity {
  const DeviceEntity({
    required super.id,
    required this.uuid,
    required this.name,
    required this.model,
    required this.platform,
    required this.systemVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.isPhysicalDevice,
    required this.manufacturer,
    required this.firstLoginAt,
    required this.lastActiveAt,
    this.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  /// UUID único do dispositivo (fingerprint)
  final String uuid;

  /// Nome do dispositivo (ex: "iPhone de João")
  final String name;

  /// Modelo do dispositivo (ex: "iPhone 14 Pro")
  final String model;

  /// Plataforma do dispositivo (iOS, Android)
  final String platform;

  /// Versão do sistema operacional
  final String systemVersion;

  /// Versão do aplicativo
  final String appVersion;

  /// Número do build do aplicativo
  final String buildNumber;

  /// Se é um dispositivo físico (não emulador)
  final bool isPhysicalDevice;

  /// Fabricante do dispositivo (Apple, Samsung, etc.)
  final String manufacturer;

  /// Data do primeiro login no dispositivo
  final DateTime firstLoginAt;

  /// Data da última atividade no dispositivo
  final DateTime lastActiveAt;

  /// Se o dispositivo está ativo (não revogado)
  final bool isActive;

  /// Retorna se o dispositivo está online recentemente (últimas 24h)
  bool get isRecentlyActive {
    final now = DateTime.now();
    return now.difference(lastActiveAt).inHours < 24;
  }

  /// Retorna descrição amigável do dispositivo
  String get displayName => '$name ($model)';

  /// Retorna string de identificação completa
  String get fullIdentifier => '$platform $systemVersion - $appVersion ($buildNumber)';

  /// Retorna se é um dispositivo confiável (físico e não emulador)
  bool get isTrusted => isPhysicalDevice && isActive;

  /// Retorna quanto tempo o dispositivo está inativo
  Duration get inactiveDuration => DateTime.now().difference(lastActiveAt);

  @override
  BaseEntity copyWith({
    String? id,
    String? uuid,
    String? name,
    String? model,
    String? platform,
    String? systemVersion,
    String? appVersion,
    String? buildNumber,
    bool? isPhysicalDevice,
    String? manufacturer,
    DateTime? firstLoginAt,
    DateTime? lastActiveAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      model: model ?? this.model,
      platform: platform ?? this.platform,
      systemVersion: systemVersion ?? this.systemVersion,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      manufacturer: manufacturer ?? this.manufacturer,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'model': model,
      'platform': platform,
      'systemVersion': systemVersion,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'isPhysicalDevice': isPhysicalDevice,
      'manufacturer': manufacturer,
      'firstLoginAt': firstLoginAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Cria instância do JSON
  factory DeviceEntity.fromJson(Map<String, dynamic> json) {
    return DeviceEntity(
      id: json['id'] as String,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      platform: json['platform'] as String,
      systemVersion: json['systemVersion'] as String,
      appVersion: json['appVersion'] as String,
      buildNumber: json['buildNumber'] as String,
      isPhysicalDevice: json['isPhysicalDevice'] as bool? ?? true,
      manufacturer: json['manufacturer'] as String,
      firstLoginAt: DateTime.parse(json['firstLoginAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String) 
        : null,
    );
  }

  /// Converte para Map (compatibilidade com Hive)
  Map<String, dynamic> toMap() => toJson();

  /// Cria instância do Map (compatibilidade com Hive)
  factory DeviceEntity.fromMap(Map<String, dynamic> map) => 
    DeviceEntity.fromJson(map);

  @override
  List<Object?> get props => [
        ...super.props,
        uuid,
        name,
        model,
        platform,
        systemVersion,
        appVersion,
        buildNumber,
        isPhysicalDevice,
        manufacturer,
        firstLoginAt,
        lastActiveAt,
        isActive,
      ];

  @override
  String toString() => 'DeviceEntity(id: $id, uuid: $uuid, name: $name, '
      'model: $model, platform: $platform, isActive: $isActive)';
}

/// Enums para tipos de dispositivo
enum DevicePlatform {
  ios,
  android,
  web,
  windows,
  macos,
  linux,
  unknown;

  /// Retorna nome amigável da plataforma
  String get displayName {
    switch (this) {
      case DevicePlatform.ios:
        return 'iOS';
      case DevicePlatform.android:
        return 'Android';
      case DevicePlatform.web:
        return 'Web';
      case DevicePlatform.windows:
        return 'Windows';
      case DevicePlatform.macos:
        return 'macOS';
      case DevicePlatform.linux:
        return 'Linux';
      case DevicePlatform.unknown:
        return 'Desconhecido';
    }
  }

  /// Cria enum a partir de string
  static DevicePlatform fromString(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return DevicePlatform.ios;
      case 'android':
        return DevicePlatform.android;
      case 'web':
        return DevicePlatform.web;
      case 'windows':
        return DevicePlatform.windows;
      case 'macos':
        return DevicePlatform.macos;
      case 'linux':
        return DevicePlatform.linux;
      default:
        return DevicePlatform.unknown;
    }
  }
}

/// Status de validação do dispositivo
enum DeviceValidationStatus {
  valid,
  invalid,
  pending,
  revoked,
  exceeded,
  unsupportedPlatform; // Web e outras plataformas não suportadas

  /// Retorna nome amigável do status
  String get displayName {
    switch (this) {
      case DeviceValidationStatus.valid:
        return 'Válido';
      case DeviceValidationStatus.invalid:
        return 'Inválido';
      case DeviceValidationStatus.pending:
        return 'Pendente';
      case DeviceValidationStatus.revoked:
        return 'Revogado';
      case DeviceValidationStatus.exceeded:
        return 'Limite Excedido';
      case DeviceValidationStatus.unsupportedPlatform:
        return 'Plataforma Não Suportada';
    }
  }

  /// Retorna cor do status para UI
  String get colorHex {
    switch (this) {
      case DeviceValidationStatus.valid:
        return '#4CAF50'; // Verde
      case DeviceValidationStatus.invalid:
        return '#F44336'; // Vermelho
      case DeviceValidationStatus.pending:
        return '#FF9800'; // Laranja
      case DeviceValidationStatus.revoked:
        return '#9E9E9E'; // Cinza
      case DeviceValidationStatus.exceeded:
        return '#FF5722'; // Vermelho escuro
      case DeviceValidationStatus.unsupportedPlatform:
        return '#9C27B0'; // Roxo
    }
  }
}
