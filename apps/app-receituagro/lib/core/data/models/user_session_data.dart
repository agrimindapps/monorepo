import 'package:core/core.dart' hide Column;

/// Dados da sessão do usuário no ReceitauAgro
/// Contém informações específicas da sessão atual
class UserSessionData extends Equatable {
  final String userId;
  final String deviceId;
  final DateTime loginTime;
  final bool isAnonymous;
  final String? deviceName;
  final Map<String, dynamic> metadata;

  const UserSessionData({
    required this.userId,
    required this.deviceId,
    required this.loginTime,
    required this.isAnonymous,
    this.deviceName,
    this.metadata = const {},
  });

  Duration get sessionDuration => DateTime.now().difference(loginTime);
  
  bool get isLongSession => sessionDuration.inMinutes > 30;

  UserSessionData copyWith({
    String? userId,
    String? deviceId,
    DateTime? loginTime,
    bool? isAnonymous,
    String? deviceName,
    Map<String, dynamic>? metadata,
  }) {
    return UserSessionData(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      loginTime: loginTime ?? this.loginTime,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      deviceName: deviceName ?? this.deviceName,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'loginTime': loginTime.toIso8601String(),
      'isAnonymous': isAnonymous,
      'deviceName': deviceName,
      'metadata': metadata,
    };
  }

  factory UserSessionData.fromJson(Map<String, dynamic> json) {
    return UserSessionData(
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      loginTime: DateTime.parse(json['loginTime'] as String),
      isAnonymous: json['isAnonymous'] as bool,
      deviceName: json['deviceName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        userId,
        deviceId,
        loginTime,
        isAnonymous,
        deviceName,
        metadata,
      ];

  @override
  String toString() {
    return 'UserSessionData(userId: $userId, deviceId: $deviceId, loginTime: $loginTime, isAnonymous: $isAnonymous)';
  }
}
