import 'dart:io';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Model específico do app-plantis para dispositivos
/// Extende a entidade do core com funcionalidades específicas do app
class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.uuid,
    required super.name,
    required super.model,
    required super.platform,
    required super.systemVersion,
    required super.appVersion,
    required super.buildNumber,
    required super.isPhysicalDevice,
    required super.manufacturer,
    required super.firstLoginAt,
    required super.lastActiveAt,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
    this.plantisSpecificData,
  });

  /// Dados específicos do app-plantis (extensão futura)
  final Map<String, dynamic>? plantisSpecificData;

  /// Cria model a partir da entidade do core
  factory DeviceModel.fromEntity(DeviceEntity entity) {
    return DeviceModel(
      id: entity.id,
      uuid: entity.uuid,
      name: entity.name,
      model: entity.model,
      platform: entity.platform,
      systemVersion: entity.systemVersion,
      appVersion: entity.appVersion,
      buildNumber: entity.buildNumber,
      isPhysicalDevice: entity.isPhysicalDevice,
      manufacturer: entity.manufacturer,
      firstLoginAt: entity.firstLoginAt,
      lastActiveAt: entity.lastActiveAt,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converte para entidade do core
  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Cria model do JSON (compatibilidade com API)
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final coreEntity = DeviceEntity.fromJson(json);
    return DeviceModel(
      id: coreEntity.id,
      uuid: coreEntity.uuid,
      name: coreEntity.name,
      model: coreEntity.model,
      platform: coreEntity.platform,
      systemVersion: coreEntity.systemVersion,
      appVersion: coreEntity.appVersion,
      buildNumber: coreEntity.buildNumber,
      isPhysicalDevice: coreEntity.isPhysicalDevice,
      manufacturer: coreEntity.manufacturer,
      firstLoginAt: coreEntity.firstLoginAt,
      lastActiveAt: coreEntity.lastActiveAt,
      isActive: coreEntity.isActive,
      createdAt: coreEntity.createdAt,
      updatedAt: coreEntity.updatedAt,
      plantisSpecificData: json['plantisSpecificData'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON (compatibilidade com API)
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (plantisSpecificData != null) {
      json['plantisSpecificData'] = plantisSpecificData;
    }
    return json;
  }

  /// Cria model com device info atual do sistema usando device_info_plus diretamente
  /// REGRA: Apenas Android e iOS são permitidos. Web e outras plataformas são bloqueadas.
  /// Retorna null se a plataforma não for suportada.
  static Future<DeviceModel?> fromCurrentDevice() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    final now = DateTime.now();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceModel: Criando device Android - ${androidInfo.brand} ${androidInfo.model}',
        );
      }

      return DeviceModel(
        id: '', // Será definido pelo servidor
        uuid: androidInfo.id, // Android ID único
        name: '${androidInfo.brand} ${androidInfo.model}',
        model: androidInfo.model,
        platform: 'Android',
        systemVersion: 'Android ${androidInfo.version.release}',
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        manufacturer: androidInfo.manufacturer,
        firstLoginAt: now,
        lastActiveAt: now,
        isActive: true,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;

      if (kDebugMode) {
        debugPrint('📱 DeviceModel: Criando device iOS - ${iosInfo.name}');
      }

      return DeviceModel(
        id: '', // Será definido pelo servidor
        uuid: iosInfo.identifierForVendor ?? 'unknown', // iOS identifier
        name: iosInfo.name,
        model: iosInfo.model,
        platform: 'iOS',
        systemVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        manufacturer: 'Apple',
        firstLoginAt: now,
        lastActiveAt: now,
        isActive: true,
      );
    } else {
      if (kDebugMode) {
        debugPrint(
          '🚫 DeviceModel: Plataforma ${Platform.operatingSystem} não permitida para registro',
        );
        debugPrint(
          '   Apenas Android e iOS são suportados para gerenciamento de dispositivos',
        );
      }
      return null;
    }
  }

  @override
  DeviceModel copyWith({
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
    Map<String, dynamic>? plantisSpecificData,
  }) {
    return DeviceModel(
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
      plantisSpecificData: plantisSpecificData ?? this.plantisSpecificData,
    );
  }

  /// Retorna ícone específico para a plataforma no app-plantis
  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'ios':
        return '🍎';
      case 'android':
        return '🤖';
      case 'web':
        return '🌐';
      case 'windows':
        return '🖥️';
      case 'macos':
        return '💻';
      default:
        return '📱';
    }
  }

  /// Retorna status visual para UI do plantis
  String get statusText {
    if (!isActive) return 'Revogado';
    if (isRecentlyActive) return 'Ativo';

    final hoursInactive = inactiveDuration.inHours;
    if (hoursInactive < 24) return 'Recente';
    if (hoursInactive < 168) return 'Esta semana'; // 7 dias
    if (hoursInactive < 720) return 'Este mês'; // 30 dias
    return 'Inativo há tempo';
  }

  /// Retorna cor do status para o tema do plantis
  String get statusColorHex {
    if (!isActive) return '#9E9E9E'; // Cinza
    if (isRecentlyActive) return '#4CAF50'; // Verde

    final hoursInactive = inactiveDuration.inHours;
    if (hoursInactive < 24) return '#8BC34A'; // Verde claro
    if (hoursInactive < 168) return '#FFC107'; // Amarelo
    if (hoursInactive < 720) return '#FF9800'; // Laranja
    return '#F44336'; // Vermelho
  }

  @override
  List<Object?> get props => [...super.props, plantisSpecificData];
}

/// Model para estatísticas de dispositivos específicas do plantis
class DeviceStatisticsModel extends DeviceStatistics {
  const DeviceStatisticsModel({
    required super.totalDevices,
    required super.activeDevices,
    required super.devicesByPlatform,
    super.lastActiveDevice,
    super.oldestDevice,
    super.newestDevice,
    this.plantisMetrics,
  });

  /// Métricas específicas do app-plantis
  final Map<String, dynamic>? plantisMetrics;

  /// Cria model a partir da entidade do core
  factory DeviceStatisticsModel.fromEntity(DeviceStatistics entity) {
    return DeviceStatisticsModel(
      totalDevices: entity.totalDevices,
      activeDevices: entity.activeDevices,
      devicesByPlatform: entity.devicesByPlatform,
      lastActiveDevice: entity.lastActiveDevice,
      oldestDevice: entity.oldestDevice,
      newestDevice: entity.newestDevice,
    );
  }

  /// Converte para entidade do core
  DeviceStatistics toEntity() {
    return DeviceStatistics(
      totalDevices: totalDevices,
      activeDevices: activeDevices,
      devicesByPlatform: devicesByPlatform,
      lastActiveDevice: lastActiveDevice,
      oldestDevice: oldestDevice,
      newestDevice: newestDevice,
    );
  }

  /// Retorna resumo formatado para UI do plantis
  String get summary {
    if (totalDevices == 0) return 'Nenhum dispositivo registrado';
    if (totalDevices == 1) return '1 dispositivo registrado';

    final inactive = totalDevices - activeDevices;
    if (inactive == 0) {
      return '$totalDevices dispositivos ativos';
    }

    return '$activeDevices de $totalDevices dispositivos ativos';
  }

  /// Retorna plataforma mais usada
  String? get mostUsedPlatform {
    if (devicesByPlatform.isEmpty) return null;

    var maxCount = 0;
    String? mostUsed;

    for (final entry in devicesByPlatform.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostUsed = entry.key;
      }
    }

    return mostUsed;
  }
}
