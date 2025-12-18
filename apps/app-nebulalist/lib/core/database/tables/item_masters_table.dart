import 'package:drift/drift.dart';

/// Tabela de ItemMasters (templates de itens reutilizáveis) no banco Drift
/// Baseada em ItemMasterEntity
@DataClassName('ItemMasterRecord')
class ItemMasters extends Table {
  /// ID único do item master
  TextColumn get id => text()();

  /// ID do proprietário
  TextColumn get ownerId => text()();

  /// Nome do item
  TextColumn get name => text()();

  /// Descrição do item
  TextColumn get description => text().withDefault(const Constant(''))();

  /// Tags (JSON array)
  TextColumn get tags => text().withDefault(const Constant('[]'))();

  /// Categoria
  TextColumn get category => text().withDefault(const Constant('outros'))();

  /// URL da foto
  TextColumn get photoUrl => text().nullable()();

  /// Preço estimado
  RealColumn get estimatedPrice => real().nullable()();

  /// Marca preferida
  TextColumn get preferredBrand => text().nullable()();

  /// Notas adicionais
  TextColumn get notes => text().nullable()();

  /// Contador de uso
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  /// Data de criação
  DateTimeColumn get createdAt => dateTime()();

  /// Data de atualização
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
