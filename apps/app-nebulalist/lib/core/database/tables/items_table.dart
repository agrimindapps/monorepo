import 'package:drift/drift.dart';

/// Tabela de itens no banco Drift
/// Representa itens individuais em uma lista
@DataClassName('ItemRecord')
class Items extends Table {
  /// ID único do item
  TextColumn get id => text()();

  /// ID da lista à qual pertence
  TextColumn get listId => text()();

  /// Nome/título do item
  TextColumn get name => text()();

  /// Item completado
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// Posição/ordem na lista
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Nota/observação
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Quantidade
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  /// Data de criação
  DateTimeColumn get createdAt => dateTime()();

  /// Data de atualização
  DateTimeColumn get updatedAt => dateTime()();

  /// Data de conclusão
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {listId, position}
      ];
}
