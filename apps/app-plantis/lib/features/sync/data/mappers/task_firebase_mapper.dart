import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/domain/entities/task.dart';

/// Firebase mapper for Task entities
/// Handles conversion between TaskModel and Firestore JSON format
///
/// Key responsibilities:
/// - Convert TaskModel to Firestore-compatible JSON (toJson)
/// - Convert Firestore JSON back to TaskModel (fromJson)
/// - Handle Timestamp conversions (DateTime ↔ Firestore Timestamp)
/// - Handle enum conversions (TaskType, TaskStatus, TaskPriority)
/// - Manage null safety for optional fields
/// - Include sync metadata (isDirty, version, firebaseId, lastSyncAt)
class TaskFirebaseMapper {
  /// Convert TaskModel to Firestore JSON
  ///
  /// Firestore field naming convention: snake_case
  /// Excludes local-only 'id' field (document ID is stored separately)
  /// Converts DateTime to Timestamp for Firestore compatibility
  /// Converts enums to String keys
  static Map<String, dynamic> toJson(TaskModel task) {
    return {
      // Task-specific fields
      'title': task.title,
      'description': task.description,
      'plant_id': task.plantId,

      // Enum fields (stored as String keys)
      'type': task.type.key,
      'status': task.status.key,
      'priority': task.priority.key,

      // DateTime fields (converted to Timestamp)
      'due_date': Timestamp.fromDate(task.dueDate.toUtc()),
      'completed_at': task.completedAt != null
          ? Timestamp.fromDate(task.completedAt!.toUtc())
          : null,

      // Optional fields
      'completion_notes': task.completionNotes,
      'is_recurring': task.isRecurring,
      'recurring_interval_days': task.recurringIntervalDays,
      'next_due_date': task.nextDueDate != null
          ? Timestamp.fromDate(task.nextDueDate!.toUtc())
          : null,

      // BaseSyncEntity fields (from Task extends BaseSyncEntity)
      'created_at': task.createdAt != null
          ? Timestamp.fromDate(task.createdAt!.toUtc())
          : Timestamp.now(),
      'updated_at': task.updatedAt != null
          ? Timestamp.fromDate(task.updatedAt!.toUtc())
          : Timestamp.now(),
      'last_sync_at': task.lastSyncAt != null
          ? Timestamp.fromDate(task.lastSyncAt!.toUtc())
          : null,
      'is_dirty': task.isDirty,
      'is_deleted': task.isDeleted,
      'version': task.version,
      'user_id': task.userId,
      'module_name': task.moduleName ?? 'plantis',
    };
  }

  /// Convert Firestore JSON to TaskModel
  ///
  /// Parameters:
  /// - json: Firestore document data
  /// - documentId: Firestore document ID (becomes task.id)
  ///
  /// Returns TaskModel with:
  /// - isDirty = false (remote data is authoritative)
  /// - All Timestamp fields converted to DateTime
  /// - Enums parsed from String keys
  /// - Null safety for all optional fields
  static TaskModel fromJson(Map<String, dynamic> json, String documentId) {
    return TaskModel(
      // Use Firestore document ID as local ID
      id: documentId,

      // Task-specific fields
      title: json['title'] as String,
      description: json['description'] as String?,
      plantId: json['plant_id'] as String,

      // Enum fields (parse from String keys)
      type: TaskType.values.firstWhere(
        (e) => e.key == json['type'],
        orElse: () => TaskType.custom,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.key == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.key == json['priority'],
        orElse: () => TaskPriority.medium,
      ),

      // DateTime fields (convert from Timestamp)
      dueDate: (json['due_date'] as Timestamp).toDate(),
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] as Timestamp).toDate()
          : null,

      // Optional fields
      completionNotes: json['completion_notes'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringIntervalDays: json['recurring_interval_days'] as int?,
      nextDueDate: json['next_due_date'] != null
          ? (json['next_due_date'] as Timestamp).toDate()
          : null,

      // BaseSyncEntity fields
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
      lastSyncAt: json['last_sync_at'] != null
          ? (json['last_sync_at'] as Timestamp).toDate()
          : DateTime.now(), // Mark as synced
      isDirty: false, // Remote data is clean (authoritative)
      isDeleted: json['is_deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      userId: json['user_id'] as String?,
      moduleName: json['module_name'] as String? ?? 'plantis',
    );
  }

  /// Batch convert multiple Firestore documents to TaskModels
  static List<TaskModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
