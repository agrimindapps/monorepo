import 'package:equatable/equatable.dart';

/// Entidade que representa informações de um dispositivo
class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.uuid,
    required this.name,
    required this.model,
    required this.platform,
    required this.systemVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.identifier,
    required this.isPhysicalDevice,
    required this.manufacturer,
    required this.firstLoginAt,
    required this.lastActiveAt,
    required this.isActive,
    this.location,
    this.ipAddress,
  });

  final String uuid;
  final String name;
  final String model;
  final String platform;
  final String systemVersion;
  final String appVersion;
  final String buildNumber;
  final String identifier;
  final bool isPhysicalDevice;
  final String manufacturer;
  final DateTime firstLoginAt;
  final DateTime lastActiveAt;
  final bool isActive;
  final String? location;
  final String? ipAddress;

  /// Nome para exibição
  String get displayName => '$name • $platform $systemVersion';

  /// Versão completa da aplicação
  String get fullAppVersion => '$appVersion ($buildNumber)';

  /// Indica se é dispositivo de desenvolvimento
  bool get isDevelopmentDevice => !isPhysicalDevice;

  /// Status de atividade baseado na última atividade
  String get activityStatus {
    final diff = DateTime.now().difference(lastActiveAt);
    if (diff.inMinutes < 5) return 'Ativo agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atrás';
    if (diff.inDays < 1) return '${diff.inHours}h atrás';
    if (diff.inDays < 30) return '${diff.inDays}d atrás';
    return 'Inativo';
  }

  /// Cria uma cópia com novos valores
  DeviceInfo copyWith({
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
    return DeviceInfo(
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

  @override
  List<Object?> get props => [
        uuid,
        name,
        model,
        platform,
        systemVersion,
        appVersion,
        buildNumber,
        identifier,
        isPhysicalDevice,
        manufacturer,
        firstLoginAt,
        lastActiveAt,
        isActive,
        location,
        ipAddress,
      ];

  @override
  String toString() => 'DeviceInfo(uuid: $uuid, displayName: $displayName)';
}
