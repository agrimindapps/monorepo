import 'package:drift/drift.dart';

@DataClassName('Exercicio')
class Exercicios extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text()();
  TextColumn get categoria => text()();
  IntColumn get duracao => integer()();
  RealColumn get caloriasQueimadas => real()();
  DateTimeColumn get dataRegistro => dateTime()();
  TextColumn get observacoes => text().nullable()();
  
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
