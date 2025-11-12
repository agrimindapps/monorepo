import 'package:drift/drift.dart';
import '../../../../shared/utils/result.dart';

/// Interface para repositórios Drift
/// Define contratos básicos para CRUD operations
/// 
/// Equivalente Drift do IHiveRepository
abstract class IDriftRepository<T extends DataClass> {
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
}

/// Interface para repositórios com suporte a queries customizadas
abstract class IQueryableDriftRepository<T extends DataClass>
    extends IDriftRepository<T> {
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
abstract class ISyncableDriftRepository<T extends DataClass>
    extends IDriftRepository<T> {
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
