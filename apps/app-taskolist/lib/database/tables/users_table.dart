import 'package:drift/drift.dart';

/// Users Table
///
/// Stores authenticated user data locally
@DataClassName('UserData')
class Users extends Table {
  // ========== BASE FIELDS ==========

  /// Local auto-increment ID
  IntColumn get id => integer().autoIncrement()();

  /// Firebase UID
  TextColumn get firebaseId => text().unique()();

  // ========== USER DATA ==========

  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // ========== STATUS ==========

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get emailVerified => boolean().withDefault(const Constant(false))();
}
