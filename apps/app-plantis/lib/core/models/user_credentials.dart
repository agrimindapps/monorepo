/// User credentials model for secure storage
class UserCredentials {
  final String userId;
  final String email;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiry;

  const UserCredentials({
    required this.userId,
    required this.email,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenExpiry': tokenExpiry?.toIso8601String(),
  };

  factory UserCredentials.fromJson(Map<String, dynamic> json) =>
      UserCredentials(
        userId: json['userId'] as String,
        email: json['email'] as String,
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
        tokenExpiry: json['tokenExpiry'] != null
            ? DateTime.parse(json['tokenExpiry'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserCredentials &&
        other.userId == userId &&
        other.email == email &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenExpiry == tokenExpiry;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        email.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        tokenExpiry.hashCode;
  }

  @override
  String toString() {
    return 'UserCredentials(userId: $userId, email: $email, hasAccessToken: ${accessToken != null}, hasRefreshToken: ${refreshToken != null}, tokenExpiry: $tokenExpiry)';
  }
}