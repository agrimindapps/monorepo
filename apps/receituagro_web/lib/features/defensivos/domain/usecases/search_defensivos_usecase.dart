import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../../../core/validation/validators.dart';
import '../entities/defensivo.dart';
import '../repositories/defensivos_repository.dart';

/// Parameters for search defensivos use case
class SearchDefensivosParams extends Equatable {
  final String query;

  const SearchDefensivosParams({required this.query});

  @override
  List<Object> get props => [query];
}

/// Use case to search defensivos by query
@injectable
class SearchDefensivosUseCase
    implements UseCase<List<Defensivo>, SearchDefensivosParams> {
  final DefensivosRepository repository;

  const SearchDefensivosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Defensivo>>> call(
    SearchDefensivosParams params,
  ) async {
    // Validation
    final validationError = _validateQuery(params.query);
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      final result = await repository.searchDefensivos(params.query);

      return result.fold(
        (failure) => Left(failure),
        (defensivos) {
          // Sort results (business logic)
          final sorted = List<Defensivo>.from(defensivos);
          sorted.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          return Right(sorted);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Validate search query
  ValidationFailure? _validateQuery(String query) {
    // Check if query is not empty
    final requiredCheck = Validators.validateRequired(query, 'Busca');
    if (requiredCheck != null) return requiredCheck;

    // Check minimum length
    final minLengthCheck = Validators.validateMinLength(query, 3, 'Busca');
    if (minLengthCheck != null) return minLengthCheck;

    return null;
  }
}
