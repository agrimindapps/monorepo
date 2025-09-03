import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart' as local_failures;
import '../../../../core/utils/typedef.dart';
import '../../../comentarios/services/comentarios_service.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/repositories/comentario_repository.dart';
import '../models/comentario_model.dart';

/// Implementação do repositório de comentários
/// 
/// Esta classe implementa o contrato definido no domain layer,
/// usando o ComentariosService como fonte de dados
class ComentarioRepositoryImpl implements ComentarioRepository {
  const ComentarioRepositoryImpl(this._comentariosService);

  final ComentariosService _comentariosService;

  @override
  ResultFuture<List<ComentarioEntity>> getComentariosByPkIdentificador(String pkIdentificador) async {
    try {
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );
      
      final models = comentarios
          .map((legacy) => ComentarioModel.fromLegacyModel(legacy))
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao buscar comentários: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<ComentarioEntity>> getComentariosByFerramenta(String ferramenta) async {
    try {
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: '', // Será filtrado por ferramenta
      );
      
      final filteredComentarios = comentarios
          .where((c) => c.ferramenta.toLowerCase() == ferramenta.toLowerCase())
          .toList();
      
      final models = filteredComentarios
          .map((legacy) => ComentarioModel.fromLegacyModel(legacy))
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao buscar comentários por ferramenta: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<ComentarioEntity> getComentarioById(String id) async {
    try {
      // Como o service não tem método específico por ID,
      // vamos buscar todos e filtrar
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: '', // Busca todos
      );
      
      final comentario = comentarios
          .where((c) => c.id == id)
          .firstOrNull;
      
      if (comentario == null) {
        return Left(local_failures.CacheFailure('Comentário não encontrado com ID: $id'));
      }
      
      final model = ComentarioModel.fromLegacyModel(comentario);
      return Right(model);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao buscar comentário por ID: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<String> addComentario(ComentarioEntity comentario) async {
    try {
      final legacyModel = ComentarioModel.fromEntity(comentario).toLegacyModel();
      await _comentariosService.addComentario(legacyModel);
      return Right(comentario.id);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao adicionar comentário: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> updateComentario(ComentarioEntity comentario) async {
    try {
      // Como o service não tem método de update específico,
      // vamos simular removendo e adicionando novamente
      await _comentariosService.deleteComentario(comentario.id);
      
      final updatedComentario = comentario.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final legacyModel = ComentarioModel.fromEntity(updatedComentario).toLegacyModel();
      await _comentariosService.addComentario(legacyModel);
      
      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao atualizar comentário: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteComentario(String id) async {
    try {
      await _comentariosService.deleteComentario(id);
      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao deletar comentário: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<ComentarioEntity>> getComentariosAtivos() async {
    try {
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: '', // Busca todos
      );
      
      final comentariosAtivos = comentarios
          .where((c) => c.status)
          .toList();
      
      final models = comentariosAtivos
          .map((legacy) => ComentarioModel.fromLegacyModel(legacy))
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao buscar comentários ativos: ${e.toString()}'));
    }
  }

  @override
  Stream<List<ComentarioEntity>> watchComentarios(String pkIdentificador) async* {
    try {
      // Como não temos stream nativo, simulamos com refresh periódico
      while (true) {
        try {
          final comentarios = await _comentariosService.getAllComentarios(
            pkIdentificador: pkIdentificador,
          );
          
          final models = comentarios
              .map((legacy) => ComentarioModel.fromLegacyModel(legacy))
              .toList();
          
          yield models;
        } catch (e) {
          yield [];
        }
        
        // Aguarda 5 segundos antes do próximo refresh
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      yield [];
    }
  }

  @override
  ResultFuture<int> countComentarios(String pkIdentificador) async {
    try {
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );
      
      final count = comentarios
          .where((c) => c.status)
          .length;
      
      return Right(count);
    } catch (e) {
      return Left(local_failures.ServerFailure('Erro ao contar comentários: ${e.toString()}'));
    }
  }
}