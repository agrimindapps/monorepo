import 'package:drift/drift.dart';

/// Exemplo de definição de tabela Drift
///
/// Esta classe demonstra as melhores práticas para definir tabelas
/// no Drift, incluindo tipos de colunas, constraints e índices.
class ExampleUsers extends Table {
  // Primary Key - Auto incremento
  IntColumn get id => integer().autoIncrement()();

  // Texto com validação de tamanho
  TextColumn get name => text().withLength(min: 1, max: 100)();

  // Email único
  TextColumn get email => text().unique()();

  // Telefone opcional
  TextColumn get phone => text().nullable()();

  // Data de criação com valor padrão
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Data de atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Booleano para status ativo
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Número com ponto flutuante (para valores monetários, idade, etc)
  RealColumn get balance => real().withDefault(const Constant(0.0))();

  // Blob para armazenar dados binários (imagens pequenas, etc)
  BlobColumn get avatar => blob().nullable()();

  // JSON como texto (para objetos complexos)
  TextColumn get metadata => text().map(const JsonConverter()).nullable()();
}

/// Exemplo de tabela com relacionamento
class ExamplePosts extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Foreign Key para Users
  IntColumn get userId => integer().references(ExampleUsers, #id)();

  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get content => text()();

  DateTimeColumn get publishedAt => dateTime()();
  BoolColumn get isDraft => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Converter personalizado para JSON
class JsonConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    // Implementar parsing de JSON
    // Em produção, use dart:convert
    return {}; // Placeholder
  }

  @override
  String toSql(Map<String, dynamic> value) {
    // Implementar serialização JSON
    // Em produção, use dart:convert
    return '{}'; // Placeholder
  }
}

/// Exemplo de índices customizados
/// 
/// Use este padrão quando precisar criar índices compostos
/// ou índices com condições específicas
/// 
/// ```dart
/// @override
/// List<Index> get customIndexes => [
///   Index('user_email_idx', 'CREATE INDEX user_email_idx ON users(email)'),
///   Index('post_user_date_idx', 
///     'CREATE INDEX post_user_date_idx ON posts(user_id, published_at DESC)'),
/// ];
/// ```
