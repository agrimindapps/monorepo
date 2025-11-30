import 'package:drift/drift.dart';

/// ========== STATIC DATA TABLES ==========

/// Tabela de Diagnósticos (Tabela de Junção/Relacionamento)
///
/// Relaciona defensivos agrícolas com culturas e pragas, definindo
/// dosagens e formas de aplicação recomendadas.
///
/// ⚠️ TABELA ESTÁTICA - Não pertence ao usuário, não sincroniza com Firebase.
/// Dados carregados do Firebase apenas para leitura (lookup table).
class Diagnosticos extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== STATIC DATA ID (Firebase Reference) ==========
  /// ID de referência no Firebase (apenas para lookup)
  TextColumn get firebaseId => text().nullable()();

  // ========== FOREIGN KEYS (NORMALIZED) ==========
  /// ID do defensivo (FK → Fitossanitarios)
  IntColumn get defensivoId => integer().references(
    Fitossanitarios,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// ID da cultura (FK → Culturas)
  IntColumn get culturaId =>
      integer().references(Culturas, #id, onDelete: KeyAction.restrict)();

  /// ID da praga (FK → Pragas)
  IntColumn get pragaId =>
      integer().references(Pragas, #id, onDelete: KeyAction.restrict)();

  // ========== BUSINESS FIELDS ==========
  /// ID de registro único (do Firebase)
  TextColumn get idReg => text().unique()();

  /// Dosagem mínima
  TextColumn get dsMin => text().nullable()();

  /// Dosagem máxima
  TextColumn get dsMax => text()();

  /// Unidade de medida
  TextColumn get um => text()();

  /// Aplicação terrestre - mínimo
  TextColumn get minAplicacaoT => text().nullable()();

  /// Aplicação terrestre - máximo
  TextColumn get maxAplicacaoT => text().nullable()();

  /// Unidade de medida terrestre
  TextColumn get umT => text().nullable()();

  /// Aplicação aérea - mínimo
  TextColumn get minAplicacaoA => text().nullable()();

  /// Aplicação aérea - máximo
  TextColumn get maxAplicacaoA => text().nullable()();

  /// Unidade de medida aérea
  TextColumn get umA => text().nullable()();

  /// Intervalo de aplicação
  TextColumn get intervalo => text().nullable()();

  /// Intervalo secundário
  TextColumn get intervalo2 => text().nullable()();

  /// Época de aplicação
  TextColumn get epocaAplicacao => text().nullable()();
}

/// ========== USER-GENERATED DATA TABLES ==========

/// Tabela de Favoritos
///
/// Armazena favoritos multi-tipo do usuário (defensivos, pragas, diagnosticos, culturas)
class Favoritos extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== SYNC DIAGNOSTICS ==========
  TextColumn get syncError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// 0=Synced, 1=Pending, 2=Error, 3=Conflict
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  // ========== BUSINESS FIELDS ==========
  /// Tipo do favorito: 'defensivos', 'pragas', 'diagnosticos', 'culturas'
  TextColumn get tipo => text()();

  /// ID do item original
  TextColumn get itemId => text()();

  /// JSON string com dados do item (cache)
  TextColumn get itemData => text()();

  // ========== UNIQUE CONSTRAINTS ==========
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, tipo, itemId}, // Previne favoritar o mesmo item duas vezes
  ];
}

/// Tabela de Comentários
///
/// Armazena comentários dos usuários vinculados a items
class Comentarios extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== SYNC DIAGNOSTICS ==========
  TextColumn get syncError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// 0=Synced, 1=Pending, 2=Error, 3=Conflict
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  // ========== BUSINESS FIELDS ==========
  /// ID do item comentado
  TextColumn get itemId => text()();

  /// Texto do comentário
  TextColumn get texto => text()();
}

/// ========== STATIC DATA TABLES (READ-ONLY) ==========

/// Tabela de Culturas (Dados estáticos - JSON)
class Culturas extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID da cultura (chave do JSON)
  TextColumn get idCultura => text().unique()();

  /// Nome da cultura
  TextColumn get nome => text()();

  /// Nome científico
  TextColumn get nomeLatino => text().nullable()();

  /// Família botânica
  TextColumn get familia => text().nullable()();

  /// URL da imagem
  TextColumn get imagemUrl => text().nullable()();

  /// Descrição
  TextColumn get descricao => text().nullable()();
}

/// Tabela de Pragas (Dados estáticos - JSON)
class Pragas extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID da praga (chave do JSON)
  TextColumn get idPraga => text().unique()();

  /// Nome comum
  TextColumn get nome => text()();

  /// Nome científico
  TextColumn get nomeLatino => text().nullable()();

  /// Tipo: 'inseto', 'fungo', 'bacteria', 'virus', 'nematoide', etc.
  TextColumn get tipo => text().nullable()();

  /// URL da imagem
  TextColumn get imagemUrl => text().nullable()();

  /// Descrição
  TextColumn get descricao => text().nullable()();
}

/// Tabela de Informações de Pragas (Dados estáticos - JSON)
class PragasInf extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID de registro (chave do JSON)
  TextColumn get idReg => text().unique()();

  /// FK → Pragas
  IntColumn get pragaId =>
      integer().references(Pragas, #id, onDelete: KeyAction.restrict)();

  /// Sintomas
  TextColumn get sintomas => text().nullable()();

  /// Controle cultural
  TextColumn get controle => text().nullable()();

  /// Danos causados
  TextColumn get danos => text().nullable()();

  /// Condições favoráveis
  TextColumn get condicoesFavoraveis => text().nullable()();
}

/// Tabela de Fitossanitários/Defensivos (Dados estáticos - JSON)
class Fitossanitarios extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID do defensivo (chave do JSON)
  TextColumn get idDefensivo => text().unique()();

  /// Nome comercial
  TextColumn get nome => text()();

  /// Nome comum (produto comercial)
  TextColumn get nomeComum => text().nullable()();

  /// Fabricante
  TextColumn get fabricante => text().nullable()();

  /// Classe: 'herbicida', 'fungicida', 'inseticida', 'acaricida', etc.
  TextColumn get classe => text().nullable()();

  /// Classe agronômica
  TextColumn get classeAgronomica => text().nullable()();

  /// Ingrediente ativo
  TextColumn get ingredienteAtivo => text().nullable()();

  /// Número de registro no MAPA
  TextColumn get registroMapa => text().nullable()();

  /// Status do produto (ativo/inativo)
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  /// Se está sendo comercializado (0 = não, 1 = sim)
  IntColumn get comercializado => integer().withDefault(const Constant(1))();

  /// Se é elegível para uso
  BoolColumn get elegivel => boolean().withDefault(const Constant(true))();
}

/// Tabela de Informações de Fitossanitários (Dados estáticos - JSON)
class FitossanitariosInfo extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID de registro (chave do JSON)
  TextColumn get idReg => text().unique()();

  /// FK → Fitossanitarios
  IntColumn get defensivoId => integer().references(
    Fitossanitarios,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// Modo de ação
  TextColumn get modoAcao => text().nullable()();

  /// Formulação
  TextColumn get formulacao => text().nullable()();

  /// Classe toxicológica
  TextColumn get toxicidade => text().nullable()();

  /// Carência (dias)
  TextColumn get carencia => text().nullable()();

  /// Informações adicionais
  TextColumn get informacoesAdicionais => text().nullable()();
}

/// Tabela de Informações de Plantas/Culturas (Dados estáticos - JSON)
class PlantasInf extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID de registro (chave do JSON)
  TextColumn get idReg => text().unique()();

  /// FK → Culturas
  IntColumn get culturaId =>
      integer().references(Culturas, #id, onDelete: KeyAction.restrict)();

  /// Ciclo da planta
  TextColumn get ciclo => text().nullable()();

  /// Tipo de reprodução
  TextColumn get reproducao => text().nullable()();

  /// Habitat natural
  TextColumn get habitat => text().nullable()();

  /// Adaptações específicas
  TextColumn get adaptacoes => text().nullable()();

  /// Altura média da planta
  TextColumn get altura => text().nullable()();

  /// Filotaxia (arranjo das folhas)
  TextColumn get filotaxia => text().nullable()();

  /// Forma do limbo foliar
  TextColumn get formaLimbo => text().nullable()();

  /// Superfície das folhas
  TextColumn get superficie => text().nullable()();

  /// Consistência das folhas
  TextColumn get consistencia => text().nullable()();

  /// Tipo de nervação
  TextColumn get nervacao => text().nullable()();

  /// Comprimento da nervação
  TextColumn get nervacaoComprimento => text().nullable()();

  /// Margem das folhas
  TextColumn get margemFolha => text().nullable()();

  /// Característica foliar
  TextColumn get folha => text().nullable()();

  /// Base da folha
  TextColumn get base => text().nullable()();

  /// Forma da base foliar
  TextColumn get formaBase => text().nullable()();

  /// Ápice foliar
  TextColumn get apice => text().nullable()();

  /// Forma do ápice
  TextColumn get formaApice => text().nullable()();

  /// Tipo de flor
  TextColumn get tipoFlor => text().nullable()();

  /// Cor da flor
  TextColumn get corFlor => text().nullable()();

  /// Tipo de fruto
  TextColumn get tipoFruto => text().nullable()();

  /// Cor do fruto
  TextColumn get corFruto => text().nullable()();

  /// Tipo de semente
  TextColumn get tipoSemente => text().nullable()();

  /// Cor da semente
  TextColumn get corSemente => text().nullable()();
}

/// ========== APP SETTINGS TABLES ==========

/// Tabela de Controle de Versão dos Dados Estáticos
///
/// Registra a versão dos dados carregados do JSON para o SQLite.
/// Permite evitar recarregamento desnecessário e força atualização
/// quando a versão do app muda.
class StaticDataVersion extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== VERSION CONTROL ==========
  /// Nome da tabela de dados estáticos
  /// Ex: 'culturas', 'pragas', 'fitossanitarios', 'diagnosticos'
  TextColumn get dataTableName => text().unique()();

  /// Versão dos dados carregados
  TextColumn get dataVersion => text()();

  /// Versão do app quando os dados foram carregados
  TextColumn get appVersion => text()();

  /// Timestamp de quando foi carregado
  DateTimeColumn get loadedAt => dateTime().withDefault(currentDateAndTime)();

  /// Quantidade de registros carregados
  IntColumn get recordCount => integer().withDefault(const Constant(0))();

  /// Checksum/hash dos dados (opcional, para validação)
  TextColumn get checksum => text().nullable()();
}

/// Tabela de Configurações do App
///
/// Armazena configurações específicas do usuário para o aplicativo,
/// como tema, idioma, notificações, etc.
class AppSettings extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== SETTINGS FIELDS ==========
  /// Tema do app ('light', 'dark', 'system')
  TextColumn get theme => text().withDefault(const Constant('system'))();

  /// Idioma do app ('pt', 'en', 'es')
  TextColumn get language => text().withDefault(const Constant('pt'))();

  /// Notificações habilitadas
  BoolColumn get enableNotifications =>
      boolean().withDefault(const Constant(true))();

  /// Sincronização habilitada
  BoolColumn get enableSync => boolean().withDefault(const Constant(true))();

  /// Flags de funcionalidades (JSON)
  TextColumn get featureFlags => text().withDefault(const Constant('{}'))();
}
