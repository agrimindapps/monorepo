import 'package:drift/drift.dart';

/// Interface base para todos os repositórios Drift
///
/// Esta classe abstrata define o contrato que todos os repositórios
/// devem seguir, promovendo consistência no acesso aos dados.
///
/// [T] - Tipo da entidade do domínio
/// [D] - Tipo da classe de dados gerada pelo Drift
abstract class BaseDriftRepository<T, D> {
  /// Insere uma nova entidade no banco de dados
  ///
  /// Retorna o ID do registro inserido
  Future<int> insert(T entity);

  /// Insere múltiplas entidades de uma vez
  ///
  /// Retorna uma lista com os IDs dos registros inseridos
  Future<List<int>> insertAll(List<T> entities);

  /// Atualiza uma entidade existente
  ///
  /// Retorna true se a atualização foi bem-sucedida
  Future<bool> update(T entity);

  /// Deleta uma entidade pelo ID
  ///
  /// Retorna true se a deleção foi bem-sucedida
  Future<bool> delete(int id);

  /// Deleta múltiplas entidades pelos IDs
  ///
  /// Retorna o número de registros deletados
  Future<int> deleteAll(List<int> ids);

  /// Busca uma entidade pelo ID
  ///
  /// Retorna null se não encontrar
  Future<T?> findById(int id);

  /// Busca todas as entidades
  Future<List<T>> findAll();

  /// Conta o número total de entidades
  Future<int> count();

  /// Verifica se existe uma entidade com o ID fornecido
  Future<bool> exists(int id);

  /// Stream que emite todas as entidades
  ///
  /// Útil para observar mudanças em tempo real
  Stream<List<T>> watchAll();

  /// Stream que emite uma entidade específica
  ///
  /// Útil para observar mudanças em um registro específico
  Stream<T?> watchById(int id);
}

/// Implementação base de repositório com funcionalidades comuns
///
/// Esta classe fornece implementações padrão para operações comuns,
/// reduzindo boilerplate nos repositórios concretos.
///
/// Exemplo de uso:
/// ```dart
/// class UserRepository extends BaseDriftRepositoryImpl<User, UserData> {
///   UserRepository(this._db);
///
///   final AppDatabase _db;
///
///   @override
///   TableInfo<Users, UserData> get table => _db.users;
///
///   @override
///   GeneratedDatabase get database => _db;
///
///   @override
///   User fromData(UserData data) => User.fromData(data);
///
///   @override
///   Insertable<UserData> toCompanion(User entity) => entity.toCompanion();
///
///   @override
///   Expression<int> idColumn(Users tbl) => tbl.id;
/// }
/// ```
abstract class BaseDriftRepositoryImpl<T, D extends DataClass>
    implements BaseDriftRepository<T, D> {
  /// Tabela associada ao repositório
  TableInfo<Table, D> get table;

  /// Database instance
  GeneratedDatabase get database;

  /// Converte de Data class do Drift para entidade do domínio
  T fromData(D data);

  /// Converte de entidade do domínio para Companion do Drift
  Insertable<D> toCompanion(T entity);

  /// Retorna a coluna de ID da tabela
  ///
  /// Este método deve ser implementado para apontar para a coluna de ID
  /// da sua tabela. Por exemplo: `(tbl) => tbl.id`
  Expression<int> idColumn(covariant Table tbl);

  @override
  Future<int> insert(T entity) async {
    return await database.into(table).insert(toCompanion(entity));
  }

  @override
  Future<List<int>> insertAll(List<T> entities) async {
    final companions = entities.map((e) => toCompanion(e)).toList();
    final results = <int>[];

    await database.transaction(() async {
      for (final companion in companions) {
        final id = await database.into(table).insert(companion);
        results.add(id);
      }
    });

    return results;
  }

  @override
  Future<bool> update(T entity) async {
    return await database.update(table).replace(toCompanion(entity));
  }

  @override
  Future<bool> delete(int id) async {
    final rowsAffected = await (database.delete(
      table,
    )..where((tbl) => idColumn(tbl).equals(id))).go();
    return rowsAffected > 0;
  }

  @override
  Future<int> deleteAll(List<int> ids) async {
    return await (database.delete(
      table,
    )..where((tbl) => idColumn(tbl).isIn(ids))).go();
  }

  @override
  Future<T?> findById(int id) async {
    final query = database.select(table)
      ..where((tbl) => idColumn(tbl).equals(id))
      ..limit(1);

    final results = await query.get();
    if (results.isEmpty) return null;

    return fromData(results.first);
  }

  @override
  Future<List<T>> findAll() async {
    final results = await database.select(table).get();
    return results.map((data) => fromData(data)).toList();
  }

  @override
  Future<int> count() async {
    final query = database.selectOnly(table)
      ..addColumns([idColumn(table).count()]);
    final result = await query.getSingle();
    return result.read(idColumn(table).count()) ?? 0;
  }

  @override
  Future<bool> exists(int id) async {
    final entity = await findById(id);
    return entity != null;
  }

  @override
  Stream<List<T>> watchAll() {
    return database
        .select(table)
        .watch()
        .map((dataList) => dataList.map((data) => fromData(data)).toList());
  }

  @override
  Stream<T?> watchById(int id) {
    final query = database.select(table)
      ..where((tbl) => idColumn(tbl).equals(id))
      ..limit(1);

    return query.watchSingleOrNull().map(
      (data) => data != null ? fromData(data) : null,
    );
  }
}
