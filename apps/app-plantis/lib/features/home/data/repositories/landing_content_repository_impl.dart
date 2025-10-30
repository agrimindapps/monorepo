import 'package:core/core.dart';

import '../../domain/entities/landing_content.dart';
import '../../domain/repositories/landing_content_repository.dart';
import '../datasources/landing_content_datasource.dart';

/// Implementation of [LandingContentRepository]
class LandingContentRepositoryImpl implements LandingContentRepository {
  final LandingContentDataSource dataSource;

  const LandingContentRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, LandingContent>> getLandingContent() async {
    try {
      final model = dataSource.getLandingContent();
      final entity = model.toEntity();
      return Right(entity);
    } on FormatException catch (e) {
      return Left(
        ParseFailure('Erro ao processar conteúdo da landing: ${e.message}'),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar conteúdo da landing: ${e.toString()}'),
      );
    }
  }
}
