import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/home_providers.dart';

/// **Home App Bar Component**
/// 
/// Specialized AppBar for the home page with notification and status indicators.
/// Provides real-time status updates and notification management.
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onStatusTap;

  const HomeAppBar({
    super.key,
    required this.onNotificationTap,
    required this.onStatusTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(homeNotificationsProvider);
    final statusState = ref.watch(homeStatusProvider);
    final hasUnreadNotifications = ref.watch(hasUnreadNotificationsProvider);
    final hasUrgentAlerts = ref.watch(hasUrgentAlertsProvider);

    return AppBar(
      title: const Text('PetiVeti'),
      centerTitle: true,
      actions: [
        _NotificationIcon(
          notificationsState: notificationsState,
          hasUnreadNotifications: hasUnreadNotifications,
          hasUrgentAlerts: hasUrgentAlerts,
          onTap: onNotificationTap,
        ),
        _StatusIcon(
          statusState: statusState,
          onTap: onStatusTap,
        ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final HomeNotificationsState notificationsState;
  final bool hasUnreadNotifications;
  final bool hasUrgentAlerts;
  final VoidCallback onTap;

  const _NotificationIcon({
    required this.notificationsState,
    required this.hasUnreadNotifications,
    required this.hasUrgentAlerts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: hasUrgentAlerts 
        ? 'Notificações urgentes, ${notificationsState.unreadCount} não lidas'
        : hasUnreadNotifications 
          ? 'Notificações, ${notificationsState.unreadCount} não lidas'
          : 'Notificações',
      hint: 'Toque para visualizar suas notificações',
      button: true,
      child: Stack(
        children: [
          IconButton(
            icon: Icon(
              hasUrgentAlerts ? Icons.notifications_active : Icons.notifications,
              color: hasUrgentAlerts ? Theme.of(context).colorScheme.error : null,
            ),
            onPressed: onTap,
          ),
          if (hasUnreadNotifications)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  '${notificationsState.unreadCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final HomeStatusState statusState;
  final VoidCallback onTap;

  const _StatusIcon({
    required this.statusState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: statusState.isOnline 
        ? 'Online, dados sincronizados'
        : 'Offline, usando dados locais',
      hint: 'Toque para ver detalhes do status de conexão',
      button: true,
      child: IconButton(
        icon: Icon(
          statusState.isOnline ? Icons.cloud_done : Icons.cloud_off,
          color: statusState.isOnline 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: onTap,
      ),
    );
  }
}
