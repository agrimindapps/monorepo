import 'package:drift/drift.dart';
import 'tasks_table.dart';

/// Task Attachments Table - Anexos de tarefas
@DataClassName('TaskAttachmentData')
class TaskAttachments extends Table {
  /// Primary key
  TextColumn get id => text()();

  /// Foreign key para Tasks
  TextColumn get taskId =>
      text().references(Tasks, #firebaseId, onDelete: KeyAction.cascade)();

  /// Nome do arquivo original
  TextColumn get fileName => text()();

  /// Caminho local do arquivo (para offline)
  TextColumn get filePath => text().nullable()();

  /// URL remota do arquivo (Firebase Storage)
  TextColumn get fileUrl => text().nullable()();

  /// Tamanho do arquivo em bytes
  IntColumn get fileSize => integer()();

  /// Tipo de anexo: image, pdf, document, other
  TextColumn get type => text()();

  /// MIME type do arquivo
  TextColumn get mimeType => text()();

  /// Data de upload
  DateTimeColumn get uploadedAt => dateTime()();

  /// ID do usuário que fez upload
  TextColumn get uploadedBy => text()();

  /// Status de sync (true = enviado para Firebase)
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE',
  ];
}
