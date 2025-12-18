import 'package:drift/drift.dart';

/// Tabela para persistir fila de sincronização offline
///
/// Armazena operações (create/update/delete) que precisam ser
/// sincronizadas com Firebase quando houver conectividade.
///
/// **Padrão:** Baseado em app-plantis/PlantsSyncQueue
///
/// **Campos:**
/// - id: Auto-increment primary key
/// - modelType: Tipo de modelo ('List', 'ItemMaster', 'ListItem')
/// - modelId: ID do registro a ser sincronizado
/// - operation: Tipo de operação ('create', 'update', 'delete')
/// - data: JSON serializado do modelo
/// - timestamp: Quando foi enfileirado
/// - attempts: Contador de tentativas de sync
/// - isSynced: Se já foi sincronizado com sucesso
/// - lastError: Última mensagem de erro (se houver)
///
/// **Exemplo de uso:**
/// ```dart
/// // Enfileirar criação de lista
/// await syncQueueDao.enqueue(
///   modelType: 'List',
///   modelId: 'abc-123',
///   operation: 'create',
///   data: jsonEncode(listModel.toJson()),
/// );
/// ```
@DataClassName('NebulalistSyncQueueData')
class NebulalistSyncQueue extends Table {
  /// Primary key auto-incrementada
  IntColumn get id => integer().autoIncrement()();

  /// Tipo do modelo (List, ItemMaster, ListItem)
  TextColumn get modelType => text()();

  /// ID do registro a ser sincronizado
  TextColumn get modelId => text()();

  /// Tipo de operação: 'create', 'update', 'delete'
  TextColumn get operation => text()();

  /// Dados do modelo (JSON serializado)
  TextColumn get data => text()();

  /// Timestamp de quando foi enfileirado
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  /// Contador de tentativas de sincronização
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Flag indicando se já foi sincronizado
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Última mensagem de erro (nullable)
  TextColumn get lastError => text().nullable()();
}
