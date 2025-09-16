import '../../domain/entities/device_session.dart';
import 'device_info_model.dart';

/// Model de DeviceStatistics para serialização de dados
class DeviceStatisticsModel extends DeviceStatistics {
  const DeviceStatisticsModel({
    required super.totalDevices,
    required super.activeDevices,
    required super.devicesByPlatform,
    super.lastActiveDevice,
    super.oldestDevice,
    super.newestDevice,
  });

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'totalDevices': totalDevices,
      'activeDevices': activeDevices,
      'devicesByPlatform': devicesByPlatform,
      'lastActiveDevice': lastActiveDevice != null
          ? DeviceInfoModel.fromEntity(lastActiveDevice!).toMap()
          : null,
      'oldestDevice': oldestDevice != null
          ? DeviceInfoModel.fromEntity(oldestDevice!).toMap()
          : null,
      'newestDevice': newestDevice != null
          ? DeviceInfoModel.fromEntity(newestDevice!).toMap()
          : null,
    };
  }

  /// Cria instância a partir de Map
  factory DeviceStatisticsModel.fromMap(Map<String, dynamic> map) {
    return DeviceStatisticsModel(
      totalDevices: map['totalDevices'] as int? ?? 0,
      activeDevices: map['activeDevices'] as int? ?? 0,
      devicesByPlatform: Map<String, int>.from(
        map['devicesByPlatform'] as Map? ?? {},
      ),
      lastActiveDevice: map['lastActiveDevice'] != null
          ? DeviceInfoModel.fromMap(
              map['lastActiveDevice'] as Map<String, dynamic>,
            )
          : null,
      oldestDevice: map['oldestDevice'] != null
          ? DeviceInfoModel.fromMap(
              map['oldestDevice'] as Map<String, dynamic>,
            )
          : null,
      newestDevice: map['newestDevice'] != null
          ? DeviceInfoModel.fromMap(
              map['newestDevice'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Cria instância a partir de JSON do Firestore
  factory DeviceStatisticsModel.fromFirestore(Map<String, dynamic> doc) {
    return DeviceStatisticsModel(
      totalDevices: doc['totalDevices'] as int? ?? 0,
      activeDevices: doc['activeDevices'] as int? ?? 0,
      devicesByPlatform: Map<String, int>.from(
        doc['devicesByPlatform'] as Map? ?? {},
      ),
      lastActiveDevice: doc['lastActiveDevice'] != null
          ? DeviceInfoModel.fromFirestore(
              doc['lastActiveDevice'] as Map<String, dynamic>,
            )
          : null,
      oldestDevice: doc['oldestDevice'] != null
          ? DeviceInfoModel.fromFirestore(
              doc['oldestDevice'] as Map<String, dynamic>,
            )
          : null,
      newestDevice: doc['newestDevice'] != null
          ? DeviceInfoModel.fromFirestore(
              doc['newestDevice'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converte para Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'totalDevices': totalDevices,
      'activeDevices': activeDevices,
      'devicesByPlatform': devicesByPlatform,
      'lastActiveDevice': lastActiveDevice != null
          ? DeviceInfoModel.fromEntity(lastActiveDevice!).toFirestore()
          : null,
      'oldestDevice': oldestDevice != null
          ? DeviceInfoModel.fromEntity(oldestDevice!).toFirestore()
          : null,
      'newestDevice': newestDevice != null
          ? DeviceInfoModel.fromEntity(newestDevice!).toFirestore()
          : null,
    };
  }

  /// Converte entidade para model
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

  /// Converte model para entidade
  DeviceStatistics toEntity() => this;

  /// Cria uma cópia com novos valores
  DeviceStatisticsModel copyWith({
    int? totalDevices,
    int? activeDevices,
    Map<String, int>? devicesByPlatform,
    DeviceInfoModel? lastActiveDevice,
    DeviceInfoModel? oldestDevice,
    DeviceInfoModel? newestDevice,
  }) {
    return DeviceStatisticsModel(
      totalDevices: totalDevices ?? this.totalDevices,
      activeDevices: activeDevices ?? this.activeDevices,
      devicesByPlatform: devicesByPlatform ?? this.devicesByPlatform,
      lastActiveDevice: lastActiveDevice ?? this.lastActiveDevice,
      oldestDevice: oldestDevice ?? this.oldestDevice,
      newestDevice: newestDevice ?? this.newestDevice,
    );
  }
}
