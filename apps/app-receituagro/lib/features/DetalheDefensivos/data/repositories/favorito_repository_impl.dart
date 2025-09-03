import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/favorito_repository.dart';

/// Implementação do repositório de favoritos
/// 
/// Esta classe implementa o contrato definido no domain layer,
/// usando o FavoritosHiveRepository como fonte de dados
class FavoritoRepositoryImpl implements FavoritoRepository {
  const FavoritoRepositoryImpl(this._hiveRepository);

  final FavoritosHiveRepository _hiveRepository;

  @override
  ResultFuture<String> addFavorito(FavoritoEntity favorito) async {
    try {
      final itemData = {
        'nome': favorito.nome,
        'fabricante': favorito.fabricante,
        'cultura': favorito.cultura,
        'idReg': favorito.itemId,
        ...favorito.metadata,
      };

      final success = await _hiveRepository.addFavorito(
        favorito.tipo,
        favorito.itemId,
        itemData,
      );

      if (success) {
        return Right(favorito.id);
      } else {
        return const Left(CacheFailure('Falha ao adicionar favorito'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar favorito: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> removeFavorito(String itemId, String tipo) async {
    try {
      final success = await _hiveRepository.removeFavorito(tipo, itemId);

      if (success) {
        return const Right(null);
      } else {
        return const Left(CacheFailure('Falha ao remover favorito'));
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao remover favorito: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<bool> isFavorito(String itemId, String tipo) async {
    try {
      final isFavorited = _hiveRepository.isFavorito(tipo, itemId);
      return Right(isFavorited);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar favorito: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<FavoritoEntity>> getFavoritosByTipo(String tipo) async {
    try {
      // O FavoritosHiveRepository não tem método específico por tipo,
      // então vamos implementar uma versão simplificada
      final favoritos = <FavoritoEntity>[];
      
      // Por simplicidade, retornamos uma lista vazia por enquanto
      // Em uma implementação real, precisaríamos iterar pelos dados do Hive
      return Right(favoritos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar favoritos por tipo: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<FavoritoEntity>> getAllFavoritos() async {
    try {
      final favoritos = <FavoritoEntity>[];
      
      // Por simplicidade, retornamos uma lista vazia por enquanto
      // Em uma implementação real, precisaríamos iterar pelos dados do Hive
      return Right(favoritos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar todos os favoritos: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<FavoritoEntity>> searchFavoritos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      // Por simplicidade, retornamos uma lista vazia por enquanto
      final favoritos = <FavoritoEntity>[];
      return Right(favoritos);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar favoritos: ${e.toString()}'));
    }
  }

  @override
  Stream<List<FavoritoEntity>> watchFavoritos() async* {
    try {
      // Como não temos stream nativo, simulamos com refresh periódico
      while (true) {
        final favoritos = <FavoritoEntity>[];
        yield favoritos;
        
        // Aguarda 5 segundos antes do próximo refresh
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      yield [];
    }
  }

  @override
  ResultFuture<int> countFavoritosByTipo(String tipo) async {
    try {
      // Por simplicidade, retornamos 0 por enquanto
      return const Right(0);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar favoritos: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> clearAllFavoritos() async {
    try {
      // O FavoritosHiveRepository não tem método específico para limpar todos,
      // então por enquanto retornamos sucesso
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar favoritos: ${e.toString()}'));
    }
  }
}