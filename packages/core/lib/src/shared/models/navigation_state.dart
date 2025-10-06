import 'package:flutter/material.dart';

/// Navigation state model for enhanced navigation tracking
class NavigationState {
  final String pageType;
  final String? route;
  final Map<String, dynamic>? arguments;
  final String? title;
  final NavigationConfiguration? configuration;
  final DateTime timestamp;
  final String? navigationSource;

  const NavigationState({
    required this.pageType,
    this.route,
    this.arguments,
    this.title,
    this.configuration,
    required this.timestamp,
    this.navigationSource,
  });

  NavigationState copyWith({
    String? pageType,
    String? route,
    Map<String, dynamic>? arguments,
    String? title,
    NavigationConfiguration? configuration,
    DateTime? timestamp,
    String? navigationSource,
  }) {
    return NavigationState(
      pageType: pageType ?? this.pageType,
      route: route ?? this.route,
      arguments: arguments ?? this.arguments,
      title: title ?? this.title,
      configuration: configuration ?? this.configuration,
      timestamp: timestamp ?? this.timestamp,
      navigationSource: navigationSource ?? this.navigationSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageType': pageType,
      'route': route,
      'arguments': arguments,
      'title': title,
      'configuration': configuration?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'navigationSource': navigationSource,
    };
  }

  @override
  String toString() {
    return 'NavigationState(pageType: $pageType, route: $route, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.pageType == pageType &&
        other.route == route &&
        other.title == title;
  }

  @override
  int get hashCode {
    return pageType.hashCode ^ route.hashCode ^ title.hashCode;
  }
}

/// Navigation configuration for controlling navigation behavior
class NavigationConfiguration {
  final bool showBottomNavigation;
  final bool showBackButton;
  final bool canGoBack;
  final String? customAppBarTitle;
  final bool showAppBar;
  final bool showLoading;
  final Color? statusBarColor;
  final Map<String, dynamic>? extensionData;

  const NavigationConfiguration({
    this.showBottomNavigation = true,
    this.showBackButton = true,
    this.canGoBack = true,
    this.customAppBarTitle,
    this.showAppBar = true,
    this.showLoading = false,
    this.statusBarColor,
    this.extensionData,
  });

  NavigationConfiguration copyWith({
    bool? showBottomNavigation,
    bool? showBackButton,
    bool? canGoBack,
    String? customAppBarTitle,
    bool? showAppBar,
    bool? showLoading,
    Color? statusBarColor,
    Map<String, dynamic>? extensionData,
  }) {
    return NavigationConfiguration(
      showBottomNavigation: showBottomNavigation ?? this.showBottomNavigation,
      showBackButton: showBackButton ?? this.showBackButton,
      canGoBack: canGoBack ?? this.canGoBack,
      customAppBarTitle: customAppBarTitle ?? this.customAppBarTitle,
      showAppBar: showAppBar ?? this.showAppBar,
      showLoading: showLoading ?? this.showLoading,
      statusBarColor: statusBarColor ?? this.statusBarColor,
      extensionData: extensionData ?? this.extensionData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showBottomNavigation': showBottomNavigation,
      'showBackButton': showBackButton,
      'canGoBack': canGoBack,
      'customAppBarTitle': customAppBarTitle,
      'showAppBar': showAppBar,
      'showLoading': showLoading,
      'statusBarColor': statusBarColor?.value,
      'extensionData': extensionData,
    };
  }

  static NavigationConfiguration fromJson(Map<String, dynamic> json) {
    return NavigationConfiguration(
      showBottomNavigation: json['showBottomNavigation'] as bool? ?? true,
      showBackButton: json['showBackButton'] as bool? ?? true,
      canGoBack: json['canGoBack'] as bool? ?? true,
      customAppBarTitle: json['customAppBarTitle'] as String?,
      showAppBar: json['showAppBar'] as bool? ?? true,
      showLoading: json['showLoading'] as bool? ?? false,
      statusBarColor: json['statusBarColor'] != null
          ? Color(json['statusBarColor'] as int)
          : null,
      extensionData: json['extensionData'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'NavigationConfiguration(showBottomNav: $showBottomNavigation, canGoBack: $canGoBack)';
  }
}

/// Navigation history entry for tracking user navigation paths
class NavigationHistoryEntry {
  final NavigationState state;
  final DateTime exitTime;
  final Duration timeSpent;

  const NavigationHistoryEntry({
    required this.state,
    required this.exitTime,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state.toJson(),
      'exitTime': exitTime.toIso8601String(),
      'timeSpentMs': timeSpent.inMilliseconds,
    };
  }
}
