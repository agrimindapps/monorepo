import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/models/comentario_model.dart';

/// Repository interface for plant comments
abstract class PlantCommentsRepository {
  /// Get all comments for a specific plant
  Future<Either<Failure, List<ComentarioModel>>> getCommentsForPlant(String plantId);
  
  /// Add a comment to a plant
  Future<Either<Failure, ComentarioModel>> addComment(String plantId, String content);
  
  /// Update an existing comment
  Future<Either<Failure, ComentarioModel>> updateComment(ComentarioModel comment);
  
  /// Delete a comment
  Future<Either<Failure, void>> deleteComment(String commentId);
  
  /// Delete all comments for a specific plant
  Future<Either<Failure, void>> deleteCommentsForPlant(String plantId);
}