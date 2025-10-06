import 'package:flutter/material.dart';

import '../utils/observer_pattern.dart';

/// Widget that displays notifications using the Observer pattern
/// 
/// Implements Observer interface to receive notification updates and display them
/// following the Observer pattern and SRP principles.
class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> 
    implements Observer<NotificationEvent> {
  
  final NotificationService _notificationService = NotificationService();
  final List<NotificationEvent> _displayedNotifications = [];

  @override
  void initState() {
    super.initState();
    _notificationService.subscribe(this);
  }

  @override
  void dispose() {
    _notificationService.unsubscribe(this);
    super.dispose();
  }

  @override
  void update(NotificationEvent data) {
    if (mounted) {
      setState(() {
        _displayedNotifications.add(data);
      });
      _showNotificationSnackBar(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _displayedNotifications
          .map((notification) => _buildNotificationCard(notification))
          .toList(),
    );
  }

  Widget _buildNotificationCard(NotificationEvent notification) {
    final theme = Theme.of(context);
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        subtitle: Text(
          notification.message,
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _dismissNotification(notification),
          iconSize: 18,
        ),
        isThreeLine: notification.message.length > 50,
      ),
    );
  }

  void _showNotificationSnackBar(NotificationEvent notification) {
    final color = _getNotificationColor(notification.type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getNotificationIcon(notification.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: notification.autoHideDuration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: notification.persistent
            ? SnackBarAction(
                label: 'Dispensar',
                textColor: Colors.white,
                onPressed: () => _dismissNotification(notification),
              )
            : null,
      ),
    );
  }

  void _dismissNotification(NotificationEvent notification) {
    setState(() {
      _displayedNotifications.remove(notification);
    });
    _notificationService.dismissNotification(notification.id);
  }

  Color _getNotificationColor(NotificationEventType type) {
    switch (type) {
      case NotificationEventType.info:
        return Colors.blue;
      case NotificationEventType.success:
        return Colors.green;
      case NotificationEventType.warning:
        return Colors.orange;
      case NotificationEventType.error:
        return Colors.red;
      case NotificationEventType.reminder:
        return Colors.purple;
      case NotificationEventType.alert:
        return Colors.deepOrange;
    }
  }

  IconData _getNotificationIcon(NotificationEventType type) {
    switch (type) {
      case NotificationEventType.info:
        return Icons.info;
      case NotificationEventType.success:
        return Icons.check_circle;
      case NotificationEventType.warning:
        return Icons.warning;
      case NotificationEventType.error:
        return Icons.error;
      case NotificationEventType.reminder:
        return Icons.schedule;
      case NotificationEventType.alert:
        return Icons.priority_high;
    }
  }
}

/// Badge widget to show notification count
class NotificationBadge extends StatefulWidget {
  final Widget child;
  final NotificationEventType? filterType;

  const NotificationBadge({
    super.key,
    required this.child,
    this.filterType,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    implements Observer<NotificationEvent> {
  
  final NotificationService _notificationService = NotificationService();
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService.subscribe(this);
    _updateCount();
  }

  @override
  void dispose() {
    _notificationService.unsubscribe(this);
    super.dispose();
  }

  @override
  void update(NotificationEvent data) {
    if (mounted) {
      _updateCount();
    }
  }

  void _updateCount() {
    final count = widget.filterType != null
        ? _notificationService.getNotificationsByType(widget.filterType!).length
        : _notificationService.notificationCount;
    
    if (count != _notificationCount) {
      setState(() {
        _notificationCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: _notificationCount > 0,
      label: Text(_notificationCount.toString()),
      child: widget.child,
    );
  }
}
