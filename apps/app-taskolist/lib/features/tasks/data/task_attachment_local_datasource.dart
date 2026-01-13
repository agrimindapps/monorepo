import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../../domain/task_attachment_entity.dart';
import '../../../database/daos/task_attachment_dao.dart';

/// Local datasource para task attachments
class TaskAttachmentLocalDataSource {
  final TaskAttachmentDao _dao;

  TaskAttachmentLocalDataSource(this._dao);

  /// Salvar anexo
  Future<Either<Failure, void>> saveAttachment(
    TaskAttachmentEntity attachment,
  ) async {
    try {
      await _dao.insertAttachment(attachment);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Erro ao salvar anexo: $e'));
    }
  }

  /// Buscar anexos por task ID
  Future<Either<Failure, List<TaskAttachmentEntity>>> getAttachmentsByTaskId(
    String taskId,
  ) async {
    try {
      final data = await _dao.getAttachmentsByTaskId(taskId);
      final entities = _dao.toEntities(data);
      return Right(entities);
    } catch (e) {
      return Left(Failure('Erro ao buscar anexos: $e'));
    }
  }

  /// Buscar anexo por ID
  Future<Either<Failure, TaskAttachmentEntity?>> getAttachmentById(
    String id,
  ) async {
    try {
      final data = await _dao.getAttachmentById(id);
      if (data == null) return const Right(null);
      return Right(_dao.toEntity(data));
    } catch (e) {
      return Left(Failure('Erro ao buscar anexo: $e'));
    }
  }

  /// Atualizar anexo
  Future<Either<Failure, void>> updateAttachment(
    TaskAttachmentEntity attachment,
  ) async {
    try {
      await _dao.updateAttachment(attachment);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Erro ao atualizar anexo: $e'));
    }
  }

  /// Marcar como uploaded
  Future<Either<Failure, void>> markAsUploaded(
    String id,
    String fileUrl,
  ) async {
    try {
      await _dao.markAsUploaded(id, fileUrl);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Erro ao marcar anexo como enviado: $e'));
    }
  }

  /// Deletar anexo
  Future<Either<Failure, void>> deleteAttachment(String id) async {
    try {
      await _dao.deleteAttachment(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Erro ao deletar anexo: $e'));
    }
  }

  /// Buscar anexos pendentes de upload
  Future<Either<Failure, List<TaskAttachmentEntity>>> getPendingUploads() async {
    try {
      final data = await _dao.getPendingUploads();
      final entities = _dao.toEntities(data);
      return Right(entities);
    } catch (e) {
      return Left(Failure('Erro ao buscar anexos pendentes: $e'));
    }
  }

  /// Watch anexos (stream)
  Stream<List<TaskAttachmentEntity>> watchAttachmentsByTaskId(String taskId) {
    return _dao.watchAttachmentsByTaskId(taskId).map((data) => _dao.toEntities(data));
  }

  /// Contar anexos de uma tarefa
  Future<Either<Failure, int>> countAttachmentsByTaskId(String taskId) async {
    try {
      final count = await _dao.countAttachmentsByTaskId(taskId);
      return Right(count);
    } catch (e) {
      return Left(Failure('Erro ao contar anexos: $e'));
    }
  }
}
