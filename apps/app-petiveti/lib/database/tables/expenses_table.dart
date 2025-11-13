import 'package:drift/drift.dart';

@DataClassName('Expense')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer().references(Animals, #id)();
  
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()(); // food, veterinary, grooming, toys, etc
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
