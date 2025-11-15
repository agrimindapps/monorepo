import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../entities/task.dart' as task_entity;

/// Exception thrown when a user tries to access a task they don't own
class UnauthorizedAccessException implements Exception {
  final String message;

  const UnauthorizedAccessException(this.message);

  @override
  String toString() => 'UnauthorizedAccessException: $message';
}

/// Interface for task ownership validation
abstract class ITaskOwnershipValidator {
  /// Validates that the current user owns the given task
  ///
  /// Returns:
  /// - `true` if the current user owns the task
  /// - `false` if no user is authenticated, task has null userId, or belongs to different user
  bool validateTaskOwnership(task_entity.Task task);

  /// Gets the current authenticated user ID
  String? getCurrentUserId();

  /// Throws UnauthorizedAccessException if user doesn't own the task
  void validateOwnershipOrThrow(task_entity.Task task);
}

/// Implementation of task ownership validator
class TaskOwnershipValidator implements ITaskOwnershipValidator {
  final AuthStateNotifier _authStateNotifier;

  TaskOwnershipValidator(this._authStateNotifier);

  @override
  bool validateTaskOwnership(task_entity.Task task) {
    final currentUser = _authStateNotifier.currentUser;

    if (currentUser == null) {
      debugPrint('🚫 Access denied: No authenticated user');
      return false;
    }

    if (task.userId == null) {
      debugPrint(
        '🚫 Access denied: Task has null userId (potential security risk)',
      );
      return false;
    }

    if (task.userId == currentUser.id) {
      return true;
    }

    debugPrint(
      '🚫 Access denied: Task belongs to user ${task.userId}, current user is ${currentUser.id}',
    );
    return false;
  }

  @override
  String? getCurrentUserId() {
    return _authStateNotifier.currentUser?.id;
  }

  @override
  void validateOwnershipOrThrow(task_entity.Task task) {
    if (!validateTaskOwnership(task)) {
      throw const UnauthorizedAccessException(
        'You are not authorized to modify this task',
      );
    }
  }
}
