import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ad_frequency_state_model.g.dart';

/// Hive model for ad frequency state tracking
/// Tracks how many times ads have been shown per placement
/// TypeId: 41
@HiveType(typeId: 41)
@JsonSerializable()
class AdFrequencyStateModel extends HiveObject {
  /// Placement identifier (e.g., 'home_screen', 'after_action')
  @HiveField(0)
  final String placement;

  /// Number of times ad was shown today
  @HiveField(1)
  int dailyCount;

  /// Number of times ad was shown this session
  @HiveField(2)
  int sessionCount;

  /// Number of times ad was shown this hour
  @HiveField(3)
  int hourlyCount;

  /// When the ad was last shown
  @HiveField(4)
  DateTime? lastShownAt;

  /// When daily count was last reset
  @HiveField(5)
  DateTime? dailyResetAt;

  /// When hourly count was last reset
  @HiveField(6)
  DateTime? hourlyResetAt;

  /// Total lifetime shows
  @HiveField(7)
  int totalCount;

  /// When this state was created
  @HiveField(8)
  DateTime createdAt;

  /// When this state was last updated
  @HiveField(9)
  DateTime updatedAt;

  AdFrequencyStateModel({
    required this.placement,
    this.dailyCount = 0,
    this.sessionCount = 0,
    this.hourlyCount = 0,
    this.lastShownAt,
    this.dailyResetAt,
    this.hourlyResetAt,
    this.totalCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON
  factory AdFrequencyStateModel.fromJson(Map<String, dynamic> json) =>
      _$AdFrequencyStateModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$AdFrequencyStateModelToJson(this);

  /// Create initial state for a placement
  factory AdFrequencyStateModel.initial(String placement) {
    final now = DateTime.now();
    return AdFrequencyStateModel(
      placement: placement,
      dailyCount: 0,
      sessionCount: 0,
      hourlyCount: 0,
      totalCount: 0,
      dailyResetAt: now,
      hourlyResetAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Increment counters when ad is shown
  void incrementCounters() {
    final now = DateTime.now();

    // Check if daily reset is needed
    if (_shouldResetDaily(now)) {
      resetDaily(now);
    }

    // Check if hourly reset is needed
    if (_shouldResetHourly(now)) {
      resetHourly(now);
    }

    dailyCount++;
    sessionCount++;
    hourlyCount++;
    totalCount++;
    lastShownAt = now;
    updatedAt = now;
  }

  /// Check if daily reset is needed
  bool _shouldResetDaily(DateTime now) {
    if (dailyResetAt == null) return true;

    final resetDate = dailyResetAt!;
    return now.year != resetDate.year ||
        now.month != resetDate.month ||
        now.day != resetDate.day;
  }

  /// Check if hourly reset is needed
  bool _shouldResetHourly(DateTime now) {
    if (hourlyResetAt == null) return true;

    final resetDate = hourlyResetAt!;
    final hoursDiff = now.difference(resetDate).inHours;
    return hoursDiff >= 1;
  }

  /// Reset daily counter
  void resetDaily(DateTime now) {
    dailyCount = 0;
    dailyResetAt = now;
    updatedAt = now;
  }

  /// Reset hourly counter
  void resetHourly(DateTime now) {
    hourlyCount = 0;
    hourlyResetAt = now;
    updatedAt = now;
  }

  /// Reset session counter (call on app start)
  void resetSession() {
    sessionCount = 0;
    updatedAt = DateTime.now();
  }

  /// Reset all counters
  void resetAll() {
    final now = DateTime.now();
    dailyCount = 0;
    sessionCount = 0;
    hourlyCount = 0;
    dailyResetAt = now;
    hourlyResetAt = now;
    updatedAt = now;
  }

  /// Get time since last shown in seconds
  int? get secondsSinceLastShown {
    if (lastShownAt == null) return null;
    return DateTime.now().difference(lastShownAt!).inSeconds;
  }

  /// Check if minimum interval has passed
  bool hasMinIntervalPassed(int minIntervalSeconds) {
    if (lastShownAt == null) return true;

    final secondsSince = secondsSinceLastShown;
    if (secondsSince == null) return true;

    return secondsSince >= minIntervalSeconds;
  }

  /// Check if daily limit is reached
  bool isDailyLimitReached(int maxAdsPerDay) {
    return dailyCount >= maxAdsPerDay;
  }

  /// Check if session limit is reached
  bool isSessionLimitReached(int maxAdsPerSession) {
    return sessionCount >= maxAdsPerSession;
  }

  /// Check if hourly limit is reached
  bool isHourlyLimitReached(int maxAdsPerHour) {
    return hourlyCount >= maxAdsPerHour;
  }

  /// Copy with new values
  AdFrequencyStateModel copyWith({
    String? placement,
    int? dailyCount,
    int? sessionCount,
    int? hourlyCount,
    DateTime? lastShownAt,
    DateTime? dailyResetAt,
    DateTime? hourlyResetAt,
    int? totalCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdFrequencyStateModel(
      placement: placement ?? this.placement,
      dailyCount: dailyCount ?? this.dailyCount,
      sessionCount: sessionCount ?? this.sessionCount,
      hourlyCount: hourlyCount ?? this.hourlyCount,
      lastShownAt: lastShownAt ?? this.lastShownAt,
      dailyResetAt: dailyResetAt ?? this.dailyResetAt,
      hourlyResetAt: hourlyResetAt ?? this.hourlyResetAt,
      totalCount: totalCount ?? this.totalCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'AdFrequencyStateModel('
      'placement: $placement, '
      'daily: $dailyCount, '
      'session: $sessionCount, '
      'total: $totalCount)';
}
