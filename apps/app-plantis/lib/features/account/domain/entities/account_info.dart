import 'package:equatable/equatable.dart';

/// Entity representando informações da conta do usuário
class AccountInfo extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final bool isAnonymous;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? avatarUrl;

  const AccountInfo({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.isAnonymous,
    required this.isPremium,
    this.createdAt,
    this.lastLoginAt,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
    userId,
    displayName,
    email,
    isAnonymous,
    isPremium,
    createdAt,
    lastLoginAt,
    avatarUrl,
  ];

  AccountInfo copyWith({
    String? userId,
    String? displayName,
    String? email,
    bool? isAnonymous,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? avatarUrl,
  }) {
    return AccountInfo(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
