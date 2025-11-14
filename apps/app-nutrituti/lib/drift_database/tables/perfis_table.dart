import 'package:drift/drift.dart';

@DataClassName('Perfil')
class Perfis extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text()();
  DateTimeColumn get dataNascimento => dateTime()();
  RealColumn get altura => real()();
  RealColumn get peso => real()();
  IntColumn get genero => integer()();
  TextColumn get imagePath => text().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
