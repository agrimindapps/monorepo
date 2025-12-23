import 'package:core/core.dart';

// Re-export DeviceStatistics from core to avoid conflicts
export 'package:core/core.dart' show DeviceStatistics;

/// Entidade que representa uma sessão de dispositivo
class DeviceSession extends Equatable {
  const DeviceSession({
    required this.id,
    required this.userId,
    required this.deviceUuid,
    required this.deviceInfo,
    required this.createdAt,
    required this.lastActiveAt,
    required this.isActive,
    this.tokenId,
    this.ipAddress,
    this.location,
    this.userAgent,
  });

  final String id;
  final String userId;
  final String deviceUuid;
  final DeviceEntity deviceInfo;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isActive;
  final String? tokenId;
  final String? ipAddress;
  final String? location;
  final String? userAgent;

  /// Indica se a sessão expirou (30 dias sem atividade)
  bool get isExpired {
    final diff = DateTime.now().difference(lastActiveAt);
    return diff.inDays > 30;
  }

  /// Status da sessão baseado na atividade
  String get sessionStatus {
    if (!isActive) return 'Inativa';
    if (isExpired) return 'Expirada';
    final diff = DateTime.now().difference(lastActiveAt);
    if (diff.inMinutes < 5) return 'Ativa agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atrás';
    if (diff.inDays < 1) return '${diff.inHours}h atrás';
    if (diff.inDays < 30) return '${diff.inDays}d atrás';
    return 'Inativa há muito tempo';
  }

  /// Cria uma cópia com novos valores
  DeviceSession copyWith({
    String? id,
    String? userId,
    String? deviceUuid,
    DeviceEntity? deviceInfo,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isActive,
    String? tokenId,
    String? ipAddress,
    String? location,
    String? userAgent,
  }) {
    return DeviceSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceUuid: deviceUuid ?? this.deviceUuid,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      tokenId: tokenId ?? this.tokenId,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        deviceUuid,
        deviceInfo,
        createdAt,
        lastActiveAt,
        isActive,
        tokenId,
        ipAddress,
        location,
        userAgent,
      ];

  @override
  String toString() => 
      'DeviceSession(id: $id, deviceUuid: $deviceUuid, isActive: $isActive)';
}
