import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/utils/result.dart';

/// Interface genérica para repositórios Hive
/// Define operações CRUD básicas que qualquer repositório deve implementar
abstract class IHiveRepository<T extends HiveObject> {
  /// Nome da box associada a este repositório
  String get boxName;

  /// Obtém todos os itens da box
  Future<Result<List<T>>> getAll();

  /// Obtém um item por sua chave
  Future<Result<T?>> getByKey(dynamic key);

  /// Obtém múltiplos itens por suas chaves
  Future<Result<List<T>>> getByKeys(List<dynamic> keys);

  /// Busca itens usando um predicado
  Future<Result<List<T>>> findBy(bool Function(T) predicate);

  /// Busca o primeiro item que atende ao predicado
  Future<Result<T?>> findFirst(bool Function(T) predicate);

  /// Salva um item na box
  /// Se a chave já existir, atualiza o item
  Future<Result<void>> save(T item, {dynamic key});

  /// Salva múltiplos itens
  Future<Result<void>> saveAll(Map<dynamic, T> items);

  /// Remove um item por sua chave
  Future<Result<void>> deleteByKey(dynamic key);

  /// Remove múltiplos itens por suas chaves
  Future<Result<void>> deleteByKeys(List<dynamic> keys);

  /// Remove itens que atendem ao predicado
  Future<Result<int>> deleteWhere(bool Function(T) predicate);

  /// Limpa todos os dados da box
  Future<Result<void>> clear();

  /// Conta o número total de itens
  Future<Result<int>> count();

  /// Método de compatibilidade que retorna count diretamente como int
  Future<int> countAsync();

  /// Conta itens que atendem ao predicado
  Future<Result<int>> countWhere(bool Function(T) predicate);

  /// Verifica se a box está vazia
  Future<Result<bool>> isEmpty();

  /// Verifica se existe um item com a chave especificada
  Future<Result<bool>> containsKey(dynamic key);

  /// Obtém todas as chaves da box
  Future<Result<List<dynamic>>> getAllKeys();

  /// Obtém estatísticas da box
  Future<Result<Map<String, dynamic>>> getStatistics();

  /// Compacta a box (remove espaços vazios)
  Future<Result<void>> compact();
}