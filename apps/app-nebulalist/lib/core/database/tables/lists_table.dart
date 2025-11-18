import 'package:drift/drift.dart';

/// Tabela de listas no banco Drift
/// Baseada em ListEntity
@DataClassName('ListRecord')
class Lists extends Table {
  /// ID único da lista
  TextColumn get id => text()();

  /// Nome da lista
  TextColumn get name => text()();

  /// ID do proprietário
  TextColumn get ownerId => text()();

  /// Descrição da lista
  TextColumn get description => text().withDefault(const Constant(''))();

  /// Tags (JSON array)
  TextColumn get tags => text().withDefault(const Constant('[]'))();

  /// Categoria
  TextColumn get category => text().withDefault(const Constant('outros'))();

  /// Favorito
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// Arquivado
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Data de criação
  DateTimeColumn get createdAt => dateTime()();

  /// Data de atualização
  DateTimeColumn get updatedAt => dateTime()();

  /// Token de compartilhamento
  TextColumn get shareToken => text().nullable()();

  /// Lista compartilhada
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  /// Data de arquivamento
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// Contador de itens
  IntColumn get itemCount => integer().withDefault(const Constant(0))();

  /// Contador de itens completados
  IntColumn get completedCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
