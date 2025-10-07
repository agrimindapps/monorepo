import 'dart:math';

import 'package:hive/hive.dart';

part 'license_model.g.dart';

/// Model representing a license for the application.
@HiveType(typeId: 10)
class LicenseModel extends HiveObject {
  /// Unique identifier for the license.
  @HiveField(0)
  final String id;

  /// The date when the license was created/started.
  @HiveField(1)
  final DateTime startDate;

  /// The date when the license expires.
  @HiveField(2)
  final DateTime expirationDate;

  /// Whether the license is currently active.
  @HiveField(3)
  final bool isActive;

  /// The type of license (e.g., trial, premium).
  @HiveField(4)
  final LicenseType type;

  /// Additional metadata for the license.
  @HiveField(5)
  final Map<String, dynamic>? metadata;

  LicenseModel({
    required this.id,
    required this.startDate,
    required this.expirationDate,
    required this.isActive,
    required this.type,
    this.metadata,
  });

  /// Factory constructor to create a 30-day trial license.
  ///
  /// If a [customId] is not provided, a unique ID will be generated.
  factory LicenseModel.createTrial({
    String? customId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return LicenseModel(
      id: customId ?? _generateLicenseId(),
      startDate: now,
      expirationDate: now.add(const Duration(days: 30)),
      isActive: true,
      type: LicenseType.trial,
      metadata: metadata,
    );
  }

  /// Checks if the license is currently valid.
  /// A license is valid if it's active and has not expired.
  bool get isValid => isActive && DateTime.now().isBefore(expirationDate);

  /// Checks if the license has expired.
  bool get isExpired => DateTime.now().isAfter(expirationDate);

  /// The number of remaining days for the license. Returns 0 if expired.
  int get remainingDays {
    if (isExpired) return 0;
    final remaining = expirationDate.difference(DateTime.now()).inDays;
    return remaining.isNegative ? 0 : remaining;
  }

  /// The number of remaining hours for the license. Returns 0 if expired.
  int get remainingHours {
    if (isExpired) return 0;
    final remaining = expirationDate.difference(DateTime.now()).inHours;
    return remaining.isNegative ? 0 : remaining;
  }

  /// Checks if the license is about to expire (within 3 days).
  bool get isAboutToExpire => remainingDays <= 3 && !isExpired;

  /// A user-friendly status text for the license.
  String get statusText {
    if (isExpired) return 'Expirada';
    if (isAboutToExpire) return 'Prestes a expirar';
    if (isValid) return 'Ativa';
    return 'Inativa';
  }

  /// Creates a copy of the license with updated fields.
  LicenseModel copyWith({
    String? id,
    DateTime? startDate,
    DateTime? expirationDate,
    bool? isActive,
    LicenseType? type,
    Map<String, dynamic>? metadata,
  }) {
    return LicenseModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts the [LicenseModel] to a JSON map for API communication.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'isActive': isActive,
      'type': type.name,
      'metadata': metadata,
    };
  }

  /// Creates a [LicenseModel] from a JSON map.
  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      isActive: json['isActive'] as bool,
      type: LicenseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LicenseType.trial,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'LicenseModel(id: $id, type: $type, isValid: $isValid, remainingDays: $remainingDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LicenseModel &&
        other.id == id &&
        other.startDate == startDate &&
        other.expirationDate == expirationDate &&
        other.isActive == isActive &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      startDate,
      expirationDate,
      isActive,
      type,
    );
  }

  /// Generates a unique ID for a trial license.
  static String _generateLicenseId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000000).toString().padLeft(6, '0');
    return 'LIC-TRIAL-$timestamp-$random';
  }
}

/// Enum for different types of licenses.
@HiveType(typeId: 11)
enum LicenseType {
  @HiveField(0)
  trial,
  @HiveField(1)
  premium,
  @HiveField(2)
  enterprise,
  @HiveField(3)
  lifetime,
}

/// An extension on [LicenseType] to provide user-friendly names and descriptions.
extension LicenseTypeExtension on LicenseType {
  /// A user-friendly name for the license type.
  String get displayName {
    switch (this) {
      case LicenseType.trial:
        return 'Trial (30 dias)';
      case LicenseType.premium:
        return 'Premium';
      case LicenseType.enterprise:
        return 'Enterprise';
      case LicenseType.lifetime:
        return 'Lifetime';
    }
  }

  /// A brief description of the license type.
  String get description {
    switch (this) {
      case LicenseType.trial:
        return 'Acesso completo por 30 dias';
      case LicenseType.premium:
        return 'Acesso premium mensal/anual';
      case LicenseType.enterprise:
        return 'Acesso empresarial completo';
      case LicenseType.lifetime:
        return 'Acesso premium vitalício';
    }
  }
}