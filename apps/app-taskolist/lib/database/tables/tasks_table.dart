import 'package:drift/drift.dart';

/// Tasks Table
///
/// Stores all user tasks with full sync support
@DataClassName('TaskData')
class Tasks extends Table {
  // ========== BASE FIELDS ==========

  /// Local auto-increment ID
  IntColumn get id => integer().autoIncrement()();

  /// Firebase document ID (UUID)
  TextColumn get firebaseId => text().map(const NullableStringConverter())();

  /// User ID (Firebase UID)
  TextColumn get userId => text().nullable()();

  /// Module name (always 'taskolist')
  TextColumn get moduleName => text().nullable()();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== BUSINESS FIELDS ==========

  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().nullable()();
  TextColumn get listId => text()();
  TextColumn get createdById => text()();
  TextColumn get assignedToId => text().nullable()();
  
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderDate => dateTime().nullable()();
  
  /// TaskStatus as integer (0=pending, 1=inProgress, 2=completed, 3=cancelled)
  IntColumn get status => integer().withDefault(const Constant(0))();
  
  /// TaskPriority as integer (0=low, 1=medium, 2=high, 3=urgent)
  IntColumn get priority => integer().withDefault(const Constant(1))();
  
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  
  /// JSON array of tags
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  
  TextColumn get parentTaskId => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  // ========== RECURRENCE FIELDS ==========
  
  /// Recurrence type: none, daily, weekly, monthly, yearly, custom
  TextColumn get recurrenceType => text().withDefault(const Constant('none'))();
  
  /// Recurrence interval (e.g., every 2 days, every 3 weeks)
  IntColumn get recurrenceInterval => integer().withDefault(const Constant(1))();
  
  /// Days of week for weekly recurrence (JSON array: [1,2,3] = Mon,Tue,Wed)
  TextColumn get recurrenceDaysOfWeek => text().nullable()();
  
  /// Day of month for monthly recurrence (1-31)
  IntColumn get recurrenceDayOfMonth => integer().nullable()();
  
  /// End date for recurrence (null = infinite)
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();

  // ========== INDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
    {firebaseId},
  ];
}

/// Converter for nullable String to handle firebaseId
class NullableStringConverter extends TypeConverter<String, String> {
  const NullableStringConverter();

  @override
  String fromSql(String fromDb) => fromDb;

  @override
  String toSql(String value) => value;
}
