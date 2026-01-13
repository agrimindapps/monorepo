import 'package:drift/drift.dart';

import '../tables/task_attachments_table.dart';
import '../taskolist_database.dart';
import '../../features/tasks/domain/task_attachment_entity.dart';

part 'task_attachment_dao.g.dart';

/// DAO para gerenciar anexos de tarefas
@DriftAccessor(tables: [TaskAttachments])
class TaskAttachmentDao extends DatabaseAccessor<TaskolistDatabase>
    with _$TaskAttachmentDaoMixin {
  TaskAttachmentDao(super.db);

  /// Buscar todos os anexos de uma tarefa
  Future<List<TaskAttachmentData>> getAttachmentsByTaskId(String taskId) {
    return (select(taskAttachments)
          ..where((a) => a.taskId.equals(taskId))
          ..orderBy([(a) => OrderingTerm(expression: a.uploadedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Buscar anexo por ID
  Future<TaskAttachmentData?> getAttachmentById(String id) {
    return (select(taskAttachments)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserir anexo
  Future<void> insertAttachment(TaskAttachmentEntity entity) {
    return into(taskAttachments).insert(
      TaskAttachmentsCompanion.insert(
        id: entity.id,
        taskId: entity.taskId,
        fileName: entity.fileName,
        filePath: Value(entity.filePath),
        fileUrl: Value(entity.fileUrl),
        fileSize: entity.fileSize,
        type: entity.type.name,
        mimeType: entity.mimeType,
        uploadedAt: entity.uploadedAt,
        uploadedBy: entity.uploadedBy,
        isUploaded: Value(entity.isUploaded),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Atualizar anexo
  Future<void> updateAttachment(TaskAttachmentEntity entity) {
    return (update(taskAttachments)..where((a) => a.id.equals(entity.id)))
        .write(
      TaskAttachmentsCompanion(
        fileName: Value(entity.fileName),
        filePath: Value(entity.filePath),
        fileUrl: Value(entity.fileUrl),
        fileSize: Value(entity.fileSize),
        type: Value(entity.type.name),
        mimeType: Value(entity.mimeType),
        uploadedAt: Value(entity.uploadedAt),
        uploadedBy: Value(entity.uploadedBy),
        isUploaded: Value(entity.isUploaded),
      ),
    );
  }

  /// Marcar anexo como uploaded (sincronizado)
  Future<void> markAsUploaded(String id, String fileUrl) {
    return (update(taskAttachments)..where((a) => a.id.equals(id)))
        .write(
      TaskAttachmentsCompanion(
        fileUrl: Value(fileUrl),
        isUploaded: const Value(true),
      ),
    );
  }

  /// Deletar anexo
  Future<int> deleteAttachment(String id) {
    return (delete(taskAttachments)..where((a) => a.id.equals(id))).go();
  }

  /// Deletar todos os anexos de uma tarefa
  Future<int> deleteAttachmentsByTaskId(String taskId) {
    return (delete(taskAttachments)..where((a) => a.taskId.equals(taskId))).go();
  }

  /// Buscar anexos pendentes de upload
  Future<List<TaskAttachmentData>> getPendingUploads() {
    return (select(taskAttachments)
          ..where((a) => a.isUploaded.equals(false))
          ..orderBy([(a) => OrderingTerm(expression: a.uploadedAt)]))
        .get();
  }

  /// Contar anexos de uma tarefa
  Future<int> countAttachmentsByTaskId(String taskId) async {
    final query = selectOnly(taskAttachments)
      ..addColumns([taskAttachments.id.count()])
      ..where(taskAttachments.taskId.equals(taskId));

    final result = await query.getSingleOrNull();
    return result?.read(taskAttachments.id.count()) ?? 0;
  }

  /// Watch anexos de uma tarefa (stream)
  Stream<List<TaskAttachmentData>> watchAttachmentsByTaskId(String taskId) {
    return (select(taskAttachments)
          ..where((a) => a.taskId.equals(taskId))
          ..orderBy([(a) => OrderingTerm(expression: a.uploadedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Converter TaskAttachmentData para TaskAttachmentEntity
  TaskAttachmentEntity toEntity(TaskAttachmentData data) {
    return TaskAttachmentEntity(
      id: data.id,
      taskId: data.taskId,
      fileName: data.fileName,
      filePath: data.filePath,
      fileUrl: data.fileUrl,
      fileSize: data.fileSize,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == data.type,
        orElse: () => AttachmentType.other,
      ),
      mimeType: data.mimeType,
      uploadedAt: data.uploadedAt,
      uploadedBy: data.uploadedBy,
      isUploaded: data.isUploaded,
    );
  }

  /// Converter lista de TaskAttachmentData para lista de TaskAttachmentEntity
  List<TaskAttachmentEntity> toEntities(List<TaskAttachmentData> dataList) {
    return dataList.map(toEntity).toList();
  }
}
