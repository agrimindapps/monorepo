import 'package:flutter/material.dart';

import '../providers/home_providers.dart';

/// Service responsible for handling home page actions and business logic
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles home page actions and data formatting
/// - **Open/Closed**: New actions can be added without modifying existing code
/// - **Dependency Inversion**: HomePage depends on this abstraction
///
/// **Features:**
/// - Data loading coordination
/// - Time formatting for status updates
/// - Notification dialog management
/// - Status information display
class HomeActionsService {
  /// Formats DateTime to human-readable relative time
  ///
  /// Returns:
  /// - "agora mesmo" if less than 1 minute ago
  /// - "Xmin atrás" if less than 1 hour ago
  /// - "Xh atrás" if less than 1 day ago
  /// - "Xd atrás" if more than 1 day ago
  ///
  /// Example:
  /// ```dart
  /// formatTime(DateTime.now().subtract(Duration(minutes: 30)))
  /// // Returns: "30min atrás"
  /// ```
  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'agora mesmo';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }

  /// Shows status information in a SnackBar
  ///
  /// Displays:
  /// - Online status with last update time
  /// - Offline status with local data indicator
  ///
  /// Example:
  /// ```dart
  /// homeActionsService.showStatusInfo(
  ///   context,
  ///   statusState,
  ///   formatTime: formatTime,
  /// );
  /// ```
  void showStatusInfo(
    BuildContext context,
    HomeStatusState statusState,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          statusState.isOnline
              ? 'Online - Última atualização: ${formatTime(statusState.lastUpdated)}'
              : 'Offline - Dados locais',
        ),
      ),
    );
  }

  /// Shows notifications dialog with list of recent notifications
  ///
  /// Displays:
  /// - List of recent notifications
  /// - "Mark all as read" action
  /// - "Close" action
  ///
  /// Example:
  /// ```dart
  /// homeActionsService.showNotifications(
  ///   context,
  ///   notifications,
  ///   onMarkAllAsRead: () => ref.read(homeNotificationsProvider.notifier).markAllAsRead(),
  /// );
  /// ```
  void showNotifications(
    BuildContext context,
    HomeNotificationsState notifications, {
    required VoidCallback onMarkAllAsRead,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notifications.recentNotifications.isEmpty
              ? [const Text('Nenhuma notificação')]
              : notifications.recentNotifications
                  .map((notification) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('• $notification'),
                      ))
                  .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onMarkAllAsRead();
              Navigator.pop(context);
            },
            child: const Text('Marcar como lidas'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Calculates species breakdown from animals list
  ///
  /// Groups animals by species and returns count for each species.
  /// This is a helper method for stats calculation.
  ///
  /// Example:
  /// ```dart
  /// final breakdown = homeActionsService.calculateSpeciesBreakdown(animals);
  /// // Returns: {'Cachorro': 3, 'Gato': 2}
  /// ```
  Map<String, int> calculateSpeciesBreakdown(List<dynamic> animals) {
    final Map<String, int> breakdown = {};

    for (final animal in animals) {
      // This assumes animal has a species property with displayName
      // Adjust based on actual Animal entity structure
      final speciesName = animal.toString(); // Placeholder
      breakdown[speciesName] = (breakdown[speciesName] ?? 0) + 1;
    }

    return breakdown;
  }

  /// Calculates average age from animals list
  ///
  /// Only considers animals with birth date set.
  /// Returns 0.0 if no animals have birth date.
  ///
  /// Note: This is a placeholder implementation.
  /// Actual calculation should be done in the stats notifier with real Animal entities.
  ///
  /// Example:
  /// ```dart
  /// final avgAge = homeActionsService.calculateAverageAge(animals);
  /// // Returns: 18.5 (months)
  /// ```
  double calculateAverageAge(List<dynamic> animals) {
    // Placeholder - actual implementation in HomeStatsNotifier
    return 0.0;
  }

  /// Calculates estimated overdue items based on total animals
  ///
  /// Uses simple heuristic: ~10% of animals have overdue items
  ///
  /// Example:
  /// ```dart
  /// final overdue = homeActionsService.calculateOverdueItems(10);
  /// // Returns: 1
  /// ```
  int calculateOverdueItems(int totalAnimals) {
    return (totalAnimals * 0.1).round();
  }

  /// Calculates estimated tasks for today based on total animals
  ///
  /// Uses simple heuristic: ~20% of animals have tasks today
  ///
  /// Example:
  /// ```dart
  /// final todayTasks = homeActionsService.calculateTodayTasks(10);
  /// // Returns: 2
  /// ```
  int calculateTodayTasks(int totalAnimals) {
    return (totalAnimals * 0.2).round();
  }

  /// Calculates health status based on overdue items count
  ///
  /// Returns:
  /// - "Atenção" if more than 5 overdue items
  /// - "Cuidado" if 1-5 overdue items
  /// - "Em dia" if no overdue items
  ///
  /// Example:
  /// ```dart
  /// final status = homeActionsService.calculateHealthStatus(3);
  /// // Returns: "Cuidado"
  /// ```
  String calculateHealthStatus(int overdueItems) {
    if (overdueItems > 5) {
      return 'Atenção';
    } else if (overdueItems > 0) {
      return 'Cuidado';
    } else {
      return 'Em dia';
    }
  }
}
