import 'package:drift/drift.dart';

/// Comentarios table definition
/// Stores user comments about terms
class Comentarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();

  // Comment fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get status => boolean().withDefault(const Constant(true))();
  TextColumn get idReg => text()();
  TextColumn get titulo => text()();
  TextColumn get conteudo => text()();
  TextColumn get ferramenta => text()();
  TextColumn get pkIdentificador => text()();

  // Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
