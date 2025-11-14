import 'package:drift/drift.dart';

@DataClassName('Comentario')
class Comentarios extends Table {
  TextColumn get id => text()();
  TextColumn get titulo => text()();
  TextColumn get conteudo => text()();
  TextColumn get ferramenta => text()();
  TextColumn get pkIdentificador => text()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
