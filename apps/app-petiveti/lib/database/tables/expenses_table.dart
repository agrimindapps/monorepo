import 'package:drift/drift.dart';

@DataClassName('Expense')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get animalId => integer()();
  
  TextColumn get title => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()(); // consultation, medication, vaccine, surgery, etc
  TextColumn get paymentMethod => text()();
  DateTimeColumn get expenseDate => dateTime()();
  
  // Optional fields
  TextColumn get veterinaryClinic => text().nullable()();
  TextColumn get veterinarianName => text().nullable()();
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get receiptNumber => text().nullable()();
  
  BoolColumn get isPaid => boolean().withDefault(const Constant(true))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceType => text().nullable()();
  
  // User reference
  TextColumn get userId => text()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
