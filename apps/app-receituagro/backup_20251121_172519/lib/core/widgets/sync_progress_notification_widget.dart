import 'dart:async';

import 'package:flutter/material.dart';

/// Sync Progress Notification Widget
///
/// Features:
/// - In-app notification for sync progress
/// - Dismissible and auto-hide options
/// - Different notification types (info, success, error, warning)
/// - Progress indicators
/// - Action buttons (retry, cancel, view details)
/// - Slide-in/slide-out animations
class SyncProgressNotificationWidget extends StatefulWidget {
  final String title;
  final String? message;
  final NotificationType type;
  final double? progress; // 0.0 to 1.0, null for indeterminate
  final Duration? autoHideDuration;
  final bool isDismissible;
  final VoidCallback? onDismissed;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final Widget? customIcon;
  final bool showProgress;

  const SyncProgressNotificationWidget({
    super.key,
    required this.title,
    this.message,
    this.type = NotificationType.info,
    this.progress,
    this.autoHideDuration,
    this.isDismissible = true,
    this.onDismissed,
    this.onActionPressed,
    this.actionLabel,
    this.customIcon,
    this.showProgress = true,
  });

  @override
  State<SyncProgressNotificationWidget> createState() =>
      _SyncProgressNotificationWidgetState();
}

class _SyncProgressNotificationWidgetState
    extends State<SyncProgressNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _autoHideTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _showNotification();
    if (widget.autoHideDuration != null) {
      _autoHideTimer = Timer(widget.autoHideDuration!, _hideNotification);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void _showNotification() {
    setState(() {
      _isVisible = true;
    });
    _animationController.forward();
  }

  void _hideNotification() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getBorderColor(context), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(context),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getTextColor(context),
                            ),
                          ),
                          if (widget.message != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.message!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: _getTextColor(
                                  context,
                                ).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.isDismissible)
                      IconButton(
                        onPressed: _hideNotification,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: _getTextColor(context).withValues(alpha: 0.7),
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(24, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                if (widget.showProgress && widget.progress != null) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(context),
                ],
                if (widget.onActionPressed != null &&
                    widget.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  _buildActionButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build notification icon
  Widget _buildIcon(BuildContext context) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    IconData iconData;
    Color iconColor = _getIconColor(context);

    switch (widget.type) {
      case NotificationType.info:
        iconData = Icons.info_outline;
        break;
      case NotificationType.success:
        iconData = Icons.check_circle_outline;
        break;
      case NotificationType.error:
        iconData = Icons.error_outline;
        break;
      case NotificationType.warning:
        iconData = Icons.warning_outlined;
        break;
      case NotificationType.sync:
        iconData = Icons.sync;
        break;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  /// Build progress bar
  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getTextColor(context).withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(widget.progress! * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getTextColor(context).withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: widget.progress,
          backgroundColor: _getIconColor(context).withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(_getIconColor(context)),
          minHeight: 4,
        ),
      ],
    );
  }

  /// Build action button
  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onActionPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _getIconColor(context),
          side: BorderSide(color: _getIconColor(context)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          widget.actionLabel!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Get background color based on notification type
  Color _getBackgroundColor(BuildContext context) {
    switch (widget.type) {
      case NotificationType.info:
        return Colors.blue.shade50;
      case NotificationType.success:
        return Colors.green.shade50;
      case NotificationType.error:
        return Colors.red.shade50;
      case NotificationType.warning:
        return Colors.orange.shade50;
      case NotificationType.sync:
        return Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
  }

  /// Get border color based on notification type
  Color _getBorderColor(BuildContext context) {
    switch (widget.type) {
      case NotificationType.info:
        return Colors.blue.shade200;
      case NotificationType.success:
        return Colors.green.shade200;
      case NotificationType.error:
        return Colors.red.shade200;
      case NotificationType.warning:
        return Colors.orange.shade200;
      case NotificationType.sync:
        return Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
    }
  }

  /// Get icon color based on notification type
  Color _getIconColor(BuildContext context) {
    switch (widget.type) {
      case NotificationType.info:
        return Colors.blue.shade600;
      case NotificationType.success:
        return Colors.green.shade600;
      case NotificationType.error:
        return Colors.red.shade600;
      case NotificationType.warning:
        return Colors.orange.shade600;
      case NotificationType.sync:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// Get text color based on notification type
  Color _getTextColor(BuildContext context) {
    switch (widget.type) {
      case NotificationType.info:
        return Colors.blue.shade900;
      case NotificationType.success:
        return Colors.green.shade900;
      case NotificationType.error:
        return Colors.red.shade900;
      case NotificationType.warning:
        return Colors.orange.shade900;
      case NotificationType.sync:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}

/// Notification Type Enum
enum NotificationType { info, success, error, warning, sync }

/// Sync Progress Notification Manager
///
/// Manages multiple sync progress notifications
class SyncProgressNotificationManager extends StatefulWidget {
  final Widget child;

  const SyncProgressNotificationManager({super.key, required this.child});

  @override
  State<SyncProgressNotificationManager> createState() =>
      _SyncProgressNotificationManagerState();
}

class _SyncProgressNotificationManagerState
    extends State<SyncProgressNotificationManager> {
  final List<SyncNotificationItem> _activeNotifications = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_activeNotifications.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children:
                    _activeNotifications.map((item) {
                      return SyncProgressNotificationWidget(
                        key: ValueKey(item.id),
                        title: item.title,
                        message: item.message,
                        type: item.type,
                        progress: item.progress,
                        autoHideDuration: item.autoHideDuration,
                        isDismissible: item.isDismissible,
                        onDismissed: () => _removeNotification(item.id),
                        onActionPressed: item.onActionPressed,
                        actionLabel: item.actionLabel,
                        showProgress: item.showProgress,
                      );
                    }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  /// Add a new notification
  void showNotification(SyncNotificationItem notification) {
    setState(() {
      _activeNotifications.add(notification);
    });
  }

  /// Remove notification by ID
  void _removeNotification(String id) {
    setState(() {
      _activeNotifications.removeWhere((item) => item.id == id);
    });
  }

  /// Remove all notifications
  void clearAllNotifications() {
    setState(() {
      _activeNotifications.clear();
    });
  }
}

/// Sync Notification Item Data Model
class SyncNotificationItem {
  final String id;
  final String title;
  final String? message;
  final NotificationType type;
  final double? progress;
  final Duration? autoHideDuration;
  final bool isDismissible;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool showProgress;

  SyncNotificationItem({
    required this.id,
    required this.title,
    this.message,
    this.type = NotificationType.info,
    this.progress,
    this.autoHideDuration,
    this.isDismissible = true,
    this.onActionPressed,
    this.actionLabel,
    this.showProgress = true,
  });
}

/// Global Sync Notification Service (Singleton)
class SyncNotificationService {
  static SyncNotificationService? _instance;
  static SyncNotificationService get instance =>
      _instance ??= SyncNotificationService._();

  SyncNotificationService._();

  _SyncProgressNotificationManagerState? _managerState;

  /// Show sync progress notification
  void showSyncNotification({
    required String title,
    String? message,
    NotificationType type = NotificationType.sync,
    double? progress,
    Duration? autoHideDuration = const Duration(seconds: 5),
    bool isDismissible = true,
    VoidCallback? onActionPressed,
    String? actionLabel,
    bool showProgress = true,
  }) {
    final notification = SyncNotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      progress: progress,
      autoHideDuration: autoHideDuration,
      isDismissible: isDismissible,
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
      showProgress: showProgress,
    );

    _managerState?.showNotification(notification);
  }

  /// Show sync success notification
  void showSyncSuccess({
    String title = 'Sincronização Completa',
    String? message = 'Todos os dados foram sincronizados com sucesso',
  }) {
    showSyncNotification(
      title: title,
      message: message,
      type: NotificationType.success,
      autoHideDuration: const Duration(seconds: 3),
      showProgress: false,
    );
  }

  /// Show sync error notification
  void showSyncError({
    String title = 'Erro na Sincronização',
    String? message,
    VoidCallback? onRetryPressed,
  }) {
    showSyncNotification(
      title: title,
      message: message ?? 'Não foi possível sincronizar os dados',
      type: NotificationType.error,
      autoHideDuration: null, // Don't auto-hide errors
      onActionPressed: onRetryPressed,
      actionLabel: onRetryPressed != null ? 'Tentar Novamente' : null,
      showProgress: false,
    );
  }

  /// Clear all notifications
  void clearAll() {
    _managerState?.clearAllNotifications();
  }
}
