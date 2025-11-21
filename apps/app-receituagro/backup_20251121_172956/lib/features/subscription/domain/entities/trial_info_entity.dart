/// Trial info entity
/// Represents trial period information for a user
class TrialInfoEntity {
  final String id;
  final String productId;
  final bool isActive;
  final int totalTrialDays;
  final DateTime startDate;
  final DateTime? endDate;
  final String? expirationReason;
  final DateTime lastUpdated;

  const TrialInfoEntity({
    required this.id,
    required this.productId,
    required this.isActive,
    required this.totalTrialDays,
    required this.startDate,
    this.endDate,
    this.expirationReason,
    required this.lastUpdated,
  });

  /// Factory constructor for default/initial state
  factory TrialInfoEntity.initial(String productId) {
    final now = DateTime.now();
    return TrialInfoEntity(
      id: 'trial-${now.millisecondsSinceEpoch}',
      productId: productId,
      isActive: false,
      totalTrialDays: 0,
      startDate: now,
      endDate: null,
      expirationReason: null,
      lastUpdated: now,
    );
  }

  /// Create a copy with modified fields
  TrialInfoEntity copyWith({
    String? id,
    String? productId,
    bool? isActive,
    int? totalTrialDays,
    DateTime? startDate,
    DateTime? endDate,
    String? expirationReason,
    DateTime? lastUpdated,
  }) {
    return TrialInfoEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      isActive: isActive ?? this.isActive,
      totalTrialDays: totalTrialDays ?? this.totalTrialDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      expirationReason: expirationReason ?? this.expirationReason,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if trial has expired
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Get days remaining in trial
  Duration? get daysRemaining {
    if (!isActive || endDate == null) return null;
    final remaining = endDate!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Get days used in trial
  Duration get daysUsed {
    return DateTime.now().difference(startDate);
  }

  /// Check if trial is expiring soon (within 3 days)
  bool get isExpiringSoon {
    final remaining = daysRemaining;
    if (remaining == null) return false;
    return remaining.inDays <= 3 && remaining.inDays > 0;
  }

  /// Check if trial has been used (even if no longer active)
  bool get hasBeenUsed => daysUsed.inSeconds > 0;

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (totalTrialDays <= 0) return 0.0;
    final used = daysUsed.inDays;
    return ((used / totalTrialDays) * 100).clamp(0.0, 100.0);
  }

  /// Get human readable time remaining
  String get timeRemainingDisplay {
    final remaining = daysRemaining;
    if (remaining == null) {
      if (isExpired) {
        return 'Expirado';
      }
      return 'Não ativo';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);

    if (days > 0) {
      return '$days dia${days > 1 ? 's' : ''} restantes';
    } else if (hours > 0) {
      return '$hours hora${hours > 1 ? 's' : ''} restantes';
    } else {
      return '$minutes minuto${minutes > 1 ? 's' : ''} restantes';
    }
  }

  /// Check if user can start a new trial
  /// (Only if current trial has ended)
  bool get canStartNewTrial => !isActive && (endDate == null || isExpired);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrialInfoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          isActive == other.isActive &&
          totalTrialDays == other.totalTrialDays &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          expirationReason == other.expirationReason;

  @override
  int get hashCode =>
      id.hashCode ^
      productId.hashCode ^
      isActive.hashCode ^
      totalTrialDays.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      expirationReason.hashCode;

  @override
  String toString() {
    return '''TrialInfoEntity(
      id: $id,
      productId: $productId,
      isActive: $isActive,
      totalTrialDays: $totalTrialDays,
      startDate: $startDate,
      endDate: $endDate,
      daysRemaining: ${daysRemaining?.inDays},
      progressPercentage: ${progressPercentage.toStringAsFixed(1)}%,
      timeRemainingDisplay: $timeRemainingDisplay,
    )''';
  }
}
