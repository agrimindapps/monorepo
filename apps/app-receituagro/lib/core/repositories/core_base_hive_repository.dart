import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../contracts/i_static_data_repository.dart';

/// Repositório base que utiliza o HiveStorageService do core package
/// Substitui o BaseHiveRepository antigo que usava Hive diretamente
abstract class CoreBaseHiveRepository<T> implements IStaticDataRepository<T> {
  @protected
  final ILocalStorageRepository _storageService;
  @protected
  final String _boxName;
  final String _versionKey = '_app_version';
  
  // Cache em memória para compatibilidade síncrona
  List<T>? _cachedEntities;

  CoreBaseHiveRepository(
    this._storageService,
    this._boxName,
  );

  /// Template method - define o fluxo, subclasses implementam detalhes
  @override
  Future<Either<Exception, void>> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String appVersion,
  ) async {
    try {
      if (isUpToDate(appVersion)) {
        return const Right(null); // Já atualizado
      }

      // Limpa dados existentes
      final clearResult = await _storageService.clear(box: HiveBoxes.receituagro);
      if (clearResult.isLeft()) {
        return Left(Exception('Erro ao limpar dados: ${clearResult.fold((f) => f.message, (_) => '')}'));
      }

      // Carrega novos dados
      for (final json in jsonData) {
        final entity = createFromJson(json); // Método abstrato
        final key = getKeyFromEntity(entity); // Método abstrato
        
        final saveResult = await _storageService.save<Map<String, dynamic>>(
          key: '${_boxName}_$key',
          data: json,
          box: HiveBoxes.receituagro,
        );
        
        if (saveResult.isLeft()) {
          return Left(Exception('Erro ao salvar dados: ${saveResult.fold((f) => f.message, (_) => '')}'));
        }
      }

      // Salva versão
      final versionResult = await _storageService.save<String>(
        key: '${_boxName}_$_versionKey',
        data: appVersion,
        box: HiveBoxes.receituagro,
      );
      
      if (versionResult.isLeft()) {
        return Left(Exception('Erro ao salvar versão: ${versionResult.fold((f) => f.message, (_) => '')}'));
      }

      // Recarrega o cache após salvar novos dados
      await getAllAsync();

      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao carregar dados: ${e.toString()}'));
    }
  }

  @override
  bool isUpToDate(String appVersion) {
    // Como o método precisa ser síncrono, vamos usar uma abordagem diferente
    // Vamos assumir que está desatualizado e deixar que loadFromJson verifique
    return false;
  }

  @override
  List<T> getAll() {
    // Para compatibilidade síncrona, manteremos um cache em memória
    // Mas fornecemos também a versão assíncrona
    return _cachedEntities ?? [];
  }

  /// Versão assíncrona de getAll
  Future<List<T>> getAllAsync() async {
    try {
      final result = await _storageService.getKeys(box: HiveBoxes.receituagro);
      
      final entities = await result.fold(
        (failure) => Future.value(<T>[]),
        (keys) async {
          final entities = <T>[];
          final relevantKeys = keys.where((key) => key.startsWith('${_boxName}_') && !key.endsWith('_$_versionKey')).toList();
          
          for (final key in relevantKeys) {
            final dataResult = await _storageService.get<Map<String, dynamic>>(
              key: key,
              box: HiveBoxes.receituagro,
            );
            
            dataResult.fold(
              (failure) => null,
              (data) {
                if (data != null) {
                  entities.add(createFromJson(data));
                }
              },
            );
          }
          
          return entities;
        },
      );

      // Atualiza cache
      _cachedEntities = entities;
      return entities;
    } catch (e) {
      return [];
    }
  }

  @override
  T? getById(String id) {
    // Compatibilidade síncrona - busca no cache
    if (_cachedEntities != null) {
      try {
        return _cachedEntities!.firstWhere(
          (entity) => getKeyFromEntity(entity) == id,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Versão assíncrona de getById
  Future<T?> getByIdAsync(String id) async {
    try {
      final result = await _storageService.get<Map<String, dynamic>>(
        key: '${_boxName}_$id',
        box: HiveBoxes.receituagro,
      );

      return result.fold(
        (failure) => null,
        (data) => data != null ? createFromJson(data) : null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  List<T> findBy(bool Function(T item) predicate) {
    final all = getAll();
    return all.where(predicate).toList();
  }

  /// Versão assíncrona de findBy
  Future<List<T>> findByAsync(bool Function(T item) predicate) async {
    final all = await getAllAsync();
    return all.where(predicate).toList();
  }

  @override
  Future<Either<Exception, void>> clear() async {
    try {
      final result = await _storageService.clear(box: HiveBoxes.receituagro);
      
      return result.fold(
        (failure) => Left(Exception('Erro ao limpar dados: ${failure.message}')),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(Exception('Erro ao limpar dados: ${e.toString()}'));
    }
  }

  @override
  int get count {
    return getAll().length;
  }
  
  /// Método count async para uso em Future.wait
  Future<int> countAsync() async {
    return count;
  }

  /// Verifica se está atualizado de forma assíncrona
  Future<bool> isUpToDateAsync(String appVersion) async {
    try {
      final result = await _storageService.get<String>(
        key: '${_boxName}_$_versionKey',
        box: HiveBoxes.receituagro,
      );

      return result.fold(
        (failure) => false,
        (storedVersion) => storedVersion == appVersion,
      );
    } catch (e) {
      return false;
    }
  }

  /// Métodos abstratos - subclasses devem implementar
  T createFromJson(Map<String, dynamic> json);
  String getKeyFromEntity(T entity);
}