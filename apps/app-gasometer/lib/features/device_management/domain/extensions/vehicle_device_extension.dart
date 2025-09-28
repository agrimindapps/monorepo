import 'package:core/core.dart';

/// Extension para DeviceEntity com funcionalidades específicas de veículos
extension VehicleDeviceExtension on DeviceEntity {
  /// Indica se o dispositivo pode acessar funcionalidades de veículo
  bool get canAccessVehicle => isActive && isTrusted;

  /// Nome de exibição específico para contexto veicular
  String get vehicleDisplayName => '$displayName (Veículo)';

  /// Status de atividade otimizado para uso veicular
  String get vehicleActivityStatus {
    final diff = inactiveDuration;
    if (diff.inMinutes < 5) return 'Ativo agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atrás';
    if (diff.inDays < 1) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}sem atrás';
    return 'Inativo há mais de 1 mês';
  }

  /// Indica se o dispositivo é adequado para operações financeiras sensíveis
  bool get canAccessFinancialData => isTrusted && isRecentlyActive;

  /// Indica se o dispositivo pode fazer sync de dados offline
  bool get canSyncOfflineData => isActive && isPhysicalDevice;

  /// Prioridade do dispositivo para sync (dispositivos mais confiáveis primeiro)
  int get syncPriority {
    if (!isActive) return 0;
    if (!isPhysicalDevice) return 1;
    if (!isRecentlyActive) return 2;
    return 3; // Máxima prioridade
  }

  /// Compatibilidade para campos que existiam no DeviceInfo antigo
  String get identifier => uuid; // DeviceInfo tinha identifier, DeviceEntity usa uuid
  String? get location => null; // DeviceEntity não tem location, pode ser null
  String? get ipAddress => null; // DeviceEntity não tem ipAddress, pode ser null

  /// Versão completa da aplicação (compatibilidade com DeviceInfo)
  String get fullAppVersion => '$appVersion ($buildNumber)';

  /// Indica se é dispositivo de desenvolvimento (compatibilidade com DeviceInfo)
  bool get isDevelopmentDevice => !isPhysicalDevice;

  /// Cria DeviceEntity a partir do DeviceInfo antigo (migração)
  static DeviceEntity fromDeviceInfo({
    required String uuid,
    required String name,
    required String model,
    required String platform,
    required String systemVersion,
    required String appVersion,
    required String buildNumber,
    required String identifier,
    required bool isPhysicalDevice,
    required String manufacturer,
    required DateTime firstLoginAt,
    required DateTime lastActiveAt,
    required bool isActive,
  }) {
    return DeviceEntity(
      id: identifier, // Usar identifier como id
      uuid: uuid,
      name: name,
      model: model,
      platform: platform,
      systemVersion: systemVersion,
      appVersion: appVersion,
      buildNumber: buildNumber,
      isPhysicalDevice: isPhysicalDevice,
      manufacturer: manufacturer,
      firstLoginAt: firstLoginAt,
      lastActiveAt: lastActiveAt,
      isActive: isActive,
      createdAt: firstLoginAt,
      updatedAt: lastActiveAt,
    );
  }
}

/// Classe para estatísticas específicas de dispositivos veiculares
class VehicleDeviceStatistics {

  const VehicleDeviceStatistics({
    required this.totalDevices,
    required this.activeDevices,
    required this.trustedDevices,
    required this.recentlyActiveDevices,
    required this.syncPriorityDevices,
    required this.lastCalculatedAt,
  });
  final int totalDevices;
  final int activeDevices;
  final int trustedDevices;
  final int recentlyActiveDevices;
  final List<DeviceEntity> syncPriorityDevices;
  final DateTime lastCalculatedAt;

  /// Taxa de dispositivos ativos
  double get activeDeviceRate =>
    totalDevices > 0 ? activeDevices / totalDevices : 0.0;

  /// Taxa de dispositivos confiáveis
  double get trustedDeviceRate =>
    totalDevices > 0 ? trustedDevices / totalDevices : 0.0;

  /// Indica se há dispositivos suficientes para sync confiável
  bool get hasReliableSyncDevices => trustedDevices >= 2;

  /// Próximo dispositivo recomendado para revogação (menos confiável)
  DeviceEntity? get deviceToRevoke {
    final inactiveDevices = syncPriorityDevices
        .where((device) => !device.isRecentlyActive)
        .toList()
      ..sort((a, b) => a.syncPriority.compareTo(b.syncPriority));

    return inactiveDevices.isEmpty ? null : inactiveDevices.first;
  }

  /// Cria estatísticas a partir de uma lista de dispositivos
  static VehicleDeviceStatistics fromDevices(List<DeviceEntity> devices) {
    final activeDevices = devices.where((d) => d.isActive).toList();
    final trustedDevices = devices.where((d) => d.isTrusted).toList();
    final recentlyActiveDevices = devices.where((d) => d.isRecentlyActive).toList();

    // Ordena por prioridade de sync (maior prioridade primeiro)
    final syncPriorityDevices = List<DeviceEntity>.from(devices)
      ..sort((a, b) => b.syncPriority.compareTo(a.syncPriority));

    return VehicleDeviceStatistics(
      totalDevices: devices.length,
      activeDevices: activeDevices.length,
      trustedDevices: trustedDevices.length,
      recentlyActiveDevices: recentlyActiveDevices.length,
      syncPriorityDevices: syncPriorityDevices,
      lastCalculatedAt: DateTime.now(),
    );
  }
}