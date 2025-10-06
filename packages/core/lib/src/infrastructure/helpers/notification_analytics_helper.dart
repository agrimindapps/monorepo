import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/i_enhanced_notification_repository.dart';

/// Helper class for notification analytics tracking and reporting
class NotificationAnalyticsHelper {
  static const String _eventsKey = 'notification_events';
  static const String _historyKey = 'notification_history';
  static const int _maxStoredEvents = 10000; // Limit stored events to prevent memory issues

  /// Tracks a notification event
  ///
  /// [event] - The event to track
  Future<void> trackEvent(NotificationEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingEvents = await _getStoredEvents(prefs);
      existingEvents.add(event);
      if (existingEvents.length > _maxStoredEvents) {
        existingEvents.removeRange(0, existingEvents.length - _maxStoredEvents);
      }
      await _saveEvents(prefs, existingEvents);

      if (kDebugMode) {
        debugPrint('📊 Tracked notification event: ${event.type} for notification ${event.notificationId}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking notification event: $e');
      }
    }
  }

  /// Gets notification analytics for a date range
  ///
  /// [dateRange] - Date range to analyze
  /// [pluginId] - Optional plugin ID filter
  /// Returns analytics data
  Future<NotificationAnalytics> getAnalytics(
    DateRange dateRange, {
    String? pluginId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = await _getStoredEvents(prefs);
      final filteredEvents = events.where((event) {
        final isInRange = event.timestamp.isAfter(dateRange.startDate) &&
                         event.timestamp.isBefore(dateRange.endDate);

        final matchesPlugin = pluginId == null || event.pluginId == pluginId;

        return isInRange && matchesPlugin;
      }).toList();

      return _calculateAnalytics(filteredEvents, dateRange);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting notification analytics: $e');
      }
      return NotificationAnalytics(
        totalScheduled: 0,
        totalDelivered: 0,
        totalClicked: 0,
        totalDismissed: 0,
        deliveryRate: 0.0,
        clickThroughRate: 0.0,
        engagementRate: 0.0,
        clicksByAction: {},
        deliveryByChannel: {},
        performanceByPlugin: {},
        trends: [],
        dateRange: dateRange,
      );
    }
  }

  /// Gets user engagement metrics
  ///
  /// [userId] - User ID to analyze
  /// [dateRange] - Date range for analysis
  /// Returns user engagement metrics
  Future<UserEngagementMetrics> getUserEngagement(
    String userId,
    DateRange dateRange,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = await _getStoredEvents(prefs);
      final userEvents = events.where((event) {
        final isInRange = event.timestamp.isAfter(dateRange.startDate) &&
                         event.timestamp.isBefore(dateRange.endDate);

        final isUserEvent = event.metadata.containsKey('userId') &&
                           event.metadata['userId'] == userId;

        return isInRange && isUserEvent;
      }).toList();

      return _calculateUserEngagement(userId, userEvents, dateRange);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting user engagement metrics: $e');
      }
      return UserEngagementMetrics(
        userId: userId,
        dateRange: dateRange,
        totalNotificationsReceived: 0,
        totalNotificationsClicked: 0,
        engagementRate: 0.0,
        averageResponseTime: Duration.zero,
        engagementByPlugin: {},
        preferredNotificationTimes: [],
      );
    }
  }

  /// Gets notification history
  ///
  /// [dateRange] - Date range to query
  /// Returns notification history
  Future<NotificationHistory> getNotificationHistory(DateRange dateRange) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = await _getStoredEvents(prefs);
      final notificationEvents = <int, List<NotificationEvent>>{};

      for (final event in events) {
        if (event.timestamp.isAfter(dateRange.startDate) &&
            event.timestamp.isBefore(dateRange.endDate)) {
          notificationEvents.putIfAbsent(event.notificationId, () => []).add(event);
        }
      }
      final entries = <NotificationHistoryEntry>[];

      for (final notificationId in notificationEvents.keys) {
        final notificationEventList = notificationEvents[notificationId]!;
        notificationEventList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final scheduledEvent = notificationEventList
            .firstWhereOrNull((e) => e.type == NotificationEventType.scheduled);
        final deliveredEvent = notificationEventList
            .firstWhereOrNull((e) => e.type == NotificationEventType.delivered);
        final clickedEvent = notificationEventList
            .firstWhereOrNull((e) => e.type == NotificationEventType.clicked);

        if (scheduledEvent != null) {
          entries.add(NotificationHistoryEntry(
            id: notificationId,
            title: scheduledEvent.metadata['title'] as String? ?? 'Unknown',
            body: scheduledEvent.metadata['body'] as String? ?? 'Unknown',
            scheduledDate: scheduledEvent.timestamp,
            deliveredDate: deliveredEvent?.timestamp,
            clickedDate: clickedEvent?.timestamp,
            templateId: scheduledEvent.templateId,
            pluginId: scheduledEvent.pluginId,
            status: _getNotificationStatus(notificationEventList),
          ));
        }
      }
      entries.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      return NotificationHistory(
        entries: entries,
        totalCount: entries.length,
        dateRange: dateRange,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting notification history: $e');
      }

      return NotificationHistory(
        entries: [],
        totalCount: 0,
        dateRange: dateRange,
      );
    }
  }

  /// Clears old analytics data
  ///
  /// [olderThan] - Clear data older than this duration
  Future<void> clearOldData(Duration olderThan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = await _getStoredEvents(prefs);
      final cutoffDate = DateTime.now().subtract(olderThan);

      final recentEvents = events
          .where((event) => event.timestamp.isAfter(cutoffDate))
          .toList();

      await _saveEvents(prefs, recentEvents);

      if (kDebugMode) {
        debugPrint('🧹 Cleared ${events.length - recentEvents.length} old notification events');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing old analytics data: $e');
      }
    }
  }

  /// Gets storage statistics
  ///
  /// Returns information about stored analytics data
  Future<AnalyticsStorageInfo> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = await _getStoredEvents(prefs);

      final oldestEvent = events.isEmpty
          ? null
          : events.reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b);

      final newestEvent = events.isEmpty
          ? null
          : events.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);

      return AnalyticsStorageInfo(
        totalEvents: events.length,
        oldestEventDate: oldestEvent?.timestamp,
        newestEventDate: newestEvent?.timestamp,
        estimatedSizeKb: _estimateDataSize(events),
      );
    } catch (e) {
      return const AnalyticsStorageInfo(
        totalEvents: 0,
        oldestEventDate: null,
        newestEventDate: null,
        estimatedSizeKb: 0,
      );
    }
  }

  Future<List<NotificationEvent>> _getStoredEvents(SharedPreferences prefs) async {
    final eventsJson = prefs.getStringList(_eventsKey) ?? [];

    return eventsJson.map((eventStr) {
      try {
        final eventMap = jsonDecode(eventStr) as Map<String, dynamic>;
        return _eventFromJson(eventMap);
      } catch (e) {
        return null;
      }
    }).whereType<NotificationEvent>().toList();
  }

  Future<void> _saveEvents(SharedPreferences prefs, List<NotificationEvent> events) async {
    final eventsJson = events.map((event) => jsonEncode(_eventToJson(event))).toList();
    await prefs.setStringList(_eventsKey, eventsJson);
  }

  NotificationEvent _eventFromJson(Map<String, dynamic> json) {
    return NotificationEvent(
      type: NotificationEventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationEventType.delivered,
      ),
      notificationId: json['notificationId'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      templateId: json['templateId'] as String?,
      pluginId: json['pluginId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> _eventToJson(NotificationEvent event) {
    return {
      'type': event.type.toString(),
      'notificationId': event.notificationId,
      'timestamp': event.timestamp.toIso8601String(),
      'templateId': event.templateId,
      'pluginId': event.pluginId,
      'metadata': event.metadata,
    };
  }

  NotificationAnalytics _calculateAnalytics(
    List<NotificationEvent> events,
    DateRange dateRange,
  ) {
    final scheduledEvents = events.where((e) => e.type == NotificationEventType.scheduled).toList();
    final deliveredEvents = events.where((e) => e.type == NotificationEventType.delivered).toList();
    final clickedEvents = events.where((e) => e.type == NotificationEventType.clicked).toList();
    final dismissedEvents = events.where((e) => e.type == NotificationEventType.dismissed).toList();

    final totalScheduled = scheduledEvents.length;
    final totalDelivered = deliveredEvents.length;
    final totalClicked = clickedEvents.length;
    final totalDismissed = dismissedEvents.length;

    final deliveryRate = totalScheduled > 0 ? totalDelivered / totalScheduled : 0.0;
    final clickThroughRate = totalDelivered > 0 ? totalClicked / totalDelivered : 0.0;
    final engagementRate = (totalClicked + totalDismissed) > 0 && totalDelivered > 0
        ? (totalClicked + totalDismissed) / totalDelivered
        : 0.0;
    final clicksByAction = <String, int>{};
    for (final event in clickedEvents) {
      final actionId = event.metadata['actionId'] as String? ?? 'notification_tap';
      clicksByAction[actionId] = (clicksByAction[actionId] ?? 0) + 1;
    }
    final deliveryByChannel = <String, int>{};
    for (final event in deliveredEvents) {
      final channelId = event.metadata['channelId'] as String? ?? 'default';
      deliveryByChannel[channelId] = (deliveryByChannel[channelId] ?? 0) + 1;
    }
    final performanceByPlugin = <String, double>{};
    final pluginEvents = <String, List<NotificationEvent>>{};

    for (final event in events) {
      if (event.pluginId != null) {
        pluginEvents.putIfAbsent(event.pluginId!, () => []).add(event);
      }
    }

    for (final pluginId in pluginEvents.keys) {
      final pluginEventList = pluginEvents[pluginId]!;
      final pluginDelivered = pluginEventList.where((e) => e.type == NotificationEventType.delivered).length;
      final pluginClicked = pluginEventList.where((e) => e.type == NotificationEventType.clicked).length;

      performanceByPlugin[pluginId] = pluginDelivered > 0 ? pluginClicked / pluginDelivered : 0.0;
    }
    final trends = _calculateTrends(events, dateRange);

    return NotificationAnalytics(
      totalScheduled: totalScheduled,
      totalDelivered: totalDelivered,
      totalClicked: totalClicked,
      totalDismissed: totalDismissed,
      deliveryRate: deliveryRate,
      clickThroughRate: clickThroughRate,
      engagementRate: engagementRate,
      clicksByAction: clicksByAction,
      deliveryByChannel: deliveryByChannel,
      performanceByPlugin: performanceByPlugin,
      trends: trends,
      dateRange: dateRange,
    );
  }

  List<NotificationTrend> _calculateTrends(
    List<NotificationEvent> events,
    DateRange dateRange,
  ) {
    final trends = <NotificationTrend>[];
    final currentDate = DateTime(dateRange.startDate.year, dateRange.startDate.month, dateRange.startDate.day);
    final endDate = DateTime(dateRange.endDate.year, dateRange.endDate.month, dateRange.endDate.day);

    var date = currentDate;
    while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
      final nextDate = date.add(const Duration(days: 1));

      final dayEvents = events.where((event) =>
          event.timestamp.isAfter(date) && event.timestamp.isBefore(nextDate)).toList();

      final scheduled = dayEvents.where((e) => e.type == NotificationEventType.scheduled).length;
      final delivered = dayEvents.where((e) => e.type == NotificationEventType.delivered).length;
      final clicked = dayEvents.where((e) => e.type == NotificationEventType.clicked).length;

      final deliveryRate = scheduled > 0 ? delivered / scheduled : 0.0;
      final engagementRate = delivered > 0 ? clicked / delivered : 0.0;

      trends.add(NotificationTrend(
        date: date,
        scheduled: scheduled,
        delivered: delivered,
        clicked: clicked,
        deliveryRate: deliveryRate,
        engagementRate: engagementRate,
      ));

      date = nextDate;
    }

    return trends;
  }

  UserEngagementMetrics _calculateUserEngagement(
    String userId,
    List<NotificationEvent> userEvents,
    DateRange dateRange,
  ) {
    final deliveredEvents = userEvents.where((e) => e.type == NotificationEventType.delivered).toList();
    final clickedEvents = userEvents.where((e) => e.type == NotificationEventType.clicked).toList();

    final totalReceived = deliveredEvents.length;
    final totalClicked = clickedEvents.length;
    final engagementRate = totalReceived > 0 ? totalClicked / totalReceived : 0.0;
    Duration totalResponseTime = Duration.zero;
    int responseCount = 0;

    final notificationTimes = <int, DateTime>{};
    for (final event in deliveredEvents) {
      notificationTimes[event.notificationId] = event.timestamp;
    }

    for (final event in clickedEvents) {
      final deliveredTime = notificationTimes[event.notificationId];
      if (deliveredTime != null) {
        totalResponseTime += event.timestamp.difference(deliveredTime);
        responseCount++;
      }
    }

    final averageResponseTime = responseCount > 0
        ? Duration(milliseconds: totalResponseTime.inMilliseconds ~/ responseCount)
        : Duration.zero;
    final engagementByPlugin = <String, int>{};
    for (final event in clickedEvents) {
      if (event.pluginId != null) {
        engagementByPlugin[event.pluginId!] = (engagementByPlugin[event.pluginId!] ?? 0) + 1;
      }
    }
    final clickHours = clickedEvents.map((e) => e.timestamp.hour).toList();
    final hourCounts = <int, int>{};
    for (final hour in clickHours) {
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final preferredHours = hourCounts.entries
        .where((entry) => entry.value >= 2) // At least 2 clicks in that hour
        .map((entry) => '${entry.key.toString().padLeft(2, '0')}:00')
        .toList();

    return UserEngagementMetrics(
      userId: userId,
      dateRange: dateRange,
      totalNotificationsReceived: totalReceived,
      totalNotificationsClicked: totalClicked,
      engagementRate: engagementRate,
      averageResponseTime: averageResponseTime,
      engagementByPlugin: engagementByPlugin,
      preferredNotificationTimes: preferredHours,
    );
  }

  NotificationEventType _getNotificationStatus(List<NotificationEvent> events) {
    if (events.any((e) => e.type == NotificationEventType.clicked)) {
      return NotificationEventType.clicked;
    }
    if (events.any((e) => e.type == NotificationEventType.dismissed)) {
      return NotificationEventType.dismissed;
    }
    if (events.any((e) => e.type == NotificationEventType.delivered)) {
      return NotificationEventType.delivered;
    }
    if (events.any((e) => e.type == NotificationEventType.cancelled)) {
      return NotificationEventType.cancelled;
    }
    if (events.any((e) => e.type == NotificationEventType.failed)) {
      return NotificationEventType.failed;
    }

    return NotificationEventType.scheduled;
  }

  int _estimateDataSize(List<NotificationEvent> events) {
    if (events.isEmpty) return 0;

    final sampleEvent = _eventToJson(events.first);
    final sampleSize = jsonEncode(sampleEvent).length;
    return (sampleSize * events.length / 1024).round();
  }
}

/// Extension for firstWhereOrNull functionality
extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Storage information for analytics data
class AnalyticsStorageInfo {
  final int totalEvents;
  final DateTime? oldestEventDate;
  final DateTime? newestEventDate;
  final int estimatedSizeKb;

  const AnalyticsStorageInfo({
    required this.totalEvents,
    this.oldestEventDate,
    this.newestEventDate,
    required this.estimatedSizeKb,
  });
}