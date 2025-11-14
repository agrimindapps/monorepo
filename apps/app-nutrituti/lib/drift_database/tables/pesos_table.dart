import 'package:drift/drift.dart';

@DataClassName('Peso')
class Pesos extends Table {
  TextColumn get id => text()();
  IntColumn get dataRegistro => integer()();
  RealColumn get peso => real()();
  TextColumn get fkIdPerfil => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
