import 'package:drift/drift.dart';

/// ============================================================================
/// PLANTIS DATABASE TABLES - Drift Schema
/// ============================================================================
///
/// Este arquivo define TODAS as 8 tabelas do app-plantis seguindo o padrão
/// Drift estabelecido no gasometer-drift.
///
/// **ORDEM DE DEPENDÊNCIAS:**
/// 1. Spaces (independente)
/// 2. Plants (FK → Spaces)
/// 3. PlantConfigs (1:1 → Plants)
/// 4. PlantTasks (FK → Plants)
/// 5. Tasks (FK → Plants)
/// 6. Comments (FK → Plants)
/// 7. ConflictHistory (independente - auditoria)
/// 8. SyncQueue (independente - sincronização)
/// ============================================================================

// ============================================================================
// 1. SPACES TABLE
// ============================================================================

/// Tabela de Espaços/Ambientes
///
/// Armazena os ambientes onde as plantas ficam localizadas (ex: Sala, Varanda)
class Spaces extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único do espaço (auto incremento - apenas local)
  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  /// Null = registro ainda não foi sincronizado com Firebase
  TextColumn get firebaseId => text().nullable()();

  /// ID do usuário proprietário (Firebase UID)
  TextColumn get userId => text().nullable()();

  /// Nome do módulo (sempre 'plantis')
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Data da última sincronização com Firebase
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  /// Indica se o registro foi modificado localmente e precisa ser sincronizado
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  /// Indica se o registro foi deletado (soft delete)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Versão do registro para controle de conflitos
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== DADOS DO ESPAÇO ==========

  /// Nome do espaço (ex: "Sala", "Varanda", "Jardim")
  TextColumn get name => text()();

  /// Descrição do espaço
  TextColumn get description => text().nullable()();

  /// Condição de luminosidade (ex: "Luz direta", "Meia sombra", "Sombra")
  TextColumn get lightCondition => text().nullable()();

  /// Umidade relativa do ambiente (%)
  RealColumn get humidity => real().nullable()();

  /// Temperatura média do ambiente (°C)
  RealColumn get averageTemperature => real().nullable()();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        // Garante que firebaseId seja único quando não for null
        {firebaseId},
      ];
}

// ============================================================================
// 2. PLANTS TABLE
// ============================================================================

/// Tabela de Plantas
///
/// Armazena informações sobre cada planta cadastrada pelo usuário
class Plants extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID do espaço onde a planta está localizada (foreign key)
  IntColumn get spaceId =>
      integer().nullable().references(Spaces, #id, onDelete: KeyAction.setNull)();

  // ========== DADOS DA PLANTA ==========

  /// Nome popular da planta
  TextColumn get name => text()();

  /// Nome científico/espécie
  TextColumn get species => text().nullable()();

  /// Imagem em base64 (armazenamento local temporário)
  TextColumn get imageBase64 => text().nullable()();

  /// URLs das imagens no Firebase Storage (JSON array)
  TextColumn get imageUrls => text().nullable()();

  /// Data de plantio/aquisição
  DateTimeColumn get plantingDate => dateTime().nullable()();

  /// Observações sobre a planta
  TextColumn get notes => text().nullable()();

  /// Indica se a planta está marcada como favorita
  BoolColumn get isFavorited => boolean().withDefault(const Constant(false))();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId},
      ];
}

// ============================================================================
// 3. PLANT CONFIGS TABLE
// ============================================================================

/// Tabela de Configurações de Cuidados das Plantas
///
/// Armazena as configurações de intervalos de cuidados para cada planta (1:1)
class PlantConfigs extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO 1:1 ==========

  /// ID da planta (relação 1:1 - foreign key unique)
  IntColumn get plantId =>
      integer().unique().references(Plants, #id, onDelete: KeyAction.cascade)();

  // ========== CONFIGURAÇÕES DE ÁGUA ==========

  BoolColumn get aguaAtiva => boolean().withDefault(const Constant(true))();
  IntColumn get intervaloRegaDias => integer().withDefault(const Constant(1))();

  // ========== CONFIGURAÇÕES DE ADUBO ==========

  BoolColumn get aduboAtivo => boolean().withDefault(const Constant(true))();
  IntColumn get intervaloAdubacaoDias =>
      integer().withDefault(const Constant(7))();

  // ========== CONFIGURAÇÕES DE BANHO DE SOL ==========

  BoolColumn get banhoSolAtivo => boolean().withDefault(const Constant(true))();
  IntColumn get intervaloBanhoSolDias =>
      integer().withDefault(const Constant(1))();

  // ========== CONFIGURAÇÕES DE INSPEÇÃO DE PRAGAS ==========

  BoolColumn get inspecaoPragasAtiva =>
      boolean().withDefault(const Constant(true))();
  IntColumn get intervaloInspecaoPragasDias =>
      integer().withDefault(const Constant(7))();

  // ========== CONFIGURAÇÕES DE PODA ==========

  BoolColumn get podaAtiva => boolean().withDefault(const Constant(true))();
  IntColumn get intervaloPodaDias => integer().withDefault(const Constant(30))();

  // ========== CONFIGURAÇÕES DE REPLANTIO ==========

  BoolColumn get replantarAtivo => boolean().withDefault(const Constant(true))();
  IntColumn get intervaloReplantarDias =>
      integer().withDefault(const Constant(180))();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId},
        {plantId}, // Garante relação 1:1
      ];
}

// ============================================================================
// 4. PLANT TASKS TABLE
// ============================================================================

/// Tabela de Tarefas de Plantas (Sistema antigo - compatibilidade)
///
/// Armazena tarefas relacionadas a cuidados com plantas
class PlantTasks extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID da planta (foreign key)
  IntColumn get plantId =>
      integer().references(Plants, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DA TAREFA ==========

  /// Tipo da tarefa (watering, fertilizing, pruning, etc.)
  TextColumn get type => text()();

  /// Título da tarefa
  TextColumn get title => text()();

  /// Descrição da tarefa
  TextColumn get description => text().nullable()();

  /// Data agendada para execução
  DateTimeColumn get scheduledDate => dateTime()();

  /// Data de conclusão (null = não concluída)
  DateTimeColumn get completedDate => dateTime().nullable()();

  /// Status da tarefa (pending, completed, overdue)
  TextColumn get status => text()();

  /// Intervalo de recorrência em dias
  IntColumn get intervalDays => integer()();

  /// Próxima data agendada (tarefas recorrentes)
  DateTimeColumn get nextScheduledDate => dateTime().nullable()();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId},
      ];
}

// ============================================================================
// 5. TASKS TABLE
// ============================================================================

/// Tabela de Tarefas (Sistema novo - completo)
///
/// Armazena tarefas com prioridades e categorias
class Tasks extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID da planta (foreign key)
  IntColumn get plantId =>
      integer().references(Plants, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DA TAREFA ==========

  /// Título da tarefa
  TextColumn get title => text()();

  /// Descrição detalhada
  TextColumn get description => text().nullable()();

  /// Tipo da tarefa (watering, fertilizing, pruning, pest_inspection, etc.)
  TextColumn get type => text()();

  /// Status da tarefa (pending, completed, cancelled, overdue)
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Prioridade (low, medium, high)
  TextColumn get priority => text().withDefault(const Constant('medium'))();

  /// Data de vencimento
  DateTimeColumn get dueDate => dateTime()();

  /// Data de conclusão
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Notas de conclusão
  TextColumn get completionNotes => text().nullable()();

  /// Indica se é uma tarefa recorrente
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// Intervalo de recorrência em dias
  IntColumn get recurringIntervalDays => integer().nullable()();

  /// Próxima data de vencimento (tarefas recorrentes)
  DateTimeColumn get nextDueDate => dateTime().nullable()();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId},
      ];
}

// ============================================================================
// 6. COMMENTS TABLE
// ============================================================================

/// Tabela de Comentários
///
/// Armazena observações e comentários sobre plantas
class Comments extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID da planta (foreign key)
  IntColumn get plantId =>
      integer().nullable().references(Plants, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DO COMENTÁRIO ==========

  /// Conteúdo do comentário
  TextColumn get conteudo => text()();

  /// Data de criação (campo legado)
  DateTimeColumn get dataCriacao => dateTime().nullable()();

  /// Data de atualização (campo legado)
  DateTimeColumn get dataAtualizacao => dateTime().nullable()();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId},
      ];
}

// ============================================================================
// 7. CONFLICT HISTORY TABLE
// ============================================================================

/// Tabela de Histórico de Conflitos
///
/// Registra resolução de conflitos de sincronização para auditoria
class ConflictHistory extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('plantis'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== DADOS DO CONFLITO ==========

  /// Tipo do model que teve conflito (Plant, Space, Task, etc.)
  TextColumn get modelType => text()();

  /// ID do registro que teve conflito
  TextColumn get modelId => text()();

  /// Versão local do registro
  IntColumn get localVersion => integer()();

  /// Versão remota do registro
  IntColumn get remoteVersion => integer()();

  /// Estratégia de resolução usada (local_wins, remote_wins, merged, etc.)
  TextColumn get resolutionStrategy => text()();

  /// Dados da versão local (JSON)
  TextColumn get localData => text()();

  /// Dados da versão remota (JSON)
  TextColumn get remoteData => text()();

  /// Dados após resolução (JSON)
  TextColumn get resolvedData => text()();

  /// Timestamp do conflito
  IntColumn get occurredAt => integer()();

  /// Timestamp da resolução (null = ainda não resolvido)
  IntColumn get resolvedAt => integer().nullable()();

  /// Indica se foi resolvido automaticamente
  BoolColumn get autoResolved => boolean().withDefault(const Constant(false))();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId},
      ];
}

// ============================================================================
// 8. PLANTS SYNC QUEUE TABLE
// ============================================================================

/// Tabela de Fila de Sincronização (Plantis)
///
/// Armazena operações pendentes de sincronização com Firebase
/// Renomeada para PlantsSyncQueue para evitar conflito com core SyncQueue
class PlantsSyncQueue extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();

  // ========== DADOS DA OPERAÇÃO ==========

  /// Tipo do model a ser sincronizado (Plant, Space, Task, etc.)
  TextColumn get modelType => text()();

  /// ID do registro a ser sincronizado
  TextColumn get modelId => text()();

  /// Operação a ser executada (create, update, delete)
  TextColumn get operation => text()();

  /// Dados serializados (JSON) da operação
  TextColumn get data => text()();

  /// Timestamp da operação
  DateTimeColumn get timestamp => dateTime()();

  /// Contador de tentativas de sincronização
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Data da última tentativa de sincronização
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// Mensagem de erro da última tentativa (se houver)
  TextColumn get error => text().nullable()();

  /// Timestamp de criação da operação
  IntColumn get createdAt => integer()();

  /// Flag indicando se já foi sincronizado
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // ========== ÍNDICES ==========
  // Índice composto para buscar operações pendentes de um modelo específico
  // Não usa uniqueKeys pois pode haver múltiplas operações para o mesmo registro
}
