import 'dart:async';

/// Observer pattern implementation following SOLID principles
/// 
/// Provides a way to notify multiple observers when state changes occur.
/// Follows Observer Pattern, SRP, and OCP principles.

/// Base observer interface
abstract class Observer<T> {
  void update(T data);
}

/// Base observable subject interface
abstract class Observable<T> {
  void attach(Observer<T> observer);
  void detach(Observer<T> observer);
  void notify(T data);
}

/// Concrete implementation of Observable
class Subject<T> implements Observable<T> {
  final List<Observer<T>> _observers = [];

  @override
  void attach(Observer<T> observer) {
    _observers.add(observer);
  }

  @override
  void detach(Observer<T> observer) {
    _observers.remove(observer);
  }

  @override
  void notify(T data) {
    for (final observer in _observers) {
      observer.update(data);
    }
  }

  /// Get current number of observers
  int get observerCount => _observers.length;

  /// Clear all observers
  void clearObservers() {
    _observers.clear();
  }
}

/// Stream-based observer for Flutter integration
class StreamObserver<T> implements Observer<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();

  @override
  void update(T data) {
    if (!_controller.isClosed) {
      _controller.add(data);
    }
  }

  /// Get the stream to listen to updates
  Stream<T> get stream => _controller.stream;

  /// Close the stream controller
  void dispose() {
    _controller.close();
  }
}

/// Event types for the notification system
enum NotificationEventType {
  info,
  success,
  warning,
  error,
  reminder,
  alert,
}

/// Notification event data structure
class NotificationEvent {
  final String id;
  final NotificationEventType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool persistent;
  final Duration? autoHideDuration;

  const NotificationEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
    this.persistent = false,
    this.autoHideDuration,
  });

  /// Create an info notification
  factory NotificationEvent.info({
    required String title,
    required String message,
    Map<String, dynamic>? data,
    Duration? autoHideDuration,
  }) {
    return NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationEventType.info,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
      autoHideDuration: autoHideDuration ?? const Duration(seconds: 3),
    );
  }

  /// Create a success notification
  factory NotificationEvent.success({
    required String title,
    required String message,
    Map<String, dynamic>? data,
    Duration? autoHideDuration,
  }) {
    return NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationEventType.success,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
      autoHideDuration: autoHideDuration ?? const Duration(seconds: 2),
    );
  }

  /// Create a warning notification
  factory NotificationEvent.warning({
    required String title,
    required String message,
    Map<String, dynamic>? data,
    Duration? autoHideDuration,
  }) {
    return NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationEventType.warning,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
      autoHideDuration: autoHideDuration ?? const Duration(seconds: 4),
    );
  }

  /// Create an error notification
  factory NotificationEvent.error({
    required String title,
    required String message,
    Map<String, dynamic>? data,
    bool persistent = true,
  }) {
    return NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationEventType.error,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
      persistent: persistent,
    );
  }

  /// Create a reminder notification
  factory NotificationEvent.reminder({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationEventType.reminder,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
      persistent: true,
    );
  }

  /// Create an alert notification
  factory NotificationEvent.alert({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationEventType.alert,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
      persistent: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Notification service using Observer pattern
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Subject<NotificationEvent> _notificationSubject = Subject<NotificationEvent>();
  final List<NotificationEvent> _activeNotifications = [];

  /// Subscribe to notifications
  void subscribe(Observer<NotificationEvent> observer) {
    _notificationSubject.attach(observer);
  }

  /// Unsubscribe from notifications
  void unsubscribe(Observer<NotificationEvent> observer) {
    _notificationSubject.detach(observer);
  }

  /// Send a notification
  void notify(NotificationEvent event) {
    _activeNotifications.add(event);
    _notificationSubject.notify(event);
    if (!event.persistent && event.autoHideDuration != null) {
      Timer(event.autoHideDuration!, () {
        dismissNotification(event.id);
      });
    }
  }

  /// Dismiss a specific notification
  void dismissNotification(String notificationId) {
    _activeNotifications.removeWhere((notification) => notification.id == notificationId);
  }

  /// Get all active notifications
  List<NotificationEvent> get activeNotifications => List.unmodifiable(_activeNotifications);

  /// Clear all notifications
  void clearAllNotifications() {
    _activeNotifications.clear();
  }

  /// Get notifications by type
  List<NotificationEvent> getNotificationsByType(NotificationEventType type) {
    return _activeNotifications.where((notification) => notification.type == type).toList();
  }

  /// Check if there are any notifications of a specific type
  bool hasNotificationsOfType(NotificationEventType type) {
    return _activeNotifications.any((notification) => notification.type == type);
  }

  /// Get notification count
  int get notificationCount => _activeNotifications.length;

  /// Get unread count (for demonstration, all are considered unread)
  int get unreadCount => _activeNotifications.length;

  /// Dispose resources
  void dispose() {
    _notificationSubject.clearObservers();
    _activeNotifications.clear();
  }
}