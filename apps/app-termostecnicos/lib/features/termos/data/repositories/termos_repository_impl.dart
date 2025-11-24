import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/termo.dart';
import '../../domain/repositories/termos_repository.dart';
import '../datasources/local/termos_local_datasource.dart';
import '../models/categoria_model.dart';

/// Implementation of TermosRepository
/// Handles all data operations with proper error handling
class TermosRepositoryImpl implements TermosRepository {
  final TermosLocalDataSource _localDataSource;

  TermosRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Termo>>> carregarTermos() async {
    try {
      final termos = await _localDataSource.loadAllTermos();
      return Right(termos);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error loading termos: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorito(String termoId) async {
    try {
      if (termoId.trim().isEmpty) {
        return const Left(
          ValidationFailure(message: 'ID do termo não pode ser vazio'),
        );
      }

      final isFavorited = await _localDataSource.setFavorito(termoId);
      return Right(isFavorited);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error toggling favorito: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorito(String termoId) async {
    try {
      if (termoId.trim().isEmpty) {
        return const Right(false);
      }

      final isFavorited = await _localDataSource.isFavorito(termoId);
      return Right(isFavorited);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error checking favorito: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Categoria>> getCategoriaAtual() async {
    try {
      final categoria = await _localDataSource.getCategoriaAtual();

      if (categoria == null) {
        return const Left(
          CacheFailure(message: 'No categoria found'),
        );
      }

      return Right(categoria);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error getting categoria: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setCategoria(Categoria categoria) async {
    try {
      // Validate categoria
      if (categoria.id <= 0) {
        return const Left(
          ValidationFailure(
            message: 'ID da categoria deve ser maior que zero',
          ),
        );
      }

      if (categoria.descricao.trim().isEmpty) {
        return const Left(
          ValidationFailure(
            message: 'Descrição da categoria não pode ser vazia',
          ),
        );
      }

      await _localDataSource.setCategoria(
        _categoriaToModel(categoria),
      );

      return const Right(unit);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error setting categoria: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Categoria>>> getCategorias() async {
    try {
      final categorias = _localDataSource.getCategorias();
      return Right(categorias);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error getting categorias: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Termo>>> getFavoritos() async {
    try {
      // Load all termos
      final allTermos = await _localDataSource.loadAllTermos();

      // Filter only favorited terms
      final favoritos = allTermos.where((termo) => termo.favorito).toList();

      return Right(favoritos);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error getting favoritos: $e'),
      );
    }
  }

  // Helper method to convert domain Categoria to CategoriaModel
  CategoriaModel _categoriaToModel(Categoria categoria) {
    if (categoria is CategoriaModel) {
      return categoria;
    }
    return CategoriaModel.fromEntity(categoria);
  }
}
