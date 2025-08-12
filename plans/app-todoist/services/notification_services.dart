// services/notification_services.dart - Cloud notifications only

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import '../constants/error_messages.dart';
import '../models/notification.dart';
import '../services/firebase_service.dart';

/// Serviço para notificações em nuvem do Todoist
/// Para notificações locais, use TodoistNotificationManager
class TodoistCloudNotificationService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final CollectionReference _notificationsCollection =
      FirebaseService.firestore.collection('notifications');

  // Stream das notificações do usuário
  Stream<List<Notification>> getUserNotificationsStream() {
    final currentUserId = FirebaseService.currentUserId;
    if (currentUserId == null) return Stream.value([]);

    return _notificationsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notification.fromJson(
                {'id': doc.id, ...doc.data() as Map<String, dynamic>}))
            .toList());
  }

  // Criar notificação
  Future<void> createNotification(Notification notification) async {
    try {
      await _notificationsCollection.add(notification.toJson());
    } catch (e) {
      throw Exception(ErrorMessages.formatError(ErrorMessages.notificationCreateError, e));
    }
  }

  // Marcar notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception(ErrorMessages.formatError(ErrorMessages.notificationMarkAsReadError, e));
    }
  }

  // Marcar todas as notificações como lidas
  Future<void> markAllAsRead() async {
    final currentUserId = FirebaseService.currentUserId;
    if (currentUserId == null) return;

    try {
      final unreadNotifications = await _notificationsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception(ErrorMessages.formatError(ErrorMessages.notificationMarkMultipleAsReadError, e));
    }
  }
}
