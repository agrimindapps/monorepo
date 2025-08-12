// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Event types for odometer module communication
enum OdometroEventType {
  dataLoaded,
  dataRefreshed,
  monthSelected,
  vehicleChanged,
  errorOccurred,
  loadingStarted,
  loadingCompleted,
}

/// Event data structure for odometer events
class OdometroEvent {
  final OdometroEventType type;
  final dynamic data;
  final DateTime timestamp;
  final String? source;

  OdometroEvent({
    required this.type,
    this.data,
    this.source,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'OdometroEvent(type: $type, data: $data, source: $source, timestamp: $timestamp)';
  }
}

/// Event bus service for odometer module communication
/// Eliminates circular dependencies between controllers
class OdometroEventBus extends GetxService {
  final RxList<OdometroEvent> _eventHistory = <OdometroEvent>[].obs;
  final _eventSubjects = <OdometroEventType, RxList<Function>>{};

  /// Subscribe to specific event types
  void subscribe(
      OdometroEventType eventType, Function(OdometroEvent) callback) {
    if (!_eventSubjects.containsKey(eventType)) {
      _eventSubjects[eventType] = <Function>[].obs;
    }
    _eventSubjects[eventType]!.add(callback);
  }

  /// Unsubscribe from specific event type
  void unsubscribe(OdometroEventType eventType, Function callback) {
    if (_eventSubjects.containsKey(eventType)) {
      _eventSubjects[eventType]!.remove(callback);
    }
  }

  /// Emit an event to all subscribers
  void emit(OdometroEventType eventType, {dynamic data, String? source}) {
    final event = OdometroEvent(
      type: eventType,
      data: data,
      source: source,
    );

    // Add to history (keep only last 100 events)
    _eventHistory.add(event);
    if (_eventHistory.length > 100) {
      _eventHistory.removeAt(0);
    }

    // Notify subscribers
    if (_eventSubjects.containsKey(eventType)) {
      for (final callback in _eventSubjects[eventType]!) {
        try {
          callback(event);
        } catch (e) {
          debugPrint('Error in event callback: $e');
        }
      }
    }
  }

  /// Get event history for debugging
  List<OdometroEvent> get eventHistory => _eventHistory.toList();

  /// Get subscriber count for an event type
  int getSubscriberCount(OdometroEventType eventType) {
    return _eventSubjects[eventType]?.length ?? 0;
  }

  /// Clear all subscriptions and history
  void clear() {
    _eventSubjects.clear();
    _eventHistory.clear();
  }

  /// Get statistics about events
  Map<String, dynamic> getEventStatistics() {
    final eventCounts = <OdometroEventType, int>{};

    for (final event in _eventHistory) {
      eventCounts[event.type] = (eventCounts[event.type] ?? 0) + 1;
    }

    return {
      'totalEvents': _eventHistory.length,
      'eventsByType':
          eventCounts.map((key, value) => MapEntry(key.toString(), value)),
      'subscribersByType': _eventSubjects
          .map((key, value) => MapEntry(key.toString(), value.length)),
      'lastEventTime': _eventHistory.isNotEmpty
          ? _eventHistory.last.timestamp.toIso8601String()
          : null,
    };
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}

/// Mixin for controllers to easily use event bus
mixin OdometroEventMixin on GetxController {
  late OdometroEventBus _eventBus;

  @override
  void onInit() {
    super.onInit();
    _eventBus = Get.find<OdometroEventBus>();
  }

  /// Emit an event
  void emitEvent(OdometroEventType eventType, {dynamic data}) {
    _eventBus.emit(eventType, data: data, source: runtimeType.toString());
  }

  /// Subscribe to an event
  void subscribeToEvent(
      OdometroEventType eventType, Function(OdometroEvent) callback) {
    _eventBus.subscribe(eventType, callback);
  }

  /// Unsubscribe from an event
  void unsubscribeFromEvent(OdometroEventType eventType, Function callback) {
    _eventBus.unsubscribe(eventType, callback);
  }
}
