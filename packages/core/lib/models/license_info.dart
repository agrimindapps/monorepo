/// License information model
class LicenseInfo {
  final bool isActive;
  final DateTime? expirationDate;
  final String type; // 'trial', 'premium', 'none'
  final int? trialDaysRemaining;
  final bool isExpired;
  final String? id;
  final DateTime? startDate;

  const LicenseInfo({
    required this.isActive,
    this.expirationDate,
    required this.type,
    this.trialDaysRemaining,
    required this.isExpired,
    this.id,
    this.startDate,
  });

  /// No license (free version)
  factory LicenseInfo.noLicense() {
    return const LicenseInfo(
      isActive: false,
      type: 'none',
      isExpired: false,
    );
  }

  /// Trial license
  factory LicenseInfo.trial({
    required DateTime expirationDate,
    required int daysRemaining,
    DateTime? startDate,
  }) {
    return LicenseInfo(
      isActive: daysRemaining > 0,
      expirationDate: expirationDate,
      type: 'trial',
      trialDaysRemaining: daysRemaining,
      isExpired: daysRemaining <= 0,
      startDate: startDate ?? DateTime.now(),
    );
  }

  /// Premium license
  factory LicenseInfo.premium({
    DateTime? expirationDate,
    DateTime? startDate,
    String? id,
  }) {
    return LicenseInfo(
      isActive: true,
      expirationDate: expirationDate,
      type: 'premium',
      isExpired: false,
      id: id,
      startDate: startDate ?? DateTime.now(),
    );
  }

  /// From JSON
  factory LicenseInfo.fromJson(Map<String, dynamic> json) {
    return LicenseInfo(
      isActive: json['isActive'] as bool? ?? false,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      type: json['type'] as String? ?? 'none',
      trialDaysRemaining: json['trialDaysRemaining'] as int?,
      isExpired: json['isExpired'] as bool? ?? false,
      id: json['id'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'expirationDate': expirationDate?.toIso8601String(),
      'type': type,
      'trialDaysRemaining': trialDaysRemaining,
      'isExpired': isExpired,
      'id': id,
      'startDate': startDate?.toIso8601String(),
    };
  }

  /// Copy with
  LicenseInfo copyWith({
    bool? isActive,
    DateTime? expirationDate,
    String? type,
    int? trialDaysRemaining,
    bool? isExpired,
    String? id,
    DateTime? startDate,
  }) {
    return LicenseInfo(
      isActive: isActive ?? this.isActive,
      expirationDate: expirationDate ?? this.expirationDate,
      type: type ?? this.type,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      isExpired: isExpired ?? this.isExpired,
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
    );
  }

  // ✅ Compatibility getters for app-plantis
  bool get hasValidLicense => isActive && !isExpired;
  bool get isTrialActive => isActive && type == 'trial' && !isExpired;
  bool get isPremiumActive => isActive && type == 'premium' && !isExpired;
  
  // For old code that expects `.license` property
  LicenseInfo? get license => this;
  
  // Remaining text for UI display
  String get remainingText {
    if (type == 'trial') {
      final days = trialDaysRemaining ?? 0;
      if (days <= 0) return 'Trial expirado';
      if (days == 1) return '1 dia restante';
      return '$days dias restantes';
    } else if (type == 'premium' && expirationDate != null) {
      final days = expirationDate!.difference(DateTime.now()).inDays;
      if (days <= 0) return 'Expirado';
      if (days == 1) return '1 dia restante';
      return '$days dias restantes';
    }
    return 'Ilimitado';
  }
  
  // Additional compatibility getters
  int get remainingDays => trialDaysRemaining ?? 0;
  
  String get statusText {
    if (isExpired) return 'Expirado';
    if (isActive && type == 'premium') return 'Premium Ativo';
    if (isActive && type == 'trial') return 'Trial Ativo';
    return 'Gratuito';
  }
  
  String get typeText {
    switch (type) {
      case 'premium':
        return 'Premium';
      case 'trial':
        return 'Trial';
      case 'none':
      default:
        return 'Gratuito';
    }
  }

  @override
  String toString() {
    return 'LicenseInfo(isActive: $isActive, type: $type, expirationDate: $expirationDate, trialDaysRemaining: $trialDaysRemaining, isExpired: $isExpired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LicenseInfo &&
        other.isActive == isActive &&
        other.expirationDate == expirationDate &&
        other.type == type &&
        other.trialDaysRemaining == trialDaysRemaining &&
        other.isExpired == isExpired &&
        other.id == id &&
        other.startDate == startDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      isActive,
      expirationDate,
      type,
      trialDaysRemaining,
      isExpired,
      id,
      startDate,
    );
  }
}
