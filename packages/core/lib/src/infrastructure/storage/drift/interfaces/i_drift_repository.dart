import 'package:drift/drift.dart';

import '../../../../shared/utils/result.dart';

/// Interface para repositórios Drift
/// Define contratos básicos para CRUD operations
///
/// Equivalente Drift do IHiveRepository
///
/// Type parameters:
/// - T: Tipo de entity (DataClass)
/// - TTable: Tipo da tabela Drift correspondente
abstract class IDriftRepository<T extends DataClass, TTable extends Table> {
  /// Nome da tabela associada a este repositório
  String get tableName;

  /// Referência à database
  GeneratedDatabase get database;

  /// Verifica se o repositório foi inicializado
  bool get isInitialized;

  /// Insere um item na tabela
  /// Retorna o ID do item inserido
  Future<Result<int>> insert(Insertable<T> item);

  /// Insere múltiplos itens (batch insert)
  /// Retorna lista de IDs inseridos
  Future<Result<List<int>>> insertAll(List<Insertable<T>> items);

  /// Atualiza um item existente
  /// Retorna o número de linhas afetadas
  Future<Result<int>> update(Insertable<T> item);

  /// Atualiza múltiplos itens (batch update)
  /// Retorna o número total de linhas afetadas
  Future<Result<int>> updateAll(List<Insertable<T>> items);

  /// Deleta um item por ID
  /// Retorna true se deletado com sucesso
  Future<Result<bool>> delete(dynamic id);

  /// Deleta múltiplos itens por IDs
  /// Retorna o número de itens deletados
  Future<Result<int>> deleteAll(List<dynamic> ids);

  /// Deleta todos os itens da tabela
  /// Retorna o número de itens deletados
  Future<Result<int>> clear();

  /// Obtém um item por ID
  /// Retorna null se não encontrado
  Future<Result<T?>> getById(dynamic id);

  /// Obtém todos os itens da tabela
  Future<Result<List<T>>> getAll();

  /// Obtém itens com paginação
  Future<Result<List<T>>> getPage({
    required int page,
    required int pageSize,
  });

  /// Conta o número total de itens
  Future<Result<int>> count();

  /// Verifica se um item existe por ID
  Future<Result<bool>> exists(dynamic id);

  /// Stream de todos os itens (reactive)
  Stream<List<T>> watchAll();

  /// Stream de um item específico por ID
  Stream<T?> watchById(dynamic id);

  /// Executa operação em transação
  Future<Result<R>> transaction<R>(
    Future<R> Function() action,
  );

  /// Limpa cache (se houver)
  Future<void> clearCache();

  /// Verifica se a tabela está vazia
  /// Equivalente ao isEmpty() do IHiveRepository
  Future<Result<bool>> isEmpty();

  /// Obtém todos os IDs da tabela
  /// Equivalente ao getAllKeys() do IHiveRepository
  Future<Result<List<dynamic>>> getAllIds();

  /// Retorna estatísticas da tabela
  /// Informações como número de registros, tamanho, etc.
  Future<Result<Map<String, dynamic>>> getStatistics();

  /// Count direto sem Result wrapper
  /// Retorna 0 em caso de erro ao invés de Result
  Future<int> countAsync();

  // ==================== Métodos Adicionais (Convenientes) ====================

  /// Obtém múltiplos itens por seus IDs
  /// Útil para buscar vários registros de uma vez
  Future<Result<List<T>>> getByIds(List<dynamic> ids);

  /// Busca itens usando um predicate Dart
  /// Carrega todos os itens e filtra em memória
  /// Para melhor performance, use queries tipadas do Drift
  Future<Result<List<T>>> findBy(bool Function(T) predicate);

  /// Busca o primeiro item que atende ao predicate
  /// Retorna null se nenhum item atender
  Future<Result<T?>> findFirst(bool Function(T) predicate);

  /// Insert ou Update (upsert)
  /// Se o item existir (baseado em primary key), atualiza
  /// Se não existir, insere
  /// Retorna o ID do item
  Future<Result<int>> upsert(Insertable<T> item);

  /// Upsert múltiplos itens
  /// Retorna lista de IDs dos itens
  Future<Result<List<int>>> upsertAll(List<Insertable<T>> items);

  /// Alias para getById() - facilita migração conceitual do Hive
  Future<Result<T?>> getByKey(dynamic key);

  /// Alias para exists() - compatibilidade conceitual com Hive
  Future<Result<bool>> containsKey(dynamic key);

  /// Conta itens que atendem ao predicate
  /// Carrega todos e filtra em memória
  Future<Result<int>> countBy(bool Function(T) predicate);

  /// Busca usando expressão SQL tipada do Drift (type-safe!)
  /// Melhor performance que findBy() pois usa SQL diretamente
  /// 
  /// Exemplo:
  /// ```dart
  /// final actives = await repo.findWhere((t) => t.active.equals(true));
  /// ```
  Future<Result<List<T>>> findWhere(
    Expression<bool> Function(TTable table) where,
  );

  /// Atualiza múltiplos registros que atendem condição
  /// Retorna o número de registros atualizados
  /// 
  /// Exemplo:
  /// ```dart
  /// await repo.updateWhere(
  ///   (t) => t.status.equals('pending'),
  ///   TasksCompanion(status: Value('completed')),
  /// );
  /// ```
  Future<Result<int>> updateWhere(
    Expression<bool> Function(TTable table) where,
    Insertable<T> update,
  );
}

/// Interface para repositórios com suporte a queries customizadas
abstract class IQueryableDriftRepository<T extends DataClass, TTable extends Table>
    extends IDriftRepository<T, TTable> {
  /// Busca itens por uma query customizada
  Future<Result<List<T>>> query(
    String where, {
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Stream de query customizada
  Stream<List<T>> watchQuery(
    String where, {
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  });

  /// Conta itens que atendem uma condição
  Future<Result<int>> countWhere(
    String where, {
    List<dynamic>? whereArgs,
  });

  /// Deleta itens que atendem uma condição
  Future<Result<int>> deleteWhere(
    String where, {
    List<dynamic>? whereArgs,
  });
}

/// Interface para repositórios com suporte a sync
abstract class ISyncableDriftRepository<T extends DataClass, TTable extends Table>
    extends IDriftRepository<T, TTable> {
  /// Obtém itens pendentes de sincronização
  Future<Result<List<T>>> getPendingSync();

  /// Marca item como sincronizado
  Future<Result<void>> markAsSynced(dynamic id);

  /// Marca múltiplos itens como sincronizados
  Future<Result<void>> markAllAsSynced(List<dynamic> ids);

  /// Obtém itens modificados desde uma data
  Future<Result<List<T>>> getModifiedSince(DateTime date);

  /// Obtém itens não sincronizados (dirty)
  Future<Result<List<T>>> getDirtyItems();
}
