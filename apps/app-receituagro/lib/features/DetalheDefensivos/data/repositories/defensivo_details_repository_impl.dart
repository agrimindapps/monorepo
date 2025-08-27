import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../../domain/entities/defensivo_details_entity.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_defensivo_details_repository.dart';
import '../mappers/diagnostico_mapper.dart';

/// Implementação do repositório de detalhes de defensivos
/// Coordena acesso aos dados de diferentes fontes (Hive, Firestore)
class DefensivoDetailsRepositoryImpl implements IDefensivoDetailsRepository {
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final FavoritosHiveRepository _favoritosRepository;
  final DiagnosticosRepositoryImpl _diagnosticosRepository;

  DefensivoDetailsRepositoryImpl({
    FitossanitarioHiveRepository? fitossanitarioRepository,
    FavoritosHiveRepository? favoritosRepository,
    DiagnosticosRepositoryImpl? diagnosticosRepository,
  }) : _fitossanitarioRepository = fitossanitarioRepository ?? sl<FitossanitarioHiveRepository>(),
        _favoritosRepository = favoritosRepository ?? sl<FavoritosHiveRepository>(),
        _diagnosticosRepository = diagnosticosRepository ?? sl<DiagnosticosRepositoryImpl>();

  @override
  Future<Either<Failure, DefensivoDetailsEntity?>> getDefensivoByName(String name) async {
    try {
      final defensivos = _fitossanitarioRepository.getAll()
          .where((d) => d.nomeComum == name || d.nomeTecnico == name);
      
      if (defensivos.isEmpty) {
        return const Right(null);
      }
      
      final defensivo = defensivos.first;
      final entity = DefensivoDetailsEntity.fromHive(defensivo);
      
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getDiagnosticosByDefensivo(String defensivoId) async {
    try {
      final result = await _diagnosticosRepository.getByDefensivo(defensivoId);
      
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final entities = DiagnosticoMapper.fromDiagnosticosEntityList(diagnosticos);
          return Right(entities);
        },
      );
    } catch (e) {
      return Left(ServerFailure( 'Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorited(String defensivoId) async {
    try {
      final isFavorited = _favoritosRepository.isFavorito('defensivos', defensivoId);
      return Right(isFavorited);
    } catch (e) {
      return Left(CacheFailure( 'Erro ao verificar favorito: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String defensivoId, Map<String, dynamic> defensivoData) async {
    try {
      final isCurrentlyFavorited = _favoritosRepository.isFavorito('defensivos', defensivoId);
      
      bool success;
      if (isCurrentlyFavorited) {
        success = await _favoritosRepository.removeFavorito('defensivos', defensivoId);
      } else {
        success = await _favoritosRepository.addFavorito('defensivos', defensivoId, defensivoData);
      }
      
      return Right(success);
    } catch (e) {
      return Left(CacheFailure( 'Erro ao alterar favorito: ${e.toString()}'));
    }
  }
}