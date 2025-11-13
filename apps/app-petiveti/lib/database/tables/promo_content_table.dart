import 'package:drift/drift.dart';

@DataClassName('PromoContentEntry')
class PromoContent extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get actionUrl => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
