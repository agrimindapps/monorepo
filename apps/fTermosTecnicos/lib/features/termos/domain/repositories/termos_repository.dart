import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';
import '../entities/termo.dart';

/// Repository contract for Termos feature
/// Defines all operations related to technical terms
abstract class TermosRepository {
  /// Load all terms from all categories
  Future<Either<Failure, List<Termo>>> carregarTermos();

  /// Toggle favorite status of a term
  Future<Either<Failure, bool>> toggleFavorito(String termoId);

  /// Check if a term is favorited
  Future<Either<Failure, bool>> isFavorito(String termoId);

  /// Get the currently selected category
  Future<Either<Failure, Categoria>> getCategoriaAtual();

  /// Set the currently selected category
  Future<Either<Failure, Unit>> setCategoria(Categoria categoria);

  /// Get all available categories
  Future<Either<Failure, List<Categoria>>> getCategorias();

  /// Get favorite terms list
  Future<Either<Failure, List<Termo>>> getFavoritos();
}
