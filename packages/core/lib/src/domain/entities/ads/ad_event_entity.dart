import 'package:equatable/equatable.dart';
import 'ad_unit_entity.dart';

/// Type of ad event
enum AdEventType {
  loaded,
  failedToLoad,
  showed,
  failedToShow,
  clicked,
  closed,
  impression,
  rewarded,
  opened,
}

/// Domain entity representing an ad event for analytics and tracking
/// This entity is immutable and contains all necessary event data
class AdEventEntity extends Equatable {
  /// Unique identifier for this event
  final String id;

  /// Type of the event
  final AdEventType eventType;

  /// Type of ad that triggered the event
  final AdType adType;

  /// Placement where the ad was triggered
  final AdPlacement placement;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Ad Unit ID (Google Ad Unit)
  final String? adUnitId;

  /// Error code if event is a failure
  final String? errorCode;

  /// Error message if event is a failure
  final String? errorMessage;

  /// Reward amount if event is a reward
  final int? rewardAmount;

  /// Reward type if event is a reward
  final String? rewardType;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const AdEventEntity({
    required this.id,
    required this.eventType,
    required this.adType,
    required this.placement,
    required this.timestamp,
    this.adUnitId,
    this.errorCode,
    this.errorMessage,
    this.rewardAmount,
    this.rewardType,
    this.metadata,
  });

  /// Creates a loaded event
  factory AdEventEntity.loaded({
    required String id,
    required AdType adType,
    required AdPlacement placement,
    String? adUnitId,
  }) {
    return AdEventEntity(
      id: id,
      eventType: AdEventType.loaded,
      adType: adType,
      placement: placement,
      timestamp: DateTime.now(),
      adUnitId: adUnitId,
    );
  }

  /// Creates a failed to load event
  factory AdEventEntity.failedToLoad({
    required String id,
    required AdType adType,
    required AdPlacement placement,
    String? adUnitId,
    required String errorCode,
    String? errorMessage,
  }) {
    return AdEventEntity(
      id: id,
      eventType: AdEventType.failedToLoad,
      adType: adType,
      placement: placement,
      timestamp: DateTime.now(),
      adUnitId: adUnitId,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  /// Creates a showed event
  factory AdEventEntity.showed({
    required String id,
    required AdType adType,
    required AdPlacement placement,
    String? adUnitId,
  }) {
    return AdEventEntity(
      id: id,
      eventType: AdEventType.showed,
      adType: adType,
      placement: placement,
      timestamp: DateTime.now(),
      adUnitId: adUnitId,
    );
  }

  /// Creates a rewarded event
  factory AdEventEntity.rewarded({
    required String id,
    required AdPlacement placement,
    String? adUnitId,
    required int rewardAmount,
    required String rewardType,
  }) {
    return AdEventEntity(
      id: id,
      eventType: AdEventType.rewarded,
      adType: AdType.rewarded,
      placement: placement,
      timestamp: DateTime.now(),
      adUnitId: adUnitId,
      rewardAmount: rewardAmount,
      rewardType: rewardType,
    );
  }

  /// Creates a clicked event
  factory AdEventEntity.clicked({
    required String id,
    required AdType adType,
    required AdPlacement placement,
    String? adUnitId,
  }) {
    return AdEventEntity(
      id: id,
      eventType: AdEventType.clicked,
      adType: adType,
      placement: placement,
      timestamp: DateTime.now(),
      adUnitId: adUnitId,
    );
  }

  /// Creates a closed event
  factory AdEventEntity.closed({
    required String id,
    required AdType adType,
    required AdPlacement placement,
    String? adUnitId,
  }) {
    return AdEventEntity(
      id: id,
      eventType: AdEventType.closed,
      adType: adType,
      placement: placement,
      timestamp: DateTime.now(),
      adUnitId: adUnitId,
    );
  }

  /// Check if this is an error event
  bool get isError =>
      eventType == AdEventType.failedToLoad || eventType == AdEventType.failedToShow;

  /// Check if this is a success event
  bool get isSuccess =>
      eventType == AdEventType.loaded ||
      eventType == AdEventType.showed ||
      eventType == AdEventType.rewarded;

  /// Convert to analytics event parameters
  Map<String, dynamic> toAnalyticsParams() {
    return {
      'ad_event_type': eventType.name,
      'ad_type': adType.name,
      'ad_placement': placement.name,
      'timestamp': timestamp.toIso8601String(),
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
      if (rewardType != null) 'reward_type': rewardType,
      if (metadata != null) ...metadata!,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventType,
        adType,
        placement,
        timestamp,
        adUnitId,
        errorCode,
        errorMessage,
        rewardAmount,
        rewardType,
        metadata,
      ];

  @override
  String toString() => 'AdEventEntity('
      'eventType: $eventType, '
      'adType: $adType, '
      'placement: $placement)';
}
