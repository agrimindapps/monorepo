import 'package:core/core.dart' as core;

/// Estatísticas de dispositivos
class DeviceStatistics {
  const DeviceStatistics({
    required this.totalDevices,
    required this.activeDevices,
    required this.inactiveDevices,
    required this.trustedDevices,
    required this.untrustedDevices,
    required this.physicalDevices,
    required this.emulators,
    required this.lastActivityDate,
    required this.oldestDeviceDate,
    required this.averageTrustLevel,
    required this.devicesByPlatform,
  });

  final int totalDevices;
  final int activeDevices;
  final int inactiveDevices;
  final int trustedDevices;
  final int untrustedDevices;
  final int physicalDevices;
  final int emulators;
  final DateTime? lastActivityDate;
  final DateTime? oldestDeviceDate;
  final double averageTrustLevel;
  final Map<String, int> devicesByPlatform;

  /// Cria estatísticas vazias
  factory DeviceStatistics.empty() {
    return const DeviceStatistics(
      totalDevices: 0,
      activeDevices: 0,
      inactiveDevices: 0,
      trustedDevices: 0,
      untrustedDevices: 0,
      physicalDevices: 0,
      emulators: 0,
      lastActivityDate: null,
      oldestDeviceDate: null,
      averageTrustLevel: 0.0,
      devicesByPlatform: {},
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
    'totalDevices': totalDevices,
    'activeDevices': activeDevices,
    'inactiveDevices': inactiveDevices,
    'trustedDevices': trustedDevices,
    'untrustedDevices': untrustedDevices,
    'physicalDevices': physicalDevices,
    'emulators': emulators,
    'lastActivityDate': lastActivityDate?.toIso8601String(),
    'oldestDeviceDate': oldestDeviceDate?.toIso8601String(),
    'averageTrustLevel': averageTrustLevel,
    'devicesByPlatform': devicesByPlatform,
  };
}

/// Serviço responsável por calcular estatísticas de dispositivos
///
/// Isola a lógica de cálculo de estatísticas,
/// seguindo o princípio Single Responsibility.

class DeviceStatisticsCalculator {
  DeviceStatisticsCalculator();

  /// Calcula estatísticas completas a partir de uma lista de dispositivos
  DeviceStatistics calculateStatistics(List<core.DeviceEntity> devices) {
    if (devices.isEmpty) {
      return DeviceStatistics.empty();
    }

    final totalDevices = devices.length;
    final activeDevices = _countActiveDevices(devices);
    final inactiveDevices = totalDevices - activeDevices;
    final trustedDevices = _countTrustedDevices(devices);
    final untrustedDevices = totalDevices - trustedDevices;
    final physicalDevices = _countPhysicalDevices(devices);
    final emulators = totalDevices - physicalDevices;
    final lastActivityDate = _getLastActivityDate(devices);
    final oldestDeviceDate = _getOldestDeviceDate(devices);
    final averageTrustLevel = _calculateAverageTrustLevel(devices);
    final devicesByPlatform = _groupDevicesByPlatform(devices);

    return DeviceStatistics(
      totalDevices: totalDevices,
      activeDevices: activeDevices,
      inactiveDevices: inactiveDevices,
      trustedDevices: trustedDevices,
      untrustedDevices: untrustedDevices,
      physicalDevices: physicalDevices,
      emulators: emulators,
      lastActivityDate: lastActivityDate,
      oldestDeviceDate: oldestDeviceDate,
      averageTrustLevel: averageTrustLevel,
      devicesByPlatform: devicesByPlatform,
    );
  }

  /// Conta dispositivos ativos
  int _countActiveDevices(List<core.DeviceEntity> devices) {
    return devices.where((device) => device.isActive).length;
  }

  /// Conta dispositivos confiáveis
  int _countTrustedDevices(List<core.DeviceEntity> devices) {
    return devices.where((device) => device.isTrusted).length;
  }

  /// Conta dispositivos físicos
  int _countPhysicalDevices(List<core.DeviceEntity> devices) {
    return devices.where((device) => device.isPhysicalDevice).length;
  }

  /// Obtém a data da última atividade
  DateTime? _getLastActivityDate(List<core.DeviceEntity> devices) {
    final activeDates = devices.map((device) => device.lastActiveAt).toList();

    if (activeDates.isEmpty) return null;

    activeDates.sort((a, b) => b.compareTo(a)); // Ordena decrescente
    return activeDates.first;
  }

  /// Obtém a data do dispositivo mais antigo
  DateTime? _getOldestDeviceDate(List<core.DeviceEntity> devices) {
    final creationDates = devices
        .map((device) => device.createdAt)
        .where((date) => date != null)
        .toList();

    if (creationDates.isEmpty) return null;

    creationDates.sort((a, b) => a!.compareTo(b!)); // Ordena crescente
    return creationDates.first;
  }

  /// Calcula o nível médio de confiança
  double _calculateAverageTrustLevel(List<core.DeviceEntity> devices) {
    if (devices.isEmpty) return 0.0;

    var totalTrustLevel = 0;

    for (final device in devices) {
      totalTrustLevel += _calculateDeviceTrustLevel(device);
    }

    return totalTrustLevel / devices.length;
  }

  /// Calcula o nível de confiança de um dispositivo (0-100)
  int _calculateDeviceTrustLevel(core.DeviceEntity device) {
    var trustLevel = 0;

    // Dispositivo físico: +30 pontos
    if (device.isPhysicalDevice) trustLevel += 30;

    // Dispositivo confiável: +40 pontos
    if (device.isTrusted) trustLevel += 40;

    // Dispositivo ativo: +10 pontos
    if (device.isActive) trustLevel += 10;

    // Atividade recente: +20 pontos
    final daysSinceActivity = DateTime.now()
        .difference(device.lastActiveAt)
        .inDays;

    if (daysSinceActivity <= 7) {
      trustLevel += 20;
    } else if (daysSinceActivity <= 30) {
      trustLevel += 10;
    }

    return trustLevel.clamp(0, 100);
  }

  /// Agrupa dispositivos por plataforma
  Map<String, int> _groupDevicesByPlatform(List<core.DeviceEntity> devices) {
    final platformCounts = <String, int>{};

    for (final device in devices) {
      final platform = device.platform;
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }

    return platformCounts;
  }

  /// Filtra dispositivos por período de atividade
  List<core.DeviceEntity> filterDevicesByActivity({
    required List<core.DeviceEntity> devices,
    required Duration inactivityThreshold,
  }) {
    final now = DateTime.now();

    return devices.where((device) {
      final inactiveDuration = now.difference(device.lastActiveAt);
      return inactiveDuration <= inactivityThreshold;
    }).toList();
  }

  /// Identifica dispositivos inativos que podem ser removidos
  List<core.DeviceEntity> findStaleDevices({
    required List<core.DeviceEntity> devices,
    int inactiveDaysThreshold = 90,
  }) {
    final now = DateTime.now();

    return devices.where((device) {
      final daysSinceActivity = now.difference(device.lastActiveAt).inDays;
      return daysSinceActivity >= inactiveDaysThreshold;
    }).toList();
  }

  /// Calcula percentual de dispositivos confiáveis
  double calculateTrustedDevicePercentage(List<core.DeviceEntity> devices) {
    if (devices.isEmpty) return 0.0;

    final trustedCount = _countTrustedDevices(devices);
    return (trustedCount / devices.length) * 100;
  }

  /// Calcula percentual de dispositivos ativos
  double calculateActiveDevicePercentage(List<core.DeviceEntity> devices) {
    if (devices.isEmpty) return 0.0;

    final activeCount = _countActiveDevices(devices);
    return (activeCount / devices.length) * 100;
  }
}
