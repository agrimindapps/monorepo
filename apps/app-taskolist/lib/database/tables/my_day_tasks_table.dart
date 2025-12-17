import 'package:drift/drift.dart';

/// MyDayTasks Table
///
/// Stores tasks added to "My Day" planner
/// Tracks daily focus tasks with history support
@DataClassName('MyDayTaskData')
class MyDayTasks extends Table {
  /// Unique ID (UUID)
  TextColumn get id => text()();
  
  /// Task ID (foreign key to Tasks.firebaseId)
  TextColumn get taskId => text()();
  
  /// Day date (normalized to 00:00:00)
  /// Example: 2025-12-17 00:00:00
  DateTimeColumn get dayDate => dateTime()();
  
  /// When task was added to My Day
  DateTimeColumn get addedAt => dateTime()();
  
  /// If task was completed while in My Day
  BoolColumn get wasCompleted => boolean().withDefault(const Constant(false))();
  
  /// When it was completed
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  /// If task was manually removed from My Day (swipe, etc)
  BoolColumn get wasRemoved => boolean().withDefault(const Constant(false))();
  
  /// When it was removed
  DateTimeColumn get removedAt => dateTime().nullable()();
  
  /// If this record is archived (past days)
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {taskId, dayDate}, // A task can only be added once per day
  ];
}
