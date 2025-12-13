import 'package:drift/drift.dart';

@DataClassName('PromoContentEntry')
class PromoContent extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Firebase reference
  TextColumn get firebaseId => text().nullable()();

  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get actionUrl => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Sync fields
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}
