import 'package:equatable/equatable.dart';

/// Types of ads supported by Google Mobile Ads
enum AdType {
  banner,
  interstitial,
  rewarded,
  rewardedInterstitial,
  appOpen,
  native,
}

/// Strategic placements for ads within the app
enum AdPlacement {
  homeScreen,
  betweenContent,
  afterAction,
  appLaunch,
  settings,
  beforePremiumFeature,
  contentDetail,
  listView,
}

/// Domain entity representing an ad unit configuration
/// This entity is pure business logic with no external dependencies
class AdUnitEntity extends Equatable {
  final String id;
  final AdType type;
  final AdPlacement placement;
  final bool isActive;
  final DateTime? lastShown;
  final int showCount;

  const AdUnitEntity({
    required this.id,
    required this.type,
    required this.placement,
    this.isActive = true,
    this.lastShown,
    this.showCount = 0,
  });

  AdUnitEntity copyWith({
    String? id,
    AdType? type,
    AdPlacement? placement,
    bool? isActive,
    DateTime? lastShown,
    int? showCount,
  }) {
    return AdUnitEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      placement: placement ?? this.placement,
      isActive: isActive ?? this.isActive,
      lastShown: lastShown ?? this.lastShown,
      showCount: showCount ?? this.showCount,
    );
  }

  /// Creates an empty ad unit for testing or default states
  factory AdUnitEntity.empty() => const AdUnitEntity(
        id: '',
        type: AdType.banner,
        placement: AdPlacement.homeScreen,
      );

  @override
  List<Object?> get props => [id, type, placement, isActive, lastShown, showCount];

  @override
  String toString() => 'AdUnitEntity(id: $id, type: $type, placement: $placement)';
}

/// Extension to get display names for ad types
extension AdTypeExtension on AdType {
  String get displayName {
    switch (this) {
      case AdType.banner:
        return 'Banner Ad';
      case AdType.interstitial:
        return 'Interstitial Ad';
      case AdType.rewarded:
        return 'Rewarded Ad';
      case AdType.rewardedInterstitial:
        return 'Rewarded Interstitial Ad';
      case AdType.appOpen:
        return 'App Open Ad';
      case AdType.native:
        return 'Native Ad';
    }
  }

  String get key {
    switch (this) {
      case AdType.banner:
        return 'banner';
      case AdType.interstitial:
        return 'interstitial';
      case AdType.rewarded:
        return 'rewarded';
      case AdType.rewardedInterstitial:
        return 'rewarded_interstitial';
      case AdType.appOpen:
        return 'app_open';
      case AdType.native:
        return 'native';
    }
  }
}

/// Extension to get display names for ad placements
extension AdPlacementExtension on AdPlacement {
  String get displayName {
    switch (this) {
      case AdPlacement.homeScreen:
        return 'Home Screen';
      case AdPlacement.betweenContent:
        return 'Between Content';
      case AdPlacement.afterAction:
        return 'After Action';
      case AdPlacement.appLaunch:
        return 'App Launch';
      case AdPlacement.settings:
        return 'Settings';
      case AdPlacement.beforePremiumFeature:
        return 'Before Premium Feature';
      case AdPlacement.contentDetail:
        return 'Content Detail';
      case AdPlacement.listView:
        return 'List View';
    }
  }
}
