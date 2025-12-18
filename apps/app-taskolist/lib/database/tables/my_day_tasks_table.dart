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
  
  /// User ID (owner)
  TextColumn get userId => text()();
  
  /// When task was added to My Day
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {taskId, userId}, // A task can only be added once per user
  ];
}
