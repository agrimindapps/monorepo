import 'package:drift/drift.dart';

@DataClassName('AguaRegistro')
class AguaRegistros extends Table {
  TextColumn get id => text()();
  IntColumn get dataRegistro => integer()();
  IntColumn get quantidade => integer()();
  TextColumn get fkIdPerfil => text()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
